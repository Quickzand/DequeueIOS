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
    var body: some View {
        if var host = appState.connectedHost {
            VStack {
                ToolbarView()
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
                            ActionPageView(pageData: $cachedActionPages[index])
                        }
                        Text("Page2")
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
    
var RowCount : Int = 4
    var ColCount : Int = 3
    
    var body : some View {
        VStack {
            Grid {
                ForEach((1...RowCount), id: \.self) {rowNum in
                    GridRow {
                        ForEach((1...ColCount), id: \.self) {colNum in
                            ActionButtonView(action:pageData.actions[rowNum - 1][colNum - 1])
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
    
    var body: some View {
        if let action = action {
            Button(action: {}) {
                VStack {
                    Image(systemName: action.icon)
                        .font(.system(size:40))
                        .frame(width:100, height:100)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25.0))
        
                    Text(action.name)
                        .font(.subheadline)
                }
                .foregroundColor(Color(hex:action.color))
                
            }
            .rotationEffect(Angle(degrees: appState.isLandscape ? 90 : 0))
        }
        else {
            Button(action: {}) {
                VStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size:40))
                        .frame(width:100, height:100)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25.0))
                        .padding(.all,10)
                    Text("Nothing here")
                        .font(.subheadline)
                }
                .foregroundColor(.white)
                
            }
            .rotationEffect(Angle(degrees: appState.isLandscape ? 90 : 0))

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
