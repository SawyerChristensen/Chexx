//
//  GameState.swift
//  Chexx
//
//  Created by Sawyer Christensen on 6/29/24.
//

import SpriteKit

struct Piece: Codable {
    var color: String // "white" or "black"
    var type: String // "pawn" or "rook" etc
    var hasMoved: Bool = false // for pawns to check if they still have their opening two moves
    var isEnPassantTarget: Bool = false //if pawns have moved two, it opens them up for temporary en passant capture!!
}

// Assign values to pieces for material scoring (used by GameState's incremental tracking and GameCPU's evaluation)
func pieceValue(_ type: String) -> Int {
    switch type {
    case "king":                return 1000
    case "queen":               return 9
    case "rook":                return 5
    case "bishop", "knight":    return 3
    case "pawn":                return 1
    default: return 0
    }
}

struct MoveUndoInfo { //for simulating moves in advance with makeMove/unmakeMove
    let fromColIndex: Int
    let fromRowIndex: Int
    let toColIndex: Int
    let toRowIndex: Int
    let movingPiece: Piece?
    let capturedPiece: Piece?
    let enPassantCapturedPiece: Piece?
    let enPassantCapturedCol: Int?
    let enPassantCapturedRow: Int?
    let previousZobristHash: UInt64
}

struct GameState: Codable {
    var currentPlayer: String // "white" or "black"
    var gameStatus: String // "ongoing" or "ended" //can probably change this into a bool "isOngoing" later
    var board: [Piece?] // flat array of 91 hex tiles (column-major), indexed via boardIndex(col:row:)

    // Number of rows in each of the 11 columns (a hex board isn't a uniform grid)
    static let columnSizes = [6, 7, 8, 9, 10, 11, 10, 9, 8, 7, 6]

    // Cumulative offset of each column's first row within the flat `board` array
    static let columnOffsets: [Int] = {
        var offsets: [Int] = []
        var running = 0
        for size in columnSizes {
            offsets.append(running)
            running += size
        }
        return offsets
    }()

    // Total number of hex tiles on the board (91 for Glinski's hexchess)
    static let tileCount = columnSizes.reduce(0, +)

    static func boardIndex(col: Int, row: Int) -> Int {
        columnOffsets[col] + row
    }

    func rowCount(forCol col: Int) -> Int {
        GameState.columnSizes[col]
    }

    subscript(col: Int, row: Int) -> Piece? {
        get { board[GameState.boardIndex(col: col, row: row)] }
        set { board[GameState.boardIndex(col: col, row: row)] = newValue }
    }

    var whiteKingPosition: String
    var blackKingPosition: String
    
    var variant: String = "Glinski's"
    var HexPgn: [UInt8] = []

    // Running material totals, kept in sync by makeMove/unmakeMove so evaluation doesn't need to rescan the board
    var whiteMaterial: Int = 0
    var blackMaterial: Int = 0

    // Per-game achievement counters. Unlike material/slider/zobrist (recomputed from the board on
    // load), these cannot be derived from a final position, so they are persisted in CodingKeys.
    var whitePromotionCount: Int = 0
    var blackPromotionCount: Int = 0
    var whiteTimesPutInCheck: Int = 0
    var blackTimesPutInCheck: Int = 0

    /// Flat board indices (`GameState.boardIndex(col:row:)`) a piece has moved onto this game, by
    /// either player. Starting squares are deliberately not pre-seeded: a tile counts as visited
    /// only once something moves onto it. Backs the Hexplorer achievement.
    var visitedTileIndices: Set<Int> = []

    /// Plies since the last capture or pawn move, for the 50-move rule. Counted in plies, so the
    /// rule triggers at 100 — fifty moves by each player.
    var halfmoveClock: Int = 0

    /// Repetition keys of the positions reached this game, for threefold repetition.
    ///
    /// Truncated alongside `halfmoveClock` on a capture or pawn move: those are irreversible, so no
    /// position from before one can ever recur, and keeping earlier entries would only risk false
    /// positives while growing without bound.
    var positionHistory: [UInt64] = []

    // Running counts of sliding pieces (rook/bishop/queen), kept in sync by makeMove/unmakeMove so
    // check detection can cheaply skip ray scans for piece types an opponent no longer has
    var whiteSliderCount: Int = 0
    var blackSliderCount: Int = 0

    // Zobrist hash of the current piece placement, kept in sync by makeMove/unmakeMove so GameCPU
    // can key a transposition table without rehashing the whole board at every search node
    var zobristHash: UInt64 = 0

    // Column/row of the single pawn currently flagged as an en passant target (if any), kept in
    // sync by finalizeMove/resetEnPassant so clearing the flag doesn't require scanning the whole board
    var enPassantCol: Int? = nil
    var enPassantRow: Int? = nil

    init() {
        // Initialize the board with nils (empty positions)
        board = Array(repeating: nil, count: GameState.tileCount)

        // Set initial game metadata
        currentPlayer = "white"
        gameStatus = "ongoing"
        whiteKingPosition = "g1"
        blackKingPosition = "g10"
        HexPgn = []
        
        if variant == "Glinski's" {
            HexPgn.append(00)
        } else if variant == "Mathewson's" {
            HexPgn.append(01)
        } else if variant == "McCooey's" {
            HexPgn.append(10)
        } else if variant == "Christensen's" {
            HexPgn.append(11)
        }
        
        // Set initial pieces on the board
        setInitialPiecePositions() //could maybe be incorporated into the if else

        (whiteMaterial, blackMaterial) = GameState.computeMaterial(for: board)
        (whiteSliderCount, blackSliderCount) = GameState.computeSliderCounts(for: board)
        zobristHash = GameState.computeZobristHash(for: board)
        (enPassantCol, enPassantRow) = (nil, nil)
    }

    private enum CodingKeys: String, CodingKey {
        case currentPlayer, gameStatus, board, whiteKingPosition, blackKingPosition, variant, HexPgn, whiteMaterial, blackMaterial
        case whitePromotionCount, blackPromotionCount, whiteTimesPutInCheck, blackTimesPutInCheck, visitedTileIndices
        case halfmoveClock, positionHistory
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentPlayer = try container.decode(String.self, forKey: .currentPlayer)
        gameStatus = try container.decode(String.self, forKey: .gameStatus)
        board = try container.decode([Piece?].self, forKey: .board)
        whiteKingPosition = try container.decode(String.self, forKey: .whiteKingPosition)
        blackKingPosition = try container.decode(String.self, forKey: .blackKingPosition)
        variant = try container.decodeIfPresent(String.self, forKey: .variant) ?? "Glinski's"
        HexPgn = try container.decodeIfPresent([UInt8].self, forKey: .HexPgn) ?? []

        // decodeIfPresent throughout: a game saved before these counters existed must still load.
        whitePromotionCount = try container.decodeIfPresent(Int.self, forKey: .whitePromotionCount) ?? 0
        blackPromotionCount = try container.decodeIfPresent(Int.self, forKey: .blackPromotionCount) ?? 0
        whiteTimesPutInCheck = try container.decodeIfPresent(Int.self, forKey: .whiteTimesPutInCheck) ?? 0
        blackTimesPutInCheck = try container.decodeIfPresent(Int.self, forKey: .blackTimesPutInCheck) ?? 0
        visitedTileIndices = try container.decodeIfPresent(Set<Int>.self, forKey: .visitedTileIndices) ?? []
        halfmoveClock = try container.decodeIfPresent(Int.self, forKey: .halfmoveClock) ?? 0
        positionHistory = try container.decodeIfPresent([UInt64].self, forKey: .positionHistory) ?? []

        // Recompute from the decoded board rather than trusting persisted totals, so saves from
        // before material tracking was added (or any drift) always resolve to a correct value
        (whiteMaterial, blackMaterial) = GameState.computeMaterial(for: board)
        (whiteSliderCount, blackSliderCount) = GameState.computeSliderCounts(for: board)
        zobristHash = GameState.computeZobristHash(for: board)
        (enPassantCol, enPassantRow) = GameState.computeEnPassantTarget(for: board)
    }

    // A saved game can only ever have at most one pawn flagged as an en passant target at a time
    // (the flag is cleared after the opponent's single response turn), so recomputing it on load
    // is a one-time scan rather than an ongoing cost
    private static func computeEnPassantTarget(for board: [Piece?]) -> (col: Int?, row: Int?) {
        for col in 0..<columnSizes.count {
            for row in 0..<columnSizes[col] {
                if board[boardIndex(col: col, row: row)]?.isEnPassantTarget == true {
                    return (col, row)
                }
            }
        }
        return (nil, nil)
    }

    private static func computeMaterial(for board: [Piece?]) -> (white: Int, black: Int) {
        var white = 0
        var black = 0
        for case let piece? in board {
            if piece.color == "white" {
                white += pieceValue(piece.type)
            } else {
                black += pieceValue(piece.type)
            }
        }
        return (white, black)
    }

    private static func isSlider(_ type: String) -> Bool {
        return type == "rook" || type == "bishop" || type == "queen"
    }

    // One random bitstring per (column, row, color, piece type) combination, generated once per
    // process launch. Board positions hash by XORing together the entries for their occupied
    // squares, so makeMove/unmakeMove can update the hash incrementally instead of rehashing everything.
    private static let zobristPieceTypeCount = 6
    private static let zobristTable: [[[UInt64]]] = {
        let columnCount = hexColumns.count
        let maxRowCount = 11
        return (0..<columnCount).map { _ in
            (0..<maxRowCount).map { _ in
                (0..<(zobristPieceTypeCount * 2)).map { _ in UInt64.random(in: UInt64.min...UInt64.max) }
            }
        }
    }()

    // XORed into a position's hash when it's black's turn to move, so the CPU's transposition
    // table can distinguish the same board with white vs. black to move
    static let zobristBlackToMove: UInt64 = UInt64.random(in: UInt64.min...UInt64.max)

    private static func zobristPieceIndex(_ piece: Piece) -> Int {
        let typeOffset: Int
        switch piece.type {
        case "pawn": typeOffset = 0
        case "knight": typeOffset = 1
        case "bishop": typeOffset = 2
        case "rook": typeOffset = 3
        case "queen": typeOffset = 4
        default: typeOffset = 5 // king
        }
        return (piece.color == "white" ? 0 : zobristPieceTypeCount) + typeOffset
    }

    private static func zobristValue(colIndex: Int, rowIndex: Int, piece: Piece) -> UInt64 {
        return zobristTable[colIndex][rowIndex][zobristPieceIndex(piece)]
    }

    private static func computeZobristHash(for board: [Piece?]) -> UInt64 {
        var hash: UInt64 = 0
        for col in 0..<columnSizes.count {
            for row in 0..<columnSizes[col] {
                if let piece = board[boardIndex(col: col, row: row)] {
                    hash ^= zobristValue(colIndex: col, rowIndex: row, piece: piece)
                }
            }
        }
        return hash
    }

    private static func computeSliderCounts(for board: [Piece?]) -> (white: Int, black: Int) {
        var white = 0
        var black = 0
        for case let piece? in board where isSlider(piece.type) {
            if piece.color == "white" {
                white += 1
            } else {
                black += 1
            }
        }
        return (white, black)
    }

    private mutating func adjustMaterial(for color: String, by delta: Int) {
        if color == "white" {
            whiteMaterial += delta
        } else {
            blackMaterial += delta
        }
    }

    private mutating func adjustSliderCount(for color: String, by delta: Int) {
        if color == "white" {
            whiteSliderCount += delta
        } else {
            blackSliderCount += delta
        }
    }

    func sliderCount(for color: String) -> Int {
        return color == "white" ? whiteSliderCount : blackSliderCount
    }

    /// Recomputes the state derived from the board: the Zobrist hash, material totals and slider
    /// counts.
    ///
    /// These are maintained incrementally by `makeMove`/`unmakeMove`, which only the CPU search
    /// uses. Real moves go through `GameScene.finalizeMove`, which writes pieces through the board
    /// subscript — and the subscript maintains none of them, so they drifted from the board for the
    /// whole game. Only the two initialisers ever recomputed them.
    ///
    /// Cheap enough to call once per played move (a single pass over 91 tiles); the incremental
    /// path still exists because search does this thousands of times per second.
    mutating func refreshDerivedState() {
        (whiteMaterial, blackMaterial) = GameState.computeMaterial(for: board)
        (whiteSliderCount, blackSliderCount) = GameState.computeSliderCounts(for: board)
        zobristHash = GameState.computeZobristHash(for: board)
    }

    mutating func recordPromotion(for color: String) {
        if color == "white" { whitePromotionCount += 1 } else { blackPromotionCount += 1 }
    }

    func promotionCount(for color: String) -> Int {
        return color == "white" ? whitePromotionCount : blackPromotionCount
    }

    mutating func recordPutInCheck(_ color: String) {
        if color == "white" { whiteTimesPutInCheck += 1 } else { blackTimesPutInCheck += 1 }
    }

    func timesPutInCheck(_ color: String) -> Int {
        return color == "white" ? whiteTimesPutInCheck : blackTimesPutInCheck
    }

    /// Turns taken so far, counting each player's move as one turn. HexPgn is a single variant
    /// byte followed by two bytes per move, so this is just its move count.
    var turnCount: Int {
        return max(0, (HexPgn.count - 1) / 2)
    }

    /// Identifies the current position for repetition purposes: the piece-placement hash with the
    /// side to move folded in, since the same placement with the other player to move is a
    /// different position. Matches the key `GameCPU` uses for its transposition table.
    ///
    /// Only meaningful while `zobristHash` is current — see `refreshDerivedState()`.
    var repetitionKey: UInt64 {
        return currentPlayer == "black" ? zobristHash ^ GameState.zobristBlackToMove : zobristHash
    }

    /// Records the position reached after a move. Call *after* the side to move has been flipped,
    /// so the key describes whose turn it now is.
    ///
    /// A capture or pawn move is irreversible: it resets the 50-move counter and makes every
    /// earlier position unreachable, so the history is cleared rather than appended to.
    mutating func recordPositionAfterMove(wasCapture: Bool, wasPawnMove: Bool) {
        if wasCapture || wasPawnMove {
            halfmoveClock = 0
            positionHistory.removeAll(keepingCapacity: true)
        } else {
            halfmoveClock += 1
        }
        positionHistory.append(repetitionKey)
    }

    /// How many times the current position has occurred this game.
    func currentPositionRepetitionCount() -> Int {
        let key = repetitionKey
        return positionHistory.reduce(0) { $0 + ($1 == key ? 1 : 0) }
    }

    /// Fifty moves by each player with no capture and no pawn move.
    var isFiftyMoveDraw: Bool {
        return halfmoveClock >= 100
    }

    /// The current position has now occurred three times.
    var isThreefoldRepetition: Bool {
        return currentPositionRepetitionCount() >= 3
    }

    /// A stable key for `color`'s opening move, or nil if that side hasn't moved yet. Same HexPgn
    /// layout as `turnCount`: one variant byte, then two bytes per move, so White's first move sits
    /// at 1...2 and Black's at 3...4. Backs the Hexperimenter achievement.
    func openingKey(for color: String) -> String? {
        let offset = color == "white" ? 1 : 3
        guard HexPgn.count >= offset + 2 else { return nil }
        return "\(HexPgn[offset])-\(HexPgn[offset + 1])"
    }

    /// Pieces each side starts with in Glinski's: 9 pawns, 3 bishops, 2 rooks, 2 knights,
    /// 1 queen, 1 king. Kept next to `setInitialPiecePositions` so the two stay in sync —
    /// the Tactical Hexcellence achievement compares against it.
    static let startingPieceCountPerSide = 18

    mutating func setInitialPiecePositions() { //when enabling variants, this is private mutating func setGlinskisPiecePositions()
        let initialPositions: [((Int, Int), Piece)] = [
            ((1, 6), Piece(color: "black", type: "pawn")),
            ((2, 6), Piece(color: "black", type: "pawn")),
            ((3, 6), Piece(color: "black", type: "pawn")),
            ((4, 6), Piece(color: "black", type: "pawn")),
            ((5, 6), Piece(color: "black", type: "pawn")),
            ((6, 6), Piece(color: "black", type: "pawn")),
            ((7, 6), Piece(color: "black", type: "pawn")),
            ((8, 6), Piece(color: "black", type: "pawn")),
            ((9, 6), Piece(color: "black", type: "pawn")),
            ((1, 0), Piece(color: "white", type: "pawn")),
            ((2, 1), Piece(color: "white", type: "pawn")),
            ((3, 2), Piece(color: "white", type: "pawn")),
            ((4, 3), Piece(color: "white", type: "pawn")),
            ((5, 4), Piece(color: "white", type: "pawn")),
            ((6, 3), Piece(color: "white", type: "pawn")),
            ((7, 2), Piece(color: "white", type: "pawn")),
            ((8, 1), Piece(color: "white", type: "pawn")),
            ((9, 0), Piece(color: "white", type: "pawn")),
            ((2, 7), Piece(color: "black", type: "rook")),
            ((8, 7), Piece(color: "black", type: "rook")),
            ((3, 8), Piece(color: "black", type: "knight")),
            ((4, 9), Piece(color: "black", type: "queen")),
            ((5, 10), Piece(color: "black", type: "bishop")),
            ((5, 9), Piece(color: "black", type: "bishop")),
            ((5, 8), Piece(color: "black", type: "bishop")),
            ((6, 9), Piece(color: "black", type: "king")),
            ((7, 8), Piece(color: "black", type: "knight")),
            ((2, 0), Piece(color: "white", type: "rook")),
            ((3, 0), Piece(color: "white", type: "knight")),
            ((4, 0), Piece(color: "white", type: "queen")),
            ((5, 0), Piece(color: "white", type: "bishop")),
            ((5, 1), Piece(color: "white", type: "bishop")),
            ((5, 2), Piece(color: "white", type: "bishop")),
            ((6, 0), Piece(color: "white", type: "king")),
            ((7, 0), Piece(color: "white", type: "knight")),
            ((8, 0), Piece(color: "white", type: "rook"))
        ]
        
        for ((col, row), piece) in initialPositions {
            self[col, row] = piece
        }
    }
/*
    mutating func setInitialPiecePositions() { //for checkmate testing
        let initialPositions: [((Int, Int), Piece)] = [
            ((1, 1), Piece(color: "white", type: "pawn")),
            ((1, 4), Piece(color: "white", type: "pawn")),
            ((2, 5), Piece(color: "white", type: "king")),
            ((5, 8), Piece(color: "black", type: "king")),
            ((4, 0), Piece(color: "white", type: "rook")),
            //((5, 0), Piece(color: "white", type: "rook")),
            ((6, 0), Piece(color: "white", type: "rook")),
            ((7, 0), Piece(color: "white", type: "rook")),
            ((8, 0), Piece(color: "white", type: "rook")),
            //((9, 6), Piece(color: "white", type: "rook")),
            //((6, 2), Piece(color: "white", type: "pawn")),
            ((7, 0), Piece(color: "white", type: "knight")),
            ((7, 5), Piece(color: "white", type: "rook")),
            ((8, 4), Piece(color: "white", type: "rook")),
            ((9, 2), Piece(color: "white", type: "rook")),
        ]
        
        for ((col, row), piece) in initialPositions {
            self[col, row] = piece
        }
    }*/
/*
    mutating func setInitialPiecePositions() { // for pawn promotion testing
        let initialPositions: [((Int, Int), Piece)] = [
            // White pawns ready to promote
            ((0, 3), Piece(color: "white", type: "pawn")),
            ((1, 4), Piece(color: "white", type: "pawn")),
            ((2, 5), Piece(color: "white", type: "pawn")),
            ((3, 6), Piece(color: "white", type: "pawn")),
            ((4, 7), Piece(color: "white", type: "pawn")),
            ((5, 8), Piece(color: "white", type: "pawn")),
            ((6, 7), Piece(color: "white", type: "pawn")),
            ((7, 6), Piece(color: "white", type: "pawn")),
            ((8, 5), Piece(color: "white", type: "pawn")),
            ((9, 4), Piece(color: "white", type: "pawn")),
            ((10, 3), Piece(color: "white", type: "pawn")),
            
            //the kings
            ((1, 3), Piece(color: "white", type: "king")),
            ((9, 3), Piece(color: "black", type: "king")),
            
            // Black pawns ready to promote
            ((0, 2), Piece(color: "black", type: "pawn")),
            ((1, 2), Piece(color: "black", type: "pawn")),
            ((2, 2), Piece(color: "black", type: "pawn")),
            ((3, 2), Piece(color: "black", type: "pawn")),
            ((4, 2), Piece(color: "black", type: "pawn")),
            ((5, 2), Piece(color: "black", type: "pawn")),
            ((6, 2), Piece(color: "black", type: "pawn")),
            ((7, 2), Piece(color: "black", type: "pawn")),
            ((8, 2), Piece(color: "black", type: "pawn")),
            ((9, 2), Piece(color: "black", type: "pawn")),
            ((10, 2), Piece(color: "black", type: "pawn")),
        ]
        
        for ((col, row), piece) in initialPositions {
            self[col, row] = piece
        }
    }*/

    mutating func movePiece(from: String, to: String, promotionPiece: Piece?) {
        let columns = hexColumns
        
        // Convert from and to positions to board indices
        guard let fromChar = from.first,
              let fromColumn = hexColumnIndex(for: fromChar),
              let fromRow = Int(from.dropFirst()),
              let toChar = to.first,
              let toColumn = hexColumnIndex(for: toChar),
              let toRow = Int(to.dropFirst()) else {
            return
        }

        // Adjust for 0-based indexing
        let fromColumnRow = (fromColumn, fromRow - 1)
        let toColumnRow = (toColumn, toRow - 1)
        
        var pieceToMove = self[fromColumnRow.0, fromColumnRow.1]

        if promotionPiece != nil {
            pieceToMove = promotionPiece
        }
        
        if pieceToMove?.type == "pawn" { // remove the opening bonus if it moved
            pieceToMove?.hasMoved = true //this modifies the actual pawn's metadata
            
            //dont forget to remove enpassant!
            if abs(fromColumnRow.0 - toColumnRow.0) == 1 { //if the pawn is moving to another row
                if self[toColumnRow.0, toColumnRow.1] == nil { //and the destination is empty, then it must be capturing en passant
                    if pieceToMove?.color == "white" {
                        self[toColumnRow.0, toColumnRow.1 - 1] = nil //remove the en passanted pawn
                    }
                    if pieceToMove?.color == "black" {
                        self[toColumnRow.0, toColumnRow.1 + 1] = nil //remove the en passanted pawn
                    }
                }
            }
        }
        
        self[fromColumnRow.0, fromColumnRow.1] = nil //[fromcolumn][fromrow] tbh we dont really need to redefine these
        self[toColumnRow.0, toColumnRow.1] = pieceToMove

        
        // Update king position if necessary
        if pieceToMove?.type == "king" {
            //print("updating king position from", from, "to", to)
            if pieceToMove?.color == "white" {
                whiteKingPosition = "\(columns[toColumn])\(toRow)"
            } else if pieceToMove?.color == "black" {
                blackKingPosition = "\(columns[toColumn])\(toRow)"
            }
        }
    }
    
    mutating func makeMove(_ from: String, to: String, promotionType: String = "queen") -> MoveUndoInfo { //able to undo this with the output info, not with movePiece()
        let fromColLetter = String(from.prefix(1))
        let fromRowString = String(from.dropFirst())
        let toColLetter = String(to.prefix(1))
        let toRowString = String(to.dropFirst())

        guard let fromColIndex = hexColumnIndex(for: fromColLetter),
              let toColIndex = hexColumnIndex(for: toColLetter),
              let fromRowIndex = Int(fromRowString).map({ $0 - 1 }),
              let toRowIndex = Int(toRowString).map({ $0 - 1 }) else {
            fatalError("Invalid move coordinates")
        }

        return makeMove(fromCol: fromColIndex, fromRow: fromRowIndex, toCol: toColIndex, toRow: toRowIndex, promotionType: promotionType)
    }

    // (col,row) fast path: skips the notation-string parse for callers (e.g. GameCPU's search
    // loop) that already have board indices in hand.
    mutating func makeMove(fromCol fromColIndex: Int, fromRow fromRowIndex: Int, toCol toColIndex: Int, toRow toRowIndex: Int, promotionType: String = "queen") -> MoveUndoInfo {
        let columns = hexColumns
        let movingPiece = self[fromColIndex, fromRowIndex]
        let capturedPiece = self[toColIndex, toRowIndex]
        let previousZobristHash = zobristHash

        // Update the board
        self[toColIndex, toRowIndex] = movingPiece
        self[fromColIndex, fromRowIndex] = nil
        
        var enPassantCapturedPiece: Piece? = nil
        var enPassantCapturedCol: Int? = nil
        var enPassantCapturedRow: Int? = nil

        if movingPiece?.type == "pawn" {
            self[toColIndex, toRowIndex]?.hasMoved = true
            if abs(fromRowIndex - toRowIndex) == 2 { //the pawn skipped a tile on its first turn
                self[toColIndex, toRowIndex]?.isEnPassantTarget = true //make it a target of en-passant
            }

            // En passant capture: pawn moves diagonally to an empty square
            if capturedPiece == nil && fromColIndex != toColIndex {
                if movingPiece?.color == "white" {
                    let epRow = toRowIndex - 1
                    if epRow >= 0 && self[toColIndex, epRow]?.isEnPassantTarget == true {
                        enPassantCapturedPiece = self[toColIndex, epRow]
                        enPassantCapturedCol = toColIndex
                        enPassantCapturedRow = epRow
                        self[toColIndex, epRow] = nil
                    }
                } else {
                    let epRow = toRowIndex + 1
                    if epRow < rowCount(forCol: toColIndex) && self[toColIndex, epRow]?.isEnPassantTarget == true {
                        enPassantCapturedPiece = self[toColIndex, epRow]
                        enPassantCapturedCol = toColIndex
                        enPassantCapturedRow = epRow
                        self[toColIndex, epRow] = nil
                    }
                }
            }

            if movingPiece?.color == "white" {
                if (toRowIndex == rowCount(forCol: toColIndex) - 1) { //it will be promoted!
                    self[toColIndex, toRowIndex]?.type = promotionType}
            } else { //...its black
                if (toRowIndex == 0) { //it will be promoted!
                    self[toColIndex, toRowIndex]?.type = promotionType}
            }
        }

        // Update king's position if necessary
        if movingPiece?.type == "king" {
            if movingPiece?.color == "white" {
                whiteKingPosition = "\(columns[toColIndex])\(toRowIndex + 1)"
            } else if movingPiece?.color == "black" {
                blackKingPosition = "\(columns[toColIndex])\(toRowIndex + 1)"
            }
        }

        // Keep running material totals in sync with the board
        if let captured = capturedPiece {
            adjustMaterial(for: captured.color, by: -pieceValue(captured.type))
            if GameState.isSlider(captured.type) {
                adjustSliderCount(for: captured.color, by: -1)
            }
        }
        if let epCaptured = enPassantCapturedPiece {
            adjustMaterial(for: epCaptured.color, by: -pieceValue(epCaptured.type))
            // en passant always captures a pawn, never a slider
        }
        if let moving = movingPiece, moving.type == "pawn",
           let promotedType = self[toColIndex, toRowIndex]?.type, promotedType != "pawn" {
            adjustMaterial(for: moving.color, by: pieceValue(promotedType) - pieceValue("pawn"))
            if GameState.isSlider(promotedType) {
                adjustSliderCount(for: moving.color, by: 1)
            }
        }

        // Update the Zobrist hash for the squares that changed: the moving piece leaves its
        // origin, any captured piece (regular or en passant) leaves the board, and the moving
        // piece (possibly promoted) arrives at its destination
        if let moving = movingPiece {
            zobristHash ^= GameState.zobristValue(colIndex: fromColIndex, rowIndex: fromRowIndex, piece: moving)
        }
        if let captured = capturedPiece {
            zobristHash ^= GameState.zobristValue(colIndex: toColIndex, rowIndex: toRowIndex, piece: captured)
        }
        if let epCaptured = enPassantCapturedPiece, let epCol = enPassantCapturedCol, let epRow = enPassantCapturedRow {
            zobristHash ^= GameState.zobristValue(colIndex: epCol, rowIndex: epRow, piece: epCaptured)
        }
        if let finalPiece = self[toColIndex, toRowIndex] {
            zobristHash ^= GameState.zobristValue(colIndex: toColIndex, rowIndex: toRowIndex, piece: finalPiece)
        }

        // Store undo information
        let undoInfo = MoveUndoInfo(
            fromColIndex: fromColIndex,
            fromRowIndex: fromRowIndex,
            toColIndex: toColIndex,
            toRowIndex: toRowIndex,
            movingPiece: movingPiece,
            capturedPiece: capturedPiece,
            enPassantCapturedPiece: enPassantCapturedPiece,
            enPassantCapturedCol: enPassantCapturedCol,
            enPassantCapturedRow: enPassantCapturedRow,
            previousZobristHash: previousZobristHash
        )

        return undoInfo
    }

    mutating func unmakeMove(_ from: String, to: String, undoInfo: MoveUndoInfo) {
        unmakeMove(undoInfo: undoInfo)
    }

    // (col,row) fast path: undoInfo already carries the board indices, so callers with no other
    // use for notation strings (e.g. GameCPU's search loop) can skip passing from/to entirely.
    mutating func unmakeMove(undoInfo: MoveUndoInfo) {
        // Reverse material/slider-count changes first, while the board still reflects any promotion that happened
        if let moving = undoInfo.movingPiece, moving.type == "pawn",
           let promotedType = self[undoInfo.toColIndex, undoInfo.toRowIndex]?.type, promotedType != "pawn" {
            adjustMaterial(for: moving.color, by: pieceValue("pawn") - pieceValue(promotedType))
            if GameState.isSlider(promotedType) {
                adjustSliderCount(for: moving.color, by: -1)
            }
        }
        if let captured = undoInfo.capturedPiece {
            adjustMaterial(for: captured.color, by: pieceValue(captured.type))
            if GameState.isSlider(captured.type) {
                adjustSliderCount(for: captured.color, by: 1)
            }
        }
        if let epCaptured = undoInfo.enPassantCapturedPiece {
            adjustMaterial(for: epCaptured.color, by: pieceValue(epCaptured.type))
        }

        zobristHash = undoInfo.previousZobristHash

        // Restore the board
        self[undoInfo.fromColIndex, undoInfo.fromRowIndex] = undoInfo.movingPiece
        self[undoInfo.toColIndex, undoInfo.toRowIndex] = undoInfo.capturedPiece

        // Restore en passant captured piece
        if let epPiece = undoInfo.enPassantCapturedPiece,
           let epCol = undoInfo.enPassantCapturedCol,
           let epRow = undoInfo.enPassantCapturedRow {
            self[epCol, epRow] = epPiece
        }

        // Restore the king's position if necessary
        if let movingPiece = undoInfo.movingPiece, movingPiece.type == "king" {
            let columns = hexColumns
            if movingPiece.color == "white" {
                whiteKingPosition = "\(columns[undoInfo.fromColIndex])\(undoInfo.fromRowIndex + 1)"
            } else if movingPiece.color == "black" {
                blackKingPosition = "\(columns[undoInfo.fromColIndex])\(undoInfo.fromRowIndex + 1)"
            }
        }
    }
    
    mutating func addMoveToHexPgn(from: String, to: String, promotionOffset: UInt8) {
        let originInt = positionStringToInt(position: from)
        let destinationInt = positionStringToInt(position: to)
        
        HexPgn.append(UInt8(originInt))
        HexPgn.append(UInt8(destinationInt + promotionOffset))
        
        //print(HexPgn) //for testing
        /*
        for value in HexPgn {
            // Convert each UInt8 to a binary string with leading zeros
            let binaryString = String(value, radix: 2).leftPadded(toLength: 8, withPad: "0")
            print(binaryString)
        }*/
    }
    
    func positionStringToInt(position: String) -> UInt8 {
        // Convert from and to positions to board indices
        guard let firstChar = position.first,
              let columnPos = hexColumnIndex(for: firstChar),
              var rowPos = Int(position.dropFirst()) else {
            return 0
        }

        rowPos -= 1 // Input String is not 0-indexed

        // Use the columnPos to fetch the corresponding offset
        let columnOffset = GameState.columnOffsets[columnPos]

        return UInt8(columnOffset + rowPos)
    }

    func positionIntToString(index: UInt8) -> String {
        let columns = hexColumns

        var remainingIndex = index
        var columnPos = 0

        // Find the correct column based on the index range
        for (i, size) in GameState.columnSizes.enumerated() {
            if remainingIndex < size {
                columnPos = i
                break
            }
            remainingIndex -= UInt8(size)
        }
        
        // Hexagon names are not 0-indexed, unlike their Int representations
        let rowPos = remainingIndex + 1
        
        // Combine column letter and row number into position string
        let columnLetter = columns[columnPos]
        return "\(columnLetter)\(rowPos)"
    }
    
    mutating func HexPgnToGameState(pgn: [UInt8]) -> GameState { //this assumes its operating on an blank gameState/new board
        guard pgn.count >= 1 else {
            //print("Invalid HexPgn: Not enough data")
            return self
        }
        
        self.HexPgn = pgn

        //let variant = pgn[0] //first uint8 is the variant identifier
        //print("Variant used: \(variant)") //0 means Glinkskis //rn thats default

        // Iterate through the remaining UInt8s in pairs (skipping the first one)
        for i in stride(from: 1, to: pgn.count, by: 2) {
            let fromIndex = pgn[i]
            let toIndex = pgn[i + 1]
            
            var adjustedIndex = UInt8(0)
            var promotionPiece: Piece?
            
            currentPlayer = (((i - 1) / 2) % 2 == 0) ? "white" : "black"
            
            if toIndex >= 91 { //pawn getting promoted! (90 is the highest normal index)
                if currentPlayer == "white" {
                    promotionPiece = getPromotionPiece(for: toIndex + 1)
                } else {
                    promotionPiece = getPromotionPiece(for: toIndex)
                }
                
                switch promotionPiece?.type {
                    case "queen":
                        adjustedIndex = 91
                    case "rook":
                        adjustedIndex = 92
                    case "bishop":
                        adjustedIndex = 93
                    case "knight":
                        adjustedIndex = 94
                    default:
                        adjustedIndex = 0
                    }
            }

            let fromPosition = positionIntToString(index: fromIndex)
            let toPosition = positionIntToString(index: toIndex - adjustedIndex)

            movePiece(from: fromPosition, to: toPosition, promotionPiece: promotionPiece)
        }
        
        // Determine the current player's turn based on the number of moves
        let moveCount = (pgn.count - 1) / 2
        currentPlayer = (moveCount % 2 == 0) ? "white" : "black"

        //printGameState()
        
        return self
    }
    
    func getPromotionPiece(for index: UInt8) -> Piece? { //helper function for HexPgnToGameState
        let queenPromotionIndexArray: [UInt8] = [91, 97, 104, 112, 121, 131, 142, 152, 161, 169, 176, 182]
        let rookPromotionIndexArray: [UInt8] = [92, 98, 105, 113, 122, 132, 143, 153, 162, 170, 177, 183]
        let bishopPromotionIndexArray: [UInt8] = [93, 99, 106, 114, 123, 133, 144, 154, 163, 171, 178, 184]
        let knightPromotionIndexArray: [UInt8] = [94, 100, 107, 115, 124, 134, 145, 155, 164, 172, 179, 185]
        
        if queenPromotionIndexArray.contains(index) {
            return Piece(color: currentPlayer, type: "queen")
        } else if rookPromotionIndexArray.contains(index) {
            return Piece(color: currentPlayer, type: "rook")
        } else if bishopPromotionIndexArray.contains(index) {
            return Piece(color: currentPlayer, type: "bishop")
        } else if knightPromotionIndexArray.contains(index) {
            return Piece(color: currentPlayer, type: "knight")
        }
        return nil
    }

    
    // (col,row) fast path: skips the notation-string parse for callers (e.g. GameCPU's search
    // loop) that already have board indices in hand.
    func pieceAt(col: Int, row: Int) -> Piece? {
        self[col, row]
    }

    func pieceAt(_ position: String) -> Piece? {
        let colLetter = String(position.prefix(1))
        let rowString = String(position.dropFirst())

        guard let colIndex = hexColumnIndex(for: colLetter),
              let rowIndex = Int(rowString).map({ $0 - 1 }) else {
            return nil
        }

        return pieceAt(col: colIndex, row: rowIndex)
    }

    mutating func setPiece(_ piece: Piece?, at position: String) {
        let colLetter = String(position.prefix(1))
        let rowString = String(position.dropFirst())

        guard let colIndex = hexColumnIndex(for: colLetter),
              let rowIndex = Int(rowString).map({ $0 - 1 }) else {
            return
        }

        self[colIndex, rowIndex] = piece
    }
    
    func getPieces(for color: String) -> [Piece] {
        var pieces = [Piece]()

        for case let piece? in board where piece.color == color {
            pieces.append(piece)
        }

        return pieces
    }

    
    /*
    func findKingPosition(for color: String) -> String? {
        let kingPosition: String
        
        if color == "white" {
            kingPosition = self.whiteKingPosition
        } else {
            kingPosition = self.blackKingPosition
        }
        
        return kingPosition
    }*/
    
    mutating func findCheckingPieces(kingPosition: String, color: String) -> [String] {
        var checkingPieces: [String] = []
        let opponentColor = color == "white" ? "black" : "white"
        
        // Rook and Queen threats (straight-line moves)
        let rookMoves = validMovesForRook(color, at: kingPosition, in: self)
        for position in rookMoves {
            if let piece = pieceAt(position),
               piece.color == opponentColor,
               (piece.type == "rook" || piece.type == "queen") {
                checkingPieces.append(position)
            }
        }

        // Bishop and Queen threats (diagonal moves)
        let bishopMoves = validMovesForBishop(color, at: kingPosition, in: self)
        for position in bishopMoves {
            if let piece = pieceAt(position),
               piece.color == opponentColor,
               (piece.type == "bishop" || piece.type == "queen") {
                checkingPieces.append(position)
            }
        }

        // Knight threats (L-shaped moves)
        let knightMoves = validMovesForKnight(color, at: kingPosition, in: self)
        for position in knightMoves {
            if let piece = pieceAt(position),
               piece.color == opponentColor,
               piece.type == "knight" {
                checkingPieces.append(position)
            }
        }

        // Pawn threats (single-step diagonal moves towards the king)
        let pawnMoves = pawnPureCaptures(color, at: kingPosition, in: self)
        for position in pawnMoves {
            if let piece = pieceAt(position),
               piece.color == opponentColor,
               piece.type == "pawn" {
                checkingPieces.append(position)
            }
        }

        return checkingPieces
    }

    mutating func hasLegalMovesForCurrentPlayer() -> Bool {
        let columns = hexColumns
        for colIndex in 0..<GameState.columnSizes.count {
            for rowIndex in 0..<GameState.columnSizes[colIndex] {
                guard let piece = self[colIndex, rowIndex], piece.color == currentPlayer else { continue }
                let currentPosition = "\(columns[colIndex])\(rowIndex + 1)"
                // Generate pseudo-legal moves first, then test each one for a legal move,
                // stopping as soon as we find one instead of filtering the whole list up front.
                let pseudoMoves = validMovesForPiece(at: currentPosition, color: piece.color, type: piece.type, in: &self, skipKingCheck: true)
                for move in pseudoMoves {
                    let undoInfo = makeMove(currentPosition, to: move)
                    let kingInCheck = isKingInCheckUsingKingSight(for: piece.color, in: &self)
                    unmakeMove(currentPosition, to: move, undoInfo: undoInfo)
                    if !kingInCheck.0 {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    mutating func isGameOver() -> (Bool, String) {
        let kingPosition = currentPlayer == "white" ? whiteKingPosition : blackKingPosition

        // 1) Check if the current player is in check
        let checkingPieces = findCheckingPieces(kingPosition: kingPosition, color: currentPlayer)
        let inCheck = !checkingPieces.isEmpty

        // 2) Check if there are any valid moves for the current player
        let hasLegalMoves = hasLegalMovesForCurrentPlayer()

        if inCheck {
            if !hasLegalMoves {
                return (true, "checkmate")
            }
            let checkingPiecesText = checkingPieces.joined(separator: ", ") //could also use an array but I dont want to return 3 seperate data types i mean come on
            return (false, "check by \(checkingPiecesText)")
        } else if !hasLegalMoves {
            return (true, "stalemate")
        }

        // Checked only after checkmate and stalemate: a position that ends the game outright takes
        // precedence over a draw that happens to become available on the same move.
        if isThreefoldRepetition {
            return (true, "threefoldRepetition")
        }
        if isFiftyMoveDraw {
            return (true, "fiftyMoveRule")
        }

        return (false, "")  //the game can still be continued
    }
    
    func printGameState() { //just for debugging
        print("********** CURRENT GAME STATE: **********")
        let columns = hexColumns

        for colIndex in 0..<GameState.columnSizes.count {
            for rowIndex in 0..<GameState.columnSizes[colIndex] {
                if let piece = self[colIndex, rowIndex] {
                    print("Piece at \(columns[colIndex])\(rowIndex + 1): \(piece.color) \(piece.type)")
                } else {
                    print("No piece at \(columns[colIndex])\(rowIndex + 1)")
                }
            }
        }
    }
}

/// Serializes game-file writes so they can't outrace a delete issued after them.
///
/// `saveGameStateToFile` writes off the main thread while `deleteGameFile` removes the file
/// synchronously, and nothing ordered the two. `finalizeMove` does both in a single pass — every
/// move saves, and the game-over branch then deletes — so an in-flight save could land *after* the
/// delete and leave a finished game on disk, to be offered as a resumable game on next launch.
///
/// Chains each operation onto the previous one through a stored "tail" task rather than relying on
/// actor reentrancy: Swift makes no FIFO guarantee about the order suspended callers resume in, the
/// same reason `GameScene`'s `CPUSearchExecutor` chains explicitly instead of using a bare actor.
/// The lock only guards the tail pointer, so enqueuing is ordered by call order from any thread
/// while the file I/O itself still happens off the main thread.
final class GameFileStore: @unchecked Sendable {
    static let shared = GameFileStore()

    private let lock = NSLock()
    private var tail: Task<Void, Never>?

    private init() {}

    func enqueue(_ work: @escaping @Sendable () -> Void) {
        lock.lock()
        let previous = tail
        tail = Task.detached(priority: .utility) {
            await previous?.value
            work()
        }
        lock.unlock()
    }

    /// Waits for everything enqueued so far. Tests use this to make saves deterministic; without it
    /// a save from one test can land in the middle of the next one.
    func flush() async {
        await currentTail()?.value
    }

    /// Deliberately synchronous: taking an NSLock directly inside an async function is unavailable
    /// from asynchronous contexts and becomes an error under the Swift 6 language mode, so the
    /// locked read is kept in its own non-async function and only the `await` happens above.
    private func currentTail() -> Task<Void, Never>? {
        lock.lock()
        defer { lock.unlock() }
        return tail
    }
}

// hexPgn is a [UInt8] value copy, so encoding/writing it off the main thread is safe —
// no shared state with the live GameState is touched.
func saveGameStateToFile(hexPgn: [UInt8], to filename: String) {
    GameFileStore.shared.enqueue {
        let saveData = HexPgnSaveData(date: Date(), hexPgn: hexPgn)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601 // Standard format for date

        if let encoded = try? encoder.encode(saveData) {
            let url = getDocumentsDirectory().appendingPathComponent(filename)
            do {
                try encoded.write(to: url)
                //print("HexPgn saved to \(url.path)")
            } catch {
                print("Failed to save HexPgn: \(error.localizedDescription)")
            }
        }
    }
}

func loadGameStateFromFile(from filename: String) -> GameState? {
    let url = getDocumentsDirectory().appendingPathComponent(filename)
    if let data = try? Data(contentsOf: url) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let saveData = try? decoder.decode(HexPgnSaveData.self, from: data) {
            var gameState = GameState() // Initialize empty GameState
            gameState = gameState.HexPgnToGameState(pgn: saveData.hexPgn) // Rebuild from HexPgn
            //print("Game state loaded from \(url.path)")
            return gameState
        }
    }
    return nil
}

func deleteGameFile(filename: String) {
    // Removed twice, deliberately. The immediate removal keeps this function synchronous, so
    // anything that checks for the file straight afterwards (e.g. whether to offer "continue")
    // still sees it gone. The queued removal then runs after any save already in flight, so a
    // late write can't resurrect the file.
    removeGameFileNow(filename: filename)
    GameFileStore.shared.enqueue {
        removeGameFileNow(filename: filename)
    }
}

private func removeGameFileNow(filename: String) {
    let url = getDocumentsDirectory().appendingPathComponent(filename)
    guard FileManager.default.fileExists(atPath: url.path) else { return }

    do {
        try FileManager.default.removeItem(at: url)
        //print("Successfully deleted game file: \(url.path)")
    } catch {
        print("Failed to delete game file: \(error.localizedDescription)")
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

extension String {
    func leftPadded(toLength length: Int, withPad character: Character) -> String {
        let padding = String(repeating: character, count: max(0, length - self.count))
        return padding + self
    }
}

struct HexPgnSaveData: Codable {
    let date: Date
    let hexPgn: [UInt8]
}
