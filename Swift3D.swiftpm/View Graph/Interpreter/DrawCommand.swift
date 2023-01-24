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
  
  func copy(command: Command? = nil,
            geometry: Geometry? = nil, 
            transform: Transform? = nil,
            renderType: RenderType? = nil,
            animations: [NodeTransition]? = nil) -> DrawCommand {
    DrawCommand(command: command ?? self.command, 
                geometry: geometry ?? self.geometry, 
                transform: transform ?? self.transform, 
                renderType: renderType ?? self.renderType, 
                animations: animations ?? self.animations,
                storage: storage)
  }
  
  func append(id: String) -> DrawCommand {
    var updatedCommand = command
    switch command {
    case .draw(let curId):
      updatedCommand = .draw("\(id).\(curId)")
    case .placeCamera(let curId):
      updatedCommand = .placeCamera("\(id).\(curId)")
    }
    
    return self.copy(command: updatedCommand)
  }
}

// MARK: - Update / Render

extension DrawCommand {
  /// Updates the values in the command with any animations that are running.
  func update(time: CFTimeInterval) {
    if let dirtyTransform = presentedTransform(time: time) {
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

// MARK: - Transitions
extension DrawCommand {
  /// Updates the draw command to have the correct values for its current time with transitions in mind.
  func presentedDrawCommand(time: CFTimeInterval) -> DrawCommand {
    return self.copy(transform: presentedTransform(time: time))
  }
}
