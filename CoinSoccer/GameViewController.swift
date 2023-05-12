//
//  GameViewController.swift
//  CoinSoccer
//
//  Created by Gilberto Arguiz on 12/5/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Carga la escena desde 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MenuScene") {
                // TODO [A03] Prueba con diferentes estrategias de escalado de la escena.
                // scene.scaleMode = ...
                scene.scaleMode = .resizeFill
                scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
                // Presenta la escena
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false

        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
