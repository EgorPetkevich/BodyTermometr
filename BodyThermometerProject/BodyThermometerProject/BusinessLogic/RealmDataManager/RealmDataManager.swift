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

final class RealmDataManager {

    private let realm: Realm

    init(realm: Realm = try! Realm()) {
        if let originalURL = Realm.Configuration.defaultConfiguration.fileURL {
            let debugURL = originalURL
                .deletingLastPathComponent()
                .appendingPathComponent("debug.realm")

            try? FileManager.default.copyItem(at: originalURL, to: debugURL)
            print("Debug Realm copied to: \(debugURL)")
        }
        self.realm = realm
    }

    // MARK: - Create / Update
    func save<T: Object>(_ object: T, update: Realm.UpdatePolicy = .modified) {
        do {
            try realm.write {
                realm.add(object, update: update)
            }
        } catch {
            print("[Error] Failed to save object: \(error)")
        }
    }

    // MARK: - Read
//    func getAll<T: Object>(_ type: T.Type) -> Observable<Results<T>> {
//        let results = realm.objects(type)
//        return Observable.collection(from: results)
//    }
    
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
