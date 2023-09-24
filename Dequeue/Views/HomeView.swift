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
    
    var body: some View {
        if var host = appState.connectedHost {
            VStack {
                ToolbarView(editMode: $editMode)
                    .navigationDestination(isPresented: $appState.showSettings) {
                        SettingsView()
                            .navigationTitle("Settings")
                    }
                    .navigationDestination(isPresented: $appState.showCreateAction) {
                        ActionCreationView()
                            .navigationTitle("Create Action")
                    }
                    TabView {
                        ForEach(cachedActionPages.indices, id: \.self) { index in
                            ActionPageView(pageData: $cachedActionPages[index], editMode: $editMode)
                        }
                        ActionPageView(pageData: $testingActionPage, editMode: $editMode)
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
    
    var body : some View {
        VStack {
            Grid {
                ForEach((1...RowCount), id: \.self) {rowNum in
                    GridRow {
                        ForEach((1...ColCount), id: \.self) {colNum in
                            ActionButtonView(action:pageData.actions[rowNum - 1][colNum - 1], editMode:$editMode)
                        }
                    }
                }
            }
            Spacer()
        }
    }
}


struct ActionButtonView : View {
    var action : Action?
    @EnvironmentObject var appState: AppState
    @Binding var editMode : Bool
    @State private var showAlert = false
    
    var body: some View {

                Button(action: {
                    if let actionID = action?.uid {
                        appState.connectedHost?.runAction(actionID: actionID)
                    }
                }) {
                    VStack {
                        Image(systemName: action?.icon ?? "bolt.fill")
                            .font(.system(size:40))
                            .frame(width:100, height:100)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25.0))
                            .padding(.horizontal,10)
                        Text(action?.name ?? "Nothing")
                            .font(.subheadline)
                    }
                    .padding(.vertical,appState.isLandscape ? 5 : 10)
                    .foregroundColor(Color(hex:action?.color ?? "#FFFFFF"))
                    
                }
                .rotationEffect(Angle(degrees: appState.isLandscape ? 90 : 0))
                .opacity(action != nil ? 1 : 0)
                .overlay( ZStack {
                    if(editMode) {
                        Button(action: {
                            showAlert = true
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .position(CGPoint(x: 20.0, y: 20.0))
                                .font(.system(size: 25))
                                .foregroundColor(.secondary)
                        }
                    }})
                .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Are you sure you would like to delete this action?"),
                                    primaryButton: .destructive(Text("Delete")) {
                                        appState.connectedHost?.deleteAction(actionID: action?.uid ?? "")
                                    },
                                    secondaryButton: .cancel()
                                )
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
