//
//  TestView.swift
//  Dequeue
//
//  Created by Matthew Sand on 1/2/24.
//

import SwiftUI

struct TestView: View {
    @State private var showSheet = false
    
    var body: some View {
        Button("Show Sheet") {
            showSheet = true
        }
        .sheet(isPresented: .constant(true)) {
            Text("Hello from the SwiftUI sheet!")
                .presentationDetents([
                    .fraction(0.2),
                    .medium,
                    .large
                    
                ])
                .interactiveDismissDisabled(true)
        }
    }
}

#Preview {
    TestView()
}
