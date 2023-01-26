//
//  NodeRenderCommand.swift
//  
//
//  Created by Andrew Zimmer on 1/26/23.
//

import Foundation
import Metal

// MARK: - NodeRenderCommand

struct RenderGeometry: MetalDrawable {
  let id: String  
  let renderType: DrawCommand.RenderType?
  let animations: [NodeTransition]?
  let transform: DrawCommand.Transform
  let geometry: RawVertices?
  
  let storage: DrawCommand.Storage
}

// MARK: - Value Alterations

extension RenderGeometry {
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
          geometry: geometry, 
          storage: storage)
  }
}

// MARK: - Render

extension RenderGeometry {
  func render(encoder: MTLRenderCommandEncoder) {
    // Shaders
    if let ps = storage.pipelineState {
      encoder.setRenderPipelineState(ps)
    }
    
    // Vertices
    if let vb = storage.vertexBuffer {
      encoder.setVertexBuffer(vb, offset: 0, index: 0)
    }
    
    if let modelM = storage.modelMatBuffer {
      encoder.setVertexBuffer(modelM, offset: 0, index: 1)
    }
    
    // Draw
    switch renderType {
    case .none:
      break
    case .triangles(let instanceCount):
      encoder.drawPrimitives(type: .triangle, 
                             vertexStart: 0, 
                             vertexCount: instanceCount * 3, 
                             instanceCount: instanceCount)
    }
    
    encoder.endEncoding()
  }
}
