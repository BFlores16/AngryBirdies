//
//  GameScene.swift
//  AngryBirdies
//
//  Created by Brando Flores on 12/17/20.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let gameCamera = SKCameraNode()
    
    override func didMove(to view: SKView) {
        addCamera()
    }
    
    func addCamera() {
        // Check if the view property contains a value
        guard let view = view else { return }
        addChild(gameCamera)
        gameCamera.position = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        camera = gameCamera
    }
    
}
