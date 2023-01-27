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
