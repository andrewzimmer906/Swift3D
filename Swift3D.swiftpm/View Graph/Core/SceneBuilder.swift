//
//  SceneBuilder3D.swift
//  
//
//  Created by Andrew Zimmer on 1/17/23.
//

import Foundation

// MARK: - Global Test Builder
func makeScene(@SceneBuilder3D _ content: () -> [any Transform3D]) -> Scene3D {
  content().build()
}

// MARK: - Array Builder

typealias Scene3DElement = (String, any Transform3D)
typealias Scene3D = [Scene3DElement]

extension Array where Element == any Transform3D {
  func build() -> Scene3D {
    self.flatMap { $0.build() }
  }
}

// MARK: - Main Builder

@resultBuilder
struct SceneBuilder3D {
  static func buildBlock() -> [any Transform3D] { [] }
}

extension SceneBuilder3D {
  static func buildBlock(_ scenes: any Transform3D...) -> [any Transform3D] {
    scenes
  }
  
  static func buildBlock(_ scenes: [any Transform3D]) -> [any Transform3D] {
    scenes
  }
}

// MARK: - Control Flow Builder

extension SceneBuilder3D {  
  static func buildOptional(_ value: [any Transform3D]?) -> any Transform3D {
    if let v = value {
      return Transform3DGroup(content: { v })
    }
                           
    return Empty()
  }
  
  static func buildEither(first: [any Transform3D]) -> any Transform3D {
    return Transform3DGroup(content: { first })
  }
  
  static func buildEither(second: [any Transform3D]) -> any Transform3D  {
    return Transform3DGroup(content: { second })
  }
}
