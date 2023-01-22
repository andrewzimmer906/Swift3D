//
//  DrawCommand.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import Metal
import simd

class DrawCommand {
  enum Geometry {
    case none
    case vertices([Float])
  }
  
  var geometry = Geometry.none
  var transform: simd_float4x4 = simd_float4x4(1)
  var needsRender: Bool {
    storage.needsRender
  }
  
  private var storage: Storage = Storage(pipelineState: nil, 
                                         vertexCount: 0, 
                                         buffer: nil)
}

// MARK: - Storage

extension DrawCommand {
  struct Storage {
    let pipelineState: MTLRenderPipelineState?
    let vertexCount: Int
    let buffer: MTLBuffer?
    
    var needsRender: Bool {
      pipelineState != nil && buffer != nil
    }
  }
  
  func createStorage(device: MTLDevice, library: MetalShaderLibrary) -> DrawCommand {
    var buffer: MTLBuffer? = nil
    var vertexCount = 0
    switch geometry {
    case .none:
      buffer = nil
    case .vertices(let vertices):
      let dataSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
      buffer = device.makeBuffer(bytes: vertices, length: dataSize, options: [])
      vertexCount = vertices.count
    }
    
    let pipeline = library.pipeline(for: "basic_vertex", fragment: "basic_fragment")
    self.storage = Storage(pipelineState: pipeline, vertexCount: vertexCount, buffer: buffer)
    return self
  }
}

// MARK: - Render

extension DrawCommand {
  func render(encoder: MTLRenderCommandEncoder) {
    if let ps = storage.pipelineState {
      encoder.setRenderPipelineState(ps)
    }
    
    if let vb = storage.buffer {
      encoder.setVertexBuffer(vb, offset: 0, index: 0)  
    }
    
    encoder.drawPrimitives(type: .triangle, 
                           vertexStart: 0, 
                           vertexCount: storage.vertexCount, 
                           instanceCount: storage.vertexCount / 3)
    encoder.endEncoding()
  }
}
