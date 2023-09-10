//
//  HomeView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/9/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        if let host = appState.connectedHost {
                ZStack {
                    ToolbarView()
                        .navigationDestination(isPresented: $appState.showSettings) {
                            SettingsView()
                        }
                    VStack {
                        Spacer()
                        Text("Current host: \(host.sanitizedName())")
                    }
                }
            
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        
        HomeView().environmentObject({
            () -> AppState in
            let envObject = AppState()
            envObject.connectedHost = Host(name: "MatbbokPro", ip: "Test", code: "1122")
            return envObject
        }())
    }
}
