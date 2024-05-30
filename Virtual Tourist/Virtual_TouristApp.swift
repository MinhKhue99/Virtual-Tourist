//
//  Virtual_TouristApp.swift
//  Virtual Tourist
//
//  Created by KhuePM on 30/05/2024.
//

import SwiftUI

@main
struct Virtual_TouristApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
