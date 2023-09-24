//
//  AppState.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/24/23.
//

import Foundation


class AppState: ObservableObject {
    @Published var connectedHost : Host? = nil
    @Published var showSettings : Bool = false
    @Published var showHome : Bool = false
    @Published var showCreateAction : Bool = false
    @Published var isLandscape : Bool = false
    @Published var showHomeScreenBackground : Bool = true
    @Published var currentPage : Int = 0
    @Published var detectedHosts: [Host] = []
    
    func startScan() {
        
        if let connectedHost = connectedHost {
            return
        }
        
        self.detectedHosts = []
        
        let port = portUsed  // Use the same port you defined earlier
        let subnetsToScan = ["192.168.0.", "10.32.195.", "10.108.12."]  // Add more subnets as needed
        
        let dispatchGroup = DispatchGroup()
        
        isScanning = true  // Set the flag to true when scanning starts
        
        for subnet in subnetsToScan {
            for i in 1...254 {
                let ip = "\(subnet)\(i)"
                dispatchGroup.enter()
                
                isPortOpen(host: ip, port: port, timeout: 4.5) { (isOpen: Bool, name: String, ip: String) in
                    if isOpen && isScanning {  // Check the flag before attempting to connect
                        DispatchQueue.main.async {
                            self.detectedHosts.append(Host(name: name, ip: ip, code: ""))
                        }
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("Scanning finished!")
            // Do anything else you need after the scanning is completed
        }
    }
}
