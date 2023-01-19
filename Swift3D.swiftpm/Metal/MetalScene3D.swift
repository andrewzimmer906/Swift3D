//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/18/23.
//

import Foundation
import Metal

class MetalScene3D {
  private let device: MTLDevice
  
  private var _commands: [any DrawCommand] = []
  var commands: [any DrawCommand] {
    _commands
  }
  
  init(device: MTLDevice) {
    self.device = device
  }
  
  func setContent(_ content: Scene3D, library: MetalShaderLibrary) {
    // Generate some draw commands
    _commands = []
    
    content.forEach { (id, transform3D) in
      if let drawable = transform3D as? any Drawable3D {
        
        // TODO: Custom Pipelines
        let pipeline = library.pipeline(for: "basic_vertex", fragment: "basic_fragment")
        let buffer = self.buffer(for: drawable.vertices)  
        let cmd = drawable.drawCommand(pipelineState: pipeline, vertexBuffer: buffer)
        _commands.append(cmd)
      }
    }
  }
  
  private func buffer(for vertices: [Float]) -> MTLBuffer {
    let dataSize = vertices.count * MemoryLayout.size(ofValue: vertices[0])
    guard let buffer = device.makeBuffer(bytes: vertices, length: dataSize, options: []) else {
      fatalError()
    } 
    return buffer
  }
}
