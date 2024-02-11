//
//  Extensions.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/12/23.
//

import Foundation
import SwiftUI
import WebKit

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0

        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    var opacityValue: Double {
        guard let components = UIColor(self).cgColor.components else { return 1.0 }
        return components[3] // Assuming component at index 3 is alpha
    }
}


public extension View {
    func iconPicker(
        isPresented: Binding<Bool>,
        selectedIconName: Binding<String>,
        selectedColor: String
    ) -> some View {
        sheet(isPresented: isPresented) {
            CustomIconPickerView(selectedIconName: selectedIconName, isPresented: isPresented, selectedColor: selectedColor)
        }
    }
    
    
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}


struct WebView: UIViewRepresentable {
    var url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadFileURL(url, allowingReadAccessTo: url)
    }
}
