//
//  GameScene.swift
//  AngryBirdies
//
//  Created by Brando Flores on 12/17/20.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let gameCamera = GameCamera()
    var panRecognizer = UIPanGestureRecognizer()
    
    override func didMove(to view: SKView) {
        addCamera()
        setupGestureRecognizer()
    }
    
    func addCamera() {
        // Check if the view property contains a value
        guard let view = view else { return }
        addChild(gameCamera)
        gameCamera.position = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        camera = gameCamera
    }
    
    func setupGestureRecognizer() {
        guard let view = view else { return }
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        view.addGestureRecognizer(panRecognizer)
    }
    
}

extension GameScene {
    
    /*
     Allow the user to pan the screen in the game
     */
    @objc func pan(sender: UIPanGestureRecognizer) {
        guard let view = view else { return }
        let translation = sender.translation(in: view)
        gameCamera.position = CGPoint(x: gameCamera.position.x - translation.x, y: gameCamera.position.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: view)
    }
}
