//
//  ActionButtonView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/27/23.
//

import SwiftUI
#if canImport(MobileCoreServices)
import MobileCoreServices
#endif

#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif




struct ActionCompletionSuccessAnimationProperties {
    var yTranslatiion  = 20.0
    var opacity  = 0.0
}

struct ActionCompletionBlurAnimationProperties {
    var radius = 0.0
}


struct ActionSwapData : Transferable, Codable {
    var col: Int
    var row: Int
    var pageNum: Int
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}



struct ActionButtonView : View {
    @State var action : Action?
    @EnvironmentObject var appState: AppState
    @Binding var editMode : Bool
    @State private var showAlert = false
    @State private var startTrim: CGFloat = 0.0
    @State private var endTrim: CGFloat = 0.0
    var col : Int
    var row : Int
    var pageNum : Int
    
    @State private var isLoading : Bool = false
    @State private var actionCompleted: Bool = false
    
    @State private var successfulCompletionCount = 0
    @State private var completionCount = 0
    @State private var errorCompletionCount = 0
    
    @State private var isError = false
    
    @State private var isBeingTapped = false
    
    @State private var isDropTargeted = false
    
    @Binding var isDragAndDropOccuring : Bool
    
    let imageSize = 100.0
    
    let completionAnimationDuration = 1.2
    
    @State private var isDragedOver : Bool = false
    @Binding var needsUpdate : Bool
    

    let timer = Timer.publish(every: 0.02
                              , on: .main, in: .common).autoconnect()


    var body: some View {

                Button(action: {
                    if let actionID = action?.uid {
                        if editMode {
                            appState.showEditAction = true
                            appState.currentlyEditingAction = action!
                            appState.showCreateAction = true
                        }
                        else {
                            isLoading = true
                            appState.connectedHost.runAction(actionID: actionID) {result in
                                
                                actionCompleted = true
                                completionCount += 1
                                let generator = UINotificationFeedbackGenerator()
                                switch result {
                                case .success:
                                    generator.notificationOccurred(.success)
                                    successfulCompletionCount += 1
                                
                                    
                                case .failure(let error):
                                    generator.notificationOccurred(.error)
                                    isError = true
                                    errorCompletionCount += 1
                                    print("Error occurred: \(error.localizedDescription)")
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    isLoading = false
                                    actionCompleted = false
                                    isError = false
                                }
                                
                            }
                        }
                    }
                    
                }) {
                    
                    VStack {
                        ZStack {
                            
                                // Custom Loading Indicator
                                RoundedRectangle(cornerRadius: 20)
//                                    .trim(from: startTrim, to: endTrim)
                                .fill(isError ? Color.red : Color("AccentColor")) // Adjust the lineWidth as needed
                                    .frame(width: 90, height: 90) // Adjust the size as needed
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .rotationEffect(.degrees(-90))
                                    .opacity(isLoading ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.5))
                            
                            
                            RoundedRectangle(cornerRadius:25.0, style:.continuous)
                                .foregroundStyle(.ultraThinMaterial)
                                .frame(width:imageSize, height:imageSize)
                                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 25, style: .continuous))
                            
                            Image(systemName: action?.icon ?? "bolt.fill")
                                .font(.system(size:40))
                                .frame(width:imageSize, height:imageSize)
                                
                                
                                
                                .keyframeAnimator(initialValue: ActionCompletionBlurAnimationProperties(), trigger: completionCount)  {
                                    content, value in
                                    content
                                        .blur(radius: value.radius)
                                } keyframes: {frames in
                                    KeyframeTrack(\.radius) {
                                        SpringKeyframe(20.0, duration: completionAnimationDuration * 0.2)
                                        LinearKeyframe(21.0, duration: completionAnimationDuration * 0.5)
                                        LinearKeyframe(0.0, duration: completionAnimationDuration * 0.4)
                                    }
                                }
                                .overlay(ActionButtonProgressView(size: imageSize, isShown: $isLoading, isError: $isError))
                                
                            
                                
                            
                            ActionSuccessButtonCompletionIcon(completionAnimationDuration: completionAnimationDuration, successfulCompletionCount: $successfulCompletionCount)
                            ActionErrorButtonCompletionIcon(completionAnimationDuration: completionAnimationDuration, errorCompletionCount: $errorCompletionCount)

                        }
                        .padding(.horizontal,10)
                        if let action = action {
                            Text(action.name)
                                .font(.subheadline)
                                .opacity(action.nameVisible ? 1 : 0)
                        }
                        else {
                            Text("Nothing")
                                .font(.subheadline)
                        }
                    }
                    .padding(.vertical,appState.isLandscape() ? 5 : 10)
                    .foregroundColor(Color(hex:action?.color ?? "#FFFFFF"))
                }
                .scaleEffect(isBeingTapped ? 0.1 : 1)
                .rotationEffect(appState.getCorrectedRotationAngle())
                .opacity((action != nil) ? 1 : 0)
                .contentShape(.dragPreview, RoundedRectangle(cornerRadius: 25, style: .continuous))
                
                
                
                .overlay( ZStack {
                    if(editMode) {
                        VStack {
                            HStack {
                                Button(action: {
                                    showAlert = true
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .position(CGPoint(x: 20.0, y: 20.0))
                                        .font(.system(size: 25))
                                        .foregroundColor(.secondary)
                                    
                                }
                                .frame(width:40, height:40)
                                .opacity((self.action != nil) ? 1 : 0)
                                Spacer()
                            }
                            Spacer()
                        }
                        
                    }
                    if(editMode && self.action == nil)
                    {
                        RoundedRectangle(cornerRadius:25).fill(.thinMaterial)
                    }
                    if(isDropTargeted) {
                        RoundedRectangle(cornerRadius:25).fill(.ultraThinMaterial)
                    }
                })
                .dropDestination(for: String.self) { actionID, location in
                    print(actionID[0], " to: ", self.row, self.col)
                    appState.connectedHost.swapActions(source: actionID[0], target: (page: self.pageNum, row: self.row-1, col: self.col-1)) {_ in 
                        needsUpdate = true
                    }
                    return true
                } isTargeted: {
                    isDropTargeted = $0
                }
        
                
        
                
      
                
                
                .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Are you sure you would like to delete this action?"),
                                    primaryButton: .destructive(Text("Delete")) {
                                        appState.connectedHost.deleteAction(actionID: action?.uid ?? "") {_ in 
                                            needsUpdate = true
                                        }
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
        
        
            }
}


struct ActionButtonProgressView : View {
    @State var rotation = 0.0
    var size : Double
    @Binding var isShown: Bool
    @Binding var isError : Bool
    var lineWidth: CGFloat {
            isShown ? 2 : 0
        }
    var body : some View {
        RoundedRectangle(cornerRadius:25, style:.continuous).fill(isError ? Color.red : Color("AccentColor"))
            .scaleEffect(x:3, y:0.9)
            .rotationEffect(.degrees(rotation))
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false))
            .mask(RoundedRectangle(cornerRadius: 25)
                .stroke(lineWidth: isShown ? 2 : 0 )
                .animation(.easeInOut(duration: 0.3))
                .frame(width:size, height:size))
            .onAppear{
                self.rotation = 359.9
            }
            .opacity(0.6)
    }
}

struct ActionSuccessButtonCompletionIcon : View {
    var completionAnimationDuration : Double
    @Binding var successfulCompletionCount : Int
    
    var body : some View {
        //                            Success!
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 40, weight: .bold))
                                            .foregroundColor(Color.white)
                                            .keyframeAnimator(initialValue: ActionCompletionSuccessAnimationProperties(),
                                                trigger: successfulCompletionCount) {
                                                content, value in
                                                content
                                                    .offset(y: value.yTranslatiion)
                                                    .opacity(value.opacity)
                                            } keyframes: {frames in
                                                KeyframeTrack(\.yTranslatiion) {
                                                    SpringKeyframe(-10.0, duration: completionAnimationDuration * 0.2)
                                                    LinearKeyframe(0.0, duration: completionAnimationDuration * 0.6)
                                                    SpringKeyframe(-40.0, duration: completionAnimationDuration * 0.2)
                                                }
                                                
                                                KeyframeTrack(\.opacity) {
                                                    SpringKeyframe(1.0, duration: completionAnimationDuration * 0.2)
                                                    LinearKeyframe(1.0, duration: completionAnimationDuration * 0.6)
                                                    SpringKeyframe(0, duration: completionAnimationDuration * 0.2)
                                                    SpringKeyframe(-1, duration: completionAnimationDuration * 0.1)
                                                }
                                            }
    }
}




struct ActionErrorButtonCompletionIcon : View {
    var completionAnimationDuration : Double
    @Binding var errorCompletionCount : Int
    
    var body : some View {
        //                            Success!
                                        Image(systemName: "xmark")
                                            .font(.system(size: 40, weight: .bold))
                                            .foregroundColor(Color.white)
                                            .keyframeAnimator(initialValue: ActionCompletionSuccessAnimationProperties(),
                                                trigger: errorCompletionCount) {
                                                content, value in
                                                content
                                                    .offset(y: value.yTranslatiion)
                                                    .opacity(value.opacity)
                                            } keyframes: {frames in
                                                KeyframeTrack(\.yTranslatiion) {
                                                    SpringKeyframe(-10.0, duration: completionAnimationDuration * 0.2)
                                                    LinearKeyframe(0.0, duration: completionAnimationDuration * 0.6)
                                                    SpringKeyframe(-40.0, duration: completionAnimationDuration * 0.2)
                                                }
                                                
                                                KeyframeTrack(\.opacity) {
                                                    SpringKeyframe(1.0, duration: completionAnimationDuration * 0.2)
                                                    LinearKeyframe(1.0, duration: completionAnimationDuration * 0.6)
                                                    SpringKeyframe(0, duration: completionAnimationDuration * 0.2)
                                                    SpringKeyframe(-1, duration: completionAnimationDuration * 0.1)
                                                }
                                            }
    }
}








struct ActionButtonPreviewa_Previews: PreviewProvider {
    static var previews: some View {
        
        HomeView().environmentObject({
            () -> AppState in
            let envObject = AppState()
            var testActionPage = ActionPage()
            testActionPage.actions[0][0] = Action()
            envObject.connectedHost =  HostViewModel(host:Host(name: "MatbbokPro", ip: "Test", code: "1122", actionPages: []))
            return envObject
        }())
    }
}

    
    
    
