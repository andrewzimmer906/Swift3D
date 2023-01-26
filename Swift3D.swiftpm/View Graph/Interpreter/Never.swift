//
//  Never.swift
//  
//
//  Created by Andrew Zimmer on 1/26/23.
//

import Foundation
import Metal

extension Never: DrawCommand_Geometry {
  func createBuffer(device: MTLDevice) -> MTLBuffer? {
    fatalError()
  }
}
