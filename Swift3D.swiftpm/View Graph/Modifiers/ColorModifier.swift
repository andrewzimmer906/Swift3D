//
//  Color.swift
//  
//
//  Created by Andrew Zimmer on 1/30/23.
//

import Foundation
import simd
import SwiftUI

struct ColorModifier: NodeModifier {
  let color: Color
  
  func printedTree(content: any Node) -> [String] {
    content.printedTree
  }
  
  func drawCommands(content: any Node) -> [any MetalDrawable] {
    let simdColor = color.components   
    return content.drawCommands.map {
      if let light = $0 as? PlaceLight {
        return light.withUpdated(color: simdColor)
      }
      return $0
    }
  }
}

// MARK: - Node Extension

protocol AcceptsColored { }

extension Node where Self: AcceptsColored {
  func colored(color: Color) -> ModifiedNodeContent<Self, ColorModifier> {
    self.modifier(ColorModifier(color: color))
  }
}
