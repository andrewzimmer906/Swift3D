//
//  Never.swift
//  
//
//  Created by Andrew Zimmer on 1/26/23.
//

import Foundation
import Metal

extension Never: MetalDrawable_Geometry {
  var numPoints: Int {
    fatalError()
  }
  
  func createIndexBuffer(device: MTLDevice) -> MTLBuffer? {
    fatalError()
  }
  
  func createBuffer(device: MTLDevice) -> MTLBuffer? {
    fatalError()
  }
}

extension Never: MetalDrawable_Shader {
  func setupEncoder(encoder: MTLRenderCommandEncoder) {
    fatalError()
  }
  func build(device: MTLDevice, library: MetalShaderLibrary, previous: (any MetalDrawable_Shader)?) {
    fatalError()
  }
}
