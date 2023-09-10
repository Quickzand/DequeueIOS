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
    var body : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: {result in
                print(result)
            }
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
