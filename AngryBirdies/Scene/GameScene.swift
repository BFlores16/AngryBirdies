//
//  GameScene.swift
//  AngryBirdies
//
//  Created by Brando Flores on 12/17/20.
//

import SpriteKit
import GameplayKit

// Defines states the game can be in during playing
enum RoundState {
    case ready, flying, finished, animating
}

class GameScene: SKScene {
    
    var mapNode = SKTileMapNode()
    
    let gameCamera = GameCamera()
    var panRecognizer = UIPanGestureRecognizer()
    var pinchRecognizer = UIPinchGestureRecognizer()
    var maxScale: CGFloat = 0.0 // Prevent the player from zooming too far/close
    
    var bird = Bird(type: .red)
    var birds = [
        Bird(type: .red),
        Bird(type: .blue),
        Bird(type: .yellow)
    ]
    let anchor = SKNode()
    
    var roundState = RoundState.ready
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        setupLevel()
        setupGestureRecognizer()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch roundState {
        case .ready:
            // touching function for the bird
            if let touch = touches.first {
                let location = touch.location(in: self)
                if bird.contains(location) {
                    panRecognizer.isEnabled = false
                    bird.grabbed = true
                    bird.position = location
                }
            }
        case .flying:
            break
        case .finished:
            guard let view = view else {return}
            roundState = .animating
            let cameraPosition = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
            let moveCameraBackAction = SKAction.move(to: cameraPosition, duration: 2.0)
            moveCameraBackAction.timingMode = .easeInEaseOut
            gameCamera.run(moveCameraBackAction) {
                self.panRecognizer.isEnabled = true
                self.addBird()
            }
        case .animating:
            break
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Makes the bird move wherever our finger moves
        if let touch = touches.first {
            if bird.grabbed {
                let location = touch.location(in: self)
                bird.position = location
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if bird.grabbed {
            gameCamera.setConstraints(with: self, and: mapNode.frame, to: bird)
            bird.grabbed = false
            bird.flying = true
            roundState = .flying
            constrainToAnchor(active: false)
            let dx = anchor.position.x - bird.position.x
            let dy = anchor.position.y - bird.position.y
            let impulse = CGVector(dx: dx, dy: dy)
            bird.physicsBody?.applyImpulse(impulse)
            bird.isUserInteractionEnabled = false
        }
    }
    
    // Bird is only draggable around its anchor point
    func constrainToAnchor(active: Bool) {
        if active {
            let slingRange = SKRange(lowerLimit: 0.0, upperLimit: bird.size.width * 3)
            let positionConstraint = SKConstraint.distance(slingRange, to: anchor)
            bird.constraints = [positionConstraint]
        }
        else {
            bird.constraints?.removeAll()
        }
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
        
        for child in mapNode.children {
            if let child = child as? SKSpriteNode {
                guard let name = child.name else {continue}
                if !["wood","stone","glass"].contains(name) {continue}
                guard let type = BlockType(rawValue: name) else {continue}
                let block = Block(type: type)
                block.size = child.size
                block.position = child.position
                block.color = UIColor.brown
                block.zPosition = ZPosition.obstacles
                block.createPhysicsBody()
                mapNode.addChild(block)
                child.color = UIColor.clear
            }
        }
        
        let physicsRect = CGRect(x: 0, y: mapNode.tileSize.height, width: mapNode.frame.size.width, height: mapNode.frame.size.height - mapNode.tileSize.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: physicsRect)
        physicsBody?.categoryBitMask = PhysicsCategory.edge
        physicsBody?.contactTestBitMask = PhysicsCategory.bird | PhysicsCategory.block
        physicsBody?.collisionBitMask = PhysicsCategory.all
        
        anchor.position = CGPoint(x: mapNode.frame.midX / 2, y: mapNode.frame.midY / 2)
        addChild(anchor)
        addBird()
    }
    
    func addCamera() {
        // Check if the view property contains a value
        guard let view = view else { return }
        addChild(gameCamera)
        gameCamera.position = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        camera = gameCamera
        gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
    }
    
    func addBird() {
        if birds.isEmpty {
            print("No mor birds")
            return
        }
        
        bird = birds.removeFirst()
        bird.physicsBody = SKPhysicsBody(rectangleOf: bird.size)
        bird.physicsBody?.categoryBitMask = PhysicsCategory.bird
        bird.physicsBody?.contactTestBitMask = PhysicsCategory.all
        // Bird cant fly off the screen
        bird.physicsBody?.collisionBitMask = PhysicsCategory.block | PhysicsCategory.edge
        // Bird wont just drop when the screen is loaded
        bird.physicsBody?.isDynamic = false
        bird.position = anchor.position
        addChild(bird)
        constrainToAnchor(active: true)
        roundState = .ready
    }
    
    override func didSimulatePhysics() {
        guard let physicsBody = bird.physicsBody else {return}
        if roundState == .flying && physicsBody.isResting {
            gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
            bird.removeFromParent()
            roundState = .finished
        }
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    /*
     Check if contact has occured between birds or blocks
     */
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch mask {
        case PhysicsCategory.bird | PhysicsCategory.block, PhysicsCategory.block | PhysicsCategory.edge:
            if let block = contact.bodyB.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
            else if let block = contact.bodyA.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
        case PhysicsCategory.block | PhysicsCategory.block:
            if let block = contact.bodyA.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
            if let block = contact.bodyB.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
        case PhysicsCategory.bird | PhysicsCategory.edge:
            bird.flying = false
        default:
            break
        }
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
                gameCamera.position = newPosition
                
                // Reset the scale so that if the user rescales it will be smooth
                sender.scale = 1.0
                gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
            }
        }
    }
    
}
