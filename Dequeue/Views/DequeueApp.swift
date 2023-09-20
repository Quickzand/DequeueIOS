//
//  DequeueApp.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/6/23.
//

import SwiftUI


class AppState: ObservableObject {
    @Published var connectedHost : Host? = nil
    @Published var showSettings : Bool = false
    @Published var showHome : Bool = false
    @Published var showCreateAction : Bool = false
    @Published var isLandscape : Bool = false
    @Published var showHomeScreenBackground : Bool = true
    @Published var currentPage : Int = 0
}
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
