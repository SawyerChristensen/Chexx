//
//  PromotionView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/8/24.
//

import SwiftUI

struct PromotionView: View {
    var completion: (String) -> Void
    @Environment(\.presentationMode) var presentationMode // to dismiss the view

    var body: some View {
        VStack {
            WaveText(text: "Pawn Promotion!") // Use the custom WaveText view
                .padding()
                //.background(Color.accentColor)
                //.foregroundColor(Color.primary)
                //.clipShape(HexagonEdgeRectangleShape())
            
            Text("Choose a piece to promote to:")
                .font(.system(size: 18, weight: .regular, design: .serif))
                //.padding()
            
            VStack {
                ForEach(["queen", "rook", "bishop", "knight"], id: \.self) { option in
                    Button(action: {
                        self.completion(option)
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(option.capitalized)
                            .font(.system(size: 20, weight: .bold, design: .serif))
                            .padding()
                            .frame(width: 160, height: 40)
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
    @State private var waveOffset: CGFloat = 0
    @State private var startWave: Bool = false
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<text.count, id: \.self) { index in
                Text(String(Array(text)[index]))
                    .font(.system(size: 25, weight: .bold, design: .serif))
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
