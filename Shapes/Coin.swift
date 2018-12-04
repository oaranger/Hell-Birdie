//
//  Coin.swift
//  Hyper Brick
//
//  Created by Binh Huynh on 11/6/16.
//  Copyright © 2016 Binh Huynh. All rights reserved.
//

import Foundation
import SpriteKit

class Coin: SKSpriteNode {
    
    let animateAtlas = SKTextureAtlas(named: "Coins")
    var frames = [SKTexture]()
    
    init() {
        
        let texture = SKTexture(imageNamed: "coin1")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.height*1.5)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = ColliderType.Coin
        self.physicsBody?.contactTestBitMask = ColliderType.Player
        
        performAnimation()
    }
    
    func performAnimation() {
        
        for i in 1...8 {
            let textureName = "coin\(i)"
            frames.append(animateAtlas.textureNamed(textureName))
        }
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.animate(with: frames, timePerFrame: 0.12)])))
    }
   
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
