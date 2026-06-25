//
//  Claudes_LockBoxApp.swift
//  LockBox by Claude
//
//  Created by Michael Fluharty on 4/16/26.
//

import SwiftUI
import SwiftData

@main
struct Claudes_LockBoxApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Folder.self,
            VaultItem.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            LockScreenView()
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        // Adds "File → Import from iPhone or iPad → Scan Documents / Take Photo".
        .commands { ImportFromDevicesCommands() }
        #endif
    }
}
