//
//  HostScanning.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/6/23.
//

import Foundation

var isScanning: Bool = false

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
                else {
                    completion(false, "",host)
                }
                
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
        isScanning = false
        DispatchQueue.main.async {

            appState.connectedHost = HostViewModel(host: host)
            appState.connectedHost.isHostConnected = true
            appState.showHome = true
        }
    }
    

    
    // Start the task
    task.resume()
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


// Get the host that was last connected to and then attempt to connect to it again
func connectToLastRememberedHost(appState: AppState) {
    // Retrieve the list of saved devices
    guard let savedDevices = getDevices(), !savedDevices.isEmpty else {
        print("No saved hosts found.")
        return
    }
    
    // Get the last remembered host (assuming it's the last one in the list)
    let lastRememberedHost = savedDevices.last!
    
    // Attempt to connect to the last remembered host
    connectToHost(host: lastRememberedHost, appState: appState, alreadySaved: true)
}



class NetworkScanner: ObservableObject {
    @Published var detectedHosts: [Host] = []
    
    
}

 
