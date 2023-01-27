//
//  ShaderPipeline.swift
//  
//
//  Created by Andrew Zimmer on 1/27/23.
//

import Foundation

extension MetalDrawableData {
  enum ShaderPipeline {
    case standard(String, String)
  }
}

extension MetalDrawableData.ShaderPipeline: Equatable {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.standard(let vA, let fA), .standard(let vB, let fB)):
      return vA == vB && fA == fB
    }
  }
}
