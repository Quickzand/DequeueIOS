//
//  DequeueApp.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/6/23.
//

import SwiftUI



@main struct DequeueApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appState)
        }
        
    }
}




//#Preview {
//    ConnectToHostView()
//}
