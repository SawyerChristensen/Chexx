//
//  TutorialView.swift
//  Chexx
//
//  Created by Sawyer Christensen on 12/30/24.
//

import SwiftUI

struct TutorialSheet: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 10) {
                Text("How to Play Hexagonal Chess")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                
                Text("Glińkski's Variant")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .italic()
                
                Divider()
                    .padding(10)
                
                Text("1. Introduction")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("      The most popular form of hexagonal chess was created by Władysław Gliński in 1936. During its peak in Eastern Europe there were once more than half a million players of Gliński's game. While many variants have since been created, Gliński's remains the most popular. It is played similarly to regular chess, albeit with some notable differences.")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                
                Text("2. Piece Movement")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(5)
                
                Text("The Rook")
                    .font(.title2)
                    .italic()
                
                Text("      The rook moves orthogonally in straight lines. This means the rook moves across the edges of each tile. Because a hexagon has six edges instead of a square's four, there are six possible directions the rook can move in hexagonal chess.")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("RookMovement")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                
                Divider()
                    .padding(10)
                
                Text("The Bishop")
                    .font(.title2)
                    .italic()
                
                Text("      The bishop moves along the diagonals (towards the corners of its tile rather than its edges) and always stays on its color. Since a hexagon has six corners, there are six possible diagonal directions. Note that in hexagonal chess, the corners of hexagons diagonal to each other do not touch.")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("BishopMovement")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                 
                 Divider()
                     .padding(10)
                 
                 Text("The Queen")
                     .font(.title2)
                     .italic()
                 
                 Text("      The queen combines the orthogonal movement of the rook with the diagonal movement of the bishop, granting her a total of 12 possible directions. As in standard chess, the queen remains the most dangerous and valuable piece on the board.")
                     .font(.body)
                     .frame(maxWidth: .infinity, alignment: .leading)
                 
                 Image("QueenMovement")
                     .resizable()
                     .scaledToFit()
                     .padding(10)
                    
                Divider()
                    .padding(10)
                
                Text("The King")
                    .font(.title2)
                    .italic()
                
                Text("      The king moves similarly to the queen, but can only move one tile in any direction. A beginner's mistake is forgetting about the one-tile diagonal movement, as those tiles do not share an edge with the king's tile.")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("KingMovement")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                
                Divider()
                    .padding(10)
                
                Text("The Knight")
                    .font(.title2)
                    .italic()
                
                Text("      The knight moves in a slightly obtuse L-shape. It travels two tiles orthogonally (across edges) and then one tile to the left or right. The knight is the only piece that can jump over other pieces to reach its destination.")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("KnightMovement")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                
                Divider()
                    .padding(10)
                
                Text("The Pawn")
                    .font(.title2)
                    .italic()
                
                Text("      The pawn advances one tile at a time along the columns, with the option to advance two tiles on its first move. It can still be captured en passant. It captures pieces to its immediate left and right (not \"diagonally\" in the hexagonal sense) and can be promoted to any other piece upon reaching the last row.")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("PawnMovement")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                
                Divider()
                    .padding(10)
                
                Text("3. Other Differences")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                
                Text("      There is no castling in hexagonal chess. There are also nine pawns instead of eight, as well as three bishops (one for each color) instead of the usual two.")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("StartingPositions")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                
                Text("      All legal moves are highlighted by default when playing in any mode. To disable this, simply toggle the \"Show Legal Moves\" option in settings. When playing in the \"Pass & Play\" mode, the board rotates after each player's turn. To make this rotation instant, enable the \"Low Motion\" option in settings.")
                    .font(.footnote)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .padding(10)
                
                Text("4. Acknowledgements")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                
                Text("      Original Rules by Władysław Gliński")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                
                Text("      iOS App by Sawyer Christensen")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                
                Text("      Pieces by Cburnett, CC BY-SA 3.0, via Wikimedia Commons")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
                
                Text("      Main Menu Theme - Habanera by Georges Bizet, via the YouTube Audio Library")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .italic()
            }
            .padding()
        }
        .navigationTitle("Tutorial")
        /*.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    // Implement dismissal if necessary
                }
            }
        }*/
    }
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialSheet()
    }
}
