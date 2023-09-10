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
                VStack {
                    
                    ToolbarView()
                        .navigationDestination(isPresented: $appState.showSettings) {
                            SettingsView()
                                .navigationTitle("Settings")
                        }
                        .navigationDestination(isPresented: $appState.showCreateAction) {
                            ActionCreationView()
                                .navigationTitle("Create Action")
                        }
                    VStack {
                        Grid {
                            GridRow (alignment: .center){
                                ActionButtonView()
                                ActionButtonView()
                                ActionButtonView()
                            }
                        }
                        Spacer()
                        Text("Current host: \(host.sanitizedName())")
                    }
                }
                .background(BackgroundView())
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            
        }
    }
}


struct ActionButtonView : View {
    var body: some View {
        Button(action: {}) {
            Text("Copy")
                .frame(width:100, height:100)
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25.0))
        .padding()
        
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
