//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 2/10/23.
//

import Foundation

public struct ProjectionModifier: NodeModifier {
  let projectionValues: CameraProjectionSettings

  public func printedTree(content: any Node) -> [String] {
    content.printedTree
  }

  public func drawCommands(content: any Node) -> [any MetalDrawable] {
    return content.drawCommands.map {
      if let cmd = $0 as? PlaceCamera {
        return cmd.withUpdated(cameraProjectionSettings: projectionValues)
      }
      return $0
    }
  }
}

// MARK: - Node Extension

extension CameraNode {
  public func projection(fov: Float = 1.0472, zNear: Float = 0.1, zFar: Float = 100) -> ModifiedNodeContent<Self, ProjectionModifier> {
    self.modifier(ProjectionModifier(projectionValues: .init(isOrtho: false, fov: fov, zNear: zNear, zFar: zFar)))
  }

  public func orthographic(zNear: Float = 0.1, zFar: Float = 100) -> ModifiedNodeContent<Self, ProjectionModifier> {
    self.modifier(ProjectionModifier(projectionValues: .init(isOrtho: true, fov: 0, zNear: zNear, zFar: zFar)))
  }

  public func testProjection(isOrtho: Bool) -> ModifiedNodeContent<Self, ProjectionModifier> {
    if isOrtho {
      return self.modifier(ProjectionModifier(projectionValues: .init(isOrtho: true, fov: 0, zNear: -0.1, zFar: 100)))
    } else {
      return self.modifier(ProjectionModifier(projectionValues: .init(isOrtho: false, fov: 1.0472, zNear: 0.1, zFar: 100)))
    }
  }
}
