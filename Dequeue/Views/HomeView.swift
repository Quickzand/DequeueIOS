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
    
    var body: some View {
        if var host = appState.connectedHost {
            VStack {
                ToolbarView(editMode: $editMode)
                    .navigationDestination(isPresented: $appState.showSettings) {
                        SettingsView()
                            .navigationTitle("Settings")
                    }
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
                        ForEach(cachedActionPages.indices, id: \.self) { index in
                            ActionPageView(pageData: $cachedActionPages[index], editMode: $editMode, pageNum: index)
                        }
                        ActionPageView(pageData: $testingPageData, editMode: $editMode, pageNum: 0)
                    }.tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(maxHeight:.infinity)
                }
                .background(appState.showHomeScreenBackground ? BackgroundView() : nil)
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                    host.fetchActions(completion: {actionPages in
                        cachedActionPages = actionPages
                        host.actionPages = actionPages
                        

                    })
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
        }
    }
}


struct ActionPageView : View {
    @Binding var pageData : ActionPage
    @Binding var editMode : Bool
var RowCount : Int = 4
    var ColCount : Int = 3
    var pageNum : Int
    
    var body : some View {
        VStack {
            Grid {
                ForEach((1...RowCount), id: \.self) {rowNum in
                    GridRow {
                        ForEach((1...ColCount), id: \.self) {colNum in
                            ActionButtonView(action:pageData.actions[rowNum - 1][colNum - 1], editMode:$editMode, pageData: $pageData, col: colNum, row:rowNum
                            , pageNum: pageNum)
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
            envObject.connectedHost =  Host(name: "MatbbokPro", ip: "Test", code: "1122")
            return envObject
        }())
    }
}
