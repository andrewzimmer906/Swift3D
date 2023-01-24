//
//  DrawCommand_Geometry.swift
//  
//
//  Created by Andrew Zimmer on 1/24/23.
//

import Foundation

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
}

// MARK: - Storage

extension DrawCommand.Storage {
  func set(_ geometry: DrawCommand.Geometry) {
    /*
    switch geometry {
    case .vertices(let vertices):
      //self.vertexBuffer?.contents().storeBytes(of: vertices, as: [Float].self)
     // Throws fatalError so we set in storage.build instead.
    }
     */
  }
}


