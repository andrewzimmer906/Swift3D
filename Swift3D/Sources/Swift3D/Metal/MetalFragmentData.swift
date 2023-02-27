//
//  MetalFragmentData.swift
//  
//
//  Created by Andrew Zimmer on 2/10/23.
//

import Foundation
import simd

enum FragmentTextureIndex: Int {
  case baseColor
  case normal
  case emission
  case metalness
  case roughness
  case occlusion
}

enum FragmentBufferIndex: Int {
  case uniform
  case material
  case lights
}

// Designed to match 16 byte memory lineup!
// So I don't need a descriptor.. >:)
struct StandardFragmentUniform {
  let camPos: simd_float4
  let lightCount: simd_float4
}

struct MaterialSettings {
  let lightingSettings: simd_float4
  let albedoTextureScaling: simd_float4;
}

struct Light {
  let position: simd_float4
  let color: simd_float4
}

extension Light: Lerpable {
  // Don't uh.. lerp between two different TYPES of lights please.. :)  It's
  // stored in position.w and may act strangely..
  static func lerp(_ from: Light, _ to: Light, _ percent: Float) -> Light {
    Light(position: simd_float4.lerp(from.position, to.position, percent),
          color: simd_float4.lerp(from.color, to.color, percent))
  }
}
