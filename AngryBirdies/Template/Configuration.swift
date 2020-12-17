//
//  Configuration.swift
//  AngryBirdies
//
//  Created by Brando Flores on 12/17/20.
//

import Foundation
import CoreGraphics

extension CGPoint {
    
    // Allow multiplication between CGPoint and CGFloat
    static public func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
    
    static public func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static public func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
}
