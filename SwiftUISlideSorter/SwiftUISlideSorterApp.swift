//
//  SwiftUISlideSorterApp.swift
//  SwiftUISlideSorter
//
//  Created by TR Solutions on 5/11/21.
//

import SwiftUI

@main
struct SwiftUISlideSorterApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
