//
//  RealmDataManager.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.06.25.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

class RealmDataManager {

    private static var didCopyDebugRealm = false

    let realm: Realm

    init(realm: Realm = try! Realm()) {
#if DEBUG
        if !RealmDataManager.didCopyDebugRealm,
           let originalURL = Realm.Configuration.defaultConfiguration.fileURL {
            let debugURL = originalURL
                .deletingLastPathComponent()
                .appendingPathComponent("debug.realm")
            // Replace existing copy with fresh one per app launch
            let fm = FileManager.default
            if fm.fileExists(atPath: debugURL.path) {
                try? fm.removeItem(at: debugURL)
            }
            do {
                try fm.copyItem(at: originalURL, to: debugURL)
                print("Debug Realm copied to: \(debugURL)")
            } catch {
                print("Failed to copy debug Realm: \(error)")
            }
            RealmDataManager.didCopyDebugRealm = true
        }
#endif
        self.realm = realm
    }

    // MARK: - Create / Update
    func save<T: Object>(_ object: T, update: Realm.UpdatePolicy = .modified) {
        do {
            try realm.write {
                realm.add(object, update: update)
                print("[Sucess] write \(object)")
            }
        } catch {
            print("[Error] Failed to save object: \(error)")
        }
    }
    
    func getAll<T: Object>(_ type: T.Type) -> Results<T> {
            realm.objects(type)
    }

    func get<T: Object>(_ type: T.Type, primaryKey: Any) -> T? {
        realm.object(ofType: type, forPrimaryKey: primaryKey)
    }

    // MARK: - Delete
    func delete<T: Object>(_ object: T) {
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("[Error] Failed to delete object: \(error)")
        }
    }

    func deleteAll<T: Object>(_ type: T.Type) {
        let objects = realm.objects(type)
        do {
            try realm.write {
                realm.delete(objects)
            }
        } catch {
            print("[Error] Failed to delete all objects of type \(type): \(error)")
        }
    }
}

//MARK: - UserInfo
extension RealmDataManager {
    
    func saveUserInfo(name: String, age: String, gender: Gender? = nil) {
        let model = get(UserInfoModel.self,
                        primaryKey: "current") ?? UserInfoModel()
        try? realm.write {
            model.userName = name
            model.userAge = age
            if let gender { model.gender = gender }
            realm.add(model, update: .modified)
        }
    }
    
    func updateGender(_ gender: Gender) {
        let model = get(UserInfoModel.self, primaryKey: "current") ?? {
            let m = UserInfoModel()
            m.id = "current"
            return m
        }()

        do {
            try realm.write {
                model.gender = gender
                realm.add(model, update: .modified)
            }
        } catch {
            print("Realm write error:", error)
        }
    }
    
    func updateIconPath(_ path: String) {
        let model = get(UserInfoModel.self, primaryKey: "current") ?? {
            let m = UserInfoModel()
            m.id = "current"
            return m
        }()

        do {
            try realm.write {
                model.iconPath = path
                realm.add(model, update: .modified)
            }
        } catch {
            print("Realm write error:", error)
        }
    }
    
    
    func getUserInfoDTO() -> UserInfoDTO {
        let model = get(UserInfoModel.self,
                    primaryKey: "current") ?? UserInfoModel()
        return UserInfoDTO(model)
    }
    
    
    func observeUserInfoDTO() -> Observable<UserInfoDTO> {
        let results = realm.objects(UserInfoModel.self)
            .filter("id == %@", "current")
        return Observable.collection(from: results)
            .map { coll -> UserInfoDTO in
                let model = coll.first ?? UserInfoModel()
                return UserInfoDTO(model)
            }
            .distinctUntilChanged()
    }
}
