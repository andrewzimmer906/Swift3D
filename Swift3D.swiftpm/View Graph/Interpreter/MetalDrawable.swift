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

// MARK: - Metal Drawable

protocol MetalDrawable {
  associatedtype Geometry: DrawCommand_Geometry

  var id: String { get }
  var transform: DrawCommand.Transform { get }
  var geometry: Geometry? { get }  
  var renderType: DrawCommand.RenderType? { get }  
  var animations: [NodeTransition]? { get }
  
  var storage: DrawCommand.Storage { get }  
  var needsRender: Bool { get }

  func withUpdated(id: String) -> Self
  func withUpdated(transform: DrawCommand.Transform) -> Self  
  func withUpdated(animations: [NodeTransition]) -> Self
  
  func update(time: CFTimeInterval)
  func render(encoder: MTLRenderCommandEncoder)
  func presentedDrawCommand(time: CFTimeInterval) -> any MetalDrawable

  func createStorage(device: MTLDevice, 
                     library: MetalShaderLibrary, 
                     previousDrawCommand: (any MetalDrawable)?,
                     surfaceAspect: Float) -> Self
}

extension MetalDrawable {
  /// Updates the values in the command with any animations that are running.  
  func update(time: CFTimeInterval) {    
    if let dirtyTransform = presentedTransform(time: time) {
      storage.set(dirtyTransform)
    }
  }
  
  /// Does this command need a render encoder?
  var needsRender: Bool {
    renderType != nil && geometry != nil
  }
  
  /// State of command at a given time with any transitions applied.
  func presentedDrawCommand(time: CFTimeInterval) -> any MetalDrawable {
    return self.withUpdated(transform: presentedTransform(time: time) ?? transform)
  }
  
  /// Creates the GPU storage for the commands data in preperation for rendering.
  /// NOTE: This may require some memory so should only be called as needed, not before every pass.
  func createStorage(device: MTLDevice, 
                     library: MetalShaderLibrary, 
                     previousDrawCommand: (any MetalDrawable)?,
                         surfaceAspect: Float) -> Self {
    self.storage.build(self, 
                       previousDrawCommand: previousDrawCommand?.presentedDrawCommand(time: CACurrentMediaTime()), 
                       device: device, 
                       library: library, 
                       surfaceAspect: surfaceAspect)
    
    return self
  }
}
