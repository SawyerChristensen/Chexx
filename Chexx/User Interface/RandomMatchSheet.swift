//
//  RandomMatchSheet.swift
//  Chexx
//
//  Created by Sawyer Christensen on 8/16/26.
//

import SwiftUI

struct RandomMatchSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var searchingTextDisplay: String = NSLocalizedString("Searching for opponent", comment: "Random matchmaking searching text")
    @State private var dotTimer: Timer?

    var body: some View {
        VStack {
            ProgressView()
                .padding()

            Text(searchingTextDisplay)
                .font(.system(size: 22, weight: .semibold, design: .serif))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding()

            Button(action: {
                cancelSearch()
            }) {
                Text("Cancel")
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                    .padding()
                    .frame(minWidth: 200, maxHeight: 60)
                    .background(Color.accentColor)
                    .foregroundColor(colorScheme == .dark ? Color.platformSystemGray6 : .white)
                    .clipShape(HexagonEdgeRectangleShape())
            }
            .crossPlatformHoverEffect()
            .padding()
        }
        .padding()
        .onAppear {
            startSearchingAnimation()
        }
        .onDisappear {
            dotTimer?.invalidate()
            dotTimer = nil
        }
    }

    private func startSearchingAnimation() {
        let baseText = NSLocalizedString("Searching for opponent", comment: "Random matchmaking searching text")
        var dotCount = 0
        dotTimer?.invalidate() // stop any previous timer, just in case
        dotTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            searchingTextDisplay = baseText + String(repeating: ".", count: dotCount)
            dotCount = (dotCount + 1) % 4
        }
    }

    private func cancelSearch() {
        dotTimer?.invalidate()
        dotTimer = nil
        MultiplayerManager.shared.leaveMatchmakingQueue()
        isPresented = false
    }
}
