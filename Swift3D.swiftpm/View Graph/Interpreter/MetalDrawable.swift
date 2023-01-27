//
//  DrawCommand.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import UIKit
import Metal
import simd

// Used for data namespacing.
enum MetalDrawableData {}
struct DrawCommand {}

// MARK: - Data Sources / Storage
protocol MetalDrawable_Storage {
  func build(_ command: (any MetalDrawable),
               previous: (any MetalDrawable)?,
               device: MTLDevice, 
               library: MetalShaderLibrary, 
               surfaceAspect: Float)
  
  func set<Value>(_ value: Value)
}

// MARK: - Metal Drawable

protocol MetalDrawable {
  associatedtype Storage: MetalDrawable_Storage
  
  var id: String { get }
  var transform: float4x4 { get }
  var animations: [NodeTransition]? { get }
  
  var storage: Storage { get }
  var needsRender: Bool { get }

  func withUpdated(id: String) -> Self
  func withUpdated(transform: float4x4) -> Self  
  func withUpdated(animations: [NodeTransition]) -> Self
  
  func update(time: CFTimeInterval, previous: (any MetalDrawable)?)
  func render(encoder: MTLRenderCommandEncoder, depthStencil: MTLDepthStencilState?)
  func presentedDrawCommand(time: CFTimeInterval, previous: (any MetalDrawable)?) -> any MetalDrawable
}

extension MetalDrawable {
  /// Updates the values in the command with any animations that are running.  
  func update(time: CFTimeInterval, previous: (any MetalDrawable)?) {    
    if let dirtyTransform = attribute(at: time, cur: self.transform, prev: previous?.transform) {
      storage.set(dirtyTransform)
    }
  }
  
  /// State of command at a given time with any transitions applied, should be used to keep transitions accurate during redraws
  func presentedDrawCommand(time: CFTimeInterval, previous: (any MetalDrawable)?) -> any MetalDrawable {    
    var toReturn = self
    if let dirtyTransform = attribute(at: time, cur: self.transform, prev: previous?.transform) {
      toReturn = self.withUpdated(transform: dirtyTransform)
    }    
    return toReturn
  }
}

// MARK: - Animated Attributes
extension MetalDrawable {
  func attribute<T: Lerpable>(at time: CFTimeInterval,
                         cur: T, 
                         prev: T?, 
                         attributes: [NodeTransition.Attribute] = [.all]) -> T? {    
    guard let animation = animations?.first(where: { attributes.contains($0.attribute) }),
          let prev = prev else {            
      return nil
    }
    
    let percent = animation.interpolate(time: time)
    return T.lerp(prev, cur, percent)
  }
}
