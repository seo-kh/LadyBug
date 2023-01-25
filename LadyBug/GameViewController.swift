//
//  GameViewController.swift
//  LadyBug
//
//  Created by hailey macbook on 2023/01/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "LadyBugScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = false
            view.showsFPS = true
            view.showsNodeCount = true
        }
        SoundManager.play(fileName: "background.mp3")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func didSoundButtonTapped(_ sender: UIBarButtonItem) {
        let sheet = UIAlertController(title: "음악 설정", message: nil, preferredStyle: .actionSheet)
        let play = UIAlertAction(title: "재생", style: .default) { _ in
            SoundManager.play(fileName: "background.mp3")
        }
        let stop = UIAlertAction(title: "정지", style: .default) { _ in
            SoundManager.stop()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        sheet.addAction(play)
        sheet.addAction(stop)
        sheet.addAction(cancel)
        
        self.present(sheet, animated: true)
    }
}
