//
//  MetalScene3D.swift
//  
//
//  Created by Andrew Zimmer on 1/18/23.
//

import Foundation
import Metal

class MetalScene3D {
  private let device: MTLDevice
  private(set) var content: any Node = EmptyNode()
  private(set) var commands: [DrawCommand] = []
  
  init(device: MTLDevice) {
    self.device = device
  }
  
  func setContent(_ content: any Node, library: MetalShaderLibrary, surfaceAspect: Float) {
    self.content = content
    
    // Generate some draw commands    
    commands = content.drawCommands.map({ command in
      command.createStorage(device: device, 
                            library: library, 
                            surfaceAspect: surfaceAspect)
    })
  }
}
