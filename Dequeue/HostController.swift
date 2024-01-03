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
    var icon : String = "bolt.fill"
    var name : String = ""
    var type : String = ""
    var displayType : String = ""
    var key : String = ""
    var ccKey : String = ""
    var color : String = "#323232"
    var textColor : String = "#FFFFFF"
    var foregroundColor: String = "#FFFFFF"
    var modifiers : [String: Bool] = [
        "Shift": false,
        "Control": false,
        "Option": false,
        "Command": false,
        "Windows": false
    ]
    var ccModifiers : [String: Bool] = [
        "Shift": false,
        "Control": false,
        "Option": false,
        "Command": false,
        "Windows": false
    ]
    var uid: String = UUID().uuidString
    var page : Int?
    var nameVisible: Bool = true
    var iconVisible: Bool = true
    var siriShortcut : String = ""
    var ccSiriShortcut : String = ""
    var text : String = ""
    
    init(icon: String = "bolt.fill",
            name: String = "",
            type: String = "",
            displayType: String = "button",
            key: String = "",
         ccKey: String = "",
            color: String = "#323232",
            textColor: String = "#FFFFFF",
            foregroundColor: String = "#FFFFFF",
            modifiers: [String: Bool] = ["Shift": false, "Control": false, "Option": false, "Command": false, "Windows": false],
         ccModifiers: [String: Bool] = ["Shift": false, "Control": false, "Option": false, "Command": false, "Windows": false],
            uid: String = UUID().uuidString,
            page: Int? = nil,
            nameVisible: Bool = true,
            iconVisible: Bool = true,
            siriShortcut: String = "",
        ccSiriShortcut: String = "",
            text: String = "") {
           self.icon = icon
           self.name = name
           self.type = type
           self.displayType = displayType
           self.key = key
        self.ccKey = ccKey
           self.color = color
           self.textColor = textColor
           self.foregroundColor = foregroundColor
           self.modifiers = modifiers
           self.uid = uid
           self.page = page
           self.nameVisible = nameVisible
           self.iconVisible = iconVisible
           self.siriShortcut = siriShortcut
           self.text = text
        self.ccModifiers = ccModifiers
        self.ccSiriShortcut = ccSiriShortcut
       }

    
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            // Decoding each property with default value fallback
            icon = try container.decodeIfPresent(String.self, forKey: .icon) ?? "bolt.fill"
            name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
            type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
            displayType = try container.decodeIfPresent(String.self, forKey: .displayType) ?? "button"
            key = try container.decodeIfPresent(String.self, forKey: .key) ?? ""
        ccKey = try container.decodeIfPresent(String.self, forKey: .ccKey) ?? ""
            color = try container.decodeIfPresent(String.self, forKey: .color) ?? "#323232"
            textColor = try container.decodeIfPresent(String.self, forKey: .textColor) ?? "#FFFFFF"
            foregroundColor = try container.decodeIfPresent(String.self, forKey: .foregroundColor) ?? "#FFFFFF"
            modifiers = try container.decodeIfPresent([String: Bool].self, forKey: .modifiers) ?? [
                "Shift": false,
                "Control": false,
                "Option": false,
                "Command": false,
                "Windows": false
            ]
        ccModifiers = try container.decodeIfPresent([String: Bool].self, forKey: .ccModifiers) ?? [
            "Shift": false,
            "Control": false,
            "Option": false,
            "Command": false,
            "Windows": false
        ]
            uid = try container.decodeIfPresent(String.self, forKey: .uid) ?? UUID().uuidString
            page = try container.decodeIfPresent(Int.self, forKey: .page)
            nameVisible = try container.decodeIfPresent(Bool.self, forKey: .nameVisible) ?? true
            iconVisible = try container.decodeIfPresent(Bool.self, forKey: .iconVisible) ?? true
            siriShortcut = try container.decodeIfPresent(String.self, forKey: .siriShortcut) ?? ""
            text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
        }
    
    
}


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
}


struct FetchActionsResponse: Decodable {
    var layout: [ActionPage]
    let actions: [String : Action]
}

struct Host : Hashable, Encodable, Decodable {
    var name: String = ""
    var ip: String = ""
    var code: String = ""
    var isMac : Bool = false
    
    var actionPages : [ActionPage] = []
    var actions: [String: Action] = [:]
    
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
                        var serverResponse = try decoder.decode(FetchActionsResponse.self, from: data)
                        print(serverResponse.layout)
                        print("Successfully retrieved actions")
                        
                        // Resize each ActionPage to adhere to the max row and column count
                        serverResponse.layout = serverResponse.layout.map { page in
                            var updatedActions = page.actions
                            let requiredSize = ActionPage.maxColCount * ActionPage.maxRowCount
                            if updatedActions.count < requiredSize {
                                updatedActions += Array(repeating: nil, count: requiredSize - updatedActions.count)
                                
                            } else if updatedActions.count > requiredSize {
                                updatedActions = Array(updatedActions.prefix(requiredSize))
                            }
                            return ActionPage(actions: updatedActions)
                        }

                        self?.host.actionPages = serverResponse.layout  // Update the host's actionPages
                        self?.host.actions = serverResponse.actions    // Update the host's actions
                            
                        completion?(serverResponse.layout)
                    } catch {
                        print("Error decoding server response: \(error)")
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
    
    
    func runAction(actionID: String, direction: String = "clockwise", completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = URL(string: "http://\(self.host.ip):\(portUsed)/runAction") else {
            completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(self.host.code, forHTTPHeaderField: "code")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonBody = ["actionID": actionID, "direction": direction]
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

    func swapActions(source : String, target: (page: Int, index: Int), completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard let url = URL(string: "http://\(self.host.ip):\(portUsed)/swapActions") else {
            completion?(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(self.host.code, forHTTPHeaderField: "code")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let jsonBody: [String: Any] = [
            "source": source,
            "targetPage": 0,
            "targetIndex": target.index,
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
                print("HERE")
                print(httpResponse.statusCode)
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
