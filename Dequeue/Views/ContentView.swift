//
//  ContentView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/6/23.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @EnvironmentObject var appState : AppState
    @State var isActive : Bool = false
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    private var orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
        .makeConnectable()
        .autoconnect()
    
    
    var body : some View {
        NavigationStack {
            ZStack {
                if isActive {
                    if !appState.settings.onboardingComplete {
                        OnboardingView()
                    }
                    else {
                        ConnectToHostView()
                            .environmentObject(appState)
                            .navigationDestination(isPresented: $appState.showHome) {
                                HomeView()
                                    .navigationBarHidden(true)
                            }
                    }
                }
                else {
                        Image("GizmoLogo")
                            .resizable()
                            .scaledToFit()
                }
            }
            .background(BackgroundView().allowsHitTesting(false))
            
        }
        .onAppear {
            print("++ Attempting to connect to last remembered host...")
            connectToLastRememberedHost(appState:appState)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut) {
                    self.isActive = true
                }
            }
        }
        .onReceive(orientationChanged) { _ in
            let orientation = UIDevice.current.orientation
            appState.deviceOrientation = AppState.DeviceOrientation(deviceOrientation: orientation)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
