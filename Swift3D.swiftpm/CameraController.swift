//
//  CameraControlelr.swift
//  Swift3D
//
//  Created by Andrew Zimmer on 2/2/23.
//

import Foundation

struct CameraController: Node {
  var id: String { "Camera Controller" }

  private var body: any Node {
    GroupNode(id: id) {
      CubeNode(id: "ehy you")
    }
  }

  var drawCommands: [any MetalDrawable] {
    self.body.drawCommands
  }
}
