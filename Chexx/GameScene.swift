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
        self.strokeColor = .black
        self.lineWidth = 1
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
        
        // Calculate hexagon size based on screen size (currently 4.5% of the smallest screen dimension, in case of screen rotation)
        hexagonSize = min(self.size.width, self.size.height) * 0.045
        
        // Create hexagon grid
        createHexagonGrid(rows: 11, columns: 12)
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }

    func createHexagonGrid(rows: Int, columns: Int) {
            for row in 0..<rows {
                for col in 0..<columns {
                    
                    // Use predefined colors
                    let color: UIColor
                    if (row + col) % 3 == 0 {
                        color = light
                    } else if (row + col) % 3 == 1 {
                        color = grey
                    } else {
                        color = dark
                    }
                                    
                    
                    let hexagon = HexagonNode(size: hexagonSize, color: color)
                    let xOffset = hexagonSize * 1.5 * CGFloat(col)
                    let yOffset = hexagonSize * sqrt(3) * CGFloat(row) + (col % 2 == 0 ? 0 : hexagonSize * sqrt(3) / 2)
                    hexagon.position = CGPoint(x: xOffset, y: yOffset)
                    hexagon.name = "hex_\(row)_\(col)"
                    addChild(hexagon)
                }
            }
        }
    

    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
        let nodesAtPoint = nodes(at: pos)
        for node in nodesAtPoint {
            if let hexagon = node as? HexagonNode {
                hexagon.fillColor = .yellow  // Example interaction: change color
                print("Hexagon touched: \(hexagon.name ?? "unknown")")
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
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
