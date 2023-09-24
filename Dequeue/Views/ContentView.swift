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
                    ConnectToHostView()
                        .environmentObject(appState)
                        .navigationDestination(isPresented: $appState.showHome) {
                            HomeView()
                                .navigationBarHidden(true) 
                        }
                }
                else {
                        Image("DequeueLogo")
                            .resizable()
                            .scaledToFit()
                        
                }
            }
            .background(BackgroundView().allowsHitTesting(false))
            
        }
        .onAppear {
            print("++ Attempting to connect to last remembered host...")
            connectToLastRememberedHost(appState:appState)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
        .onReceive(orientationChanged) { _ in
            self.orientation = UIDevice.current.orientation
            appState.isLandscape = self.orientation.isLandscape
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
