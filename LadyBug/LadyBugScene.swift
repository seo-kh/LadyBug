//
//  LadyBugScene.swift
//  LadyBug
//
//  Created by hailey macbook on 2023/01/23.
//

import SpriteKit
import GameplayKit

class LadyBugScene: SKScene {
    private var ladyBug: SKSpriteNode?
    private var block0: SKSpriteNode?
    
    override func sceneDidLoad() {
        ladyBug = childNode(withName: "ladyBug") as? SKSpriteNode
        block0 = childNode(withName: "block0") as? SKSpriteNode
        
//        print("sceneDidLoad()!")
//        print("ladyBug: ",ladyBug)
//        print("block0: ",block0)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            ladyBug?.position = t.location(in: self)
//            print("bug position: ", ladyBug?.position)
        }
    }
}

extension LadyBugScene {
    func didBegin(_ contact: SKPhysicsContact) {
        print(contact.bodyA, contact.bodyB, contact.contactPoint)
    }
}
