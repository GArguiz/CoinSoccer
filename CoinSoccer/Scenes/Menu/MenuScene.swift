//
//  MenuScene.swift
//  AirHockey
//
//  Created by Máster Móviles on 24/3/23.
//  Copyright © 2023 Miguel Angel Lozano Ortega. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuScene: SKScene, ButtonSpriteNodeDelegate {
    
    func didPushButton(_ sender: ButtonSpriteNode) {
        if let scene = SKScene(fileNamed: "GameScene"),
           let view = self.view
        {
            scene.scaleMode = .resizeFill
            scene.resizeWithFixedHeightTo(viewportSize: view.frame.size)
            view.presentScene(scene, transition: .flipHorizontal(withDuration: 2))
        }
    }
    
    
    override func didMove(to view: SKView) {
        if let playButton: ButtonSpriteNode =  self.childNode(withName: "play_button") as? ButtonSpriteNode {
            playButton.delegate = self
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        
    }
   
}
