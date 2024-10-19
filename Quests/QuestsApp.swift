//
//  QuestsApp.swift
//  Quests
//
//  Created by Jack Buhler on 2024-05-19.
//

import SwiftUI
import Firebase
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct QuestsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // register app for Firebase setup
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
            //QuestView(quests: QuestStruc.sampleData)
        }
        .modelContainer(sharedModelContainer)
    }
}


