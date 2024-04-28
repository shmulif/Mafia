//
//  mafiaApp.swift
//  mafia
//
//  Created by Shmuli Feld on 2/6/24.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct mafiaApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            NavigationStack{
                RootView()
//                DayView(userId: .constant("4l8al6EUyIMd1FhkBOmMMU4r2iB3"), gameId: .constant("party"))
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    
    class AppDelegate: NSObject, UIApplicationDelegate {
      func application(_ application: UIApplication,
                       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
      }
    }
}
