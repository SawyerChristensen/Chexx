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
                            .background(Color.accentColor)
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
    @State private var waveOffset: CGFloat = 0
    @State private var startWave: Bool = false
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<text.count, id: \.self) { index in
                Text(String(Array(text)[index]))
                    //.fixedSize()
                    .font(.system(size: fontSize - CGFloat((text.count)) * 0.5, weight: .bold, design: .serif))
                    .offset(y: startWave ? waveOffset(for: index) : 0) // so the text starts out flat
            }
        }
        .onReceive(timer) { _ in
            withAnimation(Animation.linear(duration: 4)) { // wave speed
                if startWave {
                   waveOffset += 1
                } else {
                    startWave = true //starts the wave after 0.1 seconds on flat text
                }
            }
        }
    }
    
    private func waveOffset(for index: Int) -> CGFloat {
        return sin((Double(index) + Double(waveOffset)) * .pi / 5) * 30 // wave amplitude
    }
}
