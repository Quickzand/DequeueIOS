//
//  AlternativeActionButtonView.swift
//  Dequeue
//
//  Created by Matthew Sand on 12/20/23.
//

import SwiftUI




struct BottomRightCornerArc: Shape {
    var cornerRadius: CGFloat
    var thickness: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius)
        path.addArc(center: center,
                    radius: cornerRadius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        return path.strokedPath(StrokeStyle(lineWidth: thickness))
    }
}



struct AlternativeActionButtonView: View {
    @State var action: Action
    @EnvironmentObject var appState: AppState
    @State private var isLoading: Bool = false
    @State private var isError: Bool = false
    @Binding var editMode : Bool
    @State private var showAlert = false
    @Binding var needsUpdate : Bool
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        Button(action: {

                if(editMode) {
                    appState.showEditAction = true
                    appState.currentlyEditingAction = action
                    appState.showCreateAction = true
                }
                else {
                    
                    feedbackGenerator.impactOccurred()
                    isLoading = true
                    appState.connectedHost.runAction(actionID: action.uid) { result in
                        switch result {
                        case .success:
                            // Handle success
                            print("Action successful")
                        case .failure(let error):
                            isError = true
                            print("Error occurred: \(error.localizedDescription)")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isLoading = false
                            isError = false
                        }
                    }
            }
        }) {
                ZStack {
                    ZStack {
                        Image(systemName: action.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:60, height:60)
                            .opacity(action.iconVisible ? 0.25 : 0)
                            .foregroundStyle(Color(hex: action.foregroundColor))
                        Text(action.name)
                            .opacity(action.nameVisible ? 1 : 0)
                            .foregroundStyle(Color(hex: action.textColor))
                        
                        // Additional Views
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        }
                        
                        if isError {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                        }
                    }
                    .frame(width: 90, height: 90)
                    .background(Color(hex: action.color))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    if(editMode) {
                        Button {
                            showAlert = true
                        } label: {
                            Image(systemName: "x.circle.fill")
                        }
                        .frame(width:30, height:30)
                        .position(CGPoint(x: 5.0, y: 5.0))
                            .foregroundColor(.white)
                    }
                }
                .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Are you sure you would like to delete this action?"),
                                    primaryButton: .destructive(Text("Delete")) {
                                        appState.connectedHost.deleteAction(actionID: action.uid) {_ in
                                            needsUpdate = true
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
            }
    }
}


#Preview {
    ActionSlot(action: Action(displayType: "knob"), editMode: .constant(true), needsUpdate: .constant(false), isResizeOccuring: .constant(false), resizingIndex: .constant(0), index:0).environmentObject(AppState());
}
