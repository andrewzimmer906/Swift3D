//
//  DrawCommand_Geometry.swift
//  
//
//  Created by Andrew Zimmer on 1/24/23.
//

import Foundation
import Metal

protocol DrawCommand_Geometry: Equatable {
  func createBuffer(device: MTLDevice) -> MTLBuffer? 
}

// MARK: - Raw Floats

// MARK: - Raw Floats

struct RawVertices: DrawCommand_Geometry {
  let vertices: [Float]
  
  func createBuffer(device: MTLDevice) -> MTLBuffer? {
    let dataSize = vertices.count * MemoryLayout<Float>.size
    return device.makeBuffer(bytes: vertices, length: dataSize)
  }
  
  static func == (lhs: Self, rhs: any DrawCommand_Geometry) -> Bool {
    if let rhs = rhs as? RawVertices {
      return lhs.vertices.count == rhs.vertices.count 
    }
    
    return false
  }
}




/*
extension DrawCommand {
  enum Geometry {
    case vertices([Float])
  }
}

extension DrawCommand.Geometry: Equatable {
  static func ==(lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.vertices(let a), .vertices(let b)):
      return a.count == b.count
    }
  }
}*/

// MARK: - Storage

extension DrawCommand.Storage {
  
  /*func set(_ geometry: any DrawCommand.Geometry) {
    /*
    switch geometry {
    case .vertices(let vertices):
      //self.vertexBuffer?.contents().storeBytes(of: vertices, as: [Float].self)
     // Throws fatalError so we set in storage.build instead.
    }
     */
  }*/
}


