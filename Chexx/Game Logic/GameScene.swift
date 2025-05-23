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
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("lowMotionEnabled") private var lowMotionEnabled = false
    
    let audioManager = AudioManager()
    var isVsCPU: Bool
    var isPassAndPlay: Bool
    var isOnlineMultiplayer: Bool
    var onRematch: (() -> Void)?
    //var variant: String = "Glinkski's"
    
    var gameState: GameState! //not sure if we need this, but we need to define it anyway, might as well define an init gamestate
    var hexPgn: [Int] = [0]
    var gameCPU: GameCPU!
    
    var hexagonSize: CGFloat = 50 //reset later when screen size is found
    // Colors for hexagon tiles (could be customized or adjusted based on settings)
    let light = UIColor(hex: "#ffce9e")
    let grey = UIColor(hex: "#e8ab6f")
    let dark = UIColor(hex: "#d18b47")

    var selectedPiece: SKSpriteNode?
    var originalPosition: CGPoint?
    var originalHexagonName: String?
    var validMoves: [String] = []
    //var fiftyMoveRule = 0 // Still need to implement
    
    var redStatusTextUpdater: ((String) -> Void)?
    var whiteStatusTextUpdater: ((String) -> Void)?
    var whiteStatusTextMiniUpdater: ((String) -> Void)?
    
    init(size: CGSize, isVsCPU: Bool, isPassAndPlay: Bool, isOnlineMultiplayer: Bool) {
        self.isVsCPU = isVsCPU
        self.isPassAndPlay = isPassAndPlay
        self.isOnlineMultiplayer = isOnlineMultiplayer
        super.init(size: size)
    }

    // Required initializer for loading from a storyboard or nib
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5) //centers the scene
        
        // Load the game state (if exists) or create a new one
        if isPassAndPlay {
            gameState = loadGameStateFromFile(from: "currentPassAndPlay") ?? GameState()
        } else if isVsCPU {
            gameState = loadGameStateFromFile(from: "currentSinglePlayer") ?? GameState()
            gameCPU = GameCPU(difficulty: CPUDifficulty.hard)
        } else if isOnlineMultiplayer {
            gameState = GameState()
        } else {
            print("No game mode detected!")
        }
        
        hexagonSize = min(self.size.width, self.size.height) * 0.05 // 5.5% of minimum screen dimension
        
        generateHexTiles(radius: hexagonSize, scene: self)
        
        placePieces(scene: self, gameState: gameState)
        
        onRematch = { //if the rematch button was pressed...
            self.gameState = GameState() //reset the game state
            
            self.removeAllPieces(scene: self) //clear the board
            self.clearValidMoveHighlights()
            self.clearCheckHighlights()
            
            self.placePieces(scene: self, gameState: self.gameState) //place all pieces in original positions
            
            if self.boardIsRotated { //if the board is rotated in Pass & Play mode, unrotate it
                self.boardIsRotated.toggle()
                self.rotateBoardImmediately()
                self.rotateAllPiecesImmediately()
            }
        }
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        if (isPassAndPlay && gameState.currentPlayer == "black") || (isOnlineMultiplayer && MultiplayerManager.shared.currentPlayerColor == "black") {
            rotateBoardImmediately()
            rotateAllPiecesImmediately()
        }
        
        if (isOnlineMultiplayer && gameState.currentPlayer == MultiplayerManager.shared.currentPlayerColor) {
            self.whiteStatusTextMiniUpdater?(NSLocalizedString("Your turn", comment: ""))
        } else {
            self.whiteStatusTextMiniUpdater?("")
        }
        
        if isOnlineMultiplayer {
            MultiplayerManager.shared.stopListening()
            
            MultiplayerManager.shared.startListeningForMoves { [weak self] hexPgn in
                //print("Recieved from server: \(hexPgn)")
                self?.applyHexPgn(hexPgn)
            }
        }
        
        //updateGameStatusUI(gameStatus: gameStatus) //this is also called in applyHexPgn
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
            scene.addChild(hexagon)
        }
        
        // Add all hexagons to the scene
        //for hexagon in hexagons {
        //    scene.addChild(hexagon)
        //}
    }
    
    func placePieces(scene: SKScene, gameState: GameState? = nil) { //o^2 time, can maybe be incorporated into an earlier function like generateHexTiles
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
    
    func removeAllPieces(scene: SKScene) {
        for node in scene.children {// Iterate over all hexagon nodes in the scene
            if let hexagon = node as? HexagonNode {
                // Remove all child nodes from the hexagon (these are the pieces)
                hexagon.removeAllChildren()
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

                if (pieceColor == gameState.currentPlayer &&
                    (!isVsCPU || gameState.currentPlayer == "white") &&
                    (!isOnlineMultiplayer || pieceColor == MultiplayerManager.shared.currentPlayerColor)) {
                    if selectedPiece == pieceNode { // Tapped on the already selected piece, deselect it
                        deselectCurrentPiece()
                    } else { // Tapped on a different piece
                        deselectCurrentPiece()
                        selectNewPiece(pieceNode)
                    }
                    break
                } //else {
                    //print("It's \(gameState.currentPlayer)'s turn")
                //}
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
            
            validMoves = validMovesForPiece(at: position, color: color, type: type, in: &gameState)
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
            clearValidMoveHighlights()
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
            clearValidMoveHighlights()
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
                glowOverlay.name = "validMovesOverlay"
                
                hexagon.addChild(glowOverlay)
                
                let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.8)
                let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.8)
                let pulse = SKAction.sequence([fadeOut, fadeIn])
                let repeatPulse = SKAction.repeatForever(pulse)
                glowOverlay.run(repeatPulse)
            }
        }
    }
    
    func highlightCheckStatus(for positions: [String]) {
        for position in positions {
            highlightCheckingPiece(at: position)
        }
    }
    
    func highlightCheckingPiece(at position: String) { //sdfsf
        if let hexagon = childNode(withName: position) as? HexagonNode {
            let glowOverlay = SKShapeNode(path: hexagon.path!)
            glowOverlay.fillColor = UIColor.red.withAlphaComponent(0.3)
            glowOverlay.strokeColor = UIColor.red
            glowOverlay.lineWidth = 4
            glowOverlay.zPosition = 1
            glowOverlay.name = "checkOverlay" //same as yellow highlights! might cause bugs!
            
            hexagon.addChild(glowOverlay)
            
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 0.8)
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.8)
            let pulse = SKAction.sequence([fadeOut, fadeIn])
            let repeatPulse = SKAction.repeatForever(pulse)
            glowOverlay.run(repeatPulse)
            
            redStatusTextUpdater?(NSLocalizedString("Check!", comment: ""))
        }
    }

    func clearValidMoveHighlights() {
        for node in children {
            if let hexagon = node as? HexagonNode {
                hexagon.childNode(withName: "validMovesOverlay")?.removeFromParent()
            }
        }
    }
    
    func clearCheckHighlights() {
        for node in children {
            if let hexagon = node as? HexagonNode {
                hexagon.childNode(withName: "checkOverlay")?.removeFromParent()
            }
        }
        redStatusTextUpdater?("")
    }

    func findNearestHexagon(to position: CGPoint) -> HexagonNode? { //o(n) time, calcualtes distance between EVERY hexagon on the board EVERY tap. can probably use a hash map to speed this up
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
    
    func updateGameState(with pieceNode: SKSpriteNode, at hexagonName: String?, promotionPiece: Piece? = nil) { //still need to implement game status such as "ongoing" or "ended"
        
        clearCheckHighlights() //this should also clear any status messages
        
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
        
        let originalPosition = String(pieceDetails[0])
        guard let originalColIndex = columns.firstIndex(of: String(originalPosition.first!)),
              var originalRowIndex = Int(String(originalPosition.dropFirst())) else {
            print("Invalid original position")
            return
        }
        
        /*print(originalPosition)
        print(gameState.positionStringToInt(position: originalPosition))
        print(hexagonName)
        print(gameState.positionStringToInt(position: hexagonName))*/
        
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
/*
        if type == "pawn" {
            fiftyMoveRule = 0
        }
*/
        //********** CAPTURING ********** //
        if let capturedPiece = gameState.board[colIndex][rowIndex] {//of type Piece (can get rid of this outer if statement/varaible declaration if were not printing the below statement
            //print("Captured piece at \(hexagonName): \(capturedPiece.color) \(capturedPiece.type)")
            
            //remove the piecenode at the designation hexagon, note this is different than updating the board state, but we take care of that later
            if let capturedPieceNode = findPieceNode(at: hexagonName) { //of type SKSpriteNode
                capturedPieceNode.removeFromParent()
            }
            //fiftyMoveRule = 0
        }
            //Capturing logic for En Passant
            if color == "white" && type == "pawn" && gameState.board[colIndex][rowIndex - 1]?.isEnPassantTarget == true {
                if let capturedPieceNode = findPieceNode(at: "\(columnLetter)\(rowIndex)") { //un-zero index it for addressing hexagons
                    capturedPieceNode.removeFromParent()
                    gameState.board[colIndex][rowIndex - 1] = nil 
                    //fiftyMoveRule = 0
                }
            }
            if color == "black" && type == "pawn" && gameState.board[colIndex][rowIndex + 1]?.isEnPassantTarget == true {
                if let capturedPieceNode = findPieceNode(at: "\(columnLetter)\(rowIndex + 2)") { //un-zero index it for addressing hexagons
                    capturedPieceNode.removeFromParent()
                    gameState.board[colIndex][rowIndex + 1] = nil
                    //fiftyMoveRule = 0
                }
            }
        
        // ********** PROMOTION LOGIC **********
        // If promotionPiece was passed in (i.e., from applyHexPgn), skip user/CPU selection:
        if let promo = promotionPiece {
            type = promo.type
            
            // Figure out offset for hexPgn
            let promotionOffsetInt: UInt8 = {
                switch type {
                case "queen":  return 91
                case "rook":   return 92
                case "bishop": return 93
                case "knight": return 94
                default:       return 0
                }
            }()
            
            // Finalize the move directly
            finalizeMove(pieceNode, color, type, originalPosition, hexagonName,
                         originalColIndex, originalRowIndex, colIndex, rowIndex,
                         promotionOffsetInt: promotionOffsetInt)
            return
        }
        else {
            // ********** EXISTING PROMOTION LOGIC (HUMAN/CPU) **********
            if (color == "white" && type == "pawn" && rowIndex == gameState.board[colIndex].count - 1)
                || (color == "black" && type == "pawn" && rowIndex == 0) {
                // CPU auto-queen
                if isVsCPU && color == "black" {
                    type = "queen"
                    finalizeMove(pieceNode, color, type, originalPosition, hexagonName,
                                 originalColIndex, originalRowIndex, colIndex, rowIndex,
                                 promotionOffsetInt: 91)
                }
                else {
                    // Show user promotion options
                    presentPromotionOptions { newType in
                        var promotionOffsetInt: UInt8 = 0
                        switch newType {
                        case "queen":  promotionOffsetInt = 91
                        case "rook":   promotionOffsetInt = 92
                        case "bishop": promotionOffsetInt = 93
                        case "knight": promotionOffsetInt = 94
                        default:       break
                        }
                        AchievementManager.shared.unlockAchievement(withID: "hextra_power")
                        GameCenterManager.shared.reportAchievement(identifier: "HextraPower")
                        if newType == "knight" {
                            AchievementManager.shared.unlockAchievement(withID: "hexcalibur")
                            GameCenterManager.shared.reportAchievement(identifier: "Hexcalibur")
                        }
                        // Then finalize move with user’s chosen promotion
                        //why does this need self specifically?
                        self.finalizeMove(pieceNode, color, newType, originalPosition, hexagonName,
                                     originalColIndex, originalRowIndex, colIndex, rowIndex,
                                     promotionOffsetInt: promotionOffsetInt)
                    }
                }
                return
            }
        }
        
        // ********** NORMAL (NON-PROMOTION) CASE **********
        finalizeMove(pieceNode, color, type, originalPosition, hexagonName,
                     originalColIndex, originalRowIndex, colIndex, rowIndex,
                     promotionOffsetInt: 0)
    }

    //the only reason this function exists is because the user picking pawn promotion has to happen before the rest of this function executes. making the rest of updateGameState it's own function does this. you there is a way to freeze updateGameState from executing that could be another way of doing this
    func finalizeMove(_ pieceNode: SKSpriteNode, _ color: String, _ type: String, _ originalPosition: String, _ hexagonName: String, _ originalColIndex: Int, _ originalRowIndex: Int, _ colIndex: Int, _ rowIndex: Int, promotionOffsetInt: UInt8) {
        
        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"] //jesus christ columns is defined in like every single function
        
        //MARK: - Move the piece
        //maybe use gamestate.movepiece function? rn this works
        gameState.board[originalColIndex][originalRowIndex] = nil
        gameState.board[colIndex][rowIndex] = Piece(color: gameState.currentPlayer, type: type, hasMoved: true)
        
        gameState.addMoveToHexPgn(from: originalPosition, to: hexagonName, promotionOffset: promotionOffsetInt)
        
        if isOnlineMultiplayer { //send move to cloud if online multiplayer and is our turn/move to send
            MultiplayerManager.shared.sendMove(hexPgn: gameState.HexPgn, currentTurn: gameState.currentPlayer)
        }
        
        if type == "king" {
            //print("updating king position from", from, "to", to)
            if color == "white" {
                gameState.whiteKingPosition = "\(columns[colIndex])\(rowIndex + 1)"
                if gameState.whiteKingPosition == "g10" { //achievement unlocked! (unlocks for both players, could maybe be more robust)
                    AchievementManager.shared.unlockAchievement(withID: "hexpedition")
                    GameCenterManager.shared.reportAchievement(identifier: "Hexpedition")
                }
            } else if color == "black" {
                gameState.blackKingPosition = "\(columns[colIndex])\(rowIndex + 1)"
                if gameState.blackKingPosition == "g1" && !isVsCPU { //at least this makes sure the cpu cant unlock it...
                    AchievementManager.shared.unlockAchievement(withID: "hexpedition")
                    GameCenterManager.shared.reportAchievement(identifier: "Hexpedition")
                }
            }
        }
        if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "piece_move", fileType: "mp3")}
        
        if type == "pawn" && (abs(rowIndex - originalRowIndex) == 2) {
            gameState.board[colIndex][rowIndex] = Piece(color: gameState.currentPlayer, type: type, hasMoved: true, isEnPassantTarget: true)
        }
        
        pieceNode.name = "\(hexagonName)_\(gameState.currentPlayer)_\(type)"//do we really need this??
        pieceNode.removeFromParent()
        
        let newHexagonParent = childNode(withName: hexagonName) as? HexagonNode
        newHexagonParent?.addPieceImage(named: "\(gameState.currentPlayer)_\(type)", identifier: pieceNode.name!, isBoardRotated: boardIsRotated)
        
        let opponentColor = gameState.currentPlayer == "white" ? "black" : "white"
        
        //fiftyMoveRule += 1 //still need to implement. should probably be apart of gamestate
        
        gameState.currentPlayer = opponentColor
        resetEnPassant(for: gameState.currentPlayer)
        
        if isPassAndPlay {
            if lowMotionEnabled {
                rotateBoardImmediately()
                rotateAllPiecesImmediately()
            } else {
                rotateBoard()
                rotateAllPieces()
            }
            saveGameStateToFile(hexPgn: gameState.HexPgn, to: "currentPassAndPlay")
        }
        
        // MARK: - Is the game over now?
        let (isGameOver, gameStatus) = gameState.isGameOver()
        
        if isGameOver {
            
            switch gameStatus {
    
            case "checkmate":
                let winnerColor = gameState.currentPlayer == "white" ? "black" : "white"
                let loserColor  = (winnerColor == "white") ? "black" : "white" //for achievements
                
                // If online, do Elo updates + sound effects
                if isOnlineMultiplayer {
                    let localUserId    = MultiplayerManager.shared.currentUserId
                    let opponentUserId = MultiplayerManager.shared.opponentId ?? ""
                    let localUserIsWinner = (winnerColor == MultiplayerManager.shared.currentPlayerColor)
                    
                    if localUserIsWinner {
                        if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "game_win", fileType: "mp3")}
                        AchievementManager.shared.unlockAchievement(withID: "hexceptional_win")
                        GameCenterManager.shared.reportAchievement(identifier: "HexceptionalWin")
                    } else {
                        if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "game_loss", fileType: "mp3")}
                    }

                    MultiplayerManager.shared.adjustElo(localUserId: localUserId, localUserIsWinner: localUserIsWinner, opponentUserId: opponentUserId) { oldLocalElo, newLocalElo in
                        
                        let diff = newLocalElo - oldLocalElo
                        let sign = diff >= 0 ? "+\(diff)" : "\(diff)" //need to add a plus sign if theres an increase
                       
                        let eloText = String(
                            format: NSLocalizedString(
                                "Your ELO rating changed from %d to %d (%@)",
                                comment: "Your ELO rating changed from {oldElo} to {newElo} ({+/- difference})."
                            ),
                            oldLocalElo,
                            newLocalElo,
                            sign
                        )
                        
                        // Now present the game-over window with the eloText
                        self.presentGameOverOptions(winner: winnerColor, method: "Checkmate", eloText: eloText
                        ) { action in
                            switch action {
                            case "viewBoard":
                                print("user decided to view the board") //need SOMETHING to execute after case
                            case "rematch":
                                self.onRematch?()
                            default:
                                break
                            }
                        }
                        MultiplayerManager.shared.finalizeGame()
                    }
                    
                    UserDefaults.standard.removeObject(forKey: "mostRecentGameId") //removes the "resume" button for online because the game has ended
                    
                } else { // its a single player game, so there is no elo adjustment
                    
                    if isPassAndPlay {
                        if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "game_win", fileType: "mp3")}
                        AchievementManager.shared.unlockAchievement(withID: "hexceptional_win")
                        GameCenterManager.shared.reportAchievement(identifier: "HexceptionalWin")
                        deleteGameFile(filename: "currentPassAndPlay")
                    }
                    
                    self.presentGameOverOptions(winner: winnerColor, method: "Checkmate", eloText: ""
                    ) { action in
                        switch action {
                        case "viewBoard":
                            print("user decided to view the board")
                        case "rematch":
                            self.onRematch?()
                        default:
                            break
                        }
                    }
                }
                
                // MARK: Hexecutioner Achievement
                let loserPieces = gameState.getPieces(for: loserColor)
                let nonKingPieces = loserPieces.filter { $0.type != "king" }
                if nonKingPieces.isEmpty && loserPieces.count == 1 { //the loser only has their king left!
                    AchievementManager.shared.unlockAchievement(withID: "hexecutioner")
                    GameCenterManager.shared.reportAchievement(identifier: "Hexecutioner")
                }
                
                // MARK: Hextreme Measures Achievement
                let winningKingPosition = (loserColor == "white") ? gameState.blackKingPosition : gameState.whiteKingPosition
                let losingKingPosition = (loserColor == "white") ? gameState.whiteKingPosition : gameState.blackKingPosition
                
                let loserKingWouldBeValidMoves = validMovesForPiece(at: losingKingPosition, color: loserColor, type: "king", in: &gameState, skipKingCheck: true)
                let winnerKingWouldBeValidMoves = validMovesForPiece(at: winningKingPosition, color: winnerColor, type: "king", in: &gameState, skipKingCheck: true)
                let loserKingMovesSet = Set(loserKingWouldBeValidMoves)
                let winnerKingMovesSet = Set(winnerKingWouldBeValidMoves)
                let overlappingMoves = loserKingMovesSet.intersection(winnerKingMovesSet)

                if !overlappingMoves.isEmpty {
                    //print("Overlapping pseudo-legal moves: \(overlappingMoves)")
                    AchievementManager.shared.unlockAchievement(withID: "hextreme_measures")
                    GameCenterManager.shared.reportAchievement(identifier: "HextremeMeasures")
                }
        
                // MARK: Hex Machina Achievement
                if isVsCPU {
                    if winnerColor == "white" {
                        if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "game_win", fileType: "mp3")}
                        AchievementManager.shared.unlockAchievement(withID: "hexceptional_win")
                        AchievementManager.shared.unlockAchievement(withID: "hex_machina")
                        GameCenterManager.shared.reportAchievement(identifier: "HexceptionalWin")
                        GameCenterManager.shared.reportAchievement(identifier: "HexMachina")
                    } else {
                        if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "game_loss", fileType: "mp3")}
                    }
                    deleteGameFile(filename: "currentSinglePlayer")
                }
                
                // MARK: Multiplayer Achievements
                if MultiplayerManager.shared.currentPlayerColor == winnerColor {
                    if winnerColor == "white" {
                        AchievementManager.shared.unlockAchievement(withID: "hexceeded_hexpectations")
                        GameCenterManager.shared.reportAchievement(identifier: "HexceededHexpectations")
                        //print("user joined the game")
                    } else { //the user is black, and created the game
                        AchievementManager.shared.unlockAchievement(withID: "friendly_hexchange")
                        GameCenterManager.shared.reportAchievement(identifier: "FriendlyHexchange")
                        //print("user created the game")
                    }
                }
                
                whiteStatusTextUpdater?("")
                //redStatusTextUpdater?("Checkmate!")
                gameState.gameStatus = "ended"
                return
                
            case "stalemate":
                let winnerColor = gameState.currentPlayer == "white" ? "black" : "white"
                
                // If online, do Elo updates
                if isOnlineMultiplayer {
                    let localUserId    = MultiplayerManager.shared.currentUserId
                    let opponentUserId = MultiplayerManager.shared.opponentId ?? ""
                    let localUserIsWinner = (winnerColor == MultiplayerManager.shared.currentPlayerColor)
                    
                    if localUserIsWinner {
                        if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "game_win", fileType: "mp3")}
                        AchievementManager.shared.unlockAchievement(withID: "hexceptional_win")
                        GameCenterManager.shared.reportAchievement(identifier: "HexceptionalWin")
                    } else {
                        if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "game_loss", fileType: "mp3")}
                    }
                    
                    MultiplayerManager.shared.adjustElo(localUserId: localUserId, localUserIsWinner: localUserIsWinner, opponentUserId: opponentUserId) { oldLocalElo, newLocalElo in

                        let diff = newLocalElo - oldLocalElo
                        let sign = diff >= 0 ? "+\(diff)" : "\(diff)" //need to add a plus sign if theres an increase
                       
                        let eloText = String(
                            format: NSLocalizedString(
                                "Your ELO rating changed from %d to %d (%@)",
                                comment: "Your ELO rating changed from {oldElo} to {newElo} ({+/- difference})."
                            ),
                            oldLocalElo,
                            newLocalElo,
                            sign
                        )
                        
                        // Now present the game-over window with the eloText
                        self.presentGameOverOptions(winner: winnerColor, method: "Stalemate", eloText: eloText
                        ) { action in
                            switch action {
                            case "viewBoard":
                                print("user decided to view the board")
                            case "rematch":
                                self.onRematch?()
                            default:
                                break
                            }
                        }
                        MultiplayerManager.shared.finalizeGame()
                    }
                    
                    UserDefaults.standard.removeObject(forKey: "mostRecentGameId")
                    
                } else { //its a single player game
                    if isVsCPU {
                        if winnerColor == "white" {
                            if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "game_win", fileType: "mp3")}
                            AchievementManager.shared.unlockAchievement(withID: "hexceptional_win")
                            GameCenterManager.shared.reportAchievement(identifier: "HexceptionalWin")
                        } else {
                            if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "game_loss", fileType: "mp3")}
                        }
                        deleteGameFile(filename: "currentSinglePlayer")
                    }
                    
                    if isPassAndPlay {
                        if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "game_win", fileType: "mp3")}
                        AchievementManager.shared.unlockAchievement(withID: "hexceptional_win")
                        GameCenterManager.shared.reportAchievement(identifier: "HexceptionalWin")
                        deleteGameFile(filename: "currentPassAndPlay")
                    }
                    
                    self.presentGameOverOptions(winner: winnerColor, method: "Stalemate", eloText: ""
                    ) { action in
                        switch action {
                        case "viewBoard":
                            print("user decided to view the board")
                        case "rematch":
                            self.onRematch?()
                        default:
                            break
                        }
                    }
                }
                
                whiteStatusTextUpdater?("")
                //redStatusTextUpdater?("Stalemate!")
                gameState.gameStatus = "ended"
                return
                
            default:
                break
            }
        }
        
        updateGameStatusUI(gameStatus: gameStatus)
        
        if isVsCPU && gameState.currentPlayer == "black" {
            self.whiteStatusTextUpdater?("Thinking.")
            let statusText = ["Thinking..", "Thinking...", "Thinking."]
            var currentIndex = 0
            let thinkingTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                self.whiteStatusTextUpdater?(statusText[currentIndex])
                currentIndex = (currentIndex + 1) % statusText.count
            }
            
            let delay: TimeInterval = gameCPU.difficulty == .hard ? 0.01 : 0.1 //delay isnt really needed
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + delay) {
                self.cpuMakeMove()
                
                // Once the CPU move is complete, stop the thinking timer and reset the status text on the main thread
                DispatchQueue.main.async {
                    thinkingTimer.invalidate() // Stop the timer
                    self.whiteStatusTextUpdater?("") // Clear the status text
                }
            }
        }
        
        if isVsCPU {
            saveGameStateToFile(hexPgn: gameState.HexPgn, to: "currentSinglePlayer")
        }
        
    }
    
    func cpuMakeMove() { //for single player, also moves the piece
        if let move = gameCPU.findMove(gameState: &gameState) {
            if let cpuPieceNode = findPieceNode(at: move.start) {
                if let destinationHexagon = self.childNode(withName: move.destination) {
                    if let parent = cpuPieceNode.parent {
                        let destinationPosition = parent.convert(destinationHexagon.position, from: self)
                        let slideAction = SKAction.move(to: destinationPosition, duration: 0.25)
                        //slideAction.timingMode = .linear
                        cpuPieceNode.run(slideAction)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in //pretty sure this improves the frame rate
                            guard let self = self else { return }
                            self.updateGameState(with: cpuPieceNode, at: move.destination)
                        }
                    }
                } else {
                    print("Error: Destination hexagon not found for \(move.destination)")
                }
            } else {
                print("Error: CPU's piece node not found at \(move.start)")
            }
        } else {
            // Handle no valid moves (e.g., checkmate or stalemate)
            print("CPU has no valid moves. Game over.") //change this!!!!!!!!!!!!!!!!! (checkmate detection before this might make it to that this never executes) (test)
            //redStatusTextUpdater?("CPU has no valid moves. Game over.")
            gameState.gameStatus = "ended"
        }
    }
    
    func applyHexPgn(_ hexPgn: [UInt8]) {
        // Exit early if hexPgn is unchanged or empty
        guard hexPgn != gameState.HexPgn, !hexPgn.isEmpty else {
            //print("same as stored, returning...")
            return
        }

        // If we need to reconstruct the entire game for reentry
        if gameState.HexPgn.count == 1, hexPgn.count >= 2 {
            var shortened_hexPgn = hexPgn
            shortened_hexPgn.removeLast(2)
            gameState = gameState.HexPgnToGameState(pgn: shortened_hexPgn)
            removeAllPieces(scene: self)
            placePieces(scene: self, gameState: gameState)
        }

        // Extract the last move's start and destination
        let startIndex = hexPgn[hexPgn.count - 2]
        let destinationIndex = hexPgn[hexPgn.count - 1]

        // -- PROMOTION LOGIC SAME AS HexPgnToGameState --
        var adjustedIndex: UInt8 = 0
        var promotionPiece: Piece? = nil

        // If the destinationIndex is >= 91, we know it's a promotion
        if destinationIndex >= 91 {
            let totalMoves = (hexPgn.count - 1) / 2
            let isWhiteTurn = !(totalMoves % 2 == 0)

            if isWhiteTurn {
                promotionPiece = gameState.getPromotionPiece(for: destinationIndex + 1)
            } else {
                promotionPiece = gameState.getPromotionPiece(for: destinationIndex)
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

        let startPosition = gameState.positionIntToString(index: startIndex)
        let destinationPosition = gameState.positionIntToString(index: destinationIndex - adjustedIndex)

        // Animate the move
        if let pieceNode = findPieceNode(at: startPosition) {
            if let destinationHexagon = self.childNode(withName: destinationPosition) {
                if let parent = pieceNode.parent {
                    let destinationPoint = parent.convert(destinationHexagon.position, from: self)
                    let slideAction = SKAction.move(to: destinationPoint, duration: 0.25)
                    pieceNode.run(slideAction)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                        guard let self = self else { return }
                        self.updateGameState(with: pieceNode, at: destinationPosition, promotionPiece: promotionPiece)
                    }
                }
            } else {
                print("Error: Destination hexagon not found for \(destinationPosition)")
            }
        } else {
            print("Error: Piece node not found at \(startPosition)")
        }
        
        let (_, gameStatus) = gameState.isGameOver() //replace _ with isGameOver

        updateGameStatusUI(gameStatus: gameStatus)
    }

    
    func updateGameStatusUI(gameStatus: String) { //should maybe seperate update game status with end of game achievement status
        
        //MARK: display whose turn it is
        if isOnlineMultiplayer { //can maybe be refactored out to a different function
            if gameState.currentPlayer == MultiplayerManager.shared.currentPlayerColor {
                whiteStatusTextMiniUpdater?(NSLocalizedString("Your turn", comment: ""))
                
            } else {
                whiteStatusTextMiniUpdater?(NSLocalizedString("Waiting for opponent...", comment: ""))
            }
        }
        
        //MARK: highlight any pieces in check
        if gameStatus.starts(with: "check") {
            if soundEffectsEnabled {audioManager.playSoundEffect(fileName: "check", fileType: "mp3")} //for some reason this isnt working rn
            // Extract positions after "check by " and highlight checking pieces
            let checkPositionsString = gameStatus.replacingOccurrences(of: "check by ", with: "")
            let checkPositions = checkPositionsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            
            highlightCheckStatus(for: checkPositions)
        } else {
            clearCheckHighlights()
        }
    }
    
    var boardIsRotated: Bool = false // This will track if the board is rotated by 180 degrees
    
    func rotateBoard() {
        guard self.view != nil else {
            print("View is nil, can't rotate board")
            return
        }
        
        boardIsRotated.toggle()
        UIView.animate(withDuration: 0.5) {
            self.view?.transform = (self.view?.transform.rotated(by: .pi))!
        }
    }
    
    func rotateBoardImmediately() {
        guard let view = self.view else {
            print("View is nil, can't rotate board")
            return
        }

        boardIsRotated.toggle()
        // Set the transform directly without animation
        view.transform = view.transform.rotated(by: .pi)
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
    
    func rotateAllPiecesImmediately() {
        for node in children {
            if let hexagon = node as? HexagonNode {
                for pieceNode in hexagon.children {
                    if let pieceNode = pieceNode as? SKSpriteNode {
                        pieceNode.zRotation += .pi
                    }
                }
            }
        }
    }
    
    func presentPromotionOptions(completion: @escaping (String) -> Void) {
        if let viewController = self.view?.window?.rootViewController {
            let promotionViewController = UIHostingController(rootView: PromotionWindow(completion: completion))
            promotionViewController.modalPresentationStyle = .overCurrentContext
            promotionViewController.view.backgroundColor = .clear
            viewController.present(promotionViewController, animated: true, completion: nil)
        }
    }
    
    func presentGameOverOptions(winner: String, method: String, eloText: String, completion: @escaping (String) -> Void) {
        if let viewController = self.view?.window?.rootViewController {
            let gameOverViewController = UIHostingController(
                rootView: GameOverWindow(winner: winner, method: method, isOnlineMultiplayer: isOnlineMultiplayer, eloText: eloText, completion: completion)
            )
            
            gameOverViewController.modalPresentationStyle = .overCurrentContext
            gameOverViewController.view.backgroundColor = .clear // Transparent background
            viewController.present(gameOverViewController, animated: true, completion: nil)
        }
    }

    
    func findPieceNode(at hexagonName: String) -> SKSpriteNode? { //helper function for removing captured pieces in updateGameState
        if let hexagon = childNode(withName: hexagonName) as? HexagonNode,
           let pieceNode = hexagon.children.first as? SKSpriteNode {
            return pieceNode
        }
        return nil
    }
    
    func updatePieceNode(_ pieceNode: SKSpriteNode, from start: String, to destination: String) {
        // Remove the piece from its current parent
        pieceNode.removeFromParent()
        
        // Update the pieceNode's name to reflect its new position
        if let nameComponents = pieceNode.name?.split(separator: "_"), nameComponents.count == 3 {
            let color = String(nameComponents[1])
            let type = String(nameComponents[2])
            pieceNode.name = "\(destination)_\(color)_\(type)"
        }
        
        // Add the piece to the new hexagon
        if let destinationHexagon = childNode(withName: destination) as? HexagonNode {
            destinationHexagon.addChild(pieceNode)
            pieceNode.position = CGPoint.zero // Reset position relative to the parent hexagon
        }
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
  
    func printGameState() { //just for debugging
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
    
    deinit { //(upon memory deninitialization of the GameScene (i actually have no idea when this triggers)
        if isOnlineMultiplayer {
            Task { @MainActor in
                MultiplayerManager.shared.stopListening()
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
