//
//  CharacteristicModel.swift
//  TakeHomeAssignment
//
//  Created by Muhammad Salman on 30/06/2025.
//

import Foundation

struct CharacteristicModel: Identifiable, Equatable {
    let id: UUID
    var name: String
    var value: CharacteristicValue
    var lastUpdated: Date
    var reminderEnabled: Bool
    var reminderInterval: TimeInterval
}
