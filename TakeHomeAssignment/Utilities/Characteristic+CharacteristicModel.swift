//
//  Characteristic+CharacteristicModel.swift
//  TakeHomeAssignment
//
//  Created by Muhammad Salman on 30/06/2025.
//

import Foundation
import CoreData

extension Characteristic {

    func toModel() -> CharacteristicModel? {
        guard let id = id, let name = name, let value = value else { return nil }
        return .init(id: id,
                     name: name,
                     value: value,
                     lastUpdated: createdAt ?? updatedAt ?? Date(),
                     reminderEnabled: reminderEnabled,
                     reminderInterval: reminderInterval)
    }

    func apply(from model: CharacteristicModel, updated: Bool = false) {
        name = model.name
        value = model.value
        reminderEnabled = model.reminderEnabled
        reminderInterval = model.reminderInterval
        if updated {
            updatedAt = model.lastUpdated
        } else {
            createdAt = model.lastUpdated
        }
    }
    
}
