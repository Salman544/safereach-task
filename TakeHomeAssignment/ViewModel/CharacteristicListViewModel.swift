//
//  CharacteristicListViewModel.swift
//  TakeHomeAssignment
//
//  Created by Muhammad Salman on 30/06/2025.
//

import Foundation
import Combine

final class CharacteristicListViewModel: ObservableObject {
    
    @Published var items: [CharacteristicModel] = []
    @Published var error: Error? = nil

    let repository: CharacteristicRepositoryInterface
    var cancellables = Set<AnyCancellable>()
    
    init(repository: CharacteristicRepositoryInterface = CharacteristicRepository()) {
        self.repository = repository
        fetchAll()
    }
    
    func fetchAll() {
        repository.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case let .failure(err) = completion {
                    self.error = err
                }
            } receiveValue: { models in
                self.items = models
                print("models", self.items)
            }
            .store(in: &cancellables)
    }
    
    func delete(at offsets: IndexSet) {
        let toDelete = offsets.compactMap { self.items[$0] }
        Publishers.MergeMany(
            toDelete.map { model in
                self.repository.delete(model)
            }
        )
        .flatMap { _ in self.repository.fetchAll() }
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case let .failure(err) = completion {
                self.error = err
            }
        } receiveValue: { models in
            self.items = models
        }
        .store(in: &cancellables)
    }
}
