//
//  Triangle.swift
//  
//
//  Created by Andrew Zimmer on 1/18/23.
//

import Foundation

struct Triangle: Drawable3D {
  let id: String
  let vertices: [Float] = [0.0,  0.75, 0.0,
                           -0.75, -0.75, 0.0,
                           0.75, -0.75, 0.0]
}
