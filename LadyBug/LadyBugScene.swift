//
//  LadyBugScene.swift
//  LadyBug
//
//  Created by hailey macbook on 2023/01/23.
//

import SpriteKit
import GameplayKit

final class LadyBugScene: SKScene, SKPhysicsContactDelegate {
    
    private var ladyBug: SKSpriteNode?
    private var blocks: [SKSpriteNode]?
    private var lifes: [SKSpriteNode]?
    private var isContact = false
    
    override func sceneDidLoad() {
        ladyBug = childNode(withName: "ladyBug") as? SKSpriteNode
        blocks = (0 ..< 5).map(generateBlock)
        lifes = self["life"] as? [SKSpriteNode]

        self.physicsWorld.contactDelegate = self
        
    }
    
    /// 접촉이 발생하면, 움직임이 없음.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isContact else { return }
        
        for t in touches {
            ladyBug?.position = t.location(in: self)
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !(lifes?.isEmpty ?? false) else { return }
        
        if isContact {
            ladyBug?.position = CGPoint(x: 0, y: 0)
            if let life = lifes?.removeLast() {
                life.alpha = 0
            }
            blocks?.forEach(generateMove)
            isContact = false
        } else {
            for t in touches {
                ladyBug?.position = t.location(in: self)
            }
        }
    }
    
}

extension LadyBugScene {
    func didBegin(_ contact: SKPhysicsContact) {
        isContact = true
    }
    
    private func generateBlock<T>(_ element: T) -> SKSpriteNode {
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
    
    private func generateMove(_ block: SKSpriteNode) {
        let move = SKAction.move(
            to: .init(x: .random(in: (-325 ..< 325)),
                      y: .random(in: (-667 ..< 667))),
            duration: 10
        )
        block.run(move)
    }
}

extension CGFloat {
    /// block이 좌우를 넘지않으면서, ladyBug를 침범하지않는 최소 x 범위
    static var randomX: CGFloat {
        self.random(in: (-4.0 ..< -3.0)) * [-1.0, 1.0].randomElement()! * 64.0
    }
    /// block이 상하를 넘지않으면서, life를 넘지않으면서, ladyBug를 침범하지않는 최소 y 범위
    static var randomY: CGFloat {
        self.random(in: (-8.0 ..< -6.0)) * [-1.0, 1.0].randomElement()! * 64.0
    }
}
