import SwiftUI

struct VolumeKnob: View {
    @Binding var volume: Double // Volume level
    @GestureState private var isDragging = false

    private let minimumValue: Double = 0
    private let maximumValue: Double = 10

    var body: some View {
        KnobShape()
            .fill(Color.gray)
            .frame(width: 100, height: 100)
            .rotationEffect(Angle(degrees: volumeToAngle(volume)))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isDragging) { _, state, _ in
                        state = true
                    }
                    .onChanged { gesture in
                        let vector = CGVector(dx: gesture.location.x, dy: gesture.location.y)
                        let angle = atan2(vector.dy - 50, vector.dx - 50) + .pi / 2.0
                        let adjustedAngle = angle < 0 ? angle + 2 * .pi : angle
                        let angleValue = Double(adjustedAngle) / (2 * .pi) * (maximumValue - minimumValue)
                        volume = min(max(minimumValue, angleValue), maximumValue)
                    }
            )
            .shadow(radius: isDragging ? 10 : 5)
    }

    private func volumeToAngle(_ volume: Double) -> Double {
        return (volume / (maximumValue - minimumValue)) * 360
    }
}

struct KnobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        path.addRect(CGRect(x: rect.midX - 5, y: rect.minY, width: 10, height: rect.height / 2))
        return path
    }
}


#Preview {
    VolumeKnob(volume: .constant(1.0))
}
