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
        VStack {
            HStack {
                Button(action: {
                    appState.showSettings = true
                    print("SHOW IT BABY OH YEAH")
                }) {
                    Image(systemName: "gear")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                        .font(.system(size:30, weight: .bold))
                        .foregroundColor(.white)
                }
      
                Button(action: {}) {
                    Image(systemName: "pencil")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                        .font(.system(size:30, weight: .bold))
                        .foregroundColor(.white)
                }
                Button(action: {}) {
                    Image(systemName: "plus")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                        .font(.system(size:30, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            Spacer()
        }.background(BackgroundView().allowsHitTesting(false).blur(radius: 15))
    }
}

//struct ToolbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ToolbarView()
//    }
//}
