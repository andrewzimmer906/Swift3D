//
//  CGPoint.swift
//  
//
//  Created by Andrew Zimmer on 2/3/23.
//

import Foundation

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}
