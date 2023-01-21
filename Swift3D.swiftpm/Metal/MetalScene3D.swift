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
  
  private var _commands: [DrawCommand] = []
  var commands: [DrawCommand] {
    _commands
  }
  
  init(device: MTLDevice) {
    self.device = device
  }
  
  func setContent(_ content: any Node, library: MetalShaderLibrary) {
    // Generate some draw commands    
    _commands = content.drawCommands.map({ command in
      command.createStorage(device: device, library: library)
    })
  }
}
