//
//  GameScene.swift
//  Chexx
//
//  Created by Sawyer Christensen on 6/24/24.
//

import SpriteKit
import UIKit //this and extensionUIColor could maybe be put in another file later. All this is is changing the tile color to a UIColor instance to be compatible with the HexagonNode class
import SwiftUI

class GameScene: SKScene {
    @AppStorage("highlightEnabled") private var highlightEnabled = true
    var isVsCPU: Bool = false       // To handle "vs CPU" mode
    var isPassAndPlay: Bool = false // To handle "Pass & Play" mode
    
    var gameState: GameState!
    var hexagonSize: CGFloat = 50 //reset later when screen size is found

    // Colors for hexagon tiles (could be customized or adjusted based on settings)
    let light = UIColor(hex: "#ffce9e")
    let grey = UIColor(hex: "#e8ab6f")
    let dark = UIColor(hex: "#d18b47")

    var selectedPiece: SKSpriteNode?
    var originalPosition: CGPoint?
    var originalHexagonName: String?
    var validMoves: [String] = []
    var fiftyMoveRule = 0 // Still need to implement
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        // Center the scene
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Load the game state (if exists) or create a new one
        gameState = loadGameStateFromFile(from: "currentGameState") ?? GameState()

        // Calculate hexagon size based on screen size
        hexagonSize = min(self.size.width, self.size.height) * 0.05 // 5.5% of minimum screen dimension
        
        // Generate the board
        generateHexTiles(radius: hexagonSize, scene: self)
        
        // Place pieces on the board based on the game state
        placePieces(scene: self, gameState: gameState)
        
        // Adjust the game for specific modes
        if isVsCPU {
            setupVsCPUMode()
        }
    }
    
    func setupVsCPUMode() {
        // Set up AI logic or behavior here
        // For example, decide when the AI should make a move or interact with the gameState
        print("CPU mode activated")
    }
    
    enum Direction { //for use with calcualte new center
        case above
        case below
        case upperLeft
        case bottomLeft
        case upperRight
        case bottomRight
        case none
    }

    func calculateNewCenter(x: CGFloat, y: CGFloat, radius: CGFloat, direction: Direction) -> CGPoint { //helper function for manually creating the hexagon board (yuck)
        let angle = CGFloat.pi / 3 // 60 degrees
        switch direction {
        case .above:
            return CGPoint(x: x, y: y + 2 * radius * sin(angle))
        case .below:
            return CGPoint(x: x, y: y - 2 * radius * sin(angle))
        case .upperLeft:
            return CGPoint(x: x - radius * (1 + cos(angle)), y: y + radius * sin(angle))
        case .bottomLeft:
            return CGPoint(x: x - radius * (1 + cos(angle)), y: y - radius * sin(angle))
        case .upperRight:
            return CGPoint(x: x + radius * (1 + cos(angle)), y: y + radius * sin(angle))
        case .bottomRight:
            return CGPoint(x: x + radius * (1 + cos(angle)), y: y - radius * sin(angle))
        case .none:
            return CGPoint(x: x, y: y)
        }
    }

    func generateHexTiles(radius: CGFloat, scene: SKScene) {
        // Define hexagon colors
        let grey = UIColor(hex: "#e8ab6f")
        let light = UIColor(hex: "#ffce9e")
        let dark = UIColor(hex: "#d18b47")
        
        // Define a list of directions to generate hexagons around the center
        let directions: [(String, Direction, UIColor)] = [ //every hexagons name is SEPERATE from the gamestate data structure. every hexagons string address should remain a string
            ("f6", .none, grey),
            ("f7", .above, light),
            ("e6", .bottomLeft, dark),
            ("e5", .below, light),
            ("f5", .bottomRight, dark),
            ("g5", .upperRight, light),
            ("g6", .above, dark),
            ("g7", .above, grey),
            ("f8", .upperLeft, dark),
            ("e7", .bottomLeft, grey),
            ("d6", .bottomLeft, light),
            ("d5", .below, grey),
            ("d4", .below, dark),
            ("e4", .bottomRight, grey),
            ("f4", .bottomRight, light),
            ("g4", .upperRight, grey),
            ("h4", .upperRight, dark),
            ("h5", .above, grey),
            ("h6", .above, light),
            ("h7", .above, dark),
            ("g8", .upperLeft, light),
            ("f9", .upperLeft, grey),
            ("e8", .bottomLeft, light),
            ("d7", .bottomLeft, dark),
            ("c6", .bottomLeft, grey),
            ("c5", .below, dark),
            ("c4", .below, light),
            ("c3", .below, grey),
            ("d3", .bottomRight, light),
            ("e3", .bottomRight, dark),
            ("f3", .bottomRight, grey),
            ("g3", .upperRight, dark),
            ("h3", .upperRight, light),
            ("i3", .upperRight, grey),
            ("i4", .above, light),
            ("i5", .above, dark),
            ("i6", .above, grey),
            ("i7", .above, light),
            ("h8", .upperLeft, grey),
            ("g9", .upperLeft, dark),
            ("f10", .upperLeft, light),
            ("e9", .bottomLeft, dark),
            ("d8", .bottomLeft, grey),
            ("c7", .bottomLeft, light),
            ("b6", .bottomLeft, dark),
            ("b5", .below, light),
            ("b4", .below, grey),
            ("b3", .below, dark),
            ("b2", .below, light),
            ("c2", .bottomRight, dark),
            ("d2", .bottomRight, grey),
            ("e2", .bottomRight, light),
            ("f2", .bottomRight, dark),
            ("g2", .upperRight, light),
            ("h2", .upperRight, grey),
            ("i2", .upperRight, dark),
            ("k2", .upperRight, light),
            ("k3", .above, dark),
            ("k4", .above, grey),
            ("k5", .above, light),
            ("k6", .above, dark),
            ("k7", .above, grey),
            ("i8", .upperLeft, dark),
            ("h9", .upperLeft, light),
            ("g10", .upperLeft, grey),
            ("f11", .upperLeft, dark),
            ("e10", .bottomLeft, grey),
            ("d9", .bottomLeft, light),
            ("c8", .bottomLeft, dark),
            ("b7", .bottomLeft, grey),
            ("a6", .bottomLeft, light),
            ("a5", .below, grey),
            ("a4", .below, dark),
            ("a3", .below, light),
            ("a2", .below, grey),
            ("a1", .below, dark),
            ("b1", .bottomRight, grey),
            ("c1", .bottomRight, light),
            ("d1", .bottomRight, dark),
            ("e1", .bottomRight, grey),
            ("f1", .bottomRight, light),
            ("g1", .upperRight, grey),
            ("h1", .upperRight, dark),
            ("i1", .upperRight, light),
            ("k1", .upperRight, grey),
            ("l1", .upperRight, dark),
            ("l2", .above, grey),
            ("l3", .above, light),
            ("l4", .above, dark),
            ("l5", .above, grey),
            ("l6", .above, light)
        ]
        
        //initialize currentx & y position at the center of the screen
        var currentX = CGFloat(0)
        var currentY = CGFloat(0)
        
        // Hexagon array that will be added to the scene
        var hexagons: [HexagonNode] = []
        
        // Generate hexagons based on directions and colors
        for (key, direction, color) in directions {
            
            let newCenter = calculateNewCenter(x: currentX, y: currentY, radius: radius, direction: direction)
            currentX = newCenter.x
            currentY = newCenter.y
            
            let hexagon = HexagonNode(size: radius, color: color)
            hexagon.position = CGPoint(x: currentX, y: currentY)
            hexagon.name = key
            hexagons.append(hexagon)
        }
        
        // Add all hexagons to the scene
        for hexagon in hexagons {
            scene.addChild(hexagon)
        }
    }
    
    func placePieces(scene: SKScene, gameState: GameState? = nil) {
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        let state = gameState ?? GameState()

        for (colIndex, column) in state.board.enumerated() {
            for (rowIndex, piece) in column.enumerated() {
                if let piece = piece {
                    let position = "\(columns[colIndex])\(rowIndex + 1)"
                    let identifier = "\(position)_\(piece.color)_\(piece.type)"
                    if let hexagon = scene.childNode(withName: position) as? HexagonNode {
                        let pieceImage = "\(piece.color)_\(piece.type)"
                        hexagon.addPieceImage(named: pieceImage, identifier: identifier, isBoardRotated: boardIsRotated)
                    }
                }
            }
        }
    }

    // Touch Down
    func touchDown(atPoint pos: CGPoint) {
        // Check if the tap is outside the board and deselect the piece if necessary
        guard findNearestHexagon(to: pos) != nil else {
            deselectCurrentPiece()
            return
        }

        let nodesAtPoint = nodes(at: pos)
        for node in nodesAtPoint {
            if let pieceNode = node as? SKSpriteNode,
               let pieceDetails = pieceNode.name?.split(separator: "_"),
               pieceDetails.count > 1, // Ensure there is a color component
               let pieceColor = String(pieceDetails[1]) as String? {

                if pieceColor == gameState.currentPlayer {
                    if selectedPiece == pieceNode { // Tapped on the already selected piece, deselect it
                        deselectCurrentPiece()
                    } else { // Tapped on a different piece
                        deselectCurrentPiece()
                        selectNewPiece(pieceNode)
                    }
                    break
                } else {
                    print("It's not \(pieceColor)'s turn")
                }
            }
        }
    }

    // Touch Up
    func touchUp(atPoint pos: CGPoint) {
        guard let selectedPiece = selectedPiece else { return }

        if let parent = selectedPiece.parent, let nearestHexagon = findNearestHexagon(to: pos) {
            if validMoves.contains(nearestHexagon.name!) { // Valid destination
                updateGameState(with: selectedPiece, at: nearestHexagon.name)
                selectedPiece.position = parent.convert(nearestHexagon.position, from: self)
            } else if nearestHexagon.name != originalHexagonName { // Invalid destination
                selectedPiece.position = originalPosition!
            } else { // Original hexagon
                selectedPiece.position = originalPosition!
                return
            }
        } else { // Off the board
            selectedPiece.position = originalPosition!
        }

        // Common actions for deselecting the piece
        deselectCurrentPiece()
    }
    
    // Helper Methods
    private func selectNewPiece(_ pieceNode: SKSpriteNode) {
        // Store initial rotation before applying wobble effect
        pieceNode.userData = pieceNode.userData ?? NSMutableDictionary()
        pieceNode.userData?["initialRotation"] = pieceNode.zRotation
        
        pieceNode.setScale(1.25)
        selectedPiece = pieceNode
        originalPosition = pieceNode.position

        if let parentHexagon = pieceNode.parent as? HexagonNode {
            originalHexagonName = parentHexagon.name
        }

        // Extract piece details from the node's name
        if let pieceDetails = pieceNode.name?.split(separator: "_"), pieceDetails.count == 3 {
            let position = String(pieceDetails[0])
            let color = String(pieceDetails[1])
            let type = String(pieceDetails[2])
            
            validMoves = validMovesForPiece(at: position, color: color, type: type, in: gameState)
        } else {
            validMoves = []
        }

        // Highlight the valid moves
        highlightValidMoves(validMoves)

        // Apply wobble effect
        applyWobbleEffect(to: pieceNode)
    }

    private func deselectCurrentPiece() {
        if let currentSelectedPiece = selectedPiece {
            resetPiece(currentSelectedPiece)
            selectedPiece = nil
            originalHexagonName = nil
            clearHighlights()
            validMoves.removeAll()
        }
    }
    
    private func resetPiece(_ pieceNode: SKSpriteNode) {
        let initialRotation = pieceNode.userData?["initialRotation"] as? CGFloat ?? 0.0
        pieceNode.setScale(1.0)
        pieceNode.removeAction(forKey: "wobbleEffect")
        pieceNode.zRotation = initialRotation
    }

    private func applyWobbleEffect(to pieceNode: SKSpriteNode) {
        let wobbleLeft = SKAction.rotate(byAngle: .pi / 64, duration: 0.05)
        let wobbleRight = SKAction.rotate(byAngle: -.pi / 64, duration: 0.05)
        let wobble = SKAction.sequence([wobbleLeft, wobbleRight, wobbleRight, wobbleLeft])
        let wobbleRepeat = SKAction.repeatForever(wobble)
        pieceNode.run(wobbleRepeat, withKey: "wobbleEffect")
    }
    
    // Touch Moved
    func touchMoved(toPoint pos: CGPoint) {
        guard let selectedPiece = selectedPiece else { return }
        if let parent = selectedPiece.parent {
            let convertedPos = convert(pos, to: parent)
            selectedPiece.position = convertedPos
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchMoved(toPoint: t.location(in: self))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchUp(atPoint: t.location(in: self))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let selectedPiece = selectedPiece {
            selectedPiece.position = originalPosition!
            selectedPiece.setScale(1.0)
            self.selectedPiece = nil
            originalHexagonName = nil
            clearHighlights()
        }
    }
    
    func highlightValidMoves(_ validMoves: [String]) {
        guard highlightEnabled else { return }
        
        for hexTiles in validMoves {
            if let hexagon = childNode(withName: hexTiles) as? HexagonNode {
                let glowOverlay = SKShapeNode(path: hexagon.path!)
                glowOverlay.fillColor = UIColor.yellow.withAlphaComponent(0.3)
                glowOverlay.strokeColor = UIColor.yellow
                glowOverlay.lineWidth = 4
                glowOverlay.zPosition = 1
                glowOverlay.name = "glowOverlay"
                
                hexagon.addChild(glowOverlay)
                
                let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.8)
                let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.8)
                let pulse = SKAction.sequence([fadeOut, fadeIn])
                let repeatPulse = SKAction.repeatForever(pulse)
                glowOverlay.run(repeatPulse)
            }
        }
    }

    func clearHighlights() {
        for node in children {
            if let hexagon = node as? HexagonNode {
                hexagon.childNode(withName: "glowOverlay")?.removeFromParent() // remove the glowing overlay if it exists
            }
        }
    }

    func findNearestHexagon(to position: CGPoint) -> HexagonNode? {
        var closestHexagon: HexagonNode?
        var minDistance = CGFloat.greatestFiniteMagnitude
        for node in children {
            if let hexagon = node as? HexagonNode {
                let distance = hypot(hexagon.position.x - position.x, hexagon.position.y - position.y)
                if distance < minDistance {
                    minDistance = distance
                    closestHexagon = hexagon
                }
            }
        }
        // Check if the closest hexagon is within the size of a hexagon
        if minDistance <= hexagonSize {
            return closestHexagon
        } else {
            return nil
        }
    }
    
    func updateGameState(with pieceNode: SKSpriteNode, at hexagonName: String?) { //still need to implement game status such as "ongoing" or "ended"
        guard let hexagonName = hexagonName else {
            print("Hexagon name is nil")
            return
        }
        
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        let columnLetter = hexagonName.prefix(1)
        let rowIndexString = hexagonName.dropFirst()
        
        guard let colIndex = columns.firstIndex(of: String(columnLetter)),
              var rowIndex = Int(rowIndexString) else { return }
        rowIndex = rowIndex - 1 //rowIndex is originally not 0 indexed, have to - 1
        
        // Check if pieceNode.name is not nil and split it to find original position
        guard let pieceDetails = pieceNode.name?.split(separator: "_"),
            pieceDetails.count == 3 else {
            print("Invalid piece identifier")
            return
        }
        
        let originalPosition = pieceDetails[0]
        guard let originalColIndex = columns.firstIndex(of: String(originalPosition.first!)),
              var originalRowIndex = Int(String(originalPosition.dropFirst())) else {
            print("Invalid original position")
            return
        }
        originalRowIndex = originalRowIndex - 1 //originalRowIndex is originally not 0 indexed, have to - 1)
        
        // Get piece details from identifier
        let color = String(pieceDetails[1])
        var type = String(pieceDetails[2]) // would be let, but is var just in case of pawn promotion. that is the *only* time type should change
        
        
        // Ensure the move is made by the current player (touchDown should catch this first!)
        guard color == gameState.currentPlayer else {
            //print("It's not \(color)'s turn")
            return
        }
        //print("Moving \(color) \(type) from \(originalPosition) to \(hexagonName)")

        if type == "pawn" {
            fiftyMoveRule = 0
        }
        
        //********** CAPTURING ********** // STILL NEED TO CHECK IF A KING IS CAPTURED & END THE GAME
        if let capturedPiece = gameState.board[colIndex][rowIndex] {//of type Piece (can get rid of this outer if statement/varaible declaration if were not printing the below statement
            print("Captured piece at \(hexagonName): \(capturedPiece.color) \(capturedPiece.type)")
            
            //remove the piecenode at the designation hexagon, note this is different than updating the board state, but we take care of that later
            if let capturedPieceNode = findPieceNode(at: hexagonName) { //of type SKSpriteNode
                capturedPieceNode.removeFromParent()
            }
            fiftyMoveRule = 0
        }
            //Capturing logic for En Passant
            if color == "white" && type == "pawn" && gameState.board[colIndex][rowIndex - 1]?.isEnPassantTarget == true {
                if let capturedPieceNode = findPieceNode(at: "\(columnLetter)\(rowIndex)") { //un-zero index it for addressing hexagons
                    capturedPieceNode.removeFromParent()
                    gameState.board[colIndex][rowIndex - 1] = nil //also have to update the board state!
                    fiftyMoveRule = 0
                }
            }
            if color == "black" && type == "pawn" && gameState.board[colIndex][rowIndex + 1]?.isEnPassantTarget == true {
                if let capturedPieceNode = findPieceNode(at: "\(columnLetter)\(rowIndex + 2)") { //un-zero index it for addressing hexagons
                    capturedPieceNode.removeFromParent()
                    gameState.board[colIndex][rowIndex + 1] = nil
                    fiftyMoveRule = 0
                }
            }
        
        // Pawn promotion logic without blocking the main thread
        if (color == "white" && type == "pawn" && rowIndex == gameState.board[colIndex].count - 1) ||
           (color == "black" && type == "pawn" && rowIndex == 0) {
            presentPromotionOptions { newType in
                type = newType // Update the piece type to the chosen promotion type
                self.finalizeMove(pieceNode, type, hexagonName, originalColIndex, originalRowIndex, colIndex, rowIndex)
            }
            return
        }

        // Move logic for non-promotion case
        finalizeMove(pieceNode, type, hexagonName, originalColIndex, originalRowIndex, colIndex, rowIndex)
    }

    //the only reason this function exists is because the user picking pawn promotion has to happen before the rest of this function executes. making the rest of updateGameState it's own function does this. you there is a way to freeze updateGameState from executing that could be another way of doing this
    func finalizeMove(_ pieceNode: SKSpriteNode, _ type: String, _ hexagonName: String, _ originalColIndex: Int, _ originalRowIndex: Int, _ colIndex: Int, _ rowIndex: Int) {
        gameState.board[originalColIndex][originalRowIndex] = nil
        gameState.board[colIndex][rowIndex] = Piece(color: gameState.currentPlayer, type: type, hasMoved: true)
        
        if type == "pawn" && (abs(rowIndex - originalRowIndex) == 2) {
            gameState.board[colIndex][rowIndex] = Piece(color: gameState.currentPlayer, type: type, hasMoved: true, isEnPassantTarget: true)
        }
        
        pieceNode.name = "\(hexagonName)_\(gameState.currentPlayer)_\(type)"
        pieceNode.removeFromParent()
        
        let newHexagonParent = childNode(withName: hexagonName) as? HexagonNode
        newHexagonParent?.addPieceImage(named: "\(gameState.currentPlayer)_\(type)", identifier: pieceNode.name!, isBoardRotated: boardIsRotated)

        if isPassAndPlay {
            rotateBoard()
            rotateAllPieces()
        }
        
        let opponentColor = gameState.currentPlayer == "white" ? "black" : "white"
        if isKingInCheck(for: opponentColor) {
            print("Check! for...", opponentColor)
            // Additional logic to handle check... NEED TO IMPLEMENT
        }
        
        fiftyMoveRule += 1
        gameState.currentPlayer = opponentColor
        resetEnPassant(for: gameState.currentPlayer)
    }
    
    var boardIsRotated: Bool = false // This will track if the board is rotated by 180 degrees
    
    func rotateBoard() {
        boardIsRotated.toggle()
        UIView.animate(withDuration: 0.5) {
            self.view?.transform = (self.view?.transform.rotated(by: .pi))!
        }
    }
    
    func rotateAllPieces() {
        let rotateAction = SKAction.rotate(byAngle: .pi, duration: 0.5) // Rotate 180 degrees

        for node in children {
            if let hexagon = node as? HexagonNode {
                for pieceNode in hexagon.children {
                    if let pieceNode = pieceNode as? SKSpriteNode {
                        pieceNode.run(rotateAction)
                    }
                }
            }
        }
    }
    
    func presentPromotionOptions(completion: @escaping (String) -> Void) {
        if let viewController = self.view?.window?.rootViewController {
            let promotionViewController = UIHostingController(rootView: PromotionView(completion: completion))
            promotionViewController.modalPresentationStyle = .overCurrentContext
            promotionViewController.view.backgroundColor = .clear // Make the background transparent
            viewController.present(promotionViewController, animated: true, completion: nil)
        }
    }
    
    func findPieceNode(at hexagonName: String) -> SKSpriteNode? { //helper function for removing captured pieces in updateGameState
        if let hexagon = childNode(withName: hexagonName) as? HexagonNode,
               let pieceNode = hexagon.children.first as? SKSpriteNode {
                return pieceNode
            }
            return nil
        }
    
    func findKingPosition(for color: String) -> String? {
        print("\n")
        print("Current King search:", color)
        for (colIndex, column) in gameState.board.enumerated() {
            for (rowIndex, piece) in column.enumerated() {
                if let piece = piece, piece.type == "king" && piece.color == color {
                    let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
                    return "\(columns[colIndex])\(rowIndex + 1)"
                }
            }
        }
        return nil
    }
    
    func generateAllOpponentMoves(for color: String) -> [String] {
        var opponentMoves: [String] = []
        
        // Define the columns of your board
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        
        // Determine the opponent's color
        let opponentColor = color == "white" ? "black" : "white"
        //print("Generating moves for opponent color:", opponentColor)
        
        for (colIndex, column) in gameState.board.enumerated() {
            for (rowIndex, piece) in column.enumerated() {
                if let piece = piece, piece.color == opponentColor {
                    let currentPosition = "\(columns[colIndex])\(rowIndex + 1)"
                    //print("Checking piece at \(currentPosition): \(piece.type) \(piece.color)")
                    
                    // Directly call validMovesForPiece with the piece's details
                    let validMoves = validMovesForPiece(at: currentPosition, color: piece.color, type: piece.type, in: gameState)
                    //print("Valid moves for \(piece.type) at \(currentPosition):", validMoves)
                    
                    opponentMoves.append(contentsOf: validMoves)
                }
            }
        }
        
        //print("Generated opponent moves:", opponentMoves)
        return opponentMoves
    }
    
    func isKingInCheck(for color: String) -> Bool {
        guard let kingPosition = findKingPosition(for: color) else {
            print("\(color.capitalized) king not found!")
            return false
        }
        
        let opponentMoves = generateAllOpponentMoves(for: color)
        
        //print("CURRENT KING POSITION:", kingPosition)
        //print("ALL POSSIBLE ENEMY MOVES:", opponentMoves)
        
        return opponentMoves.contains(kingPosition)
    }
    
    func resetEnPassant(for color: String) {
        for (colIndex, column) in gameState.board.enumerated() {
            for (rowIndex, piece) in column.enumerated() {
                if var piece = piece, piece.color == color {
                    piece.isEnPassantTarget = false
                    gameState.board[colIndex][rowIndex] = piece
                }
            }
        }
    }
    
    func printGameState() { //just for bug fixing
        print("********** CURRENT GAME STATE: **********")
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        
        for (colIndex, column) in gameState.board.enumerated() {
            for (rowIndex, piece) in column.enumerated() {
                if let piece = piece {
                    print("Piece at \(columns[colIndex])\(rowIndex + 1): \(piece.color) \(piece.type)")
                } else {
                    print("No piece at \(columns[colIndex])\(rowIndex + 1)")
                }
            }
        }
    }
    
}

extension UIColor {
    convenience init(hex: String) {
        let hexString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.currentIndex = hexString.index(after: hexString.startIndex)
        }
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}


class HexagonNode: SKShapeNode {
    
    static func createHexagonPath(size: CGFloat) -> CGPath {
        let path = UIBezierPath()
        let angle: CGFloat = .pi / 3
        for i in 0..<6 {
            let x = size * cos(angle * CGFloat(i))
            let y = size * sin(angle * CGFloat(i))
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        return path.cgPath
    }
    
    init(size: CGFloat, color: UIColor) {
        super.init()
        self.path = HexagonNode.createHexagonPath(size: size)
        self.fillColor = color
        self.strokeColor = color
        self.lineWidth = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addPieceImage(named imageName: String, identifier: String, isBoardRotated: Bool) {
        let texture = SKTexture(imageNamed: imageName)
        let pieceNode = SKSpriteNode(texture: texture)
        pieceNode.name = identifier
        
        let hexWidth = self.frame.size.width * 0.85// - lineWidth //need to subtract linewidth if you change the linewidth of the PARENT hexagon, fixed with glowOverlay
        pieceNode.size = CGSize(width: hexWidth, height: hexWidth)
        //print(pieceNode.size)
        pieceNode.position = CGPoint(x: 0, y: 0)
        pieceNode.zPosition = 2
        
        if isBoardRotated {
            pieceNode.zRotation = .pi
        }
        self.addChild(pieceNode)
    }
}