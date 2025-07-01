//
//  CharacteristicValue.swift
//  TakeHomeAssignment
//
//  Created by Muhammad Salman on 30/06/2025.
//

import Foundation

public enum CharacteristicValue: Codable, Equatable {
  case text(String)
  case number(Double)
}

public extension CharacteristicValue {
    
    var data: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(data: Data) {
        guard let decoded = try? JSONDecoder().decode(CharacteristicValue.self, from: data) else {
            return nil
        }
        self = decoded
    }
}
