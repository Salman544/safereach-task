//
//  CharacteristicRepository.swift
//  TakeHomeAssignment
//
//  Created by Muhammad Salman on 30/06/2025.
//

import Combine
import CoreData

protocol CharacteristicRepositoryInterface {
    func fetchAll() -> AnyPublisher<[CharacteristicModel], Error>
    func add(id: UUID, name: String, value: CharacteristicValue) -> AnyPublisher<CharacteristicModel, Error>
    func update(_ model: CharacteristicModel) -> AnyPublisher<Void, Error>
    func delete(_ model: CharacteristicModel) -> AnyPublisher<Void, Error>
}

final class CharacteristicRepository: CharacteristicRepositoryInterface {

    private let container: NSPersistentContainer
    private var context: NSManagedObjectContext { container.viewContext }

    init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    func fetchAll() -> AnyPublisher<[CharacteristicModel], Error> {
        let req: NSFetchRequest<Characteristic> = Characteristic.fetchRequest()
        return Future { promise in
            do {
                let items = try self.context.fetch(req)
                let models = items.compactMap { $0.toModel() }
                promise(.success(models))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func add(id: UUID, name: String, value: CharacteristicValue) -> AnyPublisher<CharacteristicModel, Error> {
        Future { promise in
            let char = Characteristic(context: self.context)
            char.id = id
            char.name = name
            char.value = value
            char.createdAt = Date()
            char.reminderEnabled = false
            char.reminderInterval = 300
            do {
                try self.context.save()
                guard let model = char.toModel() else {
                    promise(.failure(CharacteristicError.invalidData))
                    return
                }
                promise(.success(model))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func update(_ model: CharacteristicModel) -> AnyPublisher<Void, Error> {
        Future { promise in
            let req: NSFetchRequest<Characteristic> = Characteristic.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", model.id as CVarArg)
            do {
                guard let char = try self.context.fetch(req).first else {
                    promise(.failure(CharacteristicError.dataNotFound))
                    return
                }
                char.apply(from: model)
                try self.context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func delete(_ model: CharacteristicModel) -> AnyPublisher<Void, Error> {
        Future { promise in
            let req: NSFetchRequest<Characteristic> = Characteristic.fetchRequest()
            req.predicate = NSPredicate(format: "id == %@", model.id as CVarArg)
            do {
                if let char = try self.context.fetch(req).first {
                    self.context.delete(char)
                    try self.context.save()
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

}
