//
//  LadyBugScene.swift
//  LadyBug
//
//  Created by hailey macbook on 2023/01/23.
//

import SpriteKit
import GameplayKit

/// TODO: Contact Simulation!
///
/// link: [here](https://www.youtube.com/watch?v=43hzb4NmQfw)
final class LadyBugScene: SKScene, SKPhysicsContactDelegate {
    
    private var ladyBug: SKSpriteNode?
    private var block0: SKSpriteNode?
    private var isContact = false
    
    override func sceneDidLoad() {
        ladyBug = childNode(withName: "ladyBug") as? SKSpriteNode
        block0 = childNode(withName: "block0") as? SKSpriteNode
        self.physicsWorld.contactDelegate = self
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            ladyBug?.position = t.location(in: self)
        }
    }
    
}

extension LadyBugScene {
    func didBegin(_ contact: SKPhysicsContact) {
        print("contact! at ", contact.contactPoint)
    }
}
