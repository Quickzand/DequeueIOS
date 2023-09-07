//
//  ContentView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/6/23.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @State private var port: String = "8080"
    @State private var detectedHosts: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("Enter Port", text: $port)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                
                Button(action: startScan) {
                    Text("Scan")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            List(detectedHosts, id: \.self) { host in
                Text(host)
            }
        }
        .padding()
    }
    
    func startScan() {
        let subnetsToScan = ["192.168.0.", "192.168.1.", "192.168.2."] // Add more as needed
        
        detectedHosts = []

        for subnet in subnetsToScan {
            for i in 1...254 {
                let ip = "\(subnet)\(i)"
                
                isPortOpen(host: ip, port: Int(port) ?? 8080, timeout: 2.0) { isOpen in
                    if isOpen {
                        DispatchQueue.main.async {
                            self.detectedHosts.append(ip)
                        }
                    }
                }
            }
        }
    }
}


func isPortOpen(host: String, port: Int, timeout: TimeInterval, completion: @escaping (Bool) -> Void) {
    // Create a URL from the host and port
    guard let url = URL(string: "http://\(host):\(port)/") else {
        print("Error: Invalid URL for \(host):\(port)")
        completion(false)
        return
    }
    
    // Set up a URLRequest with the desired timeout
    var request = URLRequest(url: url, timeoutInterval: timeout)
    request.httpMethod = "HEAD"
    
    // Start a URLSession task to try connecting to the port
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let httpResponse = response as? HTTPURLResponse {
            if 200...299 ~= httpResponse.statusCode {
                print("Success: Connected to \(host) on port \(port) with response code \(httpResponse.statusCode)")
                completion(true)
            } else {
                print("Failed: Received non-success status code \(httpResponse.statusCode) for \(host):\(port)")
                completion(false)
            }
        } else if let err = error {
            print("Error: \(err.localizedDescription) for \(host):\(port)")
            completion(false)
        } else {
            print("Unknown error for \(host):\(port)")
            completion(false)
        }
    }
    task.resume()
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
