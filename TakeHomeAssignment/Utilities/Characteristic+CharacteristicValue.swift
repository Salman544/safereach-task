//
//  Characteristic+CharacteristicValue.swift
//  TakeHomeAssignment
//
//  Created by Muhammad Salman on 30/06/2025.
//

import Foundation

extension Characteristic {
    
    public var value: CharacteristicValue? {
        get {
            guard let data = valueData else { return nil }
            return CharacteristicValue(data: data)
        }
        set {
            valueData = newValue?.data
        }
    }
    
}
