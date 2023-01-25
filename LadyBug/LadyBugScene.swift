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
    private var pivotPoint: CGPoint = .zero
    
    override func sceneDidLoad() {
        ladyBug = childNode(withName: "ladyBug") as? SKSpriteNode
//        blocks = (0 ..< 5).map(generateBlock)
        lifes = self["life"] as? [SKSpriteNode]

        self.physicsWorld.contactDelegate = self
        
    }
    
    /// 접촉이 발생하면, 움직임이 없음.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isContact else { return }
        
        for t in touches {
            let position = t.location(in: self)
            /// bug's position
            ladyBug?.position = position
            /// bug's zRotaion
            /// 1. zRotation은 radian 단위다. 기준은 +x축이다.
            /// ladyBug?.zRotation = atan(position.y / position.x)
            /// 2. bug는 +y축 기준에서 회전한다. 즉, zRotation이 30˙ 도 변하면, bug는 실제 (90+30)˚로 변한다. (이것은 우리가 원하는 방향이 아니다.!)
            /// 𝛳 = 0˚면, bug는 실제 -90˚ 여야한다. 𝛳 = 90˚면, bug는 실제 0˚여야한다.
            /// swift에서 제공하는 `atan`은 양수값만 제공하지않는다. 4분면마다 각도가 다르다.
            /// 즉, 이를 보정하기위한 기준은 x값의 +/- 여부다. 이 기준에 따라 90˚, -90˚ 보정값을 추가하면 된다.
            /// 𝛳 = atan(y/x) - π / 2 , where x > 0
            /// 𝛳 = atan(y/x) + π / 2 , where x <0
            /// switch position.x {
            /// case let x where x > 0:
            ///     ladyBug?.zRotation = atan(position.y / position.x) - (.pi / 2.0)
            /// case let x where x <= 0:
            ///     ladyBug?.zRotation = atan(position.y / position.x) + (.pi / 2.0)
            /// default:
            ///     break
            /// }
            /// 3. 마우스커서에 따라 회전이 즉각적으로 변했으면 좋겠다. piviotPoint를 만들어서 업데이트하자.
            /// let deltaX = position.x - pivotPoint.x
            /// let deltaY = position.y - pivotPoint.y
            /// switch deltaX {
            /// case let x where x > 0:
            ///     ladyBug?.zRotation = atan(deltaY / deltaX) - (.pi / 2.0)
            /// case let x where x <= 0:
            ///     ladyBug?.zRotation = atan(deltaY / deltaX) + (.pi / 2.0)
            /// default:
            ///     break
            /// }
            /// 4. FPS 60이라, 계산이 너무 잦다. 조금만 움직여도 bug의 움직임이 너무 잦다.
            ///     - 이를 보정하기위해,  `treshold`값을 이용해 작은 `delta`값은 무시.
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

extension LadyBugScene {
    func didBegin(_ contact: SKPhysicsContact) {
        isContact = true
        blocks?.forEach { $0.removeAllActions() }
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
            to: .init(x: CGFloat.randomPosition.x,
                      y: CGFloat.randomPosition.y),
            duration: 10
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
