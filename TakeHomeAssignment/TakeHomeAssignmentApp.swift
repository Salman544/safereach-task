//
//  TakeHomeAssignmentApp.swift
//  TakeHomeAssignment
//
//  Created by Muhammad Salman on 30/06/2025.
//

import SwiftUI
import UserNotifications

@main
struct TakeHomeAssignmentApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        NotificationManager.shared.requestAuthorization()
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            CharacteristicListView()
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let id = response.notification.request.identifier
        print("identifier", id)
        if let uuid = UUID(uuidString: id) {
            NotificationCenter.default.post(name: .didReceiveNotification, object: nil, userInfo: ["id": uuid])
        }
        completionHandler()
    }
}
