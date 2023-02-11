//
//  MetalScene3D.swift
//  
//
//  Created by Andrew Zimmer on 1/18/23.
//

import Foundation
import UIKit
import Metal

typealias CommandAndPrevious = (any MetalDrawable, (any MetalDrawable)?)

class MetalScene3D {
  private let device: MTLDevice
  private(set) var content: any Node = EmptyNode()
  private(set) var commands: [CommandAndPrevious] = []
  
  init(device: MTLDevice) {
    self.device = device
  }
  
  func setContent(_ content: any Node,
                  shaderLibrary: MetalShaderLibrary,
                  geometryLibrary: MetalGeometryLibrary,
                  surfaceAspect: Float) {
    print("Update content!!")
    self.content = content
    
    // Generate some draw commands    
    let nextCommands = content.drawCommands.map({ command in
      let prevCommands = commands.filter { $0.0.id == command.id }
      assert(prevCommands.count <= 1, "Ids must be unique. Please check your Ids.")
      let prevTuple = prevCommands.first
      let prevCommand = prevTuple?.0.presentedDrawCommand(time: CACurrentMediaTime(), previous: prevTuple?.1)
      
      command.storage
        .build(command,
               previous: prevCommand,
               device: device,
               shaderLibrary: shaderLibrary,
               geometryLibrary: geometryLibrary,
               surfaceAspect: surfaceAspect)
      
      return (command, prevCommand)
    })
    
    commands = nextCommands
  }
}
