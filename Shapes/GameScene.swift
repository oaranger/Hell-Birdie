//
//  GameScene.swift
//  Shapes
//
//  Created by Binh Huynh on 9/11/16.
//  Copyright (c) 2016 Binh Huynh. All rights reserved.
//

import SpriteKit
import CoreMotion
import StoreKit
import GameplayKit

struct ColliderType {
    static let None:    UInt32 = 0b0
    static let Player:  UInt32 = 0b1
    static let Gap:     UInt32 = 0b10
    static let Obstacle:UInt32 = 0b100
    static let Coin:    UInt32 = 0b1000
}

enum GameState: Int {
    case waitingForTap  = 0
    case playing        = 1
    case gameOver       = 2
}

enum PlayerState: Int {
    case alive = 0
    case dead  = 1
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let playableRect: CGRect
    var frameW, frameH: CGFloat!
    var yL,yM,yH,xL,xH,xM,yD,xD: CGFloat!
    var bgHueOld = CGFloat.random(0.0, max: 1.0)
    var nextLevelY: CGFloat = 0.0
    var lastGapX: CGFloat = 0
    var newGapX: CGFloat = 0
    
    let cameraNode = SKCameraNode()
    
    let soundPop            = speakerOn ? SKAction.playSoundFileNamed("pop.mp3",waitForCompletion: false) : SKAction.run {}
    let soundHit            = speakerOn ? SKAction.playSoundFileNamed("hit.wav",waitForCompletion: false) : SKAction.run {}
    let soundJump           = speakerOn ? SKAction.playSoundFileNamed("jump.wav",waitForCompletion: false) : SKAction.run {}
    let soundWoosh          = speakerOn ? SKAction.playSoundFileNamed("woosh_4.wav",waitForCompletion: false) : SKAction.run {}
    let soundPoint          = speakerOn ? SKAction.playSoundFileNamed("misc_menu_4.wav",waitForCompletion: false) : SKAction.run {}
    let soundDie            = speakerOn ? SKAction.playSoundFileNamed("death.wav",waitForCompletion: false) : SKAction.run {}
    let soundNewGame        = speakerOn ? SKAction.playSoundFileNamed("new_game.wav",waitForCompletion: false) : SKAction.run {}
    let soundMenuClicked    = speakerOn ? SKAction.playSoundFileNamed("click.wav",waitForCompletion: false) : SKAction.run {}
    let soundCoin           = speakerOn ? SKAction.playSoundFileNamed("coin4.wav",waitForCompletion: false) : SKAction.run {}
    let soundMenuDrop       = speakerOn ? SKAction.playSoundFileNamed("swosh_15.wav",waitForCompletion: false) : SKAction.run {}
    
    let buttonGames         = SKSpriteNode(imageNamed: "MoreGamesButton")
    let buttonMusic         = SKSpriteNode(imageNamed: "MusicButton")
    let buttonRate          = SKSpriteNode(imageNamed: "RateButton")
    let buttonNoAds         = SKSpriteNode(imageNamed: "NoAdsButton")
    let buttonLike          = SKSpriteNode(imageNamed: "LikeButton")
    let buttonChart         = SKSpriteNode(imageNamed: "ChartButton")
    let buttonShare         = SKSpriteNode(imageNamed: "ShareButton")
    let buttonPlay          = SKSpriteNode(imageNamed: "PlayButton")
    let buttonIAP           = SKSpriteNode(imageNamed: "IAPButton")
    let buttonSpeakerOn     = SKSpriteNode(imageNamed: "SpeakerOnButton")
    let title               = SKSpriteNode(imageNamed: "Title2")
    let tapImg              = SKSpriteNode(imageNamed: "tap")
    let tapArrowImg         = SKSpriteNode(imageNamed: "tap_arrow")
    let introImg            = SKSpriteNode(imageNamed: "Intro")
    let tapRestart          = SKLabelNode(fontNamed: "AppleSDGothicNeo-Thin")
    let gameOverScore       = SKLabelNode(fontNamed: "AppleSDGothicNeo-Thin")
    let gameOverBestScore   = SKLabelNode(fontNamed: "Courier")
    let labelPlay           = SKLabelNode(fontNamed: "AppleSDGothicNeo-Thin")
    let labelRate           = SKLabelNode(fontNamed: "AppleSDGothicNeo-Thin")
    let labelOption         = SKLabelNode(fontNamed: "AppleSDGothicNeo-Thin")
    let scoreLabel          = SKLabelNode()
    let bestScoreLabel     = SKLabelNode()
    
    let layerPlayer = SKNode()
    let layerBGColor = SKNode()
    let layerCloud = SKNode()
    let layerHUD = SKNode()
    let layerWorld = SKNode()
    let layerPlatform = SKNode()
    let layerCoin = SKNode()
    let layerSunMoon = SKNode()
    let optionsHUD = SKNode()
    let layerBg = SKNode()
   
    var gameState = GameState.waitingForTap
    var playerState = PlayerState.alive

    var player: Player!
    var bgCount = 0
    var optionsIsShow = false
    var score = UserDefaults.standard.integer(forKey: "lastScore")
    var bestScore = UserDefaults.standard.integer(forKey: "bestScore")
    
    var productPurchased = false
    var products = [SKProduct]()
    let storeManager = StoreManager()
    let appProduct = "CuBI.com.HyperBrick.Final"
    
    override init(size: CGSize) {
        var maxAspectRatio:CGFloat = 0
        if UIDevice.current.userInterfaceIdiom == .phone {
            maxAspectRatio = 16.0/9.0
        } else {
            maxAspectRatio = 4.0/3.0
        }
        let playableWidth = size.height / maxAspectRatio
        let playableMargin = (size.width-playableWidth)/2.0
        playableRect = CGRect(x: playableMargin, y: 0,
                              width: playableWidth,
                              height: size.height)
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        //Store Module Delegate
        storeManager.delegate = self
        refreshPurchaseStatus()
        
        //DEBUG
//        productPurchased = true
        
        yL = playableRect.minY
        yH = playableRect.maxY
        xL = playableRect.minX
        xH = playableRect.maxX
        xM = playableRect.midX
        yM = playableRect.midY
        yD = playableRect.height
        xD = playableRect.width
     
        frameW = frame.size.width
        frameH = frame.size.height
        
        addChild(cameraNode)
        camera = cameraNode
//        cameraNode.isHidden = true
        cameraNode.position = CGPoint(x: xM, y: yM)
        setupPlayer()
     
        addChild(layerWorld)
        layerWorld.addChild(layerBGColor)
        layerWorld.addChild(layerPlatform)
        layerWorld.addChild(layerCloud)
        layerWorld.addChild(layerCoin)
        layerWorld.addChild(layerPlayer)
//        layerWorld.isHidden = true
        
        addRandomPlatform()
        addRandomBGColor()
        addRandomCloud()
        addRandomCoin()
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: -50)
        
        print("Purchase status \(productPurchased)")
        if productPurchased {
            NotificationCenter.default.post(name: Notification.Name(rawValue: KeyBannerAds), object: self)
        }
        
        gameBeginScene()
    }
    
   

    func setupScoreLabel() {
       scoreLabel.fontName = "AppleSDGothicNeo-Thin"
       scoreLabel.fontColor = SKColor.white
       scoreLabel.fontSize = yD*0.14
       scoreLabel.horizontalAlignmentMode = .right
       scoreLabel.verticalAlignmentMode = .top
       scoreLabel.text = "\(score)"
       scoreLabel.position = CGPoint(x:xD/2 - 50,y:yD/2 - 50)
       scoreLabel.zPosition = 100
       cameraNode.addChild(scoreLabel)
    }
    
    func setupPlayer() {
        player = Player()
        player.position = CGPoint(x: xM, y: yL + yD/3)
        player.zPosition = 100
        layerPlayer.addChild(player)
        layerPlayer.zPosition = 200
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGMutablePath()
        path.addRect(playableRect)
        shape.path = path
        shape.strokeColor = SKColor.red
        shape.lineWidth = 4.0
        addChild(shape)
    }
    
    func updateCamera() {
        let cameraTarget = player.position
        let targetPositionY = cameraTarget.y + yD*0.08
        let diff = targetPositionY - cameraNode.position.y
        let lerpValue = CGFloat(0.2)
        let lerpDiff = diff * lerpValue
        var newPositionY = cameraNode.position.y + lerpDiff
        newPositionY = max(nextLevelY - yD,newPositionY,yM)
        cameraNode.position = CGPoint(x: xM, y:newPositionY)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameState == .playing {
            let other = (contact.bodyA.categoryBitMask == ColliderType.Player ? contact.bodyB : contact.bodyA)
            switch other.categoryBitMask {
            
            case ColliderType.Obstacle:
                self.gameState = .gameOver
                isUserInteractionEnabled = false
                run(SKAction.sequence([soundHit, SKAction.run {
                    let explosion = Explosion()
                    explosion.position = contact.contactPoint
                    self.addChild(explosion)
                    }, SKAction.wait(forDuration: 0.3),soundDie]))
                layerWorld.run(SKAction.screenShakeWithNode(layerWorld, amount: CGPoint(x:0,y:-150), oscillations: 10, duration: 0.6))
                player.physicsBody?.collisionBitMask = ColliderType.None
                player.performDeadAnimation()
                run(SKAction.wait(forDuration: 1.0), completion: {
                    self.gameOverScene()
                    self.isUserInteractionEnabled = true
                })
                
            case ColliderType.Coin:
                if let node = other.node as? Coin {
                    run(soundCoin)
                    score = score + 1
                    let move = SKAction.move(to: player.position, duration: 0.2)
                    let small = SKAction.scale(to: 0.5, duration: 0.15)
                    node.run(SKAction.group([move,small]), completion: {
                        node.removeFromParent()
                    })
                }
                
            case ColliderType.Gap:
                score = score + 1
                run(soundPoint)
//                run(SKAction.playSoundFileNamed("point\(Int.random(2, max: 4)).wav",waitForCompletion: false))
                if let node = other.node as? Shape {
//                    let explode = SKEmitterNode(fileNamed: "Spark1.sks")
//                    explode!.position = player.position
//                    explode!.run(SKAction.removeFromParentAfterDelay(0.5))
//                    explode!.particleColorSequence = nil
//                    explode!.particleColorBlendFactor = 1
//                    explode!.particleColor = UIColor(hue: CGFloat(bgHueOld), saturation: 20/100, brightness: 1.0, alpha: 1.0)
//                    addChild(explode!)
                    node.removeFromParent()
                }
                for child in layerPlatform.children {
                    for node in child.children {
                        if node.name == "tile" && node.position.y < player.position.y + yD/2 {
//                            node.physicsBody?.isDynamic = true
//                            node.physicsBody?.affectedByGravity = true
                        }
                    }
                }
            default: break
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        switch gameState {
            
        case .waitingForTap:
            if location.y > CGFloat(yL) {
                gameState = .playing
                setupScoreLabel()
                layerHUD.removeAllChildren()
                player.physicsBody?.isDynamic = true
                run(soundWoosh)
                playerJump(tapAt: location)
            }
            break
            
        case .playing:
            run(soundWoosh)
            playerJump(tapAt: location)
            break
            
        case .gameOver:
            for node in nodes(at: location) {
                let theNode = node
                if theNode.name?.lowercased().range(of: "button") != nil {
                    let getSmall = SKAction.scale(by: 0.5, duration: 0.1)
                    let getBig = SKAction.scale(by: 2, duration: 0.1)
                    theNode.run(SKAction.sequence([soundMenuClicked,getSmall,getBig]), completion: { () -> Void in
                        print("Pressed \(theNode.name)")
                        if theNode.name == "MoreGamesButton"          {   self.handleMoreGames();   }
                        else if theNode.name == "ChartButton"         {   self.handleLeaderboard(); }
                        else if theNode.name == "ShareButton"         {   self.handleShare();       }
                        else if theNode.name == "RateButton"          {   self.handleRate();        }
                        else if theNode.name == "IAPButton"           {   self.handleRestoreIAP();  }
                        else if theNode.name == "NoAdsButton"         {   self.handleNoads();       }
                        else if theNode.name == "LikeButton"          {   self.handleLike();        }
                        else if theNode.name == "SpeakerButton"       {   self.handleSpeaker();     }
                        else if theNode.name == "OptionsButton"       {   self.handleOptions();     }
                        else if theNode.name == "PlayButton"          {   self.newGame();           }
                    })
                }
            }
        break
        }
    }
    
    func playerJump(tapAt: CGPoint) {
        if tapAt.x > CGFloat(xM) {
            player.physicsBody?.velocity = CGVector(dx: 480, dy: 2000)
        } else {
            player.physicsBody?.velocity = CGVector(dx: -480, dy: 2000)
        }
    }
    
    func shakeAction(_ sprite:SKSpriteNode) {
        let amount = CGPoint(x: 0, y: -100.0)
        let action = SKAction.screenShakeWithNode(sprite, amount: amount, oscillations: 5, duration: 0.4)
        sprite.run(action)
    }
    
    func addRandomPlatform() {
        
        let subPlatformNode = SKSpriteNode()
        subPlatformNode.name = "\(bgCount)"
        subPlatformNode.zPosition = 10
        
        for i in 1...3 {
            
            let gap = CGFloat.random(xD/3.0, max: xD/2.8)
            newGapX = CGFloat.random(xL+xD/8,max:xH-xD/8)
            while abs(newGapX - lastGapX) < xD/6 {
                newGapX = CGFloat.random(xL+xD/8,max:xH-xD/8)
            }
            
            let aPosition = CGPoint(x: newGapX, y: CGFloat(i)*yD/3 + nextLevelY)
            lastGapX = newGapX
            
            if Int.random(100) < 90 {
                
                let leftTile = Shape(fileNamed: "tile9")
                let rightTile = Shape(fileNamed: "tile9")
                
                leftTile.position = CGPoint(x: aPosition.x - leftTile.size.width/2 - gap/2, y: CGFloat(i)*yD/3 + nextLevelY)
                leftTile.yScale = 1.4
                subPlatformNode.addChild(leftTile)
                
                rightTile.position = CGPoint(x: aPosition.x + rightTile.size.width/2 + gap/2, y: CGFloat(i)*yD/3 + nextLevelY)
                rightTile.yScale = 1.4
                subPlatformNode.addChild(rightTile)
                
                if abs(leftTile.position.x + leftTile.size.width/2 - xL) < player.size.width/2 {
                    leftTile.position.x  = leftTile.position.x - player.size.width * 2
                }
                if abs(rightTile.position.x - rightTile.size.width/2 - xH) < player.size.width/2 {
                    rightTile.position.x = rightTile.position.x + player.size.width * 2
                }
                
            } else {
                
                let midTile = Shape(fileNamed: "tile9_mid")
                midTile.yScale = 1.2
                midTile.position = CGPoint(x: xM, y: CGFloat(i)*yD/3 + nextLevelY)
                subPlatformNode.addChild(midTile)
            }
            
            let alphaGap = Shape(fileNamed: "square")
            alphaGap.size = CGSize(width: xD, height: 30)
            alphaGap.position = CGPoint(x: xM, y: CGFloat(i)*yD/3 + nextLevelY)
            alphaGap.physicsBody = SKPhysicsBody(rectangleOf: alphaGap.size)
            alphaGap.physicsBody?.categoryBitMask = ColliderType.Gap
            alphaGap.physicsBody?.contactTestBitMask = ColliderType.Player
            alphaGap.physicsBody?.isDynamic = false
            alphaGap.alpha = 0.0
            subPlatformNode.addChild(alphaGap)
            
            if i==1 && nextLevelY==0 {
                subPlatformNode.removeAllChildren()
            }
        }
        layerPlatform.addChild(subPlatformNode)
    }
    
    func addRandomCoin() {
        let subCoinNode = SKSpriteNode()
        subCoinNode.name = "\(bgCount)"
        subCoinNode.zPosition = 25
        for i in 0...1 {
            if Int.random(100) < 20 {
                let coin = Coin()
                coin.position = CGPoint(x: CGFloat.random(xL+xD/5, max: xH-xD/5),
                                        y: CGFloat(i)*yD/3 + CGFloat.random(yD/6, max: yD/3.5) + nextLevelY)
                subCoinNode.addChild(coin)
                
                if i==0 && nextLevelY==0 {
                    subCoinNode.removeAllChildren()
                }
            }
        }
        layerCoin.addChild(subCoinNode)
    }
    
    func addRandomCloud() {
        let subCloudNode = SKSpriteNode()
        subCloudNode.name = "\(bgCount)"
        subCloudNode.zPosition = 15
        if nextLevelY > 0 {
            for i in 0...1 {
                if Int.random(100) < 80 {
                    let randScale = CGFloat.random(0.6, max: 1.2)
                    let cloud = SKSpriteNode(imageNamed: "cloud")
                    cloud.xScale = randScale
                    cloud.yScale = randScale
                    cloud.name = "cloud"
                    cloud.alpha = 0.9
                    cloud.position = CGPoint(x: xL,y: CGFloat(i)*yD/2 + CGFloat.random(yD/6, max: yD/2.2) + nextLevelY)
                    
                    subCloudNode.addChild(cloud)
                    let actionMove = SKAction.move(by: CGVector(dx:xD,dy:0), duration: Double(CGFloat.random(7.0, max: 8.8)))
                    let actionReturn = actionMove.reversed()
                    cloud.run(SKAction.repeatForever(SKAction.sequence([actionMove,actionReturn])))
                }
            }
        }
        layerCloud.addChild(subCloudNode)
    }
    
    func addRandomBGColor() {
        let subColorNode = SKSpriteNode()
        subColorNode.name = "\(bgCount)"
        subColorNode.position.y = nextLevelY
        for i in 0...64 {
            let ref = CGMutablePath()
            ref.move(to: CGPoint(x: 0, y: CGFloat(i*32)))
            ref.addLine(to: CGPoint(x: xH, y: CGFloat(i*32)))
            let line2 = SKShapeNode()
            line2.path = ref
            line2.lineWidth = 34
            bgHueOld -= 0.001
            if bgHueOld < 0        {   bgHueOld = 1.0 - bgHueOld }
            else if bgHueOld > 1   {   bgHueOld = bgHueOld - 1   }
            line2.strokeColor = UIColor(hue: CGFloat(bgHueOld), saturation: 45/100, brightness: 0.65, alpha: 1.0)
            subColorNode.addChild(line2)
        }
        layerBGColor.addChild(subColorNode)
        
        if nextLevelY < yD {
            let rand = Int.random(1, max: 2)
            let bg = SKSpriteNode(imageNamed: "bg\(rand)_bottom")
            bg.anchorPoint = CGPoint(x: 0, y: 0)
            subColorNode.addChild(bg)
            
        }
    }
   
    override func update(_ currentTime: TimeInterval) {
        updateCamera()
        updatePlayer()
        updateGameWorld()
        updateScore()
    }
    
    func setupSunMoon() {
        let sunmoon = ["sun","sun"]
        let sun = SKSpriteNode(imageNamed: sunmoon[Int.random(2)])
        sun.position = CGPoint(x: -xD/4, y: yD/3)
        layerSunMoon.addChild(sun)
        layerSunMoon.zPosition = 5
        cameraNode.addChild(layerSunMoon)
    }
    
    func updatePlayer() {
        if playerState == .alive && gameState == .playing {
            if player.position.x > xH - player.size.width/2 {
                player.position.x = xH - player.size.width/2
            } else if player.position.x < xL + player.size.width/2 {
                player.position.x = xL + player.size.width/2
            }
            if player.position.y < yL {
                run(soundDie)
                gameOverScene()
            }
        }
    }
    
    func updateGameWorld() {
        if player.position.y > nextLevelY + yD/3 {            
            nextLevelY = nextLevelY + yD
            bgCount = bgCount + 1
            addRandomPlatform()
            addRandomBGColor()
            addRandomCloud()
            addRandomCoin()
            
            if bgCount >= 3 {
                layerPlatform.childNode(withName: "\(bgCount-3)")?.removeFromParent()
                layerBGColor.childNode(withName: "\(bgCount-3)")?.removeFromParent()
                layerCloud.childNode(withName: "\(bgCount-3)")?.removeFromParent()
                layerCoin.childNode(withName: "\(bgCount-3)")?.removeFromParent()
            }
        }
    }
    
    func updateScore() {
        scoreLabel.text = "\(score)"
    }
    
    func saveGameResult() {
        UserDefaults.standard.set(0, forKey: "lastScore")
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: "bestScore")
        }
        UserDefaults.standard.synchronize()
        reportScoreToGameCenter()
    }
    
    func reportScoreToGameCenter() {
        print("report score to GameCenter")
        SGGameKit.sharedInstance.reportScore(score: Int64(bestScore), forLeaderBoardId:"CuBI.com.HyperBrickLB")
    }
    
    func gameBeginScene() {
        
        run(soundNewGame)
        
//        tapImg.xScale = 0.6
//        tapImg.yScale = 0.6
//        tapImg.position = convert(player.position, to: cameraNode) + CGPoint(x: 0, y: player.size.height*2.6)
//        layerHUD.addChild(tapImg)
        
        if gameOverCount<3 {
            tapArrowImg.position = convert(player.position, to: cameraNode) - CGPoint(x: 0, y: player.size.height)
//            layerHUD.addChild(tapArrowImg)
        }
        
        title.position = CGPoint(x: 0, y: yD/4)
        title.xScale = 1.1
        title.yScale = 1.1
        title.alpha = 0.9
        title.colorBlendFactor = 1
        title.color = UIColor.white
//        layerHUD.addChild(title)
        layerHUD.zPosition = 100
        cameraNode.addChild(layerHUD)
        
        setupSunMoon()
        if gameOverCount == 0 {
            layerWorld.isHidden = true
            cameraNode.isHidden = true
            setupIntroScreen()
        }
        if gameOverCount < 2 {
            setupTutorial()
        }
    }
    
    func setupIntroScreen() {
        let introImg = SKSpriteNode(imageNamed: "IntroScreen")
        introImg.position = CGPoint(x: xM, y: yM)
        addChild(introImg)
        let wait = SKAction.wait(forDuration: 5)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let showGame = SKAction.run {
            self.layerWorld.isHidden = false
            self.cameraNode.isHidden = false
        }
        introImg.run(SKAction.sequence([wait,fadeOut,remove,showGame]))
    }
    
    func setupTutorial() {
        
        let rec = SKShapeNode(rectOf: CGSize(width: xD/2, height: yD))
        rec.position = CGPoint(x: -xD/4, y: 0)
        rec.fillColor = .white
        rec.alpha = 0
        
        let leftHand = SKSpriteNode(imageNamed: "HandTapL")
        leftHand.position = CGPoint(x: -xD/4, y: -yD/4)
        leftHand.isHidden = true
        layerHUD.addChild(leftHand)
        
        let rightHand = SKSpriteNode(imageNamed: "HandTapR")
        rightHand.position = CGPoint(x: xD/4, y: -yD/4)
        rightHand.isHidden = true
        layerHUD.addChild(rightHand)
        
        let tapImgR = SKSpriteNode(imageNamed: "tapJumpImgR")
        tapImgR.position = CGPoint(x: tapImgR.size.width/2, y: -yD/20)
        tapImgR.isHidden = true
        tapImgR.alpha = 0.4
        layerHUD.addChild(tapImgR)
        
        let tapImgL = SKSpriteNode(imageNamed: "tapJumpImgL")
        tapImgL.position = CGPoint(x: -tapImgL.size.width/2, y: -yD/20)
        tapImgL.isHidden = true
        tapImgL.alpha = 0.4
        layerHUD.addChild(tapImgL)
        
        let showLeftHand = SKAction.run {
            leftHand.isHidden   = false
            tapImgL.isHidden    = false
            rightHand.isHidden  = true
            tapImgR.isHidden    = true
        }
        
        let showRightHand = SKAction.run {
            leftHand.isHidden   = true
            tapImgL.isHidden    = true
            rightHand.isHidden  = false
            tapImgR.isHidden    = false
        }
        
        let move = SKAction.move(by: CGVector(dx:xD/2,dy:0), duration: 0.05)
        let reverseMove = move.reversed()
        

        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.3)
        let fadeIn = SKAction.fadeAlpha(to: 0.2, duration: 0.3)
        let sequence = SKAction.sequence([fadeOut,move,showRightHand,fadeIn,fadeOut,reverseMove,showLeftHand,fadeIn])
        rec.run(SKAction.repeatForever(sequence))
        layerHUD.addChild(rec)
        
    }
    
//    func setupEmitter() {
//        
//        let snow = SKEmitterNode(fileNamed: "Snow")
//        let rain = SKEmitterNode(fileNamed: "Rain")
//     
//        let snowDuration = SKAction.wait(forDuration: 20)
//        let rainDuration = SKAction.wait(forDuration: 20)
//       
//        let wait = SKAction.wait(forDuration: 20.0)
//        
//        let snowGo = SKAction.sequence([SKAction.run({
//            self.setup(snow!, duration: snowDuration)}),snowDuration,wait])
//        
//        let rainGo = SKAction.sequence([SKAction.run({
//            self.setup(rain!, duration: rainDuration)}),rainDuration,wait])
//        
//        let i = Int.random(4)
//        
//        if i>2 {
//            scene?.run(SKAction.repeatForever(SKAction.sequence([rainGo,snowGo])), withKey: "emitterGo")
//        } else {
//            scene?.run(SKAction.repeatForever(SKAction.sequence([snowGo,rainGo])), withKey: "emitterGo")
//        }
//        
//        layerEmitter.zPosition = 200
//    }
    
//    func setup(_ emitter: SKEmitterNode, duration: SKAction) {
//        
//        let alphaIn = SKAction.fadeAlpha(to: 1, duration: 3.0)
//        let alphaOut = SKAction.fadeAlpha(to: 0, duration: 3.0)
//        let remove = SKAction.removeFromParent()
//        
//        emitter.alpha = 0
//        emitter.position = CGPoint(x: xM, y: yH)
//        
//        emitter.run(SKAction.sequence([alphaIn,duration,alphaOut,remove]))
//        layerEmitter.addChild(emitter)
//    }
    
    func gameOverScene() {
        
        gameState = .gameOver
        saveGameResult()
        
        // Load Advertisement
        gameOverCount += 1
        if !productPurchased && (gameOverCount%3==2) {
            // Load Interstitial
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyLoadInterAds), object: self)
        }
        if !productPurchased && (gameOverCount%3==0) {
            // Show Interstitial
            print("Showing Interstitial")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyShowInterAds), object: self)
        }
        if gameOverCount==14 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KeyRate), object: self)
        }
        
        layerHUD.removeAllChildren()
        cameraNode.removeAllChildren()
        
        layerHUD.alpha = 1
        layerHUD.zPosition = 120
        cameraNode.addChild(layerHUD)
        
        let recHUD = SKShapeNode(rectOf: CGSize(width: xD*2.5/3, height: yD*2.5/3.0), cornerRadius: 50)
        recHUD.position = CGPoint(x: 0, y: 0)
        recHUD.fillColor = .black
        recHUD.alpha = 0.2
        layerHUD.addChild(recHUD)
        
        gameOverScore.fontSize = xD * 0.3
        gameOverScore.position = CGPoint(x:0,y:yD/4.5)
        gameOverScore.text = String(score)
        layerHUD.addChild(gameOverScore)
        
        gameOverBestScore.fontSize = xD * 0.09
        gameOverBestScore.position = CGPoint(x:0,y:gameOverScore.position.y - 150)
        gameOverBestScore.text = "BEST " + String(bestScore)
        layerHUD.addChild(gameOverBestScore)

        let size = CGSize(width: xD/2, height: yD/13)
        
        let recPlay = SKShapeNode(rectOf: size, cornerRadius: 30)
        recPlay.position = CGPoint(x: 0, y: yD/25)
        recPlay.fillColor = .black
        recPlay.alpha = 0.3
        recPlay.zPosition = 200
        recPlay.name = "PlayButton"
        layerHUD.addChild(recPlay)
        
        labelPlay.fontSize = yD/17
        labelPlay.position = recPlay.position
        labelPlay.text = "PLAY"
        labelPlay.zPosition = 200
        labelPlay.verticalAlignmentMode = .center
        labelPlay.horizontalAlignmentMode = .center
        layerHUD.addChild(labelPlay)
        
        let recRate = SKShapeNode(rectOf: size, cornerRadius: 30)
        recRate.position = CGPoint(x: 0, y: recPlay.position.y - yD/11)
        recRate.fillColor = .black
        recRate.alpha = 0.3
        recRate.zPosition = 200
        recRate.name = "RateButton"
        layerHUD.addChild(recRate)
        
        labelRate.fontSize = yD/17
        labelRate.position = recRate.position
        labelRate.text = "RATE"
        labelRate.zPosition = 200
        labelRate.verticalAlignmentMode = .center
        labelRate.horizontalAlignmentMode = .center
        layerHUD.addChild(labelRate)
        
        let recOption = SKShapeNode(rectOf: size, cornerRadius: 30)
        recOption.position = CGPoint(x: 0, y: recRate.position.y - yD/11)
        recOption.fillColor = .black
        recOption.alpha = 0.3
        recOption.zPosition = 200
        recOption.name = "OptionsButton"
        layerHUD.addChild(recOption)
        
        labelOption.fontSize = yD/17
        labelOption.position = recOption.position
        labelOption.text = "OPTIONS"
        labelOption.zPosition = 200
        labelOption.verticalAlignmentMode = .center
        labelOption.horizontalAlignmentMode = .center
        layerHUD.addChild(labelOption)

        layerHUD.position = CGPoint(x: 0, y: yD)
        let osc = SKAction.screenShakeWithNode(layerHUD, amount: CGPoint(x: 0, y:-50), oscillations: 6, duration: 0.5)
        let move = SKAction.move(to: CGPoint(x:0,y:0), duration: 0.1)
        layerHUD.run(SKAction.sequence([soundMenuDrop,move,osc]))
    }
    
    func handleOptions() {
        if optionsIsShow {
            self.optionsHUD.removeAllChildren()
            self.optionsHUD.removeFromParent()
            self.optionsIsShow = false
            self.labelOption.alpha = 1.0
        } else {
            let levelX = -xD/2 + xD/5
            let levelY = -yD/2.8
            let levelYY = levelY + yD/10
            
            buttonGames.position = CGPoint(x: levelX,y: levelY)
            buttonGames.name = "MoreGamesButton"
            buttonGames.zPosition = 10
            optionsHUD.addChild(buttonGames)

            buttonChart.position = CGPoint(x:levelX + xD/5,y:levelY)
            buttonChart.name = "ChartButton"
            buttonChart.zPosition = 10
            optionsHUD.addChild(buttonChart)

            buttonShare.position = CGPoint(x:levelX + xD*2/5,y:levelY)
            buttonShare.name = "ShareButton"
            buttonShare.zPosition = 10
            optionsHUD.addChild(buttonShare)

            buttonRate.position = CGPoint(x:levelX + xD*3/5,y:levelY)
            buttonRate.name = "RateButton"
            buttonRate.zPosition = 10
            optionsHUD.addChild(buttonRate)

            buttonLike.position = CGPoint(x: levelX,y:levelYY)
            buttonLike.name = "LikeButton"
            buttonLike.zPosition = 10
            optionsHUD.addChild(buttonLike)
            
            var buttonSpeaker: SKSpriteNode!
            if speakerOn {
                buttonSpeaker = SKSpriteNode(imageNamed: "SpeakerOnButton")
            } else {
                buttonSpeaker = SKSpriteNode(imageNamed: "SpeakerOffButton")
            }
            buttonSpeaker.position = CGPoint(x: levelX + xD/5,y: levelYY)
            buttonSpeaker.name = "SpeakerButton"
            buttonSpeaker.zPosition = 10
            optionsHUD.addChild(buttonSpeaker)

            buttonIAP.position = CGPoint(x: levelX + xD*2/5,y: levelYY)
            buttonIAP.name = "IAPButton"
            buttonIAP.zPosition = 10
            optionsHUD.addChild(buttonIAP)

            buttonNoAds.position = CGPoint(x: levelX + xD*3/5,y: levelYY)
            buttonNoAds.name = "NoAdsButton"
            buttonNoAds.zPosition = 10
            optionsHUD.addChild(buttonNoAds)
            
            layerHUD.addChild(optionsHUD)
            labelOption.alpha = 0.4
            optionsIsShow = true
        }
    }
    
    func handleMusic() {
        if musicPlaying {
            musicPlaying = false
            backgroundMusicPlayer.volume = 0.0
        } else {
            musicPlaying = true
            backgroundMusicPlayer.volume = 0.6
        }
    }
    
    func handleSpeaker() {
        if speakerOn {
            if let speaker = optionsHUD.childNode(withName: "SpeakerButton") as? SKSpriteNode {
                speaker.texture = SKTexture(imageNamed: "SpeakerOffButton")
                speakerOn = false
            }
        } else {
            if let speaker = optionsHUD.childNode(withName: "SpeakerButton") as? SKSpriteNode {
                speaker.texture = SKTexture(imageNamed: "SpeakerOnButton")
                speakerOn = true
            }
        }
    }
    
    func handleCoinButton() {
        UserDefaults.standard.set(score, forKey: "lastScore")
        UserDefaults.standard.synchronize()
        newGame()
    }
    
    func handleRate() {
        let appId = "1170838321"
        let url = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appId)"
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    func handleLeaderboard() {
        let vc = self.view?.window?.rootViewController
        SGGameKit.sharedInstance.showGKGameCenterViewController(viewController: vc!, state: 2)
    }
    
    func handleShare() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: KeyShare), object: self)
    }
    
    func handleLike() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: KeyLoadFB), object: self)
    }
    
    func handleNoads() {
        print("NoAds Pressed")
        for product in products {
            print("productId \(product.productIdentifier)")
            if product.productIdentifier == appProduct {
                print("Start Purchasing")
                storeManager.purchaseProduct(product)
            }
        }
    }
    
    func handleRestoreIAP() {
        print("IAP Restore Pressed")
        for product in products {
            print("productId \(product.productIdentifier)")
            if product.productIdentifier == appProduct {
                print("Start Restoring")
                storeManager.restoreCompletedTransactions()
            }
        }
    }
    
    func handleMoreGames() {
        let url = "https://itunes.apple.com/us/developer/binh-huynh/id1048890134"
        UIApplication.shared.openURL(URL(string: url)!)
    }
    
    func newGame() {
        let newScene = GameScene(size:CGSize(width: 1536, height: 2048))
        newScene.scaleMode = .aspectFill
        let reveal = SKTransition.moveIn(with: .down,duration: 0.5)
        self.view?.presentScene(newScene, transition: reveal)
    }
}

extension GameScene: StoreManagerDelegate {
    
    func updateWithProducts(_ products:[SKProduct]) {
        self.products = products
    }
    
    func refreshPurchaseStatus() {
        if ProductDelivery.isProductAvailable(appProduct) {
            print("Product Status: Purchased")
            productPurchased = true
        } else {
            print("Product Status: Not Purchased")
        }
    }
}
