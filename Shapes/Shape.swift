//
//  Shape.swift
//  Shapes
//
//  Created by Binh Huynh on 9/14/16.
//  Copyright © 2016 Binh Huynh. All rights reserved.
//

import Foundation
import SpriteKit

class Shape: SKSpriteNode {
    
    let randNum = CGFloat.random(0, max: 1)
    var randColor: UIColor!
    
    init(fileNamed:String) {
//        randColor = UIColor(hue: randNum, saturation: 40/100, brightness: 1.0, alpha: 1.0)
        randColor = UIColor.white
        let texture = SKTexture(imageNamed: fileNamed)
        super.init(texture: texture, color: randColor, size: texture.size())
        self.colorBlendFactor = 1
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.mass = 2000
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.isDynamic = true
        self.physicsBody?.friction = 1
        self.physicsBody?.categoryBitMask = ColliderType.Obstacle
        self.physicsBody?.contactTestBitMask = ColliderType.Player
        self.physicsBody?.collisionBitMask = ColliderType.None

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getColor() -> UIColor {
        return randColor
    }
}
