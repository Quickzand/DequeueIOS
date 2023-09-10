//
//  HostScanning.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/6/23.
//

import Foundation
let portUsed : Int = 2326
func isPortOpen(host: String, port: Int, timeout: TimeInterval, completion: @escaping (Bool, String, String) -> Void) {
    // Create a URL from the host and port
    guard let url = URL(string: "http://\(host):\(port)/getDeviceInfo") else {
        print("++ Error: Invalid URL for \(host):\(port)")
        completion(false, "", host)
        return
    }
    
    // Set up a URLRequest with the desired timeout
    var request = URLRequest(url: url, timeoutInterval: timeout)
    request.httpMethod = "GET"  // Changed from "HEAD" to "GET" to retrieve the content
    
    // Start a URLSession task to try connecting to the port
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                print("++ Success: Connected to \(host) on port \(port) with response code \(httpResponse.statusCode)")
                
                // Print the content of the HTTP page
                if let data = data, let content = String(data: data, encoding: .utf8) {
                    print("++ Content of \(host):\(port):\n\(content)")
                    completion(true, content, host)
                }
                
                completion(false, "",host)
                
            } else {
                print("++ Failed: Received non-success status code \(httpResponse.statusCode) for \(host):\(port)")
                completion(false, "", host)
            }
        } else if let err = error {
            print("++ Error: \(err.localizedDescription) for \(host):\(port)")
            completion(false, "", host)
        } else {
            print("++ Unknown error for \(host):\(port)")
            completion(false, "", host)
        }
    }
    task.resume()
}


func checkForSavedHost(host: Host) -> Host? {
    // Retrieve the saved hosts using the getDevices() function
    guard let savedHosts = getDevices() else {
        print("No saved hosts found.")
        return nil
    }
    
    // Check if any of the saved hosts have the same IP as the given host
    for savedHost in savedHosts {
        if savedHost.ip == host.ip {
            print("Found saved host with IP: \(savedHost.ip) and code: \(savedHost.code)")
            return savedHost
        }
    }
    
    print("No saved host found with IP: \(host.ip)")
    return nil
}


func connectToHost(host: Host, appState: AppState, alreadySaved : Bool = false) {
    // Construct the full URL
    guard let url = URL(string: "http://\(host.ip):\(portUsed)/establishConnection") else {
        print("Invalid URL")
        return
    }
    
    // Create a URLRequest object
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    // Set the code in the header
    request.setValue(host.code, forHTTPHeaderField: "code") // Replace 'Your-Header-Field-Name' with the appropriate header field name
    
    // Create a URLSession task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error sending request: \(error.localizedDescription)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            if(alreadySaved) {
//                If it was saved and was incorrect remove it from saved list
                if var devices = getDevices(), let index = devices.firstIndex(where: { $0.ip == host.ip }) {
                    devices.remove(at: index)
                    saveDevices(devices)
                    print("-- Removed incorrect saved host!")
                }
            }
            print("Received HTTP \(httpResponse.statusCode)")
            return
        }
        
        // Handle the response data if needed
        if let data = data, let content = String(data: data, encoding: .utf8) {
            // Do something with the data
            print("Received data: \(content)")
        }
        
        if(!alreadySaved) {
            var devices = getDevices() ?? []
            devices.append(host)
            saveDevices(devices)
            print("++ Saved host data!")
        }
        
        DispatchQueue.main.async {

            appState.connectedHost = host
        }
    }
    

    
    // Start the task
    task.resume()
}


struct Host : Hashable, Encodable, Decodable {
    var name: String
    var ip: String
    var code: String
    
    
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


// Save the list of devices to UserDefaults
func saveDevices(_ devices: [Host]) {
    let data = try? JSONEncoder().encode(devices)
    UserDefaults.standard.set(data, forKey: "savedDevices")
}

// Retrieve the list of devices from UserDefaults
func getDevices() -> [Host]? {
    guard let data = UserDefaults.standard.data(forKey: "savedDevices") else { return nil }
    return try? JSONDecoder().decode([Host].self, from: data)
}


class NetworkScanner: ObservableObject {
    @Published var detectedHosts: [Host] = []
    
    func startScan() {
        self.detectedHosts = []
        isPortOpen(host: "192.168.0.2", port: portUsed, timeout: 1.5) {(isOpen: Bool, name: String, ip:String) in
            if(isOpen) {
                self.detectedHosts.append(Host(name: name, ip: ip,code: ""))
            }
        }
//        let port = 80
//        let subnetsToScan = ["192.168.0.", "192.168.1.", "192.168.2."] // Add more as needed
//        
//        let dispatchGroup = DispatchGroup()
//        
//        for subnet in subnetsToScan {
//            for i in 1...254 {
//                dispatchGroup.enter()
//                let ip = "\(subnet)\(i)"
//                
//                isPortOpen(host: ip, port: port, timeout: 2.0) { isOpen in
//                    if isOpen {
//                        DispatchQueue.main.async {
//                            self.detectedHosts.append(ip)
//                        }
//                    }
//                    dispatchGroup.leave()
//                }
//            }
//        }
    }
}
 
