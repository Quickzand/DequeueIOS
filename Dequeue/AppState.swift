//
//  AppState.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/24/23.
//

import Foundation
import Network
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
    @Published var serviceBrowser : ServiceBrowser?
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
        serviceBrowser = ServiceBrowser(appState: self)
        serviceBrowser?.startBrowsing()
    }
    
    


    
}

struct Settings : Encodable, Decodable {
    var showHomeScreenBackground : Bool = true
    var hapticFeedbackEnabled : Bool = true
    var onboardingComplete : Bool = false
    var selectedBackground : String = "Grid"
    var selectedBackgroundColor : String = colorToHex(Color("AccentColor"))
}



