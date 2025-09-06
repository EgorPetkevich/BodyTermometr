//
//  RealmTempManager.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 1.09.25.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

final class RealmTempManager: RealmDataManager {
    
    func createOrUpdate(dto: TempModelDTO) {
        if let existing = get(TempModelMO.self, primaryKey: dto.id) {
            do {
                try realm.write {
                    existing.apply(dto: dto)
                    realm.add(existing, update: .modified)
                }
            } catch {
                print("[Error] Failed to update BPMModelMO: \(error)")
            }
        } else {
            let newMO = TempModelMO()
            newMO.create(dto: dto)
            save(newMO, update: .modified)
        }
    }

    func delete(dto: TempModelDTO) {
        if let mo = get(TempModelMO.self, primaryKey: dto.id) {
            delete(mo)
        }
    }

    // MARK: - Fetch

    /// Get single DTO by id
    func get(by id: String) -> TempModelDTO? {
        guard
            let mo = get(TempModelMO.self,
                         primaryKey: id)
        else { return nil }
        return TempModelDTO.fromMO(mo)
    }

    /// Get all BPM entries sorted by date
    func getAllSortedByDate(desc: Bool = true) -> [TempModelDTO] {
        let results = getAll(TempModelMO.self).sorted(byKeyPath: "date", ascending: !desc)
        return results.map { TempModelDTO.fromMO($0) }
    }

    /// Observe all BPM entries as DTOs, sorted by date
    func observeAllSortedByDate(desc: Bool = true) -> Observable<[TempModelDTO]?> {
        let results = getAll(TempModelMO.self).sorted(byKeyPath: "date", ascending: !desc)
        return Observable.collection(from: results)
            .map { $0.map { TempModelDTO.fromMO($0) } }
            .distinctUntilChanged()
    }
    
    func observeTempModel(by id: String) -> Observable<TempModelDTO?> {
        let results = realm.objects(TempModelMO.self)
            .filter("id == %@", id)
        return Observable.collection(from: results)
            .map { $0.first }
            .map { mo in mo.map { TempModelDTO.fromMO($0) } }
            .distinctUntilChanged()
    }

    /// Delete all BPM entries
    func deleteAllBPM() {
        deleteAll(TempModelMO.self)
    }
    
    func getLastTemperature() -> Observable<Double?> {
        observeAllSortedByDate()
            .map { dtos in dtos?.first?.temp }
            .distinctUntilChanged()
    }
    
}
