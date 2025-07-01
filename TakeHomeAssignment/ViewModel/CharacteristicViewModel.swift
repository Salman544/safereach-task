//
//  CharacteristicViewModel.swift
//  TakeHomeAssignment
//
//  Created by Muhammad Salman on 30/06/2025.
//

import Foundation
import Combine
import CoreData

final class CharacteristicViewModel: ObservableObject {
    
    @Published var name: String
    @Published var valueType: ValueType
    @Published var textValue: String
    @Published var numberValue: Double
    @Published var reminderEnabled: Bool
    @Published var reminderInterval: TimeInterval
    @Published var saveSuccess: Bool = false
    @Published var saveError: Error? = nil

    enum ValueType { case text, number }

    public private(set) var initialModel: CharacteristicModel?
    fileprivate let repository: CharacteristicRepositoryInterface
    private var cancellables = Set<AnyCancellable>()
    
    var saveButtonEnabled: Bool {
        name.trimmingCharacters(in: .whitespaces).isEmpty || (valueType == .text && textValue.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    init(
        initialModel: CharacteristicModel? = nil,
        repository: CharacteristicRepositoryInterface = CharacteristicRepository()
    ) {
        self.initialModel = initialModel
        self.repository = repository
        
        if let model = initialModel {
            name = model.name
            switch model.value {
            case .text(let s): valueType = .text; textValue = s; numberValue = 0
            case .number(let d): valueType = .number; textValue = ""; numberValue = d
            }
            reminderEnabled = model.reminderEnabled
            reminderInterval = model.reminderInterval
        } else {
            name = ""
            valueType = .text
            textValue = ""
            numberValue = 0
            reminderEnabled = false
            reminderInterval = 300
        }
    }

    func save() {
        let newValue: CharacteristicValue = (valueType == .text) ? .text(textValue) : .number(numberValue)

        let identifier = initialModel?.id ?? UUID()
        
        let action: AnyPublisher<CharacteristicModel, Error> = initialModel == nil ? repository.add(id: identifier, name: name, value: newValue)
        : repository.update({
            var model = initialModel!
            model.name = name
            model.value = newValue
            model.reminderEnabled = reminderEnabled
            model.reminderInterval = reminderInterval
            model.lastUpdated = Date()
            return model
        }()
        ).flatMap { _ in
            self.repository
                .fetchAll()
                .compactMap { $0.first(where: { $0.id == self.initialModel!.id }) }
        }
        .eraseToAnyPublisher()
        
        action
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(err) = completion {
                    self.saveError = err
                }
            } receiveValue: { _ in
                self.saveSuccess = true
                if self.reminderEnabled {
                    NotificationManager.shared.scheduleReminder(
                        id: identifier.uuidString,
                        title: self.name,
                        body: "Update \(self.name)",
                        interval: self.reminderInterval
                    )
                } else {
                    NotificationManager.shared.cancelReminder(id: identifier.uuidString)
                }
            }
            .store(in: &cancellables)
    }
    
}
