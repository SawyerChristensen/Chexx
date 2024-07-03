//
//  GameScene.swift
//  Chexx
//
//  Created by Sawyer Christensen on 6/24/24.
//

import SpriteKit
import GameplayKit
import UIKit //this and extensionUIColor could maybe be put in another file later. All this is is changing the tile color to a UIColor instance to be compatible with the HexagonNode class

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
        //self.lineWidth = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addPieceImage(named imageName: String, identifier: String) {
        let texture = SKTexture(imageNamed: imageName)
        let pieceNode = SKSpriteNode(texture: texture)
        pieceNode.name = identifier
        
        let aspectRatio = texture.size().width / texture.size().height
        let hexWidth = self.frame.size.width * 0.9
        let hexHeight = self.frame.size.height * 0.9
        
        if aspectRatio > 1 {
            pieceNode.size = CGSize(width: hexWidth, height: hexWidth / aspectRatio)
        } else {
            pieceNode.size = CGSize(width: hexHeight * aspectRatio, height: hexHeight)
        }
        
        pieceNode.position = CGPoint(x: 0, y: 0)
        pieceNode.zPosition = 1
        self.addChild(pieceNode)
    }
}


class GameScene: SKScene {
    
    //override func didMove(to view: SKView) {
    //    self.backgroundColor = SKColor.black
     //   }
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var gameState: GameState!
    
    private var lastUpdateTime : TimeInterval = 0
    
    var hexagonSize: CGFloat = 50 //50 is arbitrary & and just for init, changed later when screen size is retrieved
    
    var selectedPiece: SKSpriteNode?
    var originalPosition: CGPoint?
    
    let light = UIColor(hex: "#ffce9e") //can  import this later depending on user color settings in app? high contrast options? red black and white? this is a bad place to initialize this anyway
    let grey = UIColor(hex: "#e8ab6f")
    let dark = UIColor(hex: "#d18b47")
    
    override func sceneDidLoad() {
        super.sceneDidLoad()

        self.lastUpdateTime = 0
        
        //load saved game state
        let gameState = loadGameStateFromFile(from: "currentGameState") ?? GameState()
        
        // Calculate hexagon size based on screen size (currently 4.5% of the smallest screen dimension, in case of screen rotation)
        hexagonSize = min(self.size.width, self.size.height) * 0.045
        
        //generate the board
        generateHexTiles(radius: hexagonSize, scene: self)
        
        //place the pieces in the saved game state on the board
        placePieces(scene: self, gameState: gameState)
        
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
                        hexagon.addPieceImage(named: pieceImage, identifier: identifier)
                    }
                }
            }
        }
    }

    func touchDown(atPoint pos: CGPoint) {
        let nodesAtPoint = nodes(at: pos)
        for node in nodesAtPoint {
            if let pieceNode = node as? SKSpriteNode {
                selectedPiece = pieceNode
                originalPosition = pieceNode.position
                break
            }
        }
    }

    func touchMoved(toPoint pos: CGPoint) {
        guard let selectedPiece = selectedPiece else { return }
        if let parent = selectedPiece.parent {
            let convertedPos = convert(pos, to: parent)
            selectedPiece.position = convertedPos
        }
    }

    func touchUp(atPoint pos: CGPoint) {
        guard let selectedPiece = selectedPiece else { return }
        if let parent = selectedPiece.parent {
            let convertedPos = convert(pos, to: parent)
            if let nearestHexagon = findNearestHexagon(to: pos) {
                selectedPiece.position = parent.convert(nearestHexagon.position, from: self)
                //updateGameState(with: selectedPiece, at: nearestHexagon.name)
            } else {
                selectedPiece.position = originalPosition!
            }
            self.selectedPiece = nil //i dont think this is needed, can comment out with no effect on code but here just in case
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
            self.selectedPiece = nil
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
        return closestHexagon
    }
    
    func updateGameState(with pieceNode: SKSpriteNode, at hexagonName: String?) {
        guard let hexagonName = hexagonName else {
                print("Hexagon name is nil")
                return
            }

        let columns = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "k", "l"]
        let columnLetter = hexagonName.prefix(1)
        let rowIndexString = hexagonName.suffix(1)
        
        guard let colIndex = columns.firstIndex(of: String(columnLetter)),
              let rowIndex = Int(rowIndexString) else { return }

        // Parse identifier to find the original position and piece details
        let identifierParts = pieceNode.name?.split(separator: "_")
        guard let originalPosition = identifierParts?.first,
              let originalColLetter = originalPosition.first,
              let originalRowIndexString = originalPosition.last,
              let originalColIndex = columns.firstIndex(of: String(originalColLetter)),
              let originalRowIndex = Int(String(originalRowIndexString)) else { return }
        
        print("Moving piece from \(originalPosition) to \(hexagonName)")

        // Remove piece from its original position
        gameState.board[originalColIndex][originalRowIndex - 1] = nil

        // Add piece to the new position
        let pieceDetails = identifierParts![1...]
        let color = String(pieceDetails[0])
        let type = String(pieceDetails[1])
        gameState.board[colIndex][rowIndex - 1] = Piece(color: color, type: type)
        
        printGameState()
    }
    
    func printGameState() { //just for bug fixing
        for (colIndex, column) in gameState.board.enumerated() {
            for (rowIndex, piece) in column.enumerated() {
                if let piece = piece {
                    print("Piece at \(colIndex),\(rowIndex): \(piece.color) \(piece.type)")
                } else {
                    print("No piece at \(colIndex),\(rowIndex)")
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
