//
//  simd+Animation.swift
//  
//
//  Created by Andrew Zimmer on 1/23/23.
//

import Foundation
import simd

protocol Lerpable {
  static func lerp(_ from: Self, _ to: Self, _ percent: Float) -> Self
}

extension Float: Lerpable {
  var saturated: Float {
    max(0, min(1, self))
  }
  
  static func lerp(_ from: Float, _ to: Float, _ percent: Float) -> Float {
    return from + (to - from) * percent
  }
}

extension float4x4: Lerpable  {  
  static func lerp(_ from: Self, _ to: Self, _ percent: Float) -> Self {
    let fromT = from.translation
    let fromR = from.rotation
    let fromS = from.scale
    
    let toT = to.translation
    let toR = to.rotation
    let toS = to.scale

    let T = simd_float3.lerp(fromT, toT, percent)
    let R = simd_slerp(fromR, toR, percent)
    let S = simd_float3.lerp(fromS, toS, percent)
    
    return float4x4.TRS(trans: T, rot: R, scale: S)    
  }

  static func straightLerp(_ from: Self, _ to: Self, _ percent: Float) -> Self {
    var mat = float4x4()

    mat[0] = SIMD4<Float>.lerp(from[0], to[0], percent)
    mat[1] = SIMD4<Float>.lerp(from[1], to[1], percent)
    mat[2] = SIMD4<Float>.lerp(from[2], to[2], percent)
    mat[3] = SIMD4<Float>.lerp(from[3], to[3], percent)

    return mat
  }
}

extension simd_float3: Lerpable  {
  static func lerp(_ from: Self, _ to: Self, _ percent: Float) -> Self {    
    return from + (to - from) * percent
  }
}

extension SIMD4<Float>: Lerpable  {
  static func lerp(_ from: Self, _ to: Self, _ percent: Float) -> Self {
    return from + (to - from) * percent
  }
}
