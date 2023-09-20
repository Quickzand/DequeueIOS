//
//  SettingsView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/9/23.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State var showConnectToHostView : Bool = false
    
    var body: some View {
        ScrollView([.vertical]) {
            SettingsItemView(title: "Connect To Host", iconName: "wifi", action: {
                showConnectToHostView = true
            }, showArrow: true)
                .navigationDestination(isPresented: $showConnectToHostView) {
                    ConnectToHostView()
                }
            SettingsItemView(title: "Refresh Actions", iconName: "arrow.clockwise", action: {
                appState.connectedHost?.fetchActions(){ actions in
                    appState.connectedHost?.actionPages = actions
                    
                }
            })
            
            SettingsItemToggleView(title: "Background on Actions Screen", iconName: "", toggle: $appState.showHomeScreenBackground)
        }
    }
}


struct SettingsItemView : View {
    var title : String
    var iconName : String
    var action : () -> ()
    var showArrow : Bool = false
     
    
    
    
    var body : some View {
        Button(action: {
            action()
        }) {
            HStack {
                Image(systemName: iconName)
                Text(title)
                Spacer()
                if showArrow {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            .frame(maxWidth:.infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
            .padding()
        }
        .foregroundColor(.white)
    }
}

struct SettingsItemToggleView : View  {
    var title : String
    var iconName : String
    @Binding var toggle : Bool
     
    
    
    
    var body : some View {
        Button(action: {
            toggle.toggle()
        }) {
            HStack {
                Image(systemName: iconName)
                Text(title)
                Spacer()
                Toggle("Test", isOn: $toggle)
                    .toggleStyle(SwitchToggleStyle(tint: Color("AccentColor")))
                    .labelsHidden()
                    
            }
            .padding()
            .frame(maxWidth:.infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
            .padding()
        }
        .foregroundColor(.white)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppState())
    }
}

