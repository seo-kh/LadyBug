//
//  LadyBugScene.swift
//  LadyBug
//
//  Created by hailey macbook on 2023/01/23.
//

import SpriteKit
import GameplayKit

final class LadyBugScene: SKScene {
    
    private var ladyBug: SKSpriteNode?
    private var blocks: [SKSpriteNode]?
    private var lifes: [SKSpriteNode]?
    private var isContact = false
    private var pivotPoint: CGPoint = .zero
    private var lastUpdatedTime: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    let duration: TimeInterval = 10
    
    override func sceneDidLoad() {
        ladyBug = childNode(withName: "ladyBug") as? SKSpriteNode
        blocks = (0 ..< 5).map(generateBlock)
        lifes = self["life"] as? [SKSpriteNode]
        self.delegate = self
        
        self.physicsWorld.contactDelegate = self
    }
    
    /// 접촉이 발생하면, 움직임이 없음.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isContact && !(lifes?.isEmpty ?? false) else { return }
        
        for t in touches {
            let position = t.location(in: self)
            /// bug's position
            ladyBug?.position = position
            /// bug's zRotaion
            let deltaX = position.x - pivotPoint.x
            let deltaY = position.y - pivotPoint.y
            let treshold = 1.0
            switch (deltaX, deltaY) {
            case let (x, y) where x > treshold && abs(y) > treshold:
                ladyBug?.zRotation = atan(y / x) - (.pi / 2.0)
            case let (x, y) where x <= -treshold && abs(y) > treshold:
                ladyBug?.zRotation = atan(y / x) + (.pi / 2.0)
            default:
                break
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !(lifes?.isEmpty ?? false) else { return }
        
        if isContact {
            blocks?.forEach { $0.removeFromParent() }
            ladyBug?.position = CGPoint(x: 0, y: 0)
            if let life = lifes?.removeLast() { life.alpha = 0 }
            blocks = (0..<5).map(generateBlock)
            isContact = false
        } else {
            for t in touches {
                ladyBug?.position = t.location(in: self)
            }
        }
    }
}

extension LadyBugScene: SKSceneDelegate {
    /// duration지난후, 새로운 블록 생성
    ///
    /// link: [here](https://blog.bitbebop.com/deltatime-spritekit-swift/)
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        guard !(lifes?.isEmpty ?? false) else { return }
        
        if lastUpdatedTime.isZero { lastUpdatedTime = currentTime }
        let delta = currentTime - lastUpdatedTime
        lastUpdatedTime = currentTime
        elapsedTime += delta
        
        if elapsedTime > duration {
            blocks?.forEach { $0.removeFromParent() }
            blocks = (0 ..< 5).map(generateBlock)
            elapsedTime = 0
        }
    }
}

extension LadyBugScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        if lifes?.count ?? 0 == 1 {
            SoundManager.stop()
            SoundManager.play(fileName: "gameover.wav")
            if let life = lifes?.removeLast() { life.alpha = 0 }
            blocks?.forEach { $0.removeFromParent() }
            ladyBug?.run(SKAction.moveTo(y: -1500.0, duration: 5.0))
        } else {
            isContact = true
            generateContactSound()
            blocks?.forEach { $0.removeAllActions() }
        }
    }
}

private extension LadyBugScene {
    func generateContactSound() {
        let sound = SKAction.playSoundFileNamed(
            "contact.wav",
            waitForCompletion: false
        )
        let volume = SKAction.changeVolume(to: 0.1, duration: sound.duration)
        ladyBug?.run(SKAction.group([sound, volume]))
    }
    
    func generateBlock<T>(_ element: T) -> SKSpriteNode {
        let block = SKSpriteNode(imageNamed: "block")
        block.setScale(0.3)
        block.physicsBody = SKPhysicsBody(rectangleOf: block.size)
        block.physicsBody?.categoryBitMask = 1
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.allowsRotation = false
        block.physicsBody?.isDynamic = false
        block.physicsBody?.pinned = false
        block.position = CGPoint(x: .randomX, y: .randomY)
        self.generateMove(block)
        self.addChild(block)
        return block
    }
    
    func generateMove(_ block: SKSpriteNode) {
        let move = SKAction.move(
            to: .init(x: CGFloat.randomPosition.x,
                      y: CGFloat.randomPosition.y),
            duration: .random(in: (3..<self.duration))
        )
        block.run(move)
    }
}

extension CGFloat {
    static var randomPosition: (x: CGFloat, y: CGFloat) {
        let theta = .pi * .random(in: 0.0 ..< 2.0)
        let x = 1000.0 * cos(theta)
        let y = 1000.0 * sin(theta)
        return (x, y)
    }
    
    /// block이 좌우를 넘지않으면서, ladyBug를 침범하지않는 최소 x 범위
    static var randomX: CGFloat {
        self.random(in: (-4.0 ..< -3.0)) * [-1.0, 1.0].randomElement()! * 64.0
    }
    /// block이 상하를 넘지않으면서, life를 넘지않으면서, ladyBug를 침범하지않는 최소 y 범위
    static var randomY: CGFloat {
        self.random(in: (-8.0 ..< -6.0)) * [-1.0, 1.0].randomElement()! * 64.0
    }
}
