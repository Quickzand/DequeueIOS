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
            
            
            SettingsBackgroundsListView()
            
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


struct Background : Hashable {
    var name : String
    var color1 : String
    var color2 : String
}

func colorToHex(_ color: Color) -> String {
    let uiColor = UIColor(color)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
}


struct SettingsBackgroundsListView : View {
    
 
    
    
    @State private var backgrounds : [Background] = [Background(name: "Grid", color1: colorToHex(Color("AccentColor")), color2: colorToHex(Color(hex:"#0000000")))]
    @State private var isSelected : Bool = false
    @State private var selectedColor : Color = Color("Accent")
    
    @EnvironmentObject var appState : AppState
    
    var body : some View {
        VStack {
            Text("Backgrounds")
            ScrollView([.horizontal]) {
                HStack {
                    ForEach(backgrounds, id: \.self) {background in
                        Button(action:{
                            appState.settings.selectedBackground = background.name
                            appState.saveSettings()
                        }) {
                            VStack {
                                VStack {
                                    
                                }
                                .frame(width:50, height:50)
                                .background(LinearGradient(colors: [Color(hex: background.color1), Color(hex: background.color2)], startPoint: UnitPoint(x: 0, y: 0),
                                                           endPoint: UnitPoint(x: 1, y: 1)), in: RoundedRectangle(cornerRadius: 20))
                                Text(background.name)
                                    .foregroundStyle(appState.settings.selectedBackground == background.name ? Color("AccentColor") : Color.primary)
                            }
                        }
                        .padding()
                    }
                    VStack {
                        ColorPicker("", selection: $selectedColor, supportsOpacity: false)
                            .labelsHidden()
                            .scaleEffect(1.5)
                            .frame(width:55, height: 55)
                            .onChange(of: selectedColor) {
                                appState.settings.selectedBackground = "custom"
                                appState.settings.selectedBackgroundColor = colorToHex(selectedColor)
                                appState.saveSettings()
                            }
                        
                        Text("Custom")
                            .foregroundStyle(appState.settings.selectedBackground == "custom" ? Color("AccentColor") : Color.primary)
                    }
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .padding()
    }
}

struct SettingsAccentsListView : View {
    @State private var colors : [Color] = [Color.red, Color.blue, Color.green, Color.red, Color.red, Color.red]
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

