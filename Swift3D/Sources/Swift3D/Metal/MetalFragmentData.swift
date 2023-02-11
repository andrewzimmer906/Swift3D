//
//  MetalFragmentData.swift
//  
//
//  Created by Andrew Zimmer on 2/10/23.
//

import Foundation
import simd

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
