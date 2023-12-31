//
//  AppState.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/24/23.
//

import Foundation
import UIKit
import SwiftUI


class AppState: ObservableObject {
    enum DeviceOrientation {
        case vertical
        case right
        case left
        
        init(deviceOrientation: UIDeviceOrientation) {
                switch deviceOrientation {
                case .portrait, .portraitUpsideDown:
                    self = .vertical
                case .landscapeRight:
                    self = .right
                case .landscapeLeft:
                    self = .left
                default:
                    self = .vertical // Default to vertical if unknown orientation
                }
            }
    }
    
    
    func isLandscape() -> Bool {
        return (self.deviceOrientation != .vertical)
    }
    
    func getCorrectedRotationAngle() -> Angle {
        switch deviceOrientation {
        case .vertical:
            return Angle(degrees: 0)
        case .right:
            return Angle(degrees: -90)
        case .left:
            return Angle(degrees: 90)
        }
    }
    
    @Published var connectedHost : HostViewModel = HostViewModel(host: Host())
    @Published var showSettings : Bool = false
    @Published var showHome : Bool = false
    @Published var showCreateAction : Bool = false
    @Published var deviceOrientation : DeviceOrientation = .vertical
    @Published var currentPage : Int = 0
    @Published var detectedHosts: [Host] = []
    @Published var showEditAction : Bool = false
    @Published var currentlyEditingAction : Action = Action()
    @Published var settings : Settings = Settings()
    @Published var needsUpdate : Bool = false
    
    
    func getSavedSettings() {
        self.settings = (try? JSONDecoder().decode(Settings.self, from: UserDefaults.standard.data(forKey: "settings") ?? Data())) ?? Settings()
    }
    func saveSettings() {
        let data = try? JSONEncoder().encode(self.settings)
        UserDefaults.standard.set(data, forKey: "settings")
    }
    
    init() {
        getSavedSettings()
    }
    
    
    private var scanStopped = false
    
    func startScan() {
        scanStopped = false
        
        if connectedHost.isHostConnected {
            return
        }
        
        self.detectedHosts = []
        
        let port = portUsed  // Use the same port you defined earlier
        let subnetsToScan = ["192.168.0.", "10.32.195.", "10.108.12.", "192.168.5.", "172.20.10."]  // Add more subnets as needed
        
        let dispatchGroup = DispatchGroup()
        
        isScanning = true  // Set the flag to true when scanning starts
        
        for subnet in subnetsToScan {
            for i in 1...254 {
                if(scanStopped) {
                    scanStopped = false
                    return
                }
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
    
    func stopScan() {
        self.scanStopped = true
    }
    
    
}

struct Settings : Encodable, Decodable {
    var showHomeScreenBackground : Bool = true
    var hapticFeedbackEnabled : Bool = true
    var onboardingComplete : Bool = false
}



