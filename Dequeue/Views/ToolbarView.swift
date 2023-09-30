//
//  ToolbarView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/9/23.
//

import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var appState : AppState
    @Binding var editMode : Bool
    
    var buttonSize   = 30.0
    
    var body: some View {
            HStack (spacing: 10) {
                Button(action: {
                    appState.showSettings = true
                }) {
                    Image(systemName: "gear")
                        .frame(width:buttonSize, height:buttonSize)
                        .padding(.all, 15)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                        .font(.system(size:25, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                .navigationDestination(isPresented: $appState.showSettings) {
                    SettingsView()
                        .navigationTitle("Settings")
                }
                Spacer()
      
                Button(action: {editMode.toggle()}) {
                    Image(systemName: editMode ?  "minus.diamond" : "pencil")
                        .frame(width:buttonSize, height:buttonSize)
                        .padding(.all, 15)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                        .font(.system(size:30, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
                Button(action: {
                    appState.showCreateAction = true
                }) {
                    Image(systemName: "plus")
                        .frame(width:buttonSize, height:buttonSize)
                        .padding(.all, 15)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                        .font(.system(size:30, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
            }
    }
}
//
//struct ToolbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ToolbarView(editMode: $editMode).environmentObject(AppState())
//    }
//}
