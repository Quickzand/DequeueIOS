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

var allowedSpecialKeys = [
    "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
    "Esc", "Tab", "Insert", "Delete",
    "Up", "Down", "Left", "Right",
    "Backspace", "Enter", "Space"
]



struct KeybindTextFieldView : View {
    @Binding var keyBinding : String
    
    

    var body : some View {
        TextField(text: $keyBinding) {
        }
        .onChange(of: keyBinding) { newValue in
            if newValue.count > 1  && !allowedSpecialKeys.contains(newValue) {
                keyBinding = String(newValue.dropLast())
            }
        }
        .font(.system(size: keyBinding.count < 3 ? 30 : 15, weight: .bold))
        .frame(width: 75, height: 75)
        .multilineTextAlignment(.center)
        .submitLabel(.done)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }
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
    @State private var systemCommands : [String] = []
    
    
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
                .foregroundColor(.primary)
                .padding(.top)
            ZStack {
                ZStack {
                    Circle()
                        .frame(width: 160, height: 160)
                        .foregroundColor(Color(hex:newAction.color))
                    RoundedRectangle(cornerRadius:50.0 )
                        .frame(width: 4, height:40)
                        .foregroundColor(.black)
                        .offset(x:0, y:-51.0)
                }
                Image(systemName: newAction.icon)
                    .resizable()
                    .frame(maxWidth:100, maxHeight:100)
                    .aspectRatio(contentMode: .fit)
                    .opacity(newAction.iconVisible ? 0.25 : 0)
                    .foregroundColor(Color(hex:newAction.foregroundColor))
                Text(newAction.name)
                    .foregroundColor(Color(hex:newAction.textColor))
                    .font(.system(size: 20, weight:.bold))
                    .opacity(newAction.nameVisible ? 1 : 0)
                    .padding(.bottom, 5)
            }
            .frame(width: 180, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 40))
        }
        
    }
    
    
    var ButtonDisplayView : some View {
        VStack {
            Text("Button")
                .font(.system(size:30, weight: .bold))
                .foregroundColor(.primary)
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
                Text("Icon Color:")
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
            VStack {
                if(newAction.displayType == "knob") {
                    HStack {
                        Text("Knob Sensitivity:")
                            .font(.system(size: 20, weight:.bold))
                        Slider(value: $newAction.knobSensitivity,
                               in: 0...100,
                               step:1)
                    }
                }
                ScrollView([.horizontal]) {
                    HStack {
                        Spacer()
                        ActionTypeButtonView(associatedAction: "shortcut", selectedActionType: $newAction.type)
                        Spacer()
                        ActionTypeButtonView(associatedAction: "siriShortcut", selectedActionType: $newAction.type)
                        Spacer()
                        ActionTypeButtonView(associatedAction: "systemCommand", selectedActionType: $newAction.type)
                        Spacer()
                        ActionTypeButtonView(associatedAction: "text", selectedActionType: $newAction.type)
                        Spacer()
                    }
                }
                switch newAction.type {
                case "shortcut":
                    shortcutCreationView
                case "siriShortcut":
                    siriShortcutCreationView
                case "systemCommand":
                    systemCommandCreationView
                case "text":
                    textCreationView
                default:
                    EmptyView()
                }
            }
            .padding(.bottom, isKeyboardVisible ? 300 : 0)
        }.frame(minHeight: isKeyboardVisible ? 500 : 0)
            .padding(.bottom, isKeyboardVisible ? 200 : 0)
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
            if(newAction.displayType == "knob") {
                Text("Clockwise:")
                    .font(.system(size: 20, weight:.bold))
                    .padding(.top)
            }
            Picker("Select a Shortcut", selection: $newAction.siriShortcut) {
                ForEach(siriShortcuts, id: \.self) { option in
                    Text(option).onAppear{
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .frame(maxWidth:.infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25.0))
            .padding(.horizontal)
            if(newAction.displayType == "knob") {
                Text("Counter Clockwise:")
                    .font(.system(size: 20, weight:.bold))
                    .padding(.top)
                Picker("Select a Shortcut", selection: $newAction.ccSiriShortcut) {
                    ForEach(siriShortcuts, id: \.self) { option in
                        Text(option).onAppear{
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
            
        }
        .padding(.horizontal)
    }
    
    var systemCommandCreationView : some View {
        VStack {
            Text("System Command:")
                .padding(.top)
                .font(.system(size: 20, weight:.bold))
            if(newAction.displayType == "knob") {
                Text("Clockwise:")
                    .font(.system(size: 20, weight:.bold))
                    .padding(.top)
            }
            Picker("Select a Command", selection: $newAction.systemCommand) {
                ForEach(systemCommands, id: \.self) { option in
                    Text(option).onAppear{
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .frame(maxWidth:.infinity)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25.0))
            .padding(.horizontal)
            if(newAction.displayType == "knob") {
                Text("Counter Clockwise:")
                    .font(.system(size: 20, weight:.bold))
                    .padding(.top)
                Picker("Select a Command", selection: $newAction.ccSystemCommand) {
                    ForEach(systemCommands, id: \.self) { option in
                        Text(option).onAppear{
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
            
        }
        .padding(.horizontal)
    }
    
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case key, ccKey
    }
    
    
    
    
    var shortcutCreationView : some View {
        VStack {
            if(newAction.displayType == "knob") {
                Text("Clockwise:")
                    .font(.system(size: 20, weight:.bold))
                    .padding(.top)
            }
            HStack {
                Text("Key:")
                    .font(.system(size: 20, weight:.bold))
                Spacer()
                KeybindTextFieldView(keyBinding: $newAction.key)
                    .focused($focusedField, equals: .key)
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
            
            if(newAction.displayType == "knob") {
                Text("Counter Clockwise:")
                    .font(.system(size: 20, weight:.bold))
                    .padding(.top)
                
                HStack {
                    Text("Key:")
                        .font(.system(size: 20, weight:.bold))
                    Spacer()
                    KeybindTextFieldView(keyBinding: $newAction.ccKey)
                        .focused($focusedField, equals: .ccKey)
                }
                .padding(.vertical)
                HStack {
                    Spacer()
                    if(appState.connectedHost.host.isMac) {
                        ModifierButton(icon: "command", modifierName: "Command", modifiers: $newAction.ccModifiers)
                    } else {
                        ModifierButton(icon: "squareshape.split.2x2", modifierName: "Windows", modifiers: $newAction.modifiers)
                    }
                    Spacer()
                    ModifierButton(icon: "control", modifierName: "Control", modifiers: $newAction.ccModifiers)
                    Spacer()
                    ModifierButton(icon: "shift", modifierName: "Shift", modifiers: $newAction.ccModifiers)
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(allowedSpecialKeys, id: \.self) {key in
                            if focusedField == .key {
                                ToolbarButtonView(key:key, bindedKey: $newAction.key)
                            } else if focusedField == .ccKey {
                                ToolbarButtonView(key:key, bindedKey: $newAction.ccKey)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    @State private var isKeyboardVisible = false
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
            .onAppear {
                appState.connectedHost.getSiriShortcuts { result, siriShortcuts in
                    self.siriShortcuts = siriShortcuts.sorted { $0.localizedCompare($1) == .orderedAscending }
                }
                
                appState.connectedHost.getSystemCommands { result, systemCommands in
                    self.systemCommands = systemCommands
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
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                       isKeyboardVisible = true
                   }
                   .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                       isKeyboardVisible = false
                   }
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
                case "systemCommand":
                    Spacer()
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 50))
                    Spacer()
                    Text("System Command")
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
        .foregroundColor((selectedActionType == associatedAction) ? Color("AccentColor") : Color.primary)
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
        .foregroundColor(isSelected() ?  Color("AccentColor") : .primary)
    }
}



struct ToolbarButtonView : View {
    var key : String
    @Binding var bindedKey : String
    var body : some View {
        Button {
            bindedKey = key
        } label: {
            Text(key).padding(.horizontal).padding(.vertical, 5).background(.ultraThickMaterial).clipShape(RoundedRectangle(cornerRadius:10.0)).foregroundColor(.primary).font(.system(size: 12.0))
        }
    }
}

struct ActionCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ActionCreationView( needsUpdate: .constant(false)).environmentObject(AppState())
    }
}

//#Preview {ActionCreationView()}
