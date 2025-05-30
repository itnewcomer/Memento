//
//  MementoApp.swift
//  Memento
//
//  Created by 小池慶彦 on 2025/05/06.
//

import SwiftUI
import SwiftData

@main
struct MementoApp: App {
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
            ContentView().preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
