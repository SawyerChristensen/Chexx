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
}


class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var spinnyNode : SKShapeNode? //JUST FOR MOUSE INTERACTION VISUALIZATION IN XCoDE, REMOVE LATER AND ALL LATER REFERENCES IN DEPLOYMENT
    
    var hexagonSize: CGFloat = 50 //50 is arbitrary & and just for init, changed later when screen size is retrieved
    let light = UIColor(hex: "#ffce9e")
    let grey = UIColor(hex: "#e8ab6f")
    let dark = UIColor(hex: "#d18b47")
    
    override func sceneDidLoad() {
        super.sceneDidLoad()

        self.lastUpdateTime = 0
        
        // Calculate hexagon size based on screen size (currently 4% of the smallest screen dimension, in case of screen rotation)
        hexagonSize = min(self.size.width, self.size.height) * 0.04
        
        // Generate and add hexagon tiles to the scene
        generateHexTiles(radius: hexagonSize, scene: self)
        
        /*// Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }*/
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
            return CGPoint(x: x, y: y - 2 * radius * sin(angle))
        case .below:
            return CGPoint(x: x, y: y + 2 * radius * sin(angle))
        case .upperLeft:
            return CGPoint(x: x - radius * (1 + cos(angle)), y: y - radius * sin(angle))
        case .bottomLeft:
            return CGPoint(x: x - radius * (1 + cos(angle)), y: y + radius * sin(angle))
        case .upperRight:
            return CGPoint(x: x + radius * (1 + cos(angle)), y: y - radius * sin(angle))
        case .bottomRight:
            return CGPoint(x: x + radius * (1 + cos(angle)), y: y + radius * sin(angle))
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
        let directions: [(String, Direction, UIColor)] = [
            ("f7", .above, dark),
            ("e6", .bottomLeft, light),
            ("e5", .below, dark),
            ("f5", .bottomRight, light),
            ("g5", .upperRight, dark),
            ("g6", .above, light),
            ("g7", .above, grey),
            ("f8", .upperLeft, light),
            ("e7", .bottomLeft, grey),
            ("d6", .bottomLeft, dark),
            ("d5", .below, grey),
            ("d4", .below, light),
            ("e4", .bottomRight, grey),
            ("f4", .bottomRight, dark),
            ("g4", .upperRight, grey),
            ("h4", .upperRight, light),
            ("h5", .above, grey),
            ("h6", .above, dark),
            ("h7", .above, light),
            ("g8", .upperLeft, dark),
            ("f9", .upperLeft, grey),
            ("e8", .bottomLeft, dark),
            ("d7", .bottomLeft, light),
            ("c6", .bottomLeft, grey),
            ("c5", .below, light),
            ("c4", .below, dark),
            ("c3", .below, grey),
            ("d3", .bottomRight, dark),
            ("e3", .bottomRight, light),
            ("f3", .bottomRight, grey),
            ("g3", .upperRight, light),
            ("h3", .upperRight, dark),
            ("i3", .upperRight, grey),
            ("i4", .above, dark),
            ("i5", .above, light),
            ("i6", .above, grey),
            ("i7", .above, dark),
            ("h8", .upperLeft, grey),
            ("g9", .upperLeft, light),
            ("f10", .upperLeft, dark),
            ("e9", .bottomLeft, light),
            ("d8", .bottomLeft, grey),
            ("c7", .bottomLeft, dark),
            ("b6", .bottomLeft, light),
            ("b5", .below, dark),
            ("b4", .below, grey),
            ("b3", .below, light),
            ("b2", .below, dark),
            ("c2", .bottomRight, light),
            ("d2", .bottomRight, grey),
            ("e2", .bottomRight, dark),
            ("f2", .bottomRight, light),
            ("g2", .upperRight, dark),
            ("h2", .upperRight, grey),
            ("i2", .upperRight, light),
            ("k2", .upperRight, dark),
            ("k3", .above, light),
            ("k4", .above, grey),
            ("k5", .above, dark),
            ("k6", .above, light),
            ("k7", .above, grey),
            ("i8", .upperLeft, light),
            ("h9", .upperLeft, dark),
            ("g10", .upperLeft, grey),
            ("f11", .upperLeft, light),
            ("e10", .bottomLeft, grey),
            ("d9", .bottomLeft, dark),
            ("c8", .bottomLeft, light),
            ("b7", .bottomLeft, grey),
            ("a6", .bottomLeft, dark),
            ("a5", .below, grey),
            ("a4", .below, light),
            ("a3", .below, dark),
            ("a2", .below, grey),
            ("a1", .below, light),
            ("b1", .bottomRight, grey),
            ("c1", .bottomRight, dark),
            ("d1", .bottomRight, light),
            ("e1", .bottomRight, grey),
            ("f1", .bottomRight, dark),
            ("g1", .upperRight, grey),
            ("h1", .upperRight, light),
            ("i1", .upperRight, dark),
            ("k1", .upperRight, grey),
            ("l1", .upperRight, light),
            ("l2", .above, grey),
            ("l3", .above, dark),
            ("l4", .above, light),
            ("l5", .above, grey),
            ("l6", .above, dark)
        ]
        
        //initialize currentx & y position at the center of the screen
        var currentX = CGFloat(0)
        var currentY = CGFloat(0)
        
        // Hexagon array that will be added to the scene
        var hexagons: [HexagonNode] = []
        
        // Add initial center hexagon
        let initialHexagon = HexagonNode(size: radius, color: grey)
        initialHexagon.position = CGPoint(x: currentX, y: currentY)
        initialHexagon.name = "f6"
        hexagons.append(initialHexagon)
        
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
    

    func touchDown(atPoint pos : CGPoint) {
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }*/
        let nodesAtPoint = nodes(at: pos)
        for node in nodesAtPoint {
            if let hexagon = node as? HexagonNode {
                hexagon.fillColor = .yellow  // Example interaction: change color
                print("Hexagon touched: \(hexagon.name ?? "unknown")")
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }*/
    }
    
    func touchUp(atPoint pos : CGPoint) {
        /*if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }*/
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
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
