//
//  HomeView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/9/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State var cachedActionPages : [ActionPage] = []
    @State var testingActionPage : ActionPage = ActionPage()
    
    @State var editMode : Bool = false
    
    @State var testingPageData = ActionPage()
    
    @State var needsUpdate = false
    
    var body: some View {
        if appState.connectedHost.isHostConnected {
            VStack {
                ToolbarView(editMode: $editMode)
                    .navigationDestination(isPresented: $appState.showCreateAction) {
                        if appState.showEditAction {
                            ActionCreationView(editingAction: appState.currentlyEditingAction,  isEditing: true)
                                .navigationTitle("Edit Action")
                        }
                        else {
                            ActionCreationView()
                                .navigationTitle("Create Action")
                        }
                    }
                    TabView {
                        if !needsUpdate {
                            ForEach(appState.connectedHost.host.actionPages, id: \.self) { actionPage in
                                ActionPageView(editMode: $editMode, pageNum: 0, actions: actionPage.actions, needsUpdate: $needsUpdate)
                            }
                        }
                        else {
                            Text("TEST").foregroundColor(.white).onAppear() {
                                appState.connectedHost.fetchActions() {_ in
                                needsUpdate = false
                            }
                                
                            }
                        }
                    }.tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(maxHeight:.infinity)
                }
                .background(appState.showHomeScreenBackground ? BackgroundView() : nil)
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
    
    @Binding var editMode : Bool
    var RowCount : Int = 4
    var ColCount : Int = 3
    var pageNum : Int
    @EnvironmentObject var appState : AppState
    @State var actions : [[Action?]]
    @Binding var needsUpdate : Bool

    var body : some View {
            VStack {
                Grid {
                    ForEach((1...RowCount), id: \.self) {rowNum in
                        GridRow {
                            ForEach((1...ColCount), id: \.self) {colNum in
                                ActionButtonView(action:actions[rowNum - 1][colNum - 1], editMode:$editMode, col: colNum, row:rowNum
                                                 , pageNum: pageNum, needsUpdate: $needsUpdate)
                            }
                        }
                    }
                }
                Spacer()
            }
        }
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
