//
//  DrawCommand.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import Metal
import simd

struct DrawCommand {  
  let command: Command
  let geometry: Geometry?
  let transform: Transform  
  let renderType: RenderType?
  let storage: Storage
  
  var needsRender: Bool {
    geometry != nil && renderType != nil
  }
  
  func copy(_ command: Command? = nil, 
            geometry: Geometry? = nil, 
            transform: Transform? = nil,
            renderType: RenderType? = nil) -> DrawCommand {
    DrawCommand(command: command ?? self.command, 
                geometry: geometry ?? self.geometry, 
                transform: transform ?? self.transform, 
                renderType: renderType ?? self.renderType, 
                storage: storage)    
  }
}

// MARK: - Data

extension DrawCommand {
  enum Command {
    case draw
    case placeCamera
  }
  
  enum Geometry {
    case vertices([Float])
  }
  
  enum Transform {
    case model(float4x4)
    case camera(CameraProjectionSettings, float4x4) // projection, view
  }
  
  enum RenderType {
    case triangles(Int)
  }
}

// MARK: - Render

extension DrawCommand {
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
