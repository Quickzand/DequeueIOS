//
//  ActionSlot.swift
//  Dequeue
//
//  Created by Matthew Sand on 1/10/24.
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
    var pageNum : Int = 0
    @Binding var needsUpdate : Bool
    var size : Int = 1
    var isHidden : Bool = false
    @Binding var isResizeOccuring : Bool
    @Binding var resizingIndex : Int
    
    @State private var scaleFactor: CGFloat = 1.0
    
    @State var isDropTargeted : Bool = false
    var index : Int
    
    private let baseSize : CGFloat = 90
    
    
    
    
    @State private var originalHandlePosition: CGPoint = .zero
    
    
    @State var isCurrentResizePossible : Bool = true
    
    
    private var resizeHandle: some View {
        BottomRightCornerArc(cornerRadius: 20, thickness: 4) // Adjust cornerRadius and thickness as needed
            .foregroundColor(.white)
            .frame(width: 20, height: 20) // Adjust frame size as needed
            .offset(x: 0, y: 0) // Adjust to align with the corner
            .background(Rectangle().opacity(0.01))
            .scaleEffect(1/scaleFactor, anchor:.bottomTrailing)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        isResizeOccuring = true
                        resizingIndex = index
                        let translation = gesture.translation
                        var dragDistance = max(translation.width,translation.height,sqrt(translation.width * translation.width + translation.height * translation.height))
                        
                        dragDistance += (max(calculateScaleFactorWithPadding() - 1, 0) * baseSize)
                        print(dragDistance)
                        // Determine scale factor based on drag direction
                        if translation.width > 0 && translation.height > 0 {
                            // Dragging down to the right - increase scale
                            scaleFactor = max(round(dragDistance / baseSize), 1)
                            
                            isCurrentResizePossible = appState.connectedHost.host.actionPages[pageNum].checkIfResizePossible(actionID: action!.uid, desiredSize: Int(scaleFactor))
                        } else if translation.width < 0 && translation.height < 0 {
                            // Dragging up to the left - decrease scale
                            scaleFactor = max(round(dragDistance / baseSize), 1)
                        }
                        
                    }
                    .onEnded { _ in
                        
                        
                        isResizeOccuring = false
                        if !isCurrentResizePossible {
                            isCurrentResizePossible = true
                            scaleFactor = 1
                        }
                        else {
                            appState.connectedHost.resizeAction(actionID: action!.uid, newSize: Int(scaleFactor), pageNum: pageNum) {result in
                                switch result {
                                case .success:
                                    // Handle success
                                    print("Action resize successful")
                                    needsUpdate = true
                                case .failure(let error):
                                    print("Error occurred: \(error.localizedDescription)")
                                }
                                
                            }
                        }
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
                            AlternativeActionButtonView(action: action, editMode: $editMode, scaleFactor: scaleFactor, needsUpdate: $needsUpdate)
                        case "knob":
                            ActionKnobView(action: action, editMode: $editMode,scaleFactor: scaleFactor, needsUpdate: $needsUpdate)
                        case "toggle":
                            ActionToggleView(action: action, editMode: $editMode,scaleFactor: scaleFactor, needsUpdate: $needsUpdate)
                        default:
                            Text(action.displayType)
                        }
                    }
                    
                } else {
                    ZStack (alignment:.center){
                        VStack {
                            
                        }.frame(width:baseSize, height:baseSize).background( .ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 20))
                        switch action.displayType {
                        case "button":
                            AlternativeActionButtonView(action: action, editMode: $editMode, scaleFactor: scaleFactor, needsUpdate: $needsUpdate)
                        case "knob":
                            ActionKnobView(action: action, editMode: $editMode, scaleFactor: scaleFactor, needsUpdate: $needsUpdate)
                        case "toggle":
                            ActionToggleView(action: action, editMode: $editMode,scaleFactor: scaleFactor, needsUpdate: $needsUpdate)
                        default:
                            Text(action.displayType)
                        }
                        
                    }.draggable(action.uid)
                        .overlay(
                            editMode ? resizeHandle : nil,
                            alignment: .bottomTrailing
                        )
                        .tint(isCurrentResizePossible ? .none : .red)
                        .opacity(isCurrentResizePossible ? 1 : 0.25)
                }
            }
            else {
                VStack {
                    
                }.frame(width:baseSize, height:baseSize).background( .ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 20)).opacity(editMode && !isResizeOccuring ?  1 : 0).animation(.easeInOut(duration: 0.25))
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
        .rotationEffect(appState.getCorrectedRotationAngle())
        .frame(width:baseSize, height:baseSize)
        .opacity(false && resizingIndex != index ? 0 : 1)
        .onAppear {
            scaleFactor = max(CGFloat(size),1)
            if isHidden {
                scaleFactor = 0
            }
        }
        .scaleEffect(calculateScaleFactorWithPadding(), anchor: .topLeading)
        
    }
    
    
    func calculateScaleFactorWithPadding() -> CGFloat {
        if scaleFactor <= 1 {
            return scaleFactor
        }
        return scaleFactor + (5 / baseSize * scaleFactor)
    }
}


#Preview {
    ActionSlot(action: Action(displayType: "knob"), editMode: .constant(true), needsUpdate: .constant(false), size: 1, isResizeOccuring: .constant(false), resizingIndex: .constant(0), index:0).environmentObject(AppState());
}
