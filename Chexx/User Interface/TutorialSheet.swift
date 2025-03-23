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
                
                Text("(Glińkski's Variant)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    //.padding(.bottom, 20)
                
                Divider()
                    .padding(10)
                
                Text("1. Introduction")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("      The most popular form of Hexagonal Chess was created by Władysław Gliński in 1936. During it's peak in Eastern Europe there was once more than half a million players of Glińkski's Hex Chess. There have since been even more variants created, although Glińkski's remains the most popular. It's played simarly to regular chess albeit with some notable differences.")
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
                
                Text("      Just like in normal chess, the rook moves along the columns. Another way to think about it is the rook moving along the edges of the tiles. Because a hexagon has six edges instead of a square's four, there are six possible columns in hex chess.")
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
                
                Text("      The bishop still moves along the diagonals (towards the points of a tile instead of it's edges) and always stays on it's color. Like the rook, because a hexagon has six points, there are six possible diagonal directions.")
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
                 
                 Text("      The queen combines the movement of the rook and bishop. It can move along the columns as well as along the diagonals.")
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
                
                Text("      The king can move along columns and diagonals, with the restriction of only one tile in any direction. A beginner's mistake is forgetting about the one-tile diagonal movement, which on first glance is not connected to the home tile of the king.")
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
                
                Text("      The knight moves two tiles along a column, and then one tile to the left or right.")
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
                
                Text("      The pawn normally moves forward one tile at a time, but can also move two tiles forward if it hasn't moved yet. It captures pieces to it's immediate left and right and can get promoted to any piece if it reaches the last row.")
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
                
                Text("      There is no castling in Hexagonal Chess. There are also nine pawns instead of eight, as well as three bishops (one for each color still) instead of the usual two. Pawns can still be captured through en passant.")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image("StartingPositions")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                
                Text("      All legal moves are highlighted by default when playing in any mode. To disable this, simply toggle the \"Highlight Legal Moves\" option in settings.")
                    .font(.body)
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
                
                Text("      Habanera (Main Menu Theme) by Georges Bizet, 1875, via the YouTube Audio Library")
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
