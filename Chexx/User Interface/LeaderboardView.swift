//
//  LeaderboardView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 7/22/26.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

private struct LeaderboardEntry: Identifiable {
    let id: String // Firestore document ID (user ID)
    let displayName: String
    let country: String
    let eloScore: Int
}

struct LeaderboardView: View {
    @Environment(\.colorScheme) var colorScheme

    @State private var entries: [LeaderboardEntry] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let db = Firestore.firestore()
    private let maxEntries = 100

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 28, weight: .medium, design: .serif))
                    .foregroundColor(Color.accentColor)

                Text("Leaderboard")
                    .font(.system(size: 22, weight: .medium, design: .serif))
            }
            .padding(.top)

            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let errorMessage {
                Spacer()
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                            LeaderboardRow(rank: index + 1, entry: entry, colorScheme: colorScheme)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
        }
        .onAppear(perform: loadLeaderboard)
    }

    private func loadLeaderboard() {
        db.collection("users")
            .order(by: "eloScore", descending: true)
            .limit(to: maxEntries)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    isLoading = false
                    if let error {
                        print("Error loading leaderboard: \(error.localizedDescription)")
                        errorMessage = "Couldn't load the leaderboard. Please try again later."
                        return
                    }
                    entries = snapshot?.documents.compactMap { document in
                        let data = document.data()
                        guard let eloScore = data["eloScore"] as? Int else { return nil }
                        let displayName = data["displayName"] as? String ?? "Player"
                        let country = data["country"] as? String ?? ""
                        return LeaderboardEntry(id: document.documentID, displayName: displayName, country: country, eloScore: eloScore)
                    } ?? []
                }
            }
    }
}

private struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    let colorScheme: ColorScheme

    private var isCurrentUser: Bool {
        entry.id == Auth.auth().currentUser?.uid
    }

    var body: some View {
        HStack {
            Text("\(rank)")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(.secondary)
                .frame(width: 32, alignment: .leading)

            if !entry.country.isEmpty {
                Text(Country.flagEmoji(forCode: entry.country))
                    .font(.system(size: 20))
            }

            Text(entry.displayName)
                .font(.system(size: 18, weight: isCurrentUser ? .bold : .regular, design: .serif))
                .lineLimit(1)

            Spacer()

            Text("\(entry.eloScore)")
                .font(.system(size: 18, weight: .semibold, design: .serif))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isCurrentUser ? Color.accentColor.opacity(0.15) : (colorScheme == .dark ? Color(UIColor.systemGray5) : Color(UIColor.systemGray6)))
        )
    }
}
