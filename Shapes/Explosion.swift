//
//  Explosion.swift
//  Hell Birdie
//
//  Created by Binh Huynh on 11/13/16.
//  Copyright © 2016 Binh Huynh. All rights reserved.
//

import Foundation
import SpriteKit

class Explosion: SKSpriteNode {
    
    let animatedAtlas = SKTextureAtlas(named: "Explosion")
    var frames = [SKTexture]()
    
    init() {
        
        let texture = SKTexture(imageNamed: "explosion1")
        super.init(texture: texture, color: UIColor.clear, size: texture.size())
        
        for i in 1...5 {
            let textureName = "explosion\(i)"
            frames.append(animatedAtlas.textureNamed(textureName))
        }
        
        self.run(SKAction.sequence([SKAction.animate(with: frames, timePerFrame: 0.1)]), completion: {
            self.removeFromParent()
        })
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



