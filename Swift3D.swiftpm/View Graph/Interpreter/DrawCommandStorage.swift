//
//  DrawCommandStorage.swift
//  
//
//  Created by Andrew Zimmer on 1/22/23.
//

import Foundation
import UIKit
import Metal
import simd

extension DrawCommand {  
  class Storage {
    // Storing two levels back of draw commands allows us to
    // do a little additional optimization and handle animations.
    private(set) var previousDrawCommand: DrawCommand?
    private(set) var surfaceAspect: Float?
    
    private(set) var device: MTLDevice?
    private(set) var pipelineState: MTLRenderPipelineState?
    
    private(set) var vertexBuffer: MTLBuffer?
    private(set) var modelMatBuffer: MTLBuffer?
    private(set) var viewProjBuffer: MTLBuffer?
  }
  
  func createStorage(device: MTLDevice, 
                     library: MetalShaderLibrary, 
                     previousDrawCommand: DrawCommand?,
                     surfaceAspect: Float) -> DrawCommand {
    storage.build(self, 
                  previousDrawCommand: previousDrawCommand?.presentedDrawCommand(time: CACurrentMediaTime()), 
                  device: device, 
                  library: library,
                  surfaceAspect: surfaceAspect)
    
    return self
  }
}

// MARK: - Build

extension DrawCommand.Storage {
  func build(_ command: DrawCommand, 
             previousDrawCommand: DrawCommand?,
             device: MTLDevice, 
             library: MetalShaderLibrary, 
             surfaceAspect: Float) {
    
    self.device = device
    self.surfaceAspect = surfaceAspect
    self.previousDrawCommand = previousDrawCommand    
    
    // Geometry
    if let geometry = command.geometry {
      make(geometry, 
           previousGeometry: previousDrawCommand?.geometry, 
           previousStorage: previousDrawCommand?.storage)
      set(geometry)  // does nothing, we have to set in build.
    }
    
    // Transform
    make(command.transform, 
         previousTransform: previousDrawCommand?.transform, 
         previousStorage: previousDrawCommand?.storage)
    set(command.presentedTransform(time: CACurrentMediaTime()) ?? command.transform)
    
    // TODO: Real shader selection!
    self.pipelineState = library.pipeline(for: "basic_vertex", fragment: "basic_fragment")
    
    // Clear out old data and release MTLBuffers that are no longer in use.
    self.previousDrawCommand?.storage.clear()
  }
  
  func clear() {
    // Clear the command from 2 back so we don't have a large stack of structs
    // after a while.
    self.previousDrawCommand?.storage.previousDrawCommand = nil
    
    self.device = nil
    self.vertexBuffer = nil
    self.viewProjBuffer = nil
    self.modelMatBuffer = nil
  }
}

// MARK: - Create Buffers
/// Updates and creates GPU Buffers where needed.
/// Also attempts to reuse GPU buffers from previous draw commands where possible.
extension DrawCommand.Storage {
  private func make(_ transform: DrawCommand.Transform,
                      previousTransform: DrawCommand.Transform?,
                      previousStorage: DrawCommand.Storage?) {
    guard let device = device else {
      fatalError()
    }
    
    let usePrevious = (transform == previousTransform)    
    switch transform {
    case .model(_):
      if usePrevious {
        self.modelMatBuffer = previousStorage?.modelMatBuffer
      }
      else {
        self.modelMatBuffer = device.makeBuffer(length: float4x4.length)  
      }     
      
    case .camera(_, _):
      if usePrevious {
        self.viewProjBuffer = previousStorage?.viewProjBuffer
      } else {
        self.viewProjBuffer = device.makeBuffer(length: MemoryLayout<ViewProjectionUniform>.size)  
      }
    }
  }

  private func make<A, B>(_ geometry: A,
                      previousGeometry: B?,
                          previousStorage: DrawCommand.Storage?) where A: DrawCommand_Geometry, B: DrawCommand_Geometry {    
    guard let device = device else {
      fatalError()
    }
    
    if let previousGeometry = previousGeometry as? A {
      let usePrevious = (geometry == previousGeometry)
      
      if usePrevious {
        self.vertexBuffer = previousStorage?.vertexBuffer
        return 
      }
    }
    
    self.vertexBuffer = geometry.createBuffer(device: device)
  }
}
