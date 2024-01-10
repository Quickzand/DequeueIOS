//
//  ActionSlot.swift
//  Dequeue
//
//  Created by Matthew Sand on 1/10/24.
//

import SwiftUI

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
    
    private let baseSize : CGFloat = 90
    

    
    
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
                                     scaleFactor = 1.0 + dragDistance / 100
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
                            
                        }.frame(width:baseSize, height:baseSize).background( .ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 20))
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
                    
                }.frame(width:baseSize, height:baseSize).background( .ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 20)).opacity(editMode ?  1 : 0).animation(.easeInOut(duration: 0.25))
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
        .frame(width:baseSize, height:baseSize)
        .opacity(isResizeOccuring && resizingIndex != index ? 0 : 1)
        
    }
    
    
    func calculateScaleFactor() -> CGFloat {
        return max(floor(scaleFactor),1)
        
    }
}


#Preview {
    ActionSlot(action: Action(displayType: "knob"), editMode: .constant(true), needsUpdate: .constant(false), isResizeOccuring: .constant(false), resizingIndex: .constant(0), index:0).environmentObject(AppState());
}
