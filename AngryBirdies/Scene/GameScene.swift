//
//  GameScene.swift
//  AngryBirdies
//
//  Created by Brando Flores on 12/17/20.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var mapNode = SKTileMapNode()
    
    let gameCamera = GameCamera()
    var panRecognizer = UIPanGestureRecognizer()
    var pinchRecognizer = UIPinchGestureRecognizer()
    var maxScale: CGFloat = 0.0 // Prevent the player from zooming too far/close
    
    override func didMove(to view: SKView) {
        setupLevel()
        setupGestureRecognizer()
    }
    
    func setupGestureRecognizer() {
        guard let view = view else { return }
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        view.addGestureRecognizer(panRecognizer)
        
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    func setupLevel() {
        if let mapNode = childNode(withName: "Tile Map Node") as? SKTileMapNode {
            self.mapNode = mapNode
            // Width is greater than height so use width to prevent scaling
            // past the background
            maxScale = mapNode.mapSize.width/frame.size.width
        }
        
        addCamera()
    }
    
    func addCamera() {
        // Check if the view property contains a value
        guard let view = view else { return }
        addChild(gameCamera)
        gameCamera.position = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        camera = gameCamera
        gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
    }
    
}

extension GameScene {
    
    /*
     Allow the user to pan the screen in the game
     */
    @objc func pan(sender: UIPanGestureRecognizer) {
        guard let view = view else { return }
        let translation = sender.translation(in: view) * gameCamera.yScale
        gameCamera.position = CGPoint(x: gameCamera.position.x - translation.x, y: gameCamera.position.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    /*
     Allow the user to zoom in and out of the screen
     */
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        guard let view = view else { return }
        if sender.numberOfTouches == 2 {
            
            // move the pov to where the user is pinching
            let locationInView = sender.location(in: view)
            // The location the user started pinching from
            let location = convertPoint(fromView: locationInView)
            
            if sender.state == .changed {
                let convertedScale = 1/sender.scale
                let newScale = gameCamera.yScale*convertedScale // Doesnt matter x or y
                // Prevent the player from zooming too much
                if newScale < maxScale && newScale > 0.5 {
                    gameCamera.setScale(newScale) // Scales both x and y
                }
                
                // Set the location to the location based on the user's area
                // they pinched
                let locationAfterScale = convertPoint(fromView: locationInView)
                
                // Uses configuration file for easy arithmetic between two
                // CGPoints
                let locationDelta = location - locationAfterScale
                let newPosition = gameCamera.position + locationDelta
                
                // Reset the scale so that if the user rescales it will be smooth
                sender.scale = 1.0
                gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
            }
        }
    }
    
}
