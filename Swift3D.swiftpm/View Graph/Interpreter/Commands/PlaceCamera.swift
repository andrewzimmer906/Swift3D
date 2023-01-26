//
//  PlaceCamera.swift
//  
//
//  Created by Andrew Zimmer on 1/26/23.
//

import Foundation
import Metal

// MARK: - NodeRenderCommand

struct PlaceCamera: MetalDrawable {
  let id: String  
  let renderType: DrawCommand.RenderType?
  let animations: [NodeTransition]?
  let transform: DrawCommand.Transform
  let storage: DrawCommand.Storage
  var geometry: Never? { nil }
}

// MARK: - Value Alterations

extension PlaceCamera {
  func withUpdated(transform: DrawCommand.Transform) -> Self {
    withUpdated(id: nil, animations: nil, transform: transform)
  }
  
  func withUpdated(id: String) -> Self {
    withUpdated(id: id, animations: nil, transform: nil)
  }
  
  func withUpdated(animations: [NodeTransition]) -> Self {
    withUpdated(id: nil, animations: animations, transform: nil)
  }
  
  private func withUpdated(id: String?, 
                           animations: [NodeTransition]?,
                           transform: DrawCommand.Transform?) -> Self {
    .init(id: id ?? self.id, 
          renderType: renderType, 
          animations: animations ?? self.animations, 
          transform: transform ?? self.transform,  
          storage: storage)
  }
}

// MARK: - Render

extension PlaceCamera {
  func render(encoder: MTLRenderCommandEncoder) {
    fatalError()
  }
}
