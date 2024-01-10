//
//  HomeView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/9/23.
//

import SwiftUI



struct ActionAppearAnimationProperties {
    var scale = 0.0
}



struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State var cachedActionPages : [ActionPage] = []
    @State var testingActionPage : ActionPage = ActionPage()
    
    @State var editMode : Bool = false
    
    @State var testingPageData = ActionPage()
    
    @State var needsUpdate = false
    
    
    
    
    
    var layout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        if appState.connectedHost.isHostConnected {
            VStack {
                ToolbarView(editMode: $editMode)
                    .navigationDestination(isPresented: $appState.showCreateAction) {
                        if editMode {
                            ActionCreationView(editingAction: appState.currentlyEditingAction,  isEditing: true, needsUpdate: $needsUpdate)
                        }
                        else {
                            ActionCreationView(needsUpdate: $needsUpdate)
                        }
                    }
                    .navigationDestination(isPresented: $appState.showSettings) {
                        SettingsView()
                            .navigationTitle("Settings")
                    }
                    TabView {
                        if !needsUpdate {
                            ForEach(appState.connectedHost.host.actionPages, id: \.self) { actionPage in
                                ActionPageView(editMode: $editMode, pageNum: 0, actionsLayout: actionPage.actions, needsUpdate: $needsUpdate)
                            }
                        }
                        else {
                            Text("").foregroundColor(.white).onAppear() {
                                appState.connectedHost.fetchActions() {_ in
                                needsUpdate = false
                            }
                                
                            }
                        }
                    }.tabViewStyle(.page(indexDisplayMode: .automatic))
                    .frame(maxHeight:.infinity)
                }
            .background(BackgroundView())
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    
                    needsUpdate = true
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
        }
    }
}

struct ActionPageView : View {
    
    @Binding var editMode: Bool
    var pageNum: Int
    @EnvironmentObject var appState: AppState
    @State var actionsLayout: [String?]
    @Binding var needsUpdate: Bool
    @State private var isDragAndDropOccuring = false
    
    
    @State private var isResizeOccuring = false
    @State private var resizingIndex = 0
    
    @State private var buttonScale = 1.0
    @State private var buttonOpacity = 1.0
    var gridLayout = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var body: some View {
        VStack (alignment:.leading){
            // Assuming Grid and GridRow are correctly implemented custom views
            LazyVGrid(columns: gridLayout, spacing: 10) {
                ForEach(0..<actionsLayout.count, id: \.self) {index in
                    VStack {
                        ActionSlot(action: appState.connectedHost.host.actions[actionsLayout[index] ?? "NOT AN ACTION"], editMode: $editMode, needsUpdate: $needsUpdate, isResizeOccuring: $isResizeOccuring, resizingIndex: $resizingIndex, index: index)
                    }
                    //                            .animation(Animation.spring().delay(0.15 * Double(calcDistance(col: colNum, row: indexedAction.index, origin: (col:2, row:3))))) // Adjust the animation as needed
                    .opacity(buttonOpacity)
                    .scaleEffect(buttonScale)
                    .onAppear {
                        buttonScale = 1
                        buttonOpacity = 1
                    }
                    
                    
                }
            }
            
        }
    }
}


func calcDistance(col: Int, row: Int, origin: (col: Int, row: Int)) -> Int {
    let deltaX = col - origin.col
    let deltaY = row - origin.row
    let distance = sqrt(Double(deltaX * deltaX + deltaY * deltaY))
    return Int(distance)
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        
        HomeView().environmentObject({
            () -> AppState in
            let envObject = AppState()
            envObject.connectedHost =  HostViewModel(host: Host(name: "MatbbokPro", ip: "Test", code: "1122"))
            return envObject
        }())
    }
}
