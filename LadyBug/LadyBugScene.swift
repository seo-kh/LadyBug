//
//  LadyBugScene.swift
//  LadyBug
//
//  Created by hailey macbook on 2023/01/23.
//

import SpriteKit
import GameplayKit

/// TODO: Life counting Simulation!
///
/// 같은 이름의 node 불러오기: [here](https://developer.apple.com/documentation/spritekit/sknode/1483070-subscript)
final class LadyBugScene: SKScene, SKPhysicsContactDelegate {
    
    private var ladyBug: SKSpriteNode?
    private var block0: SKSpriteNode?
    private var lifes: [SKSpriteNode]?
    private var isContact = false
    
    override func sceneDidLoad() {
        ladyBug = childNode(withName: "ladyBug") as? SKSpriteNode
        block0 = childNode(withName: "block0") as? SKSpriteNode
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
    
    /// 1) life가 없으면 게임끝.
    /// 2) 접촉이 있으면 ladyBug는 원점위치, life감소, contact여부 재설정
    /// 3) 이외의 경우에는 ladyBug의 위치변경
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !(lifes?.isEmpty ?? false) else { return }
        
        if isContact {
            ladyBug?.position = CGPoint(x: 0, y: 0)
            if let life = lifes?.removeLast() {
                life.alpha = 0
            }
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
}
