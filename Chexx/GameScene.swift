//
//  GameScene.swift
//  Chexx
//
//  Created by Sawyer Christensen on 6/24/24.
//

import SpriteKit
import GameplayKit

class HexagonNode: SKShapeNode {
    init(size: CGFloat) {
        super.init()
        
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
        
        self.path = path.cgPath
        self.fillColor = .cyan
        self.strokeColor = .black
        self.lineWidth = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class GameScene: SKScene {

    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        let rows = 11
        let columns = 12
        let hexSize: CGFloat = 30.0 // Adjust size as needed
        
        createHexagonGrid(rows: rows, columns: columns, hexSize: hexSize)
    }
    
    func drawHexagon(at position: CGPoint, size: CGFloat) -> SKShapeNode {
        let hexagonPath = UIBezierPath()
        let width = size * sqrt(3)
        let height = size * 2
        let center = CGPoint(x: width / 2, y: height / 2)
        
        hexagonPath.move(to: CGPoint(x: center.x + width / 2, y: center.y))
        hexagonPath.addLine(to: CGPoint(x: center.x + width / 4, y: center.y + height / 2))
        hexagonPath.addLine(to: CGPoint(x: center.x - width / 4, y: center.y + height / 2))
        hexagonPath.addLine(to: CGPoint(x: center.x - width / 2, y: center.y))
        hexagonPath.addLine(to: CGPoint(x: center.x - width / 4, y: center.y - height / 2))
        hexagonPath.addLine(to: CGPoint(x: center.x + width / 4, y: center.y - height / 2))
        hexagonPath.close()
        
        let hexagon = SKShapeNode(path: hexagonPath.cgPath)
        hexagon.position = position
        hexagon.lineWidth = 2.0
        hexagon.fillColor = SKColor.brown
        hexagon.strokeColor = SKColor.black
        
        return hexagon
    }
    
    func createHexagonGrid(rows: Int, columns: Int, hexSize: CGFloat) {
        let hexWidth = hexSize * sqrt(3)
        let hexHeight = hexSize * 2
        
        let centerX = CGFloat(columns / 2) * hexWidth
        let centerY = CGFloat(rows / 2) * (hexHeight * 3 / 4)
        
        for row in 0..<rows {
            for column in 0..<columns {
                let xOffset = (CGFloat(column) * hexWidth) + ((row % 2 == 0) ? 0 : hexWidth / 2)
                let yOffset = CGFloat(row) * (hexHeight * 3 / 4)
                let xPos = centerX + xOffset
                let yPos = centerY + yOffset
                
                // Center the grid around tile f6
                if row == 5 && column == 5 {
                    // Center of the grid (f6)
                    hexagon.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
                } else {
                    hexagon.position = CGPoint(x: xPos, y: yPos)
                }
                
                let hexagon = drawHexagon(at: CGPoint(x: xPos, y: yPos), size: hexSize)
                self.addChild(hexagon)
            }
        }
    }
}
