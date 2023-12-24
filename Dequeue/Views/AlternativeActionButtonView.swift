//
//  AlternativeActionButtonView.swift
//  Dequeue
//
//  Created by Matthew Sand on 12/20/23.
//

import SwiftUI




struct ActionSlot : View{
    @State var action: Action?
    @EnvironmentObject var appState: AppState
    @Binding var editMode : Bool
    @Binding var needsUpdate : Bool
    
    @State var isDropTargeted : Bool = false
    var index : Int
    var body : some View {
        VStack {
            if let action = action {
                if !editMode {
                    VStack {
                        switch action.displayType {
                        case "button":
                            AlternativeActionButtonView(action: action, editMode: $editMode, needsUpdate: $needsUpdate)
                        case "knob":
                            ActionKnobView(action: action, editMode: $editMode, needsUpdate: $needsUpdate)
                        default:
                            Text(action.displayType)
                        }
                    }
                    
                } else {
                    VStack {
                        switch action.displayType {
                        case "button":
                            AlternativeActionButtonView(action: action, editMode: $editMode, needsUpdate: $needsUpdate)
                        case "knob":
                            ActionKnobView(action: action, editMode: $editMode, needsUpdate: $needsUpdate)
                        default:
                            Text(action.displayType)
                        }
                    }.draggable(action.uid)
                        .opacity(isDropTargeted ? 0.5 : 1)
                }
            }
            else {
                VStack {
                    
                }.frame(width:90, height:90).background( .ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 20)).opacity(editMode ?  1 : 0).animation(.easeInOut(duration: 0.25))
            }
        }         .dropDestination(for: String.self) { actionID, location in
            appState.connectedHost.swapActions(source: actionID[0], target: (page: 0, index: self.index)) {_ in
                appState.connectedHost.fetchActions()
                needsUpdate = true
            }
            return true
        } isTargeted: {x in
            isDropTargeted = x
            
            
        }
    }
}


struct ActionKnobView : View {
    @State var action: Action
    @EnvironmentObject var appState: AppState
    @State private var isLoading: Bool = false
    @State private var isError: Bool = false
    @Binding var editMode : Bool
    @State private var showAlert = false
    @Binding var needsUpdate : Bool
    var body : some View {
        Button(action: {
            
            if(editMode) {
                appState.showEditAction = true
                appState.currentlyEditingAction = action
                appState.showCreateAction = true
            }
            else {
                
                
                isLoading = true
                appState.connectedHost.runAction(actionID: action.uid) { result in
                    switch result {
                    case .success:
                        // Handle success
                        print("Action successful")
                    case .failure(let error):
                        isError = true
                        print("Error occurred: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isLoading = false
                        isError = false
                    }
                }
        }
        }) {
            ZStack {
                ZStack {
                    ZStack {
                        Circle()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color(hex:action.foregroundColor))
                        RoundedRectangle(cornerRadius:25.0 )
                            .frame(width: 2, height:20)
                            .foregroundColor(Color(hex:action.color))
                            .offset(x:0, y:-25.0)
                    }
                    Image(systemName: action.icon)
                        .resizable()
                        .frame(maxWidth:50, maxHeight:50)
                        .aspectRatio(contentMode: .fit)
                        .opacity(action.iconVisible ? 0.25 : 0)
                        .foregroundColor(.black)
                    Text(action.name)
                        .foregroundStyle(.black)
                        .font(.system(size: 12, weight:.bold))
                        .opacity(action.nameVisible ? 1 : 0)
                        .padding(.bottom, 5)
                    
                    // Additional Views
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    
                    if isError {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.red)
                    }
                }
                .frame(width: 90, height: 90)
                .background(Color(hex: action.color))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                if(editMode) {
                    Button {
                        showAlert = true
                    } label: {
                        Image(systemName: "x.circle.fill")
                    }
                    .frame(width:30, height:30)
                    .position(CGPoint(x: 5.0, y: 5.0))
                    .foregroundColor(.white)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Are you sure you would like to delete this action?"),
                    primaryButton: .destructive(Text("Delete")) {
                        appState.connectedHost.deleteAction(actionID: action.uid) {_ in
                            needsUpdate = true
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}


struct AlternativeActionButtonView: View {
    @State var action: Action
    @EnvironmentObject var appState: AppState
    @State private var isLoading: Bool = false
    @State private var isError: Bool = false
    @Binding var editMode : Bool
    @State private var showAlert = false
    @Binding var needsUpdate : Bool
    
    var body: some View {
        Button(action: {

                if(editMode) {
                    appState.showEditAction = true
                    appState.currentlyEditingAction = action
                    appState.showCreateAction = true
                }
                else {
                    
                    
                    isLoading = true
                    appState.connectedHost.runAction(actionID: action.uid) { result in
                        switch result {
                        case .success:
                            // Handle success
                            print("Action successful")
                        case .failure(let error):
                            isError = true
                            print("Error occurred: \(error.localizedDescription)")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isLoading = false
                            isError = false
                        }
                    }
            }
        }) {
                ZStack {
                    ZStack {
                        Image(systemName: action.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(action.iconVisible ? 0.25 : 0)
                            .foregroundStyle(Color(hex: action.foregroundColor))
                        Text(action.name)
                            .opacity(action.nameVisible ? 1 : 0)
                            .foregroundStyle(Color(hex: action.textColor))
                        
                        // Additional Views
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        
                        if isError {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                        }
                    }
                    .frame(width: 90, height: 90)
                    .background(Color(hex: action.color))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    if(editMode) {
                        Button {
                            showAlert = true
                        } label: {
                            Image(systemName: "x.circle.fill")
                        }
                        .frame(width:30, height:30)
                        .position(CGPoint(x: 5.0, y: 5.0))
                            .foregroundColor(.white)
                    }
                }
                .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Are you sure you would like to delete this action?"),
                                    primaryButton: .destructive(Text("Delete")) {
                                        appState.connectedHost.deleteAction(actionID: action.uid) {_ in
                                            needsUpdate = true
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
            }
    }
}


#Preview {
    ActionSlot(action: nil, editMode: .constant(true), needsUpdate: .constant(false), index:0).environmentObject(AppState());
}
