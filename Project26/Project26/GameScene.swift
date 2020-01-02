//
//  GameScene.swift
//  Project26
//
//  Created by Lareen Melo on 12/31/19.
//  Copyright © 2019 Lareen Melo. All rights reserved.
//

import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case portal = 32
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager?
    
    var isGameOver = false
    
    var scoreLabel: SKLabelNode!
    var portalActive = true
    
    var restartGameLabel: SKLabelNode!
    var restartLevelLabel: SKLabelNode!
    var nextLevelLabel: SKLabelNode!
    var finishNode: SKSpriteNode!
    
    var currentLevelLabel: SKLabelNode!
    
    var currentLevel = 1 {
        didSet {
            currentLevelLabel.text = "Level: \(currentLevel)"
        }
    }
    var maxLevel = 7
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        currentLevelLabel = SKLabelNode(fontNamed: "Chalkduster")
        currentLevelLabel.text = "Level: \(currentLevel)"
        currentLevelLabel.horizontalAlignmentMode = .left
        currentLevelLabel.position = CGPoint(x: 16, y: 730)
        currentLevelLabel.zPosition = 2
        currentLevelLabel.name = "currentLevel"
        addChild(currentLevelLabel)
        
        prepareFinishLabels()
        
        createPlayer()
        loadLevel()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
    }
    
    func prepareFinishLabels() {
        finishNode = SKSpriteNode(imageNamed: "finish")
        finishNode.position = CGPoint(x: 512, y: 544)
        finishNode.zPosition = 2

        nextLevelLabel = SKLabelNode(fontNamed: "Chalkduster")
        nextLevelLabel.text = "Next Level"
        nextLevelLabel.fontSize = 48
        nextLevelLabel.name = "nextLevel"
        nextLevelLabel.horizontalAlignmentMode = .center
        nextLevelLabel.position = CGPoint(x: 512, y: 454)
        nextLevelLabel.zPosition = 2
        
        restartLevelLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartLevelLabel.text = "Restart Level"
        restartLevelLabel.fontSize = 48
        restartLevelLabel.name = "restartLevel"
        restartLevelLabel.horizontalAlignmentMode = .center
        restartLevelLabel.position = CGPoint(x: 512, y: 384)
        restartLevelLabel.zPosition = 2
        
        restartGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        restartGameLabel.text = "Restart Game"
        restartGameLabel.fontSize = 48
        restartGameLabel.name = "restartGame"
        restartGameLabel.horizontalAlignmentMode = .center
        restartGameLabel.position = CGPoint(x: 512, y: 314)
        restartGameLabel.zPosition = 2
    }
    
    func loadLevel() {
        let name = "level\(currentLevel)"
        
        guard let levelURL = Bundle.main.url(forResource: name, withExtension: ".txt") else {
            fatalError("Could not find \(name).txt in the app bundle")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load \(name).txt from the app bundle")
        }
        
        let lines = levelString.split(separator: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32)
                addLevelElement(withId: letter, to: position)
            }
        }
    }
    
    func destroyLevel() {
        for node in children {
            if ["wall", "vortex", "star", "finish", "portal"].contains(node.name) {
                node.removeFromParent()
            }
        }
        player.removeFromParent()
    }
    
    func addLevelElement(withId letter: Character, to position: CGPoint) {
        if letter == "x" {
            addWall(to: position)
        }
        else if letter == "v" {
            addVortex(to: position)
        }
        else if letter == "s" {
            addStar(to: position)
        }
        else if letter == "f" {
            addFinish(to: position)
        }
        else if letter == "p" {
            addPortal(to: position)
        }
        else if letter == " " {
        }
        else {
            fatalError("Unknown level letter: \(letter)")
        }
    }
    
    func addWall(to position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        node.name = "wall"
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue
        node.physicsBody?.isDynamic = false
        
        addChild(node)
    }
    
    func addVortex(to position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        addChild(node)
    }

    func addStar(to position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.position = position
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        addChild(node)
    }
    
    func addFinish(to position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.position = position
        
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        
        addChild(node)
    }
    
    func addPortal(to position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "portal")
        node.name = "portal"
        node.position = position
        
        let scale = SKAction.scale(by: 1.07, duration: 1.5)
        node.run(SKAction.repeatForever(SKAction.sequence([scale, scale.reversed()])))
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: -.pi, duration: 6)))

        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = CollisionTypes.portal.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue

        node.physicsBody?.collisionBitMask = 0
        
        addChild(node)
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.portal.rawValue
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        
        addChild(player)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
        
        for node in nodes(at: location) {
            if node.name == "nextLevel" {
                currentLevel += 1
                if currentLevel > maxLevel {
                    currentLevel = 1
                }
                restart()
            }
            else if node.name == "restartLevel" {
                restart()
            }
            else if node.name == "restartGame" {
                score = 0
                currentLevel = 1
                restart()
            }
            else if node.name == "currentLevel" {
                player.removeAllActions()
                player.physicsBody?.isDynamic = false
                addChild(nextLevelLabel)
                addChild(restartLevelLabel)
                addChild(restartGameLabel)
            }
        }
    }
    
    func restart() {
        finishNode.removeFromParent()
        nextLevelLabel.removeFromParent()
        restartLevelLabel.removeFromParent()
        restartGameLabel.removeFromParent()
        destroyLevel()
        loadLevel()
        createPlayer()
        isGameOver = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        
        #if targetEnvironment(simulator)
        if let lastTouchPosition = lastTouchPosition {
            let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        #else
        if let accelerometerData = motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
        #endif
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
    
        if nodeA == player {
            playerCollided(with: nodeB)
        }
        else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerEndedCollision(with: nodeB)
        }
        else if nodeB == player {
            playerEndedCollision(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(to: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        }
        if node.name == "portal" && portalActive {
            for currentNode in children {
                if currentNode.name == "portal" && currentNode != node {
                    enterPortalAction(portalIn: node, portalOut: currentNode)
                    break
                }
            }
        }
        else if node.name == "star" {
            node.removeFromParent()
            score += 1
        }
        else if node.name == "finish" {
            player.physicsBody?.isDynamic = false
            addChild(finishNode)
            addChild(nextLevelLabel)
            addChild(restartLevelLabel)
            addChild(restartGameLabel)
        }
        
        if !portalActive && node.name != "portal" {
            portalActive = true
        }
    }

    func playerEndedCollision(with node: SKNode) {
        guard node.name == "portal" else { return }
        
        portalActive = true
    }
    
    func enterPortalAction(portalIn: SKNode, portalOut: SKNode) {
        
        player.physicsBody?.isDynamic = false
        
        let rotate = SKAction.rotate(byAngle: -.pi, duration: 0.1)
        let rotateSequence = SKAction.sequence([rotate, rotate, rotate, rotate, rotate])
        player.run(rotateSequence)
        
        let move = SKAction.move(to: portalIn.position, duration: 0.25)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([move, fade, remove])
        
        player.run(sequence) { [weak self, weak portalOut] in
            if let portalOut = portalOut {
                self?.exitPortalAction(portalOut: portalOut)
            }
        }
    }
    
    func exitPortalAction(portalOut: SKNode) {
        createPlayer()
        player.alpha = 0.0
        player.position = portalOut.position

        let rotate = SKAction.rotate(byAngle: -.pi, duration: 0.05)
        let rotateSequence = SKAction.sequence([rotate, rotate, rotate, rotate, rotate])
        player.run(rotateSequence)

        player.run(SKAction.fadeIn(withDuration: 0.25))
        
        portalActive = false
    }
}
