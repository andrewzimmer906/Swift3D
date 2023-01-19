//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/17/23.
//

import Foundation

struct Transform3DGroup: Transform3D {
  private let _id: String?
  var id: String {
    _id ?? ""
  }
  let drawables: [any Transform3D]

  init(id anId: String? = nil, @SceneBuilder3D content: () -> [any Transform3D]) {
    _id = anId
    drawables = content()
  }

  func build() -> Scene3D {
    drawables.flatMap { scene in
      scene.build().map { child in
        if let id = _id {
          return ("\(id).\(child.0)", child.1)
        }
        return ("\(child.0)", child.1)
      }
    }
  }

  static func == (lhs: Transform3DGroup, rhs: Transform3DGroup) -> Bool {
    return true
  }
}
