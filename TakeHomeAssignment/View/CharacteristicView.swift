//
//  CharacteristicView.swift
//  TakeHomeAssignment
//
//  Created by Muhammad Salman on 30/06/2025.
//

import SwiftUI

struct CharacteristicView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var vm: CharacteristicViewModel
    @State private var showEnableConfirm = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Info")) {
                    TextField("Name", text: $vm.name)
                    Picker("Type", selection: $vm.valueType) {
                        Text("Text").tag(CharacteristicViewModel.ValueType.text)
                        Text("Number").tag(CharacteristicViewModel.ValueType.number)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    if vm.valueType == .text {
                        TextField("Value", text: $vm.textValue)
                    } else {
                        TextField(
                            "Value",
                            value: $vm.numberValue,
                            formatter: NumberFormatter()
                        )
                        .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Reminder")) {
                    Toggle("Enable", isOn: $vm.reminderEnabled)
                    if vm.reminderEnabled {
                        Picker("Interval", selection: $vm.reminderInterval) {
                            Text("1 min").tag(60.0)
                            Text("5 min").tag(300.0)
                            Text("15 min").tag(900.0)
                            Text("1 hr").tag(3600.0)
                        }
                    }
                }
            }
            .navigationTitle(vm.initialModel == nil ? "New Characteristic" : vm.name)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // If enabling notifications, confirm before saving
                        if vm.reminderEnabled {
                            showEnableConfirm = true
                        } else {
                            vm.save()
                        }
                    }
                    .disabled(vm.saveButtonEnabled)
                }
            }
            .onReceive(vm.$saveSuccess) { success in
                if success {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .alert("Enable Notifications?", isPresented: $showEnableConfirm) {
                Button("Yes") {
                    vm.save()
                }
                Button("No", role: .cancel) {
                    vm.reminderEnabled = false
                    vm.save()
                }
            } message: {
                Text("Do you want to receive alert notifications for this characteristic?")
            }
            .alert(isPresented: Binding(
                get: { vm.saveError != nil },
                set: { _ in vm.saveError = nil }
            )) {
                Alert(
                    title: Text("Error"),
                    message: Text(vm.saveError?.localizedDescription ?? ""),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}


#Preview {
    CharacteristicView(vm: .init())
}
