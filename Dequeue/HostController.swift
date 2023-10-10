//
//  HostController.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/11/23.
//

import Foundation
import SwiftUI




struct Group : Hashable, Encodable, Decodable, Equatable {
    var uid : String = UUID().uuidString
    var name : String
}

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
    var nameVisible: Bool = true
    var siriShortcut : String = ""
    var text : String = ""
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
    var name: String = ""
    var ip: String = ""
    var code: String = ""
    
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
    
   

}


class HostViewModel: ObservableObject {
    @Published var host: Host
    
    init(host: Host) {
        self.host = host
    }
    
    var isHostConnected = false 
    
    func fetchActions(completion: (([ActionPage]) -> Void)? = nil) {
        print("++ FETCHING ACTIONS")
        guard let url = URL(string: "http://\(self.host.ip):\(portUsed)/getActions") else {
            print("Invalid URL for getting actions")
            completion?([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(self.host.code, forHTTPHeaderField: "code")

        let task = URLSession.shared.dataTask(with: request) { [weak self, code = self.host.code] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error sending request for code \(code): \(error.localizedDescription)")
                    completion?([])
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    print("HTTP Error: \(httpResponse.statusCode) for code \(code)")
                    completion?([])
                    return
                }

                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let receivedActions = try decoder.decode([ActionPage].self, from: data)
                        print("Successfully retrieved actions")
                        self?.host.actionPages = receivedActions  // Update the host's actions
                        completion?(receivedActions)
                    } catch {
                        print("Error decoding Actions: \(error)")
                        completion?([])
                    }
                } else {
                    completion?([])
                }
            }
        }

        task.resume()
    }

    
    func createAction(action: inout Action, page: Int, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = URL(string: "http://\(self.host.ip):\(portUsed)/createAction") else {
            print("Invalid URL for creating action")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(self.host.code, forHTTPHeaderField: "code")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        action.page = page
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(action)
            request.httpBody = jsonData
        } catch {
            print("Failed to encode action: \(error)")
            completion?(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [code = self.host.code] data, response, error in
            if let error = error {
                print("Error sending request for code \(code): \(error.localizedDescription)")
                completion?(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode) for code \(code)")
                completion?(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])))
                return
            }
            
            completion?(.success(()))
        }
        
        task.resume()
    }
    
    func deleteAction(actionID: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = URL(string: "http://\(self.host.ip):\(portUsed)/deleteAction") else {
            completion?(.failure(NSError(domain: "URLConstruction", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for deleting action"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(self.host.code, forHTTPHeaderField: "code")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert the actionID to a JSON object
        let jsonBody = ["actionID": actionID]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            completion?(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [code = self.host.code] data, response, error in
            if let error = error {
                completion?(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion?(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode) for code \(code)"])))
                return
            }

            completion?(.success(()))
        }

        task.resume()
    }


    
    func updateAction(action: Action, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = URL(string: "http://\(self.host.ip):\(portUsed)/updateAction") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(self.host.code, forHTTPHeaderField: "code")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(action)
            request.httpBody = jsonData
        } catch {
            completion?(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [code = self.host.code] data, response, error in
            if let error = error {
                completion?(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion?(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: nil)))
                return
            }
            
            completion?(.success(()))
        }
        
        task.resume()
    }
    
    
    func runAction(actionID: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = URL(string: "http://\(self.host.ip):\(portUsed)/runAction") else {
            completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(self.host.code, forHTTPHeaderField: "code")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody = ["actionID": actionID]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            completion?(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [code = self.host.code] data, response, error in
            if let error = error {
                completion?(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion?(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: nil)))
                return
            }

            completion?(.success(()))
        }

        task.resume()
    }

    func swapActions(source : String, target: (page: Int, row: Int, col: Int), completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = URL(string: "http://\(self.host.ip):\(portUsed)/swapAction") else {
            completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(self.host.code, forHTTPHeaderField: "code")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonBody: [String: Any] = [
            "source": source,
            "targetPage": target.page,
            "targetRow": target.row,
            "targetCol": target.col
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
        } catch {
            completion?(.failure(error))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [code = self.host.code] data, response, error in
            if let error = error {
                completion?(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion?(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: nil)))
                return
            }

            completion?(.success(()))
        }

        task.resume()
    }
    
    
    
    func getSiriShortcuts(completion: ((Result<Void, Error>, [String]) -> Void)? = nil) {
        print("++ FETCHING SIRI SHORTCUTS")
        guard let url = URL(string: "http://\(self.host.ip):\(portUsed)/getSiriShortcuts") else {
            completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])), [])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(self.host.code, forHTTPHeaderField: "code")

        let task = URLSession.shared.dataTask(with: request) { [code = self.host.code] data, response, error in
            if let error = error {
                completion?(.failure(error), [])
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                completion?(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: nil)), [])
                return
            }
            
            
            if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let receivedShortcuts = try decoder.decode([String].self, from: data)
                        print("Successfully retrieved siri shortcuts")
                        completion?(.success(()),receivedShortcuts)
                    } catch {
                        print("Error decoding Actions: \(error)")
                }
                
            }
        }
        task.resume()
    }

}
