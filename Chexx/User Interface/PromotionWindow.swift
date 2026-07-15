//
//  PromotionView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/8/24.
//

import SwiftUI

struct PromotionWindow: View {
    var completion: (String) -> Void
    @Environment(\.presentationMode) var presentationMode // to dismiss the view
    let promotionOptions = ["queen", "rook", "bishop", "knight"]

    var body: some View {
        VStack {
            
            WaveText(text: NSLocalizedString("Pawn Promotion!", comment: ""), fontSize: 40)
                .padding(8)
            
            Text("Choose a piece to promote to:")
                .font(.system(size: 18, weight: .light, design: .serif))
                //.padding()
            
            VStack {
                ForEach(promotionOptions, id: \.self) { option in
                    Button(action: {
                        self.completion(option)
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(PieceNames.localized(option))
                            .font(.system(size: 24, weight: .semibold, design: .serif))
                            .padding()
                            .frame(minWidth: 160, maxHeight: 40)
                            .background(Color(red: 232/255, green: 171/255, blue: 111/255)) //the accent color in rgb because imessage doesnt want to recognize the accent color in assets (only here though?)
                            .foregroundColor(Color.primary)
                            .clipShape(HexagonEdgeRectangleShape())
                    }
                    .padding(5)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

struct WaveText: View {
    let text: String
    let fontSize: CGFloat

    @State private var time: Double = 0.0

    private var amplitude: CGFloat { fontSize * 0.1 }

    private var naturalTextWidth: CGFloat {
        let baseDescriptor = UIFont.systemFont(ofSize: fontSize, weight: .semibold).fontDescriptor
        let descriptor = baseDescriptor.withDesign(.serif) ?? baseDescriptor
        let font = UIFont(descriptor: descriptor, size: fontSize)
        return (text as NSString).size(withAttributes: [.font: font]).width
    }

    var body: some View {
        GeometryReader { geo in
            let scale = min(1.0, geo.size.width / max(naturalTextWidth, 1))

            HStack(spacing: 0) {
                ForEach(0..<text.count, id: \.self) { index in
                    Text(String(Array(text)[index]))
                        .font(.system(size: fontSize, weight: .semibold, design: .serif))
                        .modifier(WaveEffect(
                            time: self.time,
                            index: index,
                            amplitude: amplitude
                        ))
                }
            }
            .fixedSize()
            .scaleEffect(scale)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .frame(height: fontSize + amplitude * 2)
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                self.time = 360
            }
        }
    }
}

struct WaveEffect: GeometryEffect {
    var time: Double
    let index: Int //index of the current character in the string
    let amplitude: CGFloat //how high the wave should be
    let frequency: Double = 0.5 //how tight the wave cycles are

    var animatableData: Double {
        get { time }
        set { time = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        // Calculate the vertical offset using a sine wave.
        let yOffset = sin((time + Double(index)) * frequency) * amplitude
        
        // Create and return a transform that moves the character.
        let translation = CGAffineTransform(translationX: 0, y: yOffset)
        return ProjectionTransform(translation)
    }
}
