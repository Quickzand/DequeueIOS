//
//  HostScanning.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/6/23.
//

import Foundation
import Network


var isScanning: Bool = false

let portUsed : Int = 2326

struct DeviceInfoResponse: Decodable {
    let name: String
    let version: String
}


func isPortOpen(host: String, port: Int, timeout: TimeInterval, completion: @escaping (Bool, String, String, String) -> Void) {
    // Create a URL from the host and port
    guard let url = URL(string: "http://\(host):\(port)/getDeviceInfo") else {
        print("++ Error: Invalid URL for \(host):\(port)")
        completion(false, "", "", host)
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
                    
                    let decoder = JSONDecoder()
                    do {
                        var serverResponse = try decoder.decode(DeviceInfoResponse.self, from: data)
                        completion(true, serverResponse.name, serverResponse.version, host)
                    }
                    catch {
                        completion(false, "", "", host)
                    }
                    
                    
                    
                }
                else {
                    completion(false, "", "", host)
                }
                
            } else {
                print("++ Failed: Received non-success status code \(httpResponse.statusCode) for \(host):\(port)")
                completion(false, "", "", host)
            }
        } else if let err = error {
            //            print("++ Error: \(err.localizedDescription) for \(host):\(port)")
            completion(false, "", "", host)
        } else {
            print("++ Unknown error for \(host):\(port)")
            completion(false, "", "", host)
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
//func connectToLastRememberedHost(appState: AppState) {
//    // Retrieve the list of saved devices
//    guard let savedDevices = getDevices(), !savedDevices.isEmpty else {
//        print("No saved hosts found.")
//        return
//    }
//
//    // Get the last remembered host (assuming it's the last one in the list)
//    let lastRememberedHost = savedDevices.last!
//    print(savedDevices)
//}


class ServiceBrowser {
    private var browser: NWBrowser?
    private var appState : AppState
    
    init(appState: AppState) {
        let parameters = NWParameters()
        parameters.includePeerToPeer = true
        let browserDescriptor = NWBrowser.Descriptor.bonjourWithTXTRecord(type: "_http._tcp", domain: nil)
        self.browser = NWBrowser(for: browserDescriptor, using: parameters)
        self.appState = appState
    }
    
    func startBrowsing() {
        self.browser?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Browser ready")
            case .failed(let error):
                print("Browser failed with error: \(error)")
            default:
                break
            }
        }
        
        self.browser?.browseResultsChangedHandler = { [weak self] results, changes in
            for result in results {
                self?.attemptConnection(to: result.endpoint)
            }
        }
        
        self.browser?.start(queue: .main)
    }
    
    
    private func attemptConnection(to endpoint: NWEndpoint) {
        switch endpoint {
        case .service(let name, let type, let domain, _):
            print("Attempting to connect to service: \(name) of type \(type) in domain \(domain)")
            let connection = NWConnection(to: endpoint, using: .tcp)
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    if let endpoint = connection.currentPath?.remoteEndpoint {
                        print("Remote endpoint: \(endpoint)")
                        var ipAddressPort = "\(endpoint)"
                        let components = ipAddressPort.split(separator: ":")
                        if components.count == 2 {
                            let ip = String(components[0]).replacingOccurrences(of: "%en0", with: "")
                            let port = String(components[1])
                            self.getHostInfo(ip: ip, port: port, timeout: 5.0) {(isOpen: Bool, name: String, version: String, ip: String) in
                                
                                if isOpen {
                                    var host = Host(name: name, ip: "\(ip):\(port)", code: "")
                                    if let savedHost = checkForSavedHost(host: host) {
                                        self.connectToHost(host: savedHost, alreadySaved: true)
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.appState.detectedHosts.append(host)
                                    }
                                }
                            }
                        } else {
                            print("Invalid format")
                        }
                        
                        
                    }
                case .failed(let error):
                    print("Failed to connect to \(name) with error: \(error)")
                default:
                    break
                }
            }
            
            connection.start(queue: .main)
        default:
            print("Unsupported endpoint type")
        }
    }
    
    func stopBrowsing() {
        self.browser?.cancel()
    }
    
    // MARK: - All logic to connect to host
    
    func getHostInfo(ip: String, port: String, timeout: TimeInterval, completion: @escaping (Bool, String, String, String) -> Void) {
        // Create a URL from the host and port
        guard let url = URL(string: "http://\(ip):\(port)/getDeviceInfo") else {
            print("++ Error: Invalid URL for \(ip):\(port)")
            completion(false, "", "", ip)
            return
        }
        
        // Set up a URLRequest with the desired timeout
        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = "GET"  // Changed from "HEAD" to "GET" to retrieve the content
        // Start a URLSession task to try connecting to the port
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if 200...299 ~= httpResponse.statusCode {
                    print("++ Success: Connected to \(ip) on port \(port) with response code \(httpResponse.statusCode)")
                    
                    // Print the content of the HTTP page
                    if let data = data, let content = String(data: data, encoding: .utf8) {
                        print("++ Content of \(ip):\(port):\n\(content)")
                        
                        let decoder = JSONDecoder()
                        do {
                            let serverResponse = try decoder.decode(DeviceInfoResponse.self, from: data)
                            completion(true, serverResponse.name, serverResponse.version, ip)
                        }
                        catch {
                            completion(false, "", "", ip)
                        }
                        
                        
                        
                    }
                    else {
                        completion(false, "", "", ip)
                    }
                    
                } else {
                    print("++ Failed: Received non-success status code \(httpResponse.statusCode) for \(ip):\(port)")
                    completion(false, "", "", ip)
                }
            } else if let err = error {
                            print("++ Error: \(err.localizedDescription) for \(ip):\(port)")
                completion(false, "", "", ip)
            } else {
                print("++ Unknown error for \(ip):\(port)")
                completion(false, "", "", ip)
            }
        }
        task.resume()
    }
    
    
    
    func connectToHost(host: Host, alreadySaved: Bool = false, completion: ((Bool) -> Void)? = nil) {
        // Construct the full URL
        guard let url = URL(string: "http://\(host.ip)/establishConnection") else {
            print("Invalid URL")
            completion?(false) // Call completion with false if provided
            return
        }
        print(url)
        // Create a URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Set the code in the header
        request.setValue(host.code, forHTTPHeaderField: "code")
    
        // Create a URLSession task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending request: \(error.localizedDescription)")
                completion?(false) // Call completion with false if provided
                return
            }
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                if alreadySaved {
                    // If it was saved and was incorrect, remove it from the saved list
                    if var devices = getDevices(), let index = devices.firstIndex(where: { $0.ip == host.ip }) {
                        devices.remove(at: index)
                        saveDevices(devices)
                        print("-- Removed incorrect saved host!")
                    }
                }
                print("Received HTTP \(httpResponse.statusCode)")
                completion?(false) // Call completion with false if provided
                return
            }
            
            // Handle the response data if needed
            var isMac = false
            if let data = data, let content = String(data: data, encoding: .utf8) {
                print("Received data: \(content)")
                if content == "true" {
                    isMac = true
                }
            }
            
            if !alreadySaved {
                var devices = getDevices() ?? []
                devices.append(host)
                saveDevices(devices)
                print("++ Saved host data!")
            }
            self.stopBrowsing()
            DispatchQueue.main.async {
                var tempHost = host
                tempHost.isMac = isMac
                self.appState.connectedHost = HostViewModel(host: tempHost)
                self.appState.connectedHost.isHostConnected = true
                self.appState.showHome = true
                completion?(true) // Call completion with true if provided
            }
        }
        
        // Start the task
        task.resume()
    }
    
}


