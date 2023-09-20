//
//  ToolbarView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/9/23.
//

import SwiftUI

struct ToolbarView: View {
    @EnvironmentObject var appState : AppState
    
    var body: some View {
            HStack (spacing: 10) {
                Button(action: {
                    appState.showSettings = true
                }) {
                    Image(systemName: "gear")
                        .padding(.all, 15)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                        .font(.system(size:25, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
                Spacer()
      
                Button(action: {}) {
                    Image(systemName: "pencil")
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
                        .padding(.all, 15)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                        .font(.system(size:30, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }
            }
    }
}

struct ToolbarView_Previews: PreviewProvider {
    static var previews: some View {
        ToolbarView().environmentObject(AppState())
    }
}
