
//
//
//  CGVectorArithmetics.swift
//
//  Created by fewlinesofcode.com on 2/6/19.
//  Copyright © 2019 fewlinesofcode.com All rights reserved.
//

import Foundation
import CoreGraphics

extension CGVector: AdditiveArithmetic {
    // Vector addition
    public static func + (left: CGVector, right: CGVector) -> CGVector {
        return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
    }
    
    // Vector subtraction
    public static func - (left: CGVector, right: CGVector) -> CGVector {
        return left + (-right)
    }
    
    // Vector addition assignment
    public static func += (left: inout CGVector, right: CGVector) {
        left = left + right
    }
    
    // Vector subtraction assignment
    public static func -= (left: inout CGVector, right: CGVector) {
        left = left - right
    }
    
    // Vector negation
    public static prefix func - (vector: CGVector) -> CGVector {
        return CGVector(dx: -vector.dx, dy: -vector.dy)
    }
}

infix operator * : MultiplicationPrecedence
infix operator / : MultiplicationPrecedence
infix operator • : MultiplicationPrecedence

extension CGVector {
    // Scalar-vector multiplication
    public static func * (left: CGFloat, right: CGVector) -> CGVector {
        return CGVector(dx: right.dx * left, dy: right.dy * left)
    }
    
    public static func * (left: CGVector, right: CGFloat) -> CGVector {
        return CGVector(dx: left.dx * right, dy: left.dy * right)
    }
    
    // Vector-scalar division
    public static func / (left: CGVector, right: CGFloat) -> CGVector {
        guard right != 0 else { fatalError("Division by zero") }
        return CGVector(dx: left.dx / right, dy: left.dy / right)
    }
    
    // Vector-scalar division assignment
    public static func /= (left: inout CGVector, right: CGFloat) -> CGVector {
        guard right != 0 else { fatalError("Division by zero") }
        return CGVector(dx: left.dx / right, dy: left.dy / right)
    }
    
    // Scalar-vector multiplication assignment
    public static func *= (left: inout CGVector, right: CGFloat) {
        left = left * right
    }
}

extension CGVector {
    // Vector magnitude (length)
    public var magnitude: CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    // Distance between two vectors
    public func distance(to vector: CGVector) -> CGFloat {
        return (self - vector).magnitude
    }
    
    // Vector normalization
    public var normalized: CGVector {
        return CGVector(dx: dx / magnitude, dy: dy / magnitude)
    }
    
    // Dot product of two vectors
    public static func • (left: CGVector, right: CGVector) -> CGFloat {
        return left.dx * right.dx + left.dy * right.dy
    }
    
    // Angle between two vectors
    // θ = acos(AB)
    public func angle(to vector: CGVector) -> CGFloat {
        return acos(self.normalized • vector.normalized)
    }
}

extension CGPoint {
    var cgVector: CGVector {
        return CGVector(dx: self.x, dy: self.y)
    }
}
