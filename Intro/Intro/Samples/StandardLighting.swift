//
//  StandardLighting.swift
//  Intro
//
//  Created by Andrew Zimmer on 2/10/23.
//

import Foundation
import Swift3D
import simd

struct StandardLighting: Node {
  let id: String

  var body: some Node {
    AmbientLightNode(id: "Ambient")
      .colored(color: .white.opacity(0.5))

    DirectionalLightNode(id: "Directional")
      .colored(color: .white.opacity(0.25))
      .transform(.lookAt(eye: .zero, look: simd_float3(x: 0, y: 0, z: 0.5), up: .up))
  }
}
