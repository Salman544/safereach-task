//
//  CharacteristicListView.swift
//  TakeHomeAssignment
//
//  Created by Muhammad Salman on 30/06/2025.
//

import SwiftUI

struct CharacteristicListView: View {
    @StateObject private var vm = CharacteristicListViewModel()
    @State private var showingDetail = false
    @State private var detailModel: CharacteristicModel? = nil    

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.items) { model in
                    Button {
                        detailModel = model
                        showingDetail = true
                    } label: {
                        HStack {
                            Text(model.name)
                            Spacer()
                            switch model.value {
                            case .text(let s): Text(s)
                            case .number(let d): Text(String(d))
                            }
                        }
                    }
                }
                .onDelete(perform: vm.delete)
            }
            .navigationTitle("Characteristics")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        detailModel = nil
                        showingDetail = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingDetail, onDismiss: vm.fetchAll) {
                let viewModel = CharacteristicViewModel(
                    initialModel: detailModel
                )
                CharacteristicView(vm: viewModel)
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .didReceiveNotification)
            ) { note in
                if let uuid = note.userInfo?["id"] as? UUID,
                   let model = vm.items.first(where: { $0.id == uuid }) {
                    detailModel = model
                    showingDetail = true
                }
            }
        }
        .alert(
            isPresented: Binding(
                get: { vm.error != nil },
                set: { _ in vm.error = nil }
            )
        ) {
            Alert(
                title: Text("Error"),
                message: Text(vm.error?.localizedDescription ?? ""),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    CharacteristicListView()
}
