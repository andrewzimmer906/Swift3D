//
//  Color.swift
//  
//
//  Created by Andrew Zimmer on 1/30/23.
//

import Foundation
import simd
import SwiftUI

public struct ColorModifier: NodeModifier {
  let color: Color
  let intensity: Float
  
  public func printedTree(content: any Node) -> [String] {
    content.printedTree
  }
  
  public func drawCommands(content: any Node) -> [any MetalDrawable] {
    let simdColor = color.components   
    return content.drawCommands.map {
      if let light = $0 as? PlaceLight {
        return light.withUpdated(color: simd_float4(simdColor.xyz, intensity))
      }
      return $0
    }
  }
}

// MARK: - Node Extension

public protocol AcceptsColored { }

extension Node where Self: AcceptsColored {
  public func colored(color: Color, intensity: Float = 1) -> ModifiedNodeContent<Self, ColorModifier> {
    self.modifier(ColorModifier(color: color, intensity: intensity))
  }
}
