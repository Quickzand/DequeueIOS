import SwiftUI

struct GradientSquare: View {
    var size: CGFloat
    var opacity: Double
    @Binding var animateAfterAppear: Bool  // Add a binding to control animation

    var body: some View {
        Rectangle()
            .fill(Color.black) // Fill with white to act as a mask
            .opacity(opacity)
            .frame(width: size+8, height: size+5)
            .animation(animateAfterAppear ? Animation.timingCurve(0.42, 0, 0.58, 0.98, duration: 2.0) : nil) // Conditional animationation: 2.0)) // Custom ease-in ease-out timing curve
    }
}


struct BackgroundView : View {
    @EnvironmentObject var appState : AppState
    var body : some View {
        switch appState.settings.selectedBackground {
        case "Grid":
            GridBackgroundView()
        case "custom":
            VStack {
                Rectangle().fill(Color(hex:appState.settings.selectedBackgroundColor)).ignoresSafeArea()
            }
        default:
            EmptyView()
        }
    }
}


struct GridBackgroundView: View {
    let gap: CGFloat = 0
    let initialSquareSize: CGFloat = 50
    @State private var animateAfterAppear = false  // New state variable to control animation
    @State private var opacities: [Double] = Array(repeating: 0.9, count: 100) // Assuming a maximum of 100 squares for simplicity

    var columns: Int {
        let totalWidth = UIScreen.main.bounds.width
        return Int(totalWidth / (initialSquareSize + gap))
    }

    var adjustedSquareSize: CGFloat {
        let totalWidth = UIScreen.main.bounds.width - (gap * CGFloat(columns - 1))
        return totalWidth / CGFloat(columns)
    }

    var rows: Int {
        let totalHeight = UIScreen.main.bounds.height
        return Int((totalHeight + gap) / (adjustedSquareSize + gap)) + 2
    }

    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect() // Change opacity every 1.5 seconds

    var body: some View {
        ZStack {
            // Full-screen gradient
            LinearGradient(gradient: Gradient(colors: [Color("AccentColor"), Color.blue]), startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Grid of squares as a mask
            LazyVGrid(columns: Array(repeating: .init(.fixed(adjustedSquareSize)), count: columns), spacing: gap) {
                ForEach(0..<(rows * columns)) { index in
                    GradientSquare(size: adjustedSquareSize, opacity: opacities[min(index, opacities.count - 1)], animateAfterAppear: $animateAfterAppear)
                }
            }
            .padding(.all, gap/2)  // Add padding to ensure gaps on the edges as well
            .mask(
                LazyVGrid(columns: Array(repeating: .init(.fixed(adjustedSquareSize)), count: columns), spacing: gap) {
                    ForEach(0..<(rows * columns)) { index in
                        GradientSquare(size: adjustedSquareSize, opacity: opacities[min(index, opacities.count - 1)], animateAfterAppear: $animateAfterAppear)
                    }
                }
                .padding(.all, gap/2)
            )
        }
        .blur(radius: 15)
        .onReceive(timer) { _ in
            let randomIndex = Int.random(in: 0..<opacities.count)
            opacities[randomIndex] = 0.5 // Set opacity to 0.1
            
            // After a delay, animate the opacity back to 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                opacities[randomIndex] = 0.9
            }
        }
        .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        animateAfterAppear = true
                    }
                }
    }
}

struct GradientGridBackground_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
            .environmentObject(AppState())
    }
}
