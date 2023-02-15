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
