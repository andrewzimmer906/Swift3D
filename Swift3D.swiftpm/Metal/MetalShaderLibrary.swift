//
//  MetalShaderLibrary.swift
//  
//
//  Created by Andrew Zimmer on 1/18/23.
//

import Foundation
import Metal
import simd

// Library Uniform Requirements
struct ViewProjectionUniform {
  let projectionMatrix: float4x4
  let viewMatrix: float4x4
}

class MetalShaderLibrary {
  // TODO: Limit the size of this fella.
  private var pipelines: [String: MTLRenderPipelineState] = [:]
  
  let device: MTLDevice
  let library: MTLLibrary
  
  init(device: MTLDevice) {
    guard let lib = device.makeDefaultLibrary() else {
      fatalError()
    } 
    
    self.device = device
    self.library = lib 
  }
  
  func pipeline(for vertex: String, fragment: String) -> MTLRenderPipelineState {
    let key = vertex + "." + fragment
    if let pipe = pipelines[key] {
      return pipe
    }
    
    let vertexProgram = library.makeFunction(name: vertex)
    let fragmentProgram = library.makeFunction(name: fragment)

    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    do {
      let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
      pipelines[key] = pipelineState
      return pipelineState
    } catch {
      fatalError()
    }
  }
}
