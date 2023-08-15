//
//  personaApp.swift
//  persona
//
//  Created by hashimo ryoya on 2023/08/12.
//

import SwiftUI
import Firebase

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
}

@main
struct personaApp: App {
    @ObservedObject var authManager: AuthManager
    
    init() {
        FirebaseApp.configure()
        authManager = AuthManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            PersonsListView()
        }
    }
}
