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
    @State var isFeedbackAlertPresented : Bool = false
    
    var body: some View {
        ScrollView([.vertical]) {
            SettingsItemView(title: "Connect To Host", iconName: "wifi", action: {
                showConnectToHostView = true
            }, showArrow: true)
                .navigationDestination(isPresented: $showConnectToHostView) {
                    ConnectToHostView()
                }
            SettingsItemView(title: "Refresh Actions", iconName: "arrow.clockwise", action: {
                appState.connectedHost.fetchActions()
            })
            SettingsItemView(title: "Share Feedback", iconName: "megaphone", action: {
                if let url = URL(string: "mailto:matthewsand22@gmail.com") {
                    UIApplication.shared.open(url)
                }
            })
            
//            SettingsAccentsListView()
            
            SettingsItemToggleView(title: "Background on Actions Screen", iconName: "", toggle: $appState.settings.showHomeScreenBackground)
            
            SettingsItemToggleView(title: "Haptic Feedback", iconName: "", toggle: $appState.settings.hapticFeedbackEnabled)
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
    @EnvironmentObject var appState : AppState
     
    
    
    
    var body : some View {
        Button(action: {
            toggle.toggle()
            appState.saveSettings()
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

struct SettingsAccentsListView : View {
    @State private var colors : [Color] = [Color.red, Color.blue, Color.green]
    @State private var isSelected : Bool = false
    var body : some View {
        VStack {
            Text("Accent Colors")
            ScrollView([.horizontal]) {
                HStack {
                    ForEach(colors, id: \.self) {color in
                        VStack {
                            VStack {
                                
                            }
                            .frame(width:50, height:50)
                            .background(color, in: RoundedRectangle(cornerRadius: 20))
                            Text("Name")
                        }
                        .padding()
                        
                        
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}


struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(AppState())
    }
}

