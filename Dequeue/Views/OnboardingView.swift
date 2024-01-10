//
//  OnboardingView.swift
//  Dequeue
//
//  Created by Matthew Sand on 10/11/23.
//

import SwiftUI
import SDWebImageSwiftUI

import UIKit


struct OnboardingView: View {
    @State var hideContinue = true
    @State var currentPage : Int = 2
    @EnvironmentObject var appState : AppState
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage)
               {
                FirstOnboardingView(hideContinue: $hideContinue)
                       .tag(0)
                SecondOnboardingView()
                       .tag(1)
                ThirdOnboardingView()
                       .tag(2)
                FinalOnboardingView()
                       .tag(3)
            }
            .tabViewStyle(.page)
            .animation(.easeInOut, value: currentPage)
            .transition(.slide)
            Button {
                currentPage += 1
                if(currentPage > 3) {
                    appState.settings.onboardingComplete = true
                    appState.saveSettings()
                }
                
            } label: {
                HStack {
                    Spacer()
                    Text(currentPage == 3 ? "Get Started ⚡" : "Continue")
                        .font(.system(size: 25, weight: .bold))
                        .animation(.easeInOut)
                    Spacer()
                }
            }
            .padding()
            .foregroundStyle(.white)
            .background(Color("AccentColor"))
            .clipShape(RoundedRectangle(cornerRadius: 20.0))
            .padding()
            .opacity(hideContinue && currentPage == 0 ? 0 : 1)
            .animation(.easeInOut(duration:2), value: hideContinue)
        }
    }
}


struct GizmoLogoAnimationInitialState {
    var opacity = 0.0
    var scale = 1.0
    var rotation = 0.0
}

struct FirstOnboardingView : View {
    var text : String = "Welcome To Gizmo"
    @State private var textAnimationComplete : Bool = false
    @Binding var hideContinue : Bool

    var body : some View {
        VStack {
            Spacer()
            HStack(spacing:0.1) {
                ForEach(Array(text.enumerated()), id: \.offset) { index, char in
                    FirstOnboardingLetterView(char: char, index: index,  textAnimationComplete: $textAnimationComplete, stringLength: text.count, hideContinue: $hideContinue )
                    
                }
            }
            Spacer()
            Image("GizmoLogo")
                .resizable()
                .scaledToFit()
                
                .keyframeAnimator(initialValue: GizmoLogoAnimationInitialState(), trigger: textAnimationComplete, content: { content, value in
                    content
                        .opacity(value.opacity)
                        .scaleEffect(value.scale)
                        .rotationEffect(Angle(degrees: value.rotation))
                }, keyframes: { frames in
                    KeyframeTrack(\.opacity)  {
                        SpringKeyframe(1,duration: 0.5)
                    }
                    KeyframeTrack(\.scale) {
                        LinearKeyframe(1, duration:0.5)
                        SpringKeyframe(1.25, duration: 0.75, spring: Spring(bounce: 0.1))
                        CubicKeyframe(1, duration: 0.175)
                    }
                    KeyframeTrack(\.rotation) {
                        LinearKeyframe(0, duration:0.5)
                        SpringKeyframe(15, duration: 0.175)
                        SpringKeyframe(-15, duration: 0.175)
                        SpringKeyframe(0, duration: 0.175)
                        SpringKeyframe(0, duration: 0.175)
                        
                    }
                })
            Spacer()
        }
    }
}

struct FirstOnboardingLetterView : View {
    @State private var charOpacity = 0.0
    @State private var charOffset = -20.0
    var char : Character
    var index : Int
    @Binding var textAnimationComplete : Bool
    var stringLength: Int
    @Binding var hideContinue : Bool
    
    var body : some View {
        Text(String(char))
            .font(.title)
            .padding(.all, 0)
            
            .offset(y: charOffset)
            .opacity(charOpacity)
            .animation(.spring(duration: 0.5))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + (0.05 * Double(index))) {
                    charOffset = 0
                    charOpacity = 1
                    if stringLength == index + 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            textAnimationComplete = true
                            hideContinue = false
                        }
                    }
                }
            }
        
    }
    
}


struct SecondOnboardingView : View {
    var body : some View {
        VStack {
            Spacer()
            WebImage(url: Bundle.main.url(forResource: "OnboardingAnimation", withExtension: "png"))
                .resizable() // Resizable like SwiftUI.Image
                .indicator(.activity) // Activity Indicator
                .transition(.fade(duration: 0.5)) // Fade Transition with duration
                .scaledToFit() // Fit the frame
                .frame(width: 200, height: 200)
            Spacer()
            Text("Gizmo lets you run actions on your Computer from your phone!")
                .font(.system(size: 25, weight:.semibold))
                .padding()
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
}

struct ThirdOnboardingView : View {
    var body : some View {
        VStack {
            Spacer()
            Text("Before getting started though, make sure to download and run the Gizmo desktop app")
                .font(.system(size: 25, weight:.semibold))
                .padding()
                .multilineTextAlignment(.center)
            Button{
                if let url = URL(string: "https://www.matthewsand.info/Gizmo") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("Go to the Website")
                    .foregroundStyle(.white)
                    .font(.system(size:20, weight: .bold))
            }
            .padding(.all,20)
            .background(Color("AccentColor"))
            .clipShape(RoundedRectangle(cornerRadius: 25.0))
            Spacer()
            ZStack {
              
                Image(systemName: "laptopcomputer")
                    .resizable()
                    .foregroundColor(.white)
                    .symbolRenderingMode(.monochrome)
                    .font(.system(size:16, weight:.ultraLight))
                    
                    .scaledToFit()
                    .overlay {
                        Image("GizmoLogo")
                            .resizable()
                            .scaledToFit()
                            .padding(.all, 50)
                    }
            }
     
            Spacer()
        }
    }
}

struct FinalOnboardingView : View {
    
    @State var displayAction : Action? = Action(icon:"bolt.fill")
    var body : some View {
        VStack {
            Spacer()
            Text("Time to get started streamlining your workload!")
                .font(.system(size:25, weight: .semibold))
                .multilineTextAlignment(.center)
            Spacer()
            Spacer()
        }
    }
    
}

#Preview {
    OnboardingView().environmentObject(AppState())
}
