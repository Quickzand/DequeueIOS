//
//  ActionCreationView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/10/23.
//

import SwiftUI

enum ActionType {
    case shortcut
    case action
    case none
}


struct ActionCreationView: View {
    @State var actionName : String = ""
    @State private var selectedActionType : ActionType = .shortcut
    
    var body: some View {
        VStack {
            TextField("Action name", text: $actionName)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .padding()
                .font(.title)
            Text("Action Type").font(.headline)
                HStack(alignment:.center) {
                    Spacer()
                    ActionTypeView(associatedAction: .shortcut, selectedActionType: $selectedActionType)
                    Spacer()
                    ActionTypeView(associatedAction: .none, selectedActionType: $selectedActionType)
                    Spacer()
                    ActionTypeView(associatedAction: .none, selectedActionType: $selectedActionType)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            Text("Keyboard Shortcut").font(.headline).padding(.top)
            keyboardShortcutCreationView()
            
            Spacer()
        }
        .background(BackgroundView())
    }
}



struct ActionTypeView : View {
    var associatedAction : ActionType
    @Binding var selectedActionType : ActionType
    
    
    var body : some View {
        Button (action: {
            selectedActionType = associatedAction
        }) {
            VStack {
                Spacer()
                Image(systemName: "keyboard")
                    .font(.system(size: 50))
                Spacer()
                Text("Keyboard Shortcut")
                    .font(.subheadline)
            }
            .frame(width:75, height: 100)
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 25.0))
        }
        .foregroundColor((selectedActionType == associatedAction) ? Color("AccentColor") : Color.white)
    }
}
enum Modifier {
    case shift
    case command
    case control
    case option
    case none
}

struct keyboardShortcutCreationView : View {
    @State var key : String = ""

    @State private var modifiers : [Modifier] = [.none,.none,.none,.none]
    
    func getModifierViewCount() -> Int {
        var count : Int = 1
        for modifier in modifiers {
            if(modifier != .none) {
                count += 1
            }
        }
        if(count > 4) {
            count = 4
        }
        return count
    }
    var body : some View {
        VStack {
            HStack {
//                THis is where the modifier selector goes
                ForEach(1...getModifierViewCount(), id: \.self) { i in
                    modifierSelectionView(chosenModifier: $modifiers[i-1])
                }
                
                Spacer()
                TextField(text: $key) {
                    
                }
                .frame(width: 75, height: 75)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
        }.padding(.horizontal)
    }
}


struct modifierSelectionView : View  {
    @State private var isExpanded : Bool = false

    @Binding var chosenModifier : Modifier
    
    
    
    func setChosenModifier(choice : Modifier) {
        chosenModifier = choice
        isExpanded = false
    }
    
    func getDisplayedIcon() -> String {
        switch self.chosenModifier {
        case .shift:
            return "shift"
        case .command:
            return "command"
        case .control:
            return "control"
        case .option:
            return "option"
        case .none:
            return "plus"
        }
    }
    
    
    var body : some View {
        ZStack(alignment: .top) {
            Button (action:{
                isExpanded = true
            }) {
                Image(systemName: getDisplayedIcon())
                    .font(.system(size: 30))
                    
            }
            .frame(width: 75, height: 75)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .opacity(isExpanded ? 0 : 1)
            .overlay(Group {
                if isExpanded {
                    VStack(spacing: 10) {
                        Spacer(minLength: 325)
                        Button(action: {setChosenModifier(choice: .none)}) {
                            Image(systemName: "xmark")
                                .font(.system(size: 30))
                                
                        }
                        .frame(width: 75, height: 75)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        Button(action: {
                            setChosenModifier(choice: .command)
                        }) {
                            Image(systemName: "command")
                                .font(.system(size: 30))
                        }
                        .frame(width: 75, height: 75)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        
                        Button(action: {
                            setChosenModifier(choice: .control)
                        }) {
                            Image(systemName: "control")
                                .font(.system(size: 30))
                        }
                        .frame(width: 75, height: 75)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        
                        Button(action: {
                            setChosenModifier(choice: .option)
                        }) {
                            Image(systemName: "option")
                                .font(.system(size: 30))
                        }
                        .frame(width: 75, height: 75)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                        
                        Button(action: {
                            setChosenModifier(choice: .shift)
                        }) {
                            Image(systemName: "shift")
                                .font(.system(size: 30))
                        }
                        .frame(width: 75, height: 75)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    }
                    
                }
            }
            )
        }.foregroundColor(.white)
    }
}

struct ActionCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ActionCreationView()
    }
}
