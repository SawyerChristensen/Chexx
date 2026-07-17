//
//  ChexxWidgetsLiveActivity.swift
//  ChexxWidgets
//

import ActivityKit
import WidgetKit
import SwiftUI

/// A single flat-top hexagon, matching the six-point geometry used by the
/// board's SpriteKit tiles (see `HexagonNode.createHexagonPath`).
private struct HexagonTile: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        for i in 0..<6 {
            let angle = CGFloat.pi / 3 * CGFloat(i) - .pi / 6
            let point = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

/// A small, decorative hex-grid used as a stand-in board preview on the Lock
/// Screen and in the Dynamic Island. It doesn't reflect real piece positions
/// yet — that requires threading board state through `ContentState`.
private struct BoardPreviewView: View {
    private let tileColors: [Color] = [
        Color(red: 0.93, green: 0.80, blue: 0.62),
        Color(red: 0.80, green: 0.62, blue: 0.42),
        Color(red: 0.62, green: 0.44, blue: 0.28)
    ]
    private let columns = 5
    private let rows = 3

    var body: some View {
        GeometryReader { geometry in
            let tileSize = geometry.size.height / CGFloat(rows)
            let hStep = tileSize * 0.86

            HStack(spacing: -tileSize * 0.14) {
                ForEach(0..<columns, id: \.self) { column in
                    VStack(spacing: 0) {
                        if column.isMultiple(of: 2) == false {
                            Spacer().frame(height: tileSize / 2)
                        }
                        ForEach(0..<rows, id: \.self) { row in
                            HexagonTile()
                                .fill(tileColors[(column + row) % tileColors.count])
                                .frame(width: tileSize, height: tileSize)
                        }
                    }
                    .frame(width: hStep)
                }
            }
        }
    }
}

struct GameLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: GameLiveActivityAttributes.self) { context in
            HStack(spacing: 12) {
                BoardPreviewView()
                    .frame(width: 64, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.opponentName)
                        .font(.subheadline.bold())
                    Text(context.state.moveDescription)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.8))
            .activitySystemActionForegroundColor(Color.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    BoardPreviewView()
                        .frame(width: 56, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.opponentName)
                        .font(.caption.bold())
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.state.moveDescription)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                HexagonTile()
                    .fill(Color(red: 0.80, green: 0.62, blue: 0.42))
                    .frame(width: 18, height: 18)
            } compactTrailing: {
                Text(context.state.opponentName)
                    .font(.caption2)
                    .lineLimit(1)
            } minimal: {
                HexagonTile()
                    .fill(Color(red: 0.80, green: 0.62, blue: 0.42))
                    .frame(width: 16, height: 16)
            }
        }
    }
}
