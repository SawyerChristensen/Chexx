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
    let promotionOptions: [String: String] = [
        "queen": NSLocalizedString("promotion_queen", comment: "Promotion option"),
        "rook": NSLocalizedString("promotion_rook", comment: "Promotion option"),
        "bishop": NSLocalizedString("promotion_bishop", comment: "Promotion option"),
        "knight": NSLocalizedString("promotion_knight", comment: "Promotion option")
    ]


    var body: some View {
        VStack {
            
            WaveText(text: NSLocalizedString("Pawn Promotion!", comment: ""), fontSize: 40)
                .padding(8)
            
            Text("Choose a piece to promote to:")
                .font(.system(size: 18, weight: .regular, design: .serif))
                //.padding()
            
            VStack {
                ForEach(["queen", "rook", "bishop", "knight"], id: \.self) { option in
                    Button(action: {
                        self.completion(option)
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(promotionOptions[option] ?? option.capitalized)
                            .font(.system(size: 24, weight: .bold, design: .serif))
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
    
    // A single state variable to drive the animation.
    @State private var time: Double = 0.0
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<text.count, id: \.self) { index in
                Text(String(Array(text)[index]))
                    .font(.system(size: fontSize, weight: .bold, design: .serif))
                    // Apply the GeometryEffect instead of .offset()
                    .modifier(WaveEffect(
                        time: self.time,
                        index: index,
                        // Make amplitude proportional to the font size for consistency.
                        amplitude: fontSize * 0.1
                    ))
            }
        }
        .onAppear {
            // Start a single, repeating animation when the view appears.
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                self.time = 360 // A large value to ensure continuous animation.
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
