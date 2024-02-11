//
//  ActionPage.swift
//  Dequeue
//
//  Created by Matthew Sand on 1/14/24.
//

import Foundation


struct ActionPage : Hashable, Encodable, Decodable, Equatable  {
    static var maxColCount = 4
    static var maxRowCount = 6
    var actions: [String?]
    init() {
        actions = Array(repeating: nil, count: Self.maxColCount * Self.maxRowCount)
    }
    
    init(actions: [String?]) {
        self.actions = actions
    }
    
    func findPositionOfAction(actionID: String) -> Int? {
            return actions.firstIndex(of: actionID)
        }
    
    func checkIfResizePossible(actionID: String, desiredSize: Int) -> Bool {
        guard let actionIndex = findPositionOfAction(actionID: actionID) else {
            return false
        }

        // Calculate row and column position
        let rowPos = actionIndex / ActionPage.maxColCount
        let colPos = actionIndex % ActionPage.maxColCount

        // Check if it fits in the grid
        if rowPos + desiredSize > ActionPage.maxRowCount || colPos + desiredSize > ActionPage.maxColCount {
            return false
        }
        
        // Check for overlaps
        for row in rowPos..<(rowPos + desiredSize) {
            for col in colPos..<(colPos + desiredSize) {
                let index = row * ActionPage.maxColCount + col
                if index < actions.count, actions[index] != nil, actions[index] != actionID {
                    return false
                }
            }
        }
        
        return true
    }
}
