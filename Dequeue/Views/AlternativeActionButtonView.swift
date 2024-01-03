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

struct ActionSlot : View{
    @State var action: Action?
    @EnvironmentObject var appState: AppState
    @Binding var editMode : Bool
    @Binding var needsUpdate : Bool
    @Binding var isResizeOccuring : Bool
    @Binding var resizingIndex : Int
    
    @State private var scaleFactor: CGFloat = 1.0
    
    @State var isDropTargeted : Bool = false
    var index : Int
    
    
    
    
    @State private var originalHandlePosition: CGPoint = .zero
    
    
    
    private var resizeHandle: some View {
           BottomRightCornerArc(cornerRadius: 20, thickness: 4) // Adjust cornerRadius and thickness as needed
               .foregroundColor(.white)
               .frame(width: 20, height: 20) // Adjust frame size as needed
               .offset(x: 0, y: 0) // Adjust to align with the corner
               .background(Rectangle().opacity(0.01))
               .gesture(
                         DragGesture(minimumDistance: 0)
                             .onChanged { gesture in
                                 isResizeOccuring = true
                                 resizingIndex = index
                                 let translation = gesture.translation
                                 let dragDistance = sqrt(translation.width * translation.width + translation.height * translation.height)

                                 // Determine scale factor based on drag direction
                                 if translation.width > 0 && translation.height > 0 {
                                     // Dragging down to the right - increase scale
                                     scaleFactor = 1.0 + dragDistance / 200
                                 } else if translation.width < 0 && translation.height < 0 {
                                     // Dragging up to the left - decrease scale
                                     scaleFactor = max(1.0 - dragDistance / 200, 0.5) // Minimum scale factor to prevent inversion
                                 }
                             }
                             .onEnded { _ in
                                 scaleFactor = 1.0 // Reset scale when drag ends
                                 isResizeOccuring = false
                             }
                     )
       }
    
    
    
    var body : some View {
        VStack {
            if let action = action {
                if !editMode {
                    VStack {
                        switch action.displayType {
                        case "button":
                            AlternativeActionButtonView(action: action, editMode: $editMode, needsUpdate: $needsUpdate)
                        case "knob":
                            ActionKnobView(action: action, editMode: $editMode, needsUpdate: $needsUpdate)
                        default:
                            Text(action.displayType)
                        }
                    }
                    
                } else {
                    ZStack (alignment:.center){
                        VStack {
                            
                        }.frame(width:90, height:90).background( .ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 20))
                        switch action.displayType {
                        case "button":
                            AlternativeActionButtonView(action: action, editMode: $editMode, needsUpdate: $needsUpdate)
                        case "knob":
                            ActionKnobView(action: action, editMode: $editMode, needsUpdate: $needsUpdate)
                        default:
                            Text(action.displayType)
                        }
                        
                    }.draggable(action.uid) 
                        .overlay(
                        editMode ? resizeHandle : nil,
                        alignment: .bottomTrailing
                    )
                }
            }
            else {
                VStack {
                    
                }.frame(width:90, height:90).background( .ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 20)).opacity(editMode ?  1 : 0).animation(.easeInOut(duration: 0.25))
            }
        }         .dropDestination(for: String.self) { actionID, location in
            appState.connectedHost.swapActions(source: actionID[0], target: (page: 0, index: self.index)) {_ in
                appState.connectedHost.fetchActions()
                needsUpdate = true
            }
            return true
        } isTargeted: {x in
            isDropTargeted = x
            
            
        }
        .frame(width:90, height:90)
        .scaleEffect(calculateScaleFactor(), anchor: .topLeading)
        .opacity(isResizeOccuring && resizingIndex != index ? 0 : 1)
        
    }
    
    
    func calculateScaleFactor() -> CGFloat {
        return max(floor(scaleFactor),1)
        
    }
}


struct ActionKnobView: View {
    @State var action: Action
    @EnvironmentObject var appState: AppState
    @State private var isLoading: Bool = false
    @State private var isError: Bool = false
    @Binding var editMode: Bool
    @State private var showAlert = false
    @Binding var needsUpdate: Bool
    @State private var rotation: Angle = .zero
       @State private var lastRotation: Angle = .zero
    @State private var lastSnapRotation: Angle = .zero
       private let snapDegrees: Double = 30
       private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @State private var initialAngle: Angle = .zero
    @State private var currentRotation: Angle = .zero
    
    @State private var startDragPoint: CGPoint? = nil
    @State private var initialRotation: Angle = .zero

    private func startRotation(gesture: DragGesture.Value) {
        let center = CGPoint(x: 45, y: 45)  // Assuming the knob's center
        let startVector = CGVector(dx: gesture.startLocation.x - center.x, dy: gesture.startLocation.y - center.y)
        initialAngle = Angle(radians: atan2(startVector.dy, startVector.dx))
    }

    // Function to handle the start of the drag
       private func handleDragStart(gesture: DragGesture.Value) {
           let center = CGPoint(x: 45, y: 45) // Assuming the knob's center
           let startVector = CGVector(dx: gesture.startLocation.x - center.x, dy: gesture.startLocation.y - center.y)
           initialRotation = Angle(radians: atan2(startVector.dy, startVector.dx)) - rotation
       }

       // Function to update rotation during the drag
    private func updateRotation(gesture: DragGesture.Value) {
        let dragVector = CGVector(dx: gesture.location.x - 45, dy: gesture.location.y - 45)
        let dragAngle = Angle(radians: atan2(dragVector.dy, dragVector.dx))
        let rawRotation = dragAngle - initialRotation

        // Snapping logic
        let snap = round(rawRotation.degrees / snapDegrees) * snapDegrees
        let snapRotation = Angle(degrees: snap)

        if snapRotation != lastSnapRotation {
            // Determine the direction of rotation
            let direction = snapRotation.degrees > lastSnapRotation.degrees ? "clockwise" : "counterclockwise"
            
            rotation = snapRotation
            lastSnapRotation = snapRotation

            onSnap(direction) // Call onSnap with the direction
        }
    }
    private func endRotation(gesture: DragGesture.Value) {
        currentRotation = rotation
    }

    
    var body: some View {
        ZStack {
            Button(action: {
                if(editMode) {
                    appState.showEditAction = true
                    appState.currentlyEditingAction = action
                    appState.showCreateAction = true
                }
            }) {
                knob
                    .rotationEffect(rotation)
                    .gesture(
                        DragGesture(minimumDistance:5)
                            .onChanged { gesture in
                                if gesture.translation.width == 0 && gesture.translation.height == 0 {
                                    startRotation(gesture: gesture)
                                }
                                updateRotation(gesture: gesture)
                            }
                            .onEnded { gesture in
                                endRotation(gesture: gesture)
                            }
                    )
                
            }.buttonStyle(PlainButtonStyle())
            if editMode {
                editButton
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

    private var knob: some View {
        ZStack {
            ZStack {
                Circle()
                    .frame(width: 90, height: 90)
                    .foregroundColor(Color(hex:action.color))
                RoundedRectangle(cornerRadius:25.0 )
                    .frame(width: 2, height:20)
                    .foregroundColor(.black)
                    .offset(x:0, y:-30.0)
            }
            Image(systemName: action.icon)
                .resizable()
                .frame(maxWidth:50, maxHeight:50)
                .aspectRatio(contentMode: .fit)
                .opacity(action.iconVisible ? 0.25 : 0)
                .foregroundColor(.black)
            Text(action.name)
                .foregroundColor(Color(hex:action.foregroundColor))
                .font(.system(size: 12, weight:.bold))
                .opacity(action.nameVisible ? 1 : 0)
                .padding(.bottom, 5)
            
            // Additional Views
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            
            if isError {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                
                    .frame(width: 90, height: 90)
                    .background(Color(hex: action.color))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }

    private var editButton: some View {
        Button {
            showAlert = true
        } label: {
            Image(systemName: "x.circle.fill")
        }
        .frame(width: 30, height: 30)
        .position(CGPoint(x: 5.0, y: 5.0))
        .foregroundColor(.white)
    }

    private func onSnap(_ direction: String) {
         // Function to run when the knob snaps to a position
         // Add your code here that should be executed on each snap
        appState.connectedHost.runAction(actionID: action.uid, direction: direction) { result in
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
    ActionSlot(action: Action(displayType: "button"), editMode: .constant(true), needsUpdate: .constant(false), isResizeOccuring: .constant(false), resizingIndex: .constant(0), index:0).environmentObject(AppState());
}
