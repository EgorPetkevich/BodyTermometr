//
//  RealmBPMManager.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.08.25.
//

import Foundation
import RealmSwift
import RxSwift
import RxRealm

final class RealmBPMManager: RealmDataManager {
    
    func createOrUpdate(dto: BPMModelDTO) {
        if let existing = get(BPMModelMO.self, primaryKey: dto.id) {
            do {
                try realm.write {
                    existing.apply(dto: dto)
                    realm.add(existing, update: .modified)
                }
            } catch {
                print("[Error] Failed to update BPMModelMO: \(error)")
            }
        } else {
            let newMO = BPMModelMO()
            newMO.apply(dto: dto)
            save(newMO, update: .modified)
        }
    }

    func delete(dto: BPMModelDTO) {
        if let mo = get(BPMModelMO.self, primaryKey: dto.id) {
            delete(mo)
        }
    }

    // MARK: - Fetch

    /// Get single DTO by id
    func get(by id: String) -> BPMModelDTO? {
        guard
            let mo = get(BPMModelMO.self,
                         primaryKey: id)
        else { return nil }
        return BPMModelDTO.fromMO(mo)
    }

    /// Get all BPM entries sorted by date
    func getAllSortedByDate(desc: Bool = true) -> [BPMModelDTO] {
        let results = getAll(BPMModelMO.self).sorted(byKeyPath: "date", ascending: !desc)
        return results.map { BPMModelDTO.fromMO($0) }
    }

    /// Observe all BPM entries as DTOs, sorted by date
    func observeAllSortedByDate(desc: Bool = true) -> Observable<[BPMModelDTO]?> {
        let results = getAll(BPMModelMO.self).sorted(byKeyPath: "date", ascending: !desc)
        return Observable.collection(from: results)
            .map { $0.map { BPMModelDTO.fromMO($0) } }
            .distinctUntilChanged()
    }

    /// Delete all BPM entries
    func deleteAllBPM() {
        deleteAll(BPMModelMO.self)
    }
    
}
