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
    var body : some View {
        NavigationStack {
            ZStack {
                    ConnectToHostView()
                        .environmentObject(appState)
            }
            .background(BackgroundView().allowsHitTesting(false))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
