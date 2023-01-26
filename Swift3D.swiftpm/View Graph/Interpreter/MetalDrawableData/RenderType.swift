//
//  DrawCommand_RenderType.swift
//  
//
//  Created by Andrew Zimmer on 1/24/23.
//

import Foundation

extension MetalDrawableData {
  enum RenderType {
    case triangles(Int)
  }
}

extension MetalDrawableData.RenderType: Equatable {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.triangles(let a), .triangles(let b)):
      return a == b
    }
  }
}
