//
//  GameCamera.swift
//  AngryBirdies
//
//  Created by Brando Flores on 12/17/20.
//

import SpriteKit

class GameCamera: SKCameraNode {

    func setConstraints(with scene: SKScene, and frame: CGRect, to node: SKNode?) {
        let scaledSize = CGSize(width: scene.size.width * xScale, height: scene.size.height * yScale)
        let boardContentRect = frame
        
        // Compare scaled width and complete frames width and use the smaller
        // of the two values
        let xInset = min(scaledSize.width / 2, boardContentRect.width / 2)
        let yInset = min(scaledSize.height / 2, boardContentRect.height / 2)
        
        // Complete a new rectangle that allows our camera to move
        // Prevent the camera from leaving the rectangle and prevent the player
        // from seeing outside the scene
        let insetContentRect = boardContentRect.insetBy(dx: xInset, dy: yInset)
        
        let xRange = SKRange(lowerLimit: insetContentRect.minX, upperLimit: insetContentRect.maxX)
        let yRange = SKRange(lowerLimit: insetContentRect.minY, upperLimit: insetContentRect.maxY)
        
        let levelEdgeContraint = SKConstraint.positionX(xRange, y: yRange)
        
        // The camera will follow the bird
        if let passedNode = node {
            let zeroRange = SKRange(constantValue: 0.0)
            let positionConstraint = SKConstraint.distance(zeroRange, to: passedNode)
            constraints = [positionConstraint , levelEdgeContraint]
        }
        else {
            constraints = [levelEdgeContraint]
        }

    }
    
}
