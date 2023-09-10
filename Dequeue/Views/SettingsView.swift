//
//  SettingsView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/9/23.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ScrollView([.vertical]) {
            SettingsItemView(title: "Connect To Host", iconName: "wifi")
        }
    }
}


struct SettingsItemView : View {
    var title : String
    var iconName : String
    var body : some View {
        Button(action: {}) {
            HStack {
                Image(systemName: iconName)
                Text(title)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .frame(maxWidth:.infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
            .padding()
        }
        .foregroundColor(.white)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

