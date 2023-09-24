//
//  HostController.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/11/23.
//

import Foundation
import SwiftUI


struct Action : Hashable, Encodable, Decodable, Equatable {
    var icon : String = ""
    var name : String = ""
    var type : String = ""
    var key : String = ""
    var color : String = "#FFFFFF"
    var modifiers : [String: Bool] = [
        "Shift": false,
        "Control": false,
        "Option": false,
        "Command": false
    ]
    var uid: String = UUID().uuidString
    var page : Int?
}


struct ActionPage : Hashable, Encodable, Decodable, Equatable  {
    static var rowCount = 5;
    static var colCount = 3;
    var actions: [[Action?]]

    init() {
        actions = Array(repeating: Array(repeating: nil, count: Self.colCount), count: Self.rowCount)
    }
}


struct Host : Hashable, Encodable, Decodable {
    var name: String
    var ip: String
    var code: String
    
    var actionPages : [ActionPage] = []
    
    
    func sanitizedName() -> String {
        var tempName = name
        
        // Remove .local from the name
        if tempName.hasSuffix(".local") {
            tempName = String(tempName.dropLast(".local".count))
        }
        
        // Capitalize the first character
        tempName = tempName.prefix(1).capitalized + tempName.dropFirst()
        
        return tempName
    }

        mutating func fetchActions(completion: @escaping ([ActionPage]) -> Void) {
            print("++ FETCHING ACTIONS")
            // Construct the full URL
            guard let url = URL(string: "http://\(self.ip):\(portUsed)/getActions") else {
                print("Invalid URL for getting actions")
                completion([])
                return
            }

            // Create a URLRequest object
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            // Set the code in the header
            request.setValue(self.code, forHTTPHeaderField: "code")

            // Create a URLSession task
            let task = URLSession.shared.dataTask(with: request) { [code = self.code] data, response, error in
                    // Dispatch the completion handler to the main thread
                    DispatchQueue.main.async {
                        if let error = error {
                            print("Error sending request for code \(code): \(error.localizedDescription)")
                            completion([])
                            return
                        }

                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                            print("HTTP Error: \(httpResponse.statusCode) for code \(code)")
                            completion([])
                            return
                        }

                        // Attempt to decode the data into an array of Actions
                        if let data = data {
                            do {
                                let decoder = JSONDecoder()
                                let receivedActions = try decoder.decode([ActionPage].self, from: data)
                                print("Successfully retreived actions")
                                completion(receivedActions)
                                
                            } catch {
                                print("Error decoding Actions: \(error)")
                                completion([])
                            }
                        } else {
                            completion([])
                        }
                    }
                }

                // Start the task
                task.resume()
            }
    
    
    mutating func createAction(action: inout Action, page : Int) {
            guard let url = URL(string: "http://\(self.ip):\(portUsed)/createAction") else {
                print("Invalid URL for creating action")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(self.code, forHTTPHeaderField: "code")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // Convert the action to JSON data
            do {
                let encoder = JSONEncoder()
                action.page = page
                let jsonData = try encoder.encode(action)
                print("THE ENCODED NEW JSON IS \(jsonData)")
                request.httpBody = jsonData
            } catch {
                print("Failed to encode action: \(error)")
                return
            }

            let task = URLSession.shared.dataTask(with: request) { [code = self.code] data, response, error in
                if let error = error {
                    print("Error sending request for code \(code): \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("HTTP Error: \(httpResponse.statusCode) for code \(code)")
                    return
                }

                // Handle successful response if needed. For instance, update actions list or handle returned data.
            }

            task.resume()
        }
    
    
    mutating func runAction(actionID: String) {
        guard let url = URL(string: "http://\(self.ip):\(portUsed)/runAction") else {
            print("Invalid URL for creating action")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(self.code, forHTTPHeaderField: "code")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Convert the actionID to a JSON object
            let jsonBody = ["actionID": actionID]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
            } catch {
                print("Failed to serialize actionID to JSON: \(error)")
                return
            }
        
        
        let task = URLSession.shared.dataTask(with: request) { [code = self.code] data, response, error in
            if let error = error {
                print("Error sending request for code \(code): \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode) for code \(code)")
                return
            }

            // Handle successful response if needed. For instance, update actions list or handle returned data.
        }

        task.resume()
        
        
        
    }
    
    
    mutating func deleteAction(actionID: String) {
        guard let url = URL(string: "http://\(self.ip):\(portUsed)/deleteAction") else {
            print("Invalid URL for deleting action")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(self.code, forHTTPHeaderField: "code")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Convert the actionID to a JSON object
            let jsonBody = ["actionID": actionID]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
            } catch {
                print("Failed to serialize actionID to JSON: \(error)")
                return
            }
        
        
        let task = URLSession.shared.dataTask(with: request) { [code = self.code] data, response, error in
            if let error = error {
                print("Error sending request for code \(code): \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode) for code \(code)")
                return
            }

            // Handle successful response if needed. For instance, update actions list or handle returned data.
        }

        task.resume()
        
        
        
    }



}
