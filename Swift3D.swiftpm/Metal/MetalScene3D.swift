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
  private(set) var commands: [any MetalDrawable] = []
  
  init(device: MTLDevice) {
    self.device = device
  }
  
  func setContent(_ content: any Node, library: MetalShaderLibrary, surfaceAspect: Float) {
    self.content = content
    
    // Generate some draw commands    
    let nextCommands = content.drawCommands.map({ command in
      let prevCommands = commands.filter { $0.id == command.id }
      assert(prevCommands.count <= 1, "Ids must be unique. Please check your Ids.")
      let prevCommand = prevCommands.first
            
      return command.createStorage(device: device, 
                                   library: library, 
                                   previousDrawCommand: prevCommand,
                                   surfaceAspect: surfaceAspect)
    })
    
    commands = nextCommands
  }
}
