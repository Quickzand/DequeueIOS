//
//  AlternativeActionButtonView.swift
//  Dequeue
//
//  Created by Matthew Sand on 12/20/23.
//

import SwiftUI







struct AlternativeActionButtonView: View {
    @State var action: Action
    @EnvironmentObject var appState: AppState
    @State private var isLoading: Bool = false
    @State private var isError: Bool = false
    @Binding var editMode : Bool
    @State private var showAlert = false
    var scaleFactor : CGFloat
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
                            .opacity(action.iconVisible ? action.iconOpacity : 0)
                            .foregroundStyle(Color(hex: action.foregroundColor))
                        VStack {
                            if action.iconVisible {
                                Spacer()
                            }
                            Text(action.name)
                                .opacity(action.nameVisible ? action.textOpacity : 0)
                                .foregroundStyle(Color(hex: action.textColor))
                                .font(.system(size: 10, weight: .bold))
                                .padding(.all, 5)
                        }
                        
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
                    .background(Color(hex: action.color).opacity(action.backgroundOpacity))
                    .onAppear {
                        print(action.backgroundOpacity)
                    }
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
                            .scaleEffect( 1 / scaleFactor, anchor: .topLeading )
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
    ActionSlot(action: Action(displayType: "button", text: "TEST"), editMode: .constant(false), needsUpdate: .constant(false), isResizeOccuring: .constant(false), resizingIndex: .constant(0), index:0).environmentObject(AppState());
}
