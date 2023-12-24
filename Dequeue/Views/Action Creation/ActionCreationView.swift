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
    
    
    @State private var selectedBackgroundColor : Color = Color(hex:Action().color)
    @State private var selectedTextColor : Color = Color(hex:Action().textColor)
    @State private var selectedForegroundColor : Color = Color(hex:Action().foregroundColor)
    
    @State private var updateActionDisplay : Bool = false
    
    @State var isEditing : Bool = false
    
    @FocusState var isTextFieldActive : Bool
    
    
    @State private var pickerSelection : String = "functionality"
    
    
    @State private var selectedDisplayType : String = "button"
    
    
    @Binding var needsUpdate : Bool
    
    func colorToHex(_ color: Color) -> String {
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "#%02X%02X%02X", Int(red * 255), Int(green * 255), Int(blue * 255))
    }
    
    var KnobDisplayView : some View {
        VStack {
            Text("Knob")
                .font(.system(size:30, weight: .bold))
                .foregroundColor(.white)
                .padding(.top)
            ZStack {
                ZStack {
                    Circle()
                        .frame(width: 160, height: 160)
                        .foregroundColor(Color(hex:newAction.foregroundColor))
                    RoundedRectangle(cornerRadius:50.0 )
                        .frame(width: 4, height:40)
                        .foregroundColor(Color(hex:newAction.color))
                        .offset(x:0, y:-51.0)
                }
                Image(systemName: newAction.icon)
                    .resizable()
                    .frame(maxWidth:100, maxHeight:100)
                    .aspectRatio(contentMode: .fit)
                    .opacity(newAction.iconVisible ? 0.25 : 0)
                    .foregroundColor(.black)
                Text(newAction.name)
                    .foregroundStyle(.black)
                    .font(.system(size: 12, weight:.bold))
                    .opacity(newAction.nameVisible ? 1 : 0)
                    .padding(.bottom, 5)
            }
            .frame(width: 180, height: 180)
            .background(Color(hex: newAction.color))
            .clipShape(RoundedRectangle(cornerRadius: 40))
        }
        
    }
    
    
    var ButtonDisplayView : some View {
        VStack {
            Text("Button")
                .font(.system(size:30, weight: .bold))
                .foregroundColor(.white)
                .padding(.top)
            ZStack {
                Image(systemName: newAction.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(newAction.iconVisible ? 0.25 : 0)
                    .foregroundColor(Color(hex:newAction.foregroundColor))
                Text(newAction.name)
                    .foregroundStyle(Color(hex: newAction.textColor))
                    .font(.system(size: 24, weight:.bold))
                    .opacity(newAction.nameVisible ? 1 : 0)
            }
            .frame(width: 180, height: 180)
            .background(Color(hex: newAction.color))
            .clipShape(RoundedRectangle(cornerRadius: 40))
        }
    }
    
    
    var DisplayOptionsView : some View {
        ScrollView([.vertical]) {
            VStack {
                Text("Name:")
                    .font(.system(size: 20, weight:.bold))
                HStack {
                    Button(action: {
                        newAction.nameVisible.toggle()
                    }) {
                        Image(systemName: newAction.nameVisible ? "eye" : "eye.slash" )
                    }
                    .font(.system(.body, weight: .bold))
                    .opacity(0.5)
                    TextField("", text: $newAction.name)
                    
                }
                .padding()
                .foregroundColor(.primary)
                .font(.system(size:16))
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20.0))
            }
            .padding(.top)
            HStack {
                Text("Text Color:")
                    .font(.system(size: 20, weight:.bold))
                Spacer()
                ColorPicker("", selection: $selectedTextColor, supportsOpacity: false)
                    .labelsHidden()
                    .scaleEffect(1.5)
                    .frame(width:55, height: 55)
                    .onChange(of:selectedTextColor) {
                        newAction.textColor = colorToHex(selectedTextColor)
                    }
            }.padding(.top)
            HStack {
                Text("Foreground Color:")
                    .font(.system(size: 20, weight:.bold))
                Spacer()
                ColorPicker("", selection: $selectedForegroundColor, supportsOpacity: false)
                    .labelsHidden()
                    .scaleEffect(1.5)
                    .frame(width:55, height: 55)
                    .onChange(of:selectedForegroundColor) {
                        newAction.foregroundColor = colorToHex(selectedForegroundColor)
                    }
            }.padding(.top)
            HStack {
                Text("Background Color:")
                    .font(.system(size: 20, weight:.bold))
                Spacer()
                ColorPicker("", selection: $selectedBackgroundColor, supportsOpacity: false)
                    .labelsHidden()
                    .scaleEffect(1.5)
                    .frame(width:55, height: 55)
                    .onChange(of:selectedBackgroundColor) {
                        newAction.color = colorToHex(selectedBackgroundColor)
                    }
            }.padding(.top)
            ///                 ICON SELECTION
            HStack {
                Text("Icon:")
                    .font(.system(size: 20, weight:.bold))
                Spacer()
                HStack {
                    Button(action: {
                        newAction.iconVisible.toggle()
                    }) {
                        Image(systemName: newAction.iconVisible ? "eye" : "eye.slash" )
                    }
                    .font(.system(.body, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    Button {
                        iconPickerPresented = true
                    } label: {
                        Image(systemName: newAction.icon)
                            .foregroundColor(Color(hex:newAction.foregroundColor))
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .font(.title)
                    
                }
            }.padding(.top)
        }
    }
    
    
    var FunctionalityOptionsView : some View {
        ScrollView([.vertical]) {
            
                HStack {
                    ActionTypeButtonView(associatedAction: "shortcut", selectedActionType: $newAction.type)
                    ActionTypeButtonView(associatedAction: "siriShortcut", selectedActionType: $newAction.type)
                    ActionTypeButtonView(associatedAction: "text", selectedActionType: $newAction.type)
                }
            switch newAction.type {
            case "shortcut":
                shortcutCreationView
            case "siriShortcut":
                siriShortcutCreationView
            case "text":
                textCreationView
            default:
                EmptyView()
            }
                
        }
    }
    
    
    var textCreationView : some View {
        VStack {
            Text("Text Insertion").font(.title2).padding(.top)
            TextEditor(text:$newAction.text)
                .scrollContentBackground(.hidden)
                .submitLabel(.done)
                .padding()
                .background(.ultraThinMaterial, in:RoundedRectangle(cornerRadius: 25.0))
                .frame(height: 400)
            
                
            
        }
        .padding(.horizontal)
    }
    
    
    var siriShortcutCreationView : some View {
        VStack {
            Text("Shortcut:")
                .padding(.top)
                .font(.system(size: 20, weight:.bold))
            Picker("Select a Shortcut", selection: $newAction.siriShortcut) {
                 ForEach(siriShortcuts, id: \.self) { option in
                     Text(option).onAppear{
                         print(option)
                     }
                 }
             }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .frame(maxWidth:.infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25.0))
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
    
    var shortcutCreationView : some View {
        VStack {
            HStack {
                Text("Key:")
                    .font(.system(size: 20, weight:.bold))
                Spacer()
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
                .submitLabel(.done)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            .padding(.vertical)
            HStack {
                Spacer()
                if(appState.connectedHost.host.isMac) {
                    ModifierButton(icon: "command", modifierName: "Command", modifiers: $newAction.modifiers)
                } else {
                    ModifierButton(icon: "squareshape.split.2x2", modifierName: "Windows", modifiers: $newAction.modifiers)
                }
                Spacer()
                ModifierButton(icon: "control", modifierName: "Control", modifiers: $newAction.modifiers)
                Spacer()
                ModifierButton(icon: "shift", modifierName: "Shift", modifiers: $newAction.modifiers)
                Spacer()
            }
        }
        .padding(.horizontal)
    }
    
    var body: some View {
            
        VStack {
            TabView(selection:$newAction.displayType) {
                    VStack {
                        ButtonDisplayView
                        Spacer()
                    }.tag("button")
                    VStack {
                        KnobDisplayView
                        Spacer()
                    }.tag("knob")
                }
            
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .automatic))
                VStack {
                    Picker("", selection: $pickerSelection) {
                        Text("Functionality").tag("functionality")
                        Text("Display").tag("display")
                        
                    }
                    .padding(.top)
                    .pickerStyle(.segmented)
                    TabView(selection:$pickerSelection) {
                        FunctionalityOptionsView.tag("functionality")
                        DisplayOptionsView.tag("display")
                    }
                    .ignoresSafeArea()
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    
                }
                .frame(maxWidth:.infinity, maxHeight:.infinity).padding(.horizontal).background(.thinMaterial)
            }
                    .iconPicker(
                        isPresented: $iconPickerPresented, selectedIconName: $newAction.icon, selectedColor: newAction.foregroundColor
                    )
                    .onAppear{appState.connectedHost.getSiriShortcuts {result, siriShortcuts in
                        self.siriShortcuts = siriShortcuts
                    }
                    
                    }
            
                    .onAppear {
                        if let editingAction = editingAction {
                            self.newAction = editingAction
                        }
                    }
                    .toolbar {
                        ToolbarItem {
                            Button {
                                if self.isEditing {
                                                 appState.connectedHost.updateAction(action: newAction) {_ in
                                                     appState.connectedHost.fetchActions()
                                                     {newLayout in
                                                         needsUpdate = true
                                                     }
                                                 }
                                             }
                                             else {
                                                 appState.connectedHost.createAction(action: &newAction, page: appState.currentPage)
                                             }
                             
                                             appState.connectedHost.fetchActions()
                                             appState.showCreateAction = false
                                             appState.showEditAction = false
                            } label: {
                                Text(isEditing ? "Update" : "Create")
                            }
                        }
                    }
                    .navigationTitle(isEditing ? "Update Action" :  "New Action")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}



struct ActionTypeButtonView : View {
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
                    Text("Keybind")
                        .font(.subheadline)
                case "siriShortcut":
                    Spacer()
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.system(size: 50))
                    Spacer()
                    Text("Shortcut")
                        .font(.subheadline)
                case "text":
                    Spacer()
                    Image(systemName: "character.textbox")
                        .font(.system(size: 50))
                    Spacer()
                    Text("Text")
                        .font(.subheadline)
                case "group":
                    Spacer()
                    Image(systemName: "square.on.square")
                        .font(.system(size: 50))
                    Spacer()
                    Text("Group")
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

struct ModifierSelectionView : View  {

    @Binding var modifiers : [String: Bool]
    @EnvironmentObject var appState : AppState
    
    
    
    var body : some View {
        HStack {
            Spacer()
            if(appState.connectedHost.host.isMac) {
                ModifierButton(icon: "command", modifierName: "Command", modifiers: $modifiers)
            } else {
                ModifierButton(icon: "squareshape.split.2x2", modifierName: "Windows", modifiers: $modifiers)
            }
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
                    .font(.system(size: 30))
                    .frame(width:50, height:50)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            Text(modifierName)
        }
        .foregroundColor(isSelected() ?  Color("AccentColor") : .white)
    }
}

struct ActionCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ActionCreationView( needsUpdate: .constant(false)).environmentObject(AppState())
    }
}

//#Preview {ActionCreationView()}
