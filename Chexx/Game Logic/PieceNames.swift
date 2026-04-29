//
//  PieceNames.swift
//  Chexx
//
//  Created by Sawyer Christensen on 4/29/26.
//

import Foundation

enum PieceNames {
    static func localized(_ type: String) -> String {
        switch type {
        case "pawn":   return NSLocalizedString("piece_pawn", comment: "Chess piece name")
        case "knight": return NSLocalizedString("piece_knight", comment: "Chess piece name")
        case "bishop": return NSLocalizedString("piece_bishop", comment: "Chess piece name")
        case "rook":   return NSLocalizedString("piece_rook", comment: "Chess piece name")
        case "queen":  return NSLocalizedString("piece_queen", comment: "Chess piece name")
        case "king":   return NSLocalizedString("piece_king", comment: "Chess piece name")
        default:       return type.capitalized
        }
    }
}
