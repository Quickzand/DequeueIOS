//
//  QRCodeScannerView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/7/23.
//

import SwiftUI
import CodeScanner

struct QRCodeScannerView: View {
    var handleScannedCode: (String) -> Void
    @EnvironmentObject var appState: AppState
    var body : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: {jsonString in
                if case .success(let scanResult) = jsonString
                {
                    do {
                        let data = Data(scanResult.string.utf8)
                        let decodedData = try JSONDecoder().decode(ScannedData.self, from: data);
                        var host : Host = Host(name: "", ip: decodedData.ip, code: decodedData.code)
                        var devices = getDevices() ?? []
                        devices.append(host)
                        saveDevices(devices)
                        connectToHost(host:host, appState: appState)
                        print("Code: \(decodedData.code), IP: \(decodedData.ip)")
                        // Handle the decoded data as needed
                    } catch {
                        print("Failed to decode JSON: \(error)")
                    }
                }
            }
        ).overlay(
            Image(systemName: "viewfinder")
                .resizable()
                .scaledToFit()
                .padding(.all, 100)
        )
    }
}


struct QRCodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerView()
        { code in
        print(code)
        // Handle the scanned code as needed
        }
    }
}


struct ScannedData: Codable {
    let code: String
    let ip: String
}
