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
public enum MetalDrawableData {}

extension MetalDrawableData {
  public struct Transform {
    public let value: float4x4

    static func transform(_ value: float4x4) -> Transform {
      .init(value: value)
    }
    
    static var identity: Transform {
      .init(value: .identity)
    }
  }
}

// MARK: - Data Storage
public protocol MetalDrawable_Storage {
  func update(time: CFTimeInterval, command: (any MetalDrawable), previous: (any MetalDrawable_Storage)?)
  func build(_ command: (any MetalDrawable),
               previous: (any MetalDrawable_Storage)?,
               device: MTLDevice, 
               shaderLibrary: MetalShaderLibrary,
               geometryLibrary: MetalGeometryLibrary,
               surfaceAspect: Float)


  func set<Value>(_ value: Value)
  func copy(from previous: Self)
}

// MARK: - Metal Drawable

public protocol MetalDrawable {
  associatedtype Storage: MetalDrawable_Storage
  
  var id: String { get }
  var transform: MetalDrawableData.Transform { get }
  var animations: [NodeTransition]? { get }
  
  var storage: Storage { get }
  var needsRender: Bool { get }

  func withUpdated(id: String) -> Self
  func withUpdated(transform: MetalDrawableData.Transform) -> Self
  func withUpdated(animations: [NodeTransition]) -> Self

  func render(encoder: MTLRenderCommandEncoder, depthStencil: MTLDepthStencilState?)
}

extension MetalDrawable {
  /// Updates the values in the command with any animations that are running.  
  func update(time: CFTimeInterval, previous: (any MetalDrawable)?) {    
    if let dirtyTransform = attribute(at: time, cur: self.transform, prev: previous?.transform) {
      storage.set(dirtyTransform)
    }
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

extension Array where Element == NodeTransition {
  func with(_ attributes: [NodeTransition.Attribute]) -> NodeTransition? {
    self.first(where: { attributes.contains($0.attribute) })
  }
}

extension MetalDrawable_Storage {
  func attribute<T: Lerpable>(at time: CFTimeInterval,
                         cur: T,
                         prev: T?,
                         animation: NodeTransition?) -> T {
    guard let animation = animation,
          let prev = prev else {
      return cur
    }

    let percent = animation.interpolate(time: time)
    return T.lerp(prev, cur, percent)
  }
}
