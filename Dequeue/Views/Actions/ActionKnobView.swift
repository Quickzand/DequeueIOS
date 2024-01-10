//
//  ActionKnobView.swift
//  Dequeue
//
//  Created by Matthew Sand on 1/9/24.
//

import SwiftUI

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
    @State private var snapDegrees: Double = 30
       private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @State private var initialAngle: Angle = .zero
    @State private var currentRotation: Angle = .zero
    
    @State private var startDragPoint: CGPoint? = nil
    @State private var initialRotation: Angle = .zero

    private func startRotation(gesture: DragGesture.Value) {
        let center = CGPoint(x: 45, y: 45) // Assuming the knob's center
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
        let center = CGPoint(x: 45, y: 45) // Assuming the knob's center
        let dragVector = CGVector(dx: gesture.location.x - center.x, dy: gesture.location.y - center.y)
        let currentDragAngle = Angle(radians: atan2(dragVector.dy, dragVector.dx))

        // Check if the movement resembles a circular motion
        if isCircularMotion(gesture: gesture, center: center) {
            let deltaRotation = currentDragAngle - lastRotation
            var newRotation = rotation + deltaRotation

            // Normalize the new rotation angle
            newRotation = Angle(degrees: (newRotation.degrees).truncatingRemainder(dividingBy: 360))

            // Calculate the snap position
            let snap = round(newRotation.degrees / snapDegrees) * snapDegrees
            let snapRotation = Angle(degrees: snap)

            // Update the rotation if it's different from the last snap
            if snapRotation != lastSnapRotation {
                rotation = snapRotation
                lastSnapRotation = snapRotation
                lastRotation = currentDragAngle // Update lastRotation to the current drag angle

                let direction = (snap > lastRotation.degrees) ? "clockwise" : "counterclockwise"

                // Execute the snap action
                onSnap(direction)
            }
        }
    }


    private func isCircularMotion(gesture: DragGesture.Value, center: CGPoint) -> Bool {
        // Calculate the angle of the initial and current touch points relative to the center
        let initialVector = CGVector(dx: gesture.startLocation.x - center.x, dy: gesture.startLocation.y - center.y)
        let initialAngle = atan2(initialVector.dy, initialVector.dx)

        let currentVector = CGVector(dx: gesture.location.x - center.x, dy: gesture.location.y - center.y)
        let currentAngle = atan2(currentVector.dy, currentVector.dx)

        // Calculate the difference in angles
        var angleDifference = currentAngle - initialAngle

        // Adjust for angle wrapping
        if angleDifference > CGFloat.pi {
            angleDifference -= 2 * CGFloat.pi
        } else if angleDifference < -CGFloat.pi {
            angleDifference += 2 * CGFloat.pi
        }

        // Determine if the angle difference is consistent with a circular motion
        // This is a simplistic approach; you might need a more sophisticated method
        // to handle different use cases or more complex gestures.
        let isCircular = abs(angleDifference) > CGFloat.pi / 4 // Example threshold

        return isCircular
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
        }.onAppear {
            snapDegrees = (1-(action.knobSensitivity / 100)) * 180
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


#Preview {
    ActionSlot(action: Action(displayType: "knob", foregroundColor: "#FFFFFF"), editMode: .constant(false), needsUpdate: .constant(false), isResizeOccuring: .constant(false), resizingIndex: .constant(0), index:0).environmentObject(AppState());
}
