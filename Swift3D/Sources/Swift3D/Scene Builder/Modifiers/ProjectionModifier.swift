//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 2/10/23.
//

import Foundation

public struct ProjectionModifier: NodeModifier {
  let value: CameraProjection

  public func printedTree(content: any Node) -> [String] {
    content.printedTree
  }

  public func drawCommands(content: any Node) -> [any MetalDrawable] {
    return content.drawCommands.map {
      if let cmd = $0 as? PlaceCamera {
        return cmd.withUpdated(projection: value)
      }
      return $0
    }
  }
}

// MARK: - Node Extension

extension CameraNode {
  public func perspective(fov: Float = 1.0472, zNear: Float = 0.1, zFar: Float = 100) -> ModifiedNodeContent<Self, ProjectionModifier> {
    self.modifier(ProjectionModifier(value: .perspective(.init(fov: fov, zNear: zNear, zFar: zFar))))
  }

  public func orthographic(viewSpace: CGRect, zNear: Float = 0.1, zFar: Float = 100) -> ModifiedNodeContent<Self, ProjectionModifier> {
    self.modifier(ProjectionModifier(value: .orthographic(.init(left: Float(viewSpace.minX),
                                                                right: Float(viewSpace.maxX),
                                                                top: Float(viewSpace.maxY),
                                                                bottom: Float(viewSpace.minY),
                                                                nearZ: zNear,
                                                                farZ: zFar))))
  }
}
