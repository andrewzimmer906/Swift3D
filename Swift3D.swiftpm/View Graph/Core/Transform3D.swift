//
//  Scene.swift
//  
//
//  Created by Andrew Zimmer on 1/17/23.
//

import Foundation

protocol Transform3D: Equatable {
  var id: String { get }
  func build() -> Scene3D

  // associatedtype Body: Scene3D
  // var body: Self.Body { get }
}

extension Transform3D {
  public static func == (a: any Transform3D, b: any Transform3D) -> Bool {
    return a.id == b.id
  }
  
  func build() -> Scene3D {
    [(id, self)]
  }
}
