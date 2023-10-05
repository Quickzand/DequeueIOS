//
//  ActionCreationView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/10/23.
//

import SwiftUI
import SymbolPicker
import SystemImagePicker

enum ActionType {
    case shortcut
    case siriShortcut
    case none
}


struct ActionCreationView: View {
    @State private var selectedActionType : ActionType = .shortcut
    @State private var iconPickerPresented = false
    @State private var newAction = Action(icon: "bolt.fill", name: "New Action", type: "shortcut")
    @State var editingAction : Action? 
    @EnvironmentObject var appState: AppState
    @State private var actionColor = Color(.white);
    @State private var currentAction = Action()
    
    @State private var siriShortcuts : [String] = []
    
    
    @State var isEditing : Bool = false
    
    func colorToHex(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
    
    var body: some View {

        VStack {
            ScrollView([.vertical]) {
                HStack {
                    Button(action: {
                        iconPickerPresented = true
                    }) {
                        Image(systemName: newAction.icon)
                            .foregroundColor(Color(hex:newAction.color))
                    }
                    .padding()
                    .frame(width:65, height:65)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .font(.title)
                    HStack {
                        Button(action: {
                            newAction.nameVisible.toggle()
                        }) {
                            Image(systemName: newAction.nameVisible ? "eye" : "eye.slash" )
                        }
                        .font(.system(.body, weight: .heavy))
                        .opacity(0.5)
                        TextField("Action name", text: $newAction.name)
                            .font(.title)
                    }.padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        
                }
                .foregroundColor(.white)
                .padding()
                Text("Action Type").font(.headline)
                HStack(alignment:.center) {
                    Spacer()
                    ActionTypeView(associatedAction: "shortcut", selectedActionType: $newAction.type)
                    Spacer()
                    ActionTypeView(associatedAction: "siriShortcut", selectedActionType:$newAction.type)
                    Spacer()
                    ActionTypeView(associatedAction: "none", selectedActionType: $newAction.type)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                switch newAction.type {
                case "shortcut":
                    keyboardShortcutCreationView(newAction: $newAction)
                case "siriShortcut":
                    siriShortcutCreationView(newAction: $newAction, siriShortcuts: $siriShortcuts)
                case "none":
                    Text("None").font(.headline).padding(.top)
                default:
                    EmptyView()
                }
                
                
                Spacer()
            }
            //        .sheet(isPresented: $iconPickerPresented) {
            //            SymbolPicker(symbol: $icon)
            //        }
            .iconPicker(
                isPresented: $iconPickerPresented, selectedIconName: $newAction.icon, selectedColor: $newAction.color
            )
            .onAppear() {
                if let editingAction = editingAction {
                    self.newAction = editingAction
                    print("WORKS")
                }
            }
            .background(BackgroundView())
            Button(action: {
                print("HERE")
                if self.isEditing {
                    print("HERE2")
                    appState.connectedHost.updateAction(action: newAction)
                }
                else {
                    appState.connectedHost.createAction(action: &newAction, page: appState.currentPage)
                }
                
                appState.connectedHost.fetchActions()
                appState.showCreateAction = false
                appState.showEditAction = false
            }) {
                HStack {
                    Spacer()
                    Text(self.isEditing ? "Update Action" : "Create Action")
                    Spacer()
                }.font(.system(size:27,weight:.bold))
                    .frame(height: 25)
                    .padding(.top)
                    .background(Color("AccentColor").opacity(0.75))
                    .foregroundColor(Color.white)
                
                
            }
            .onDisappear() {
                appState.showEditAction = false
            }
            .onAppear{appState.connectedHost.getSiriShortcuts {result, siriShortcuts in
                self.siriShortcuts = siriShortcuts
            }
            }
        }
    }
}



struct ActionTypeView : View {
    var associatedAction : String
    @Binding var selectedActionType : String
    
    
    var body : some View {
        Button (action: {
            selectedActionType = associatedAction
        }) {
            VStack {
                switch associatedAction {
                case "shortcut":
                    Spacer()
                    Image(systemName: "keyboard.fill")
                        .font(.system(size: 50))
                    Spacer()
                    Text("Key")
                        .font(.subheadline)
                case "siriShortcut":
                    Spacer()
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 50))
                    Spacer()
                    Text("Shortcut")
                        .font(.subheadline)
                case "none":
                    Spacer()
                    Image(systemName: "square.slash")
                        .font(.system(size: 50))
                    Spacer()
                    Text("None")
                        .font(.subheadline)
                default:
                    EmptyView()
                }

            }
            .frame(width:75, height: 100)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 25.0))
        }
        .foregroundColor((selectedActionType == associatedAction) ? Color("AccentColor") : Color.white)
    }
}



struct siriShortcutCreationView : View {
    
    @Binding var newAction : Action
    
    @Binding var siriShortcuts : [String]
    
    
    var body : some View {
        VStack {
            Text("Siri Shortcut").font(.title2).padding(.top)
            VStack {
                Picker("Select an Option", selection: $newAction.siriShortcut) {
                     ForEach(siriShortcuts, id: \.self) { option in
                         Text(option).onAppear{
                             print(option)
                         }
                     }
                 }
                 .pickerStyle(MenuPickerStyle())
                 .padding()
            }
            .onAppear {
                print(siriShortcuts)
            }
        }.padding(.horizontal)
    }
}


struct keyboardShortcutCreationView : View {
    
    @Binding var newAction : Action
    
    var body : some View {
        VStack {
            Text("Keyboard Shortcut").font(.title2).padding(.top)
            VStack {
                Text("Key").font(.headline).padding(.top, 3)
                    TextField(text: $newAction.key) {
                        
                    }
                    .onChange(of: newAction.key) { newValue in
                        if newValue.count > 1 {
                            newAction.key = String(newValue.prefix(1))
                        }
                    }
                    .font(.system(size: 30, weight: .bold))
                    .frame(width: 75, height: 75)
                    .multilineTextAlignment(.center)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            
            Text("Modifiers").font(.headline).padding(.top)
            ModifierSelectionView(modifiers: $newAction.modifiers)
        }.padding(.horizontal)
    }
}


struct ModifierSelectionView : View  {

    @Binding var modifiers : [String: Bool]
    
    
    
    
    var body : some View {
        HStack {
            Spacer()
            ModifierButton(icon: "command", modifierName: "Command", modifiers: $modifiers)
            Spacer()
            ModifierButton(icon: "control", modifierName: "Control", modifiers: $modifiers)
            Spacer()
            ModifierButton(icon: "shift", modifierName: "Shift", modifiers: $modifiers)
            Spacer()
        }
    }
}

struct ModifierButton : View {
    var icon : String
    var modifierName: String
    @Binding var modifiers : [String: Bool]
    
    func isSelected() -> Bool {
        return modifiers[modifierName]!
    }
    
    var body : some View {
        VStack {
            Button(action:{
                modifiers[modifierName]?.toggle()
            }) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .padding()
                    .frame(width:100, height:100)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            Text(modifierName)
        }
        .foregroundColor(isSelected() ?  Color("AccentColor") : .white)
    }
}

struct ActionCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ActionCreationView()
    }
}
