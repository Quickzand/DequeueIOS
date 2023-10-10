//
//  ConnectToHostView.swift
//  Dequeue
//
//  Created by Matthew Sand on 9/7/23.
//

import SwiftUI


struct ConnectToHostView: View {
    
    @State private var showQRScanner = false
    @State private var showCodeInput = false;
    
    @EnvironmentObject var appState: AppState
    
    var body : some View {
        NavigationStack {
            VStack {
                DetectedHostsListView(detectedHosts: $appState.detectedHosts, appState: appState)
                Spacer()
                Button(action: {
                    print("++ Starting scan for devices on local network...")
                    appState.connectedHost.isHostConnected = false
                    appState.startScan()
                })
                {
                    Text("Refresh")
                }
                Button(action: {
                    showQRScanner.toggle()
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "qrcode.viewfinder")
                        Text("Scan QR Code")
                        Spacer()
                    }.font(.system(size:27))
                    
                }
                .navigationDestination(isPresented: $showQRScanner){
                    QRCodeScannerView(handleScannedCode: {code in
                        print(code)
                    })
                }
                .frame(height: 25)
                .padding(.top)
                .background(Color("AccentColor").opacity(0.75))
                .foregroundColor(Color.white)
                
                
                
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clear)
            .onAppear() {
                print("++ Starting scan for devices on local network...")
                appState.startScan()
            }
            .onDisappear {
                appState.stopScan()
            }
            
        }
            
    }
    
    
}


struct HostConnectionScreenView: View {
    var host: Host
    @State private var digits: [String] = ["", "", "", ""]
    @State private var focusedIndex: Int? = 0
    @ObservedObject var appState: AppState
    
      
      var body: some View {
               VStack(spacing: 0) {
                   Spacer()
                   DigitInputView(digits: $digits, focusedIndex: $focusedIndex)
                       .padding()
                   Spacer()
                   BottomConnectButton(host: host, appState: appState, digits: digits)
               }
               .frame(maxWidth:.infinity, maxHeight:.infinity)
               .background(Color.clear)
               .onAppear() {
                   if let savedHost = checkForSavedHost(host: host) {
                       connectToHost(host: savedHost, appState: appState, alreadySaved: true)
                   }
               }
           }
      }

struct DigitInputView: View {
    @Binding var digits: [String]
    @Binding var focusedIndex: Int?

    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<4) { index in
                CustomDigitInput(text: $digits[index], isFirstResponder: focusedIndex == index)
                    .frame(width: 40, height: 40)
                    .background(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .onChange(of: digits[index]) { value in
                        if value.count == 1 && index < 3 {
                            focusedIndex = index + 1
                        }
                    }
            }
        }
    }
}



struct BottomConnectButton : View {
    @State var host : Host
    @ObservedObject var appState: AppState
    
    var digits : [String]
    
    var body: some View {
        Button(action: {
            let code : String = digits[0] + digits[1] + digits[2] + digits[3]
            host.code = code
            connectToHost(host: host, appState: appState)
        }) {
            Text("Connect")
                .frame(maxWidth: .infinity)
                .foregroundColor(.white)
            
        }
        .frame(height: 50)
        .background(Color("AccentColor"))
    }
}

struct CustomDigitInput: UIViewRepresentable {
    @Binding var text: String
    var isFirstResponder: Bool = false

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.keyboardType = .numberPad
        textField.textColor = .white
        textField.textAlignment = .center
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        if isFirstResponder {
            uiView.becomeFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomDigitInput

        init(_ parent: CustomDigitInput) {
            self.parent = parent
        }

        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Ensure only one character is allowed
            if let currentText = textField.text, (currentText.count + string.count - range.length) > 1 {
                return false
            }
            
            parent.text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            return false
        }
    }
}


struct DetectedHostsListView: View {
    @Binding var detectedHosts: [Host]
    @ObservedObject var appState : AppState
    
    
    var body: some View {
        ScrollView {
                ForEach(detectedHosts, id: \.self) { host in
                    DetectedHostView(host:host, appState: appState)
                }
            }
            .padding(.horizontal)
            .refreshable {
                print("++ Starting scan for devices on local network...")
                appState.connectedHost.isHostConnected = false
                appState.startScan()
            }
        }
    
}

struct DetectedHostView: View {
    var host: Host
    @ObservedObject var appState: AppState
    var body : some View {
        NavigationLink (destination: HostConnectionScreenView(host: host, appState: appState)){
            HStack {
                Image(systemName: "desktopcomputer")
                    .padding(.leading)
                    .font(.system(size: 30))
                Text(host.sanitizedName())
                    .font(.system(size:30, weight: .bold))
                Spacer()
            }
            .frame(maxWidth: .infinity, minHeight: 70)
            
        }
        .background(
            .ultraThinMaterial, in:
                RoundedRectangle(cornerRadius: 16.0)
        )
        .foregroundColor(Color.white)
        .onAppear(perform: {
        })
        
        
    }
}






struct ConnectToHostView_Previews: PreviewProvider {
    static var previews: some View {
        ConnectToHostView().environmentObject(AppState())
    }
}
