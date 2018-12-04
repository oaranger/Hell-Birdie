//
//  Player.swift
//  Sky Up
//
//  Created by Binh Huynh on 9/28/16.
//  Copyright © 2016 Binh Huynh. All rights reserved.
//

import Foundation
import SpriteKit

class Player: SKSpriteNode {
    
    let playerAnimatedAtlas = SKTextureAtlas(named: "RoundMonsters")
    var frames = [SKTexture]()
    
    init() {
        
        let texture = SKTexture(imageNamed: "monster1")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())

        self.physicsBody = SKPhysicsBody(rectangleOf: self.frame.size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.categoryBitMask = ColliderType.Player
        self.physicsBody?.contactTestBitMask = ColliderType.Obstacle
        self.physicsBody?.collisionBitMask = ColliderType.Obstacle
        
        performAliveAnimation()
    }
    
    func performAliveAnimation() {
            
        for i in 1...8 {
            let textureName = "monster\(i)"
            frames.append(playerAnimatedAtlas.textureNamed(textureName))
        }
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.animate(with: frames, timePerFrame: 0.1)])))
    }
    
    func performDeadAnimation() {
        
        frames.removeAll()
        self.removeAllActions()
    
        for i in 9...10 {
            let textureName = "monster\(i)"
            frames.append(playerAnimatedAtlas.textureNamed(textureName))
        }
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.animate(with: frames, timePerFrame: 0.15)])))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


