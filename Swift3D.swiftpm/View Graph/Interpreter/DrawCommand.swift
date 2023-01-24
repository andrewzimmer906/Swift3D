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
  
  let animations: [NodeTransition]?
  
  let storage: Storage
  
  var needsRender: Bool {
    geometry != nil && renderType != nil
  }
  
  func copy(geometry: Geometry? = nil, 
            transform: Transform? = nil,
            renderType: RenderType? = nil,
            animations: [NodeTransition]? = nil) -> DrawCommand {
    DrawCommand(command: self.command, 
                geometry: geometry ?? self.geometry, 
                transform: transform ?? self.transform, 
                renderType: renderType ?? self.renderType, 
                animations: animations ?? self.animations,
                storage: storage)
  }
}

// MARK: - Data

extension DrawCommand {
  enum Command: Equatable {
    case draw(String)
    case placeCamera(String)
    
    var isCamera: Bool {
      switch self {
      case .placeCamera:
        return true
      default:
        return false
      }
    }
    
    static func ==(lhs: Command, rhs: Command) -> Bool {
      switch(lhs, rhs) {
      case (.draw(let lhsId), .draw(let rhsId)):
        return lhsId == rhsId
      case (.placeCamera(let lhsId), .placeCamera(let rhsId)):
        return lhsId == rhsId  
      default:
        return false
      }
    }
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
  /// Updates the values in the command with any animations that are running.
  func update(time: CFTimeInterval) {
    if let dirtyTransform = updatedTransform(time: time) {
      storage.set(dirtyTransform)
    }
  }
  
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
