//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import simd
import GLKit

// MARK: - simd_float3

extension simd_float3 {
  static var up: simd_float3 {
    simd_float3(x: 0, y: 1, z: 0)
  }
  static var down: simd_float3 {
    simd_float3(x: 0, y: -1, z: 0)
  }
  static var right: simd_float3 {
    simd_float3(x: 1, y: 0, z: 0)
  }
  static var left: simd_float3 {
    simd_float3(x: -1, y: 0, z: 0)
  }
  static var forward: simd_float3 {
    simd_float3(x: 0, y: 0, z: 1)
  }
  static var back: simd_float3 {
    simd_float3(x: 0, y: 0, z: -1)
  }
}

// MARK: - float4x4

extension float4x4 {
  static var length: Int {
    MemoryLayout<Float>.size * 16
  }
  
  static var identity: float4x4 {
    float4x4(1)
  }
  
  static func translated(_ trans: simd_float3) -> float4x4 {
    return unsafeBitCast(GLKMatrix4MakeTranslation(trans.x, trans.y, trans.z), to: float4x4.self)
  }
  
  static func rotated(angle: Float, axis: simd_float3) -> float4x4 {
    let quat = simd_quatf(angle: angle, axis: axis)
    return float4x4(quat)
  }
  
  static func scaled(_ scale: simd_float3) -> float4x4 {
    return unsafeBitCast(GLKMatrix4MakeScale(scale.x, scale.y, scale.z), to: float4x4.self)
  }
  
  static func TRS(trans: simd_float3, rot: simd_quatf, scale: simd_float3) -> float4x4 {
    return translated(trans) * simd_float4x4(rot) * scaled(scale)
  }

  static func makePerspective(fovyRadians: Float, _ aspect: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
    return unsafeBitCast(GLKMatrix4MakePerspective(fovyRadians, aspect, nearZ, farZ), to: float4x4.self)
  }

  static func makeFrustum(left: Float, _ right: Float, _ bottom: Float, _ top: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
    return unsafeBitCast(GLKMatrix4MakeFrustum(left, right, bottom, top, nearZ, farZ), to: float4x4.self)
  }

  static func makeOrtho(left: Float, _ right: Float, _ bottom: Float, _ top: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
    return unsafeBitCast(GLKMatrix4MakeOrtho(left, right, bottom, top, nearZ, farZ), to: float4x4.self)
  }

  static func makeLookAt(eyeX: Float, _ eyeY: Float, _ eyeZ: Float, _ centerX: Float, _ centerY: Float, _ centerZ: Float, _ upX: Float, _ upY: Float, _ upZ: Float) -> float4x4 {
    return unsafeBitCast(GLKMatrix4MakeLookAt(eyeX, eyeY, eyeZ, centerX, centerY, centerZ, upX, upY, upZ), to: float4x4.self)
  }

  // MARK: - Instance
  
  var scale: simd_float3 {
    let x = simd_length(simd_float3(x: self.columns.0.x, y: self.columns.0.y, z: self.columns.0.z))
    let y = simd_length(simd_float3(x: self.columns.1.x, y: self.columns.1.y, z: self.columns.1.z))
    let z = simd_length(simd_float3(x: self.columns.2.x, y: self.columns.2.y, z: self.columns.2.z))
    
    return 
      .init(x: x, y: y, z: z)
  }
  
  var rotation: simd_quatf {    
    return simd_quatf(self)
  }
  
  var translation: simd_float3 {
    return simd_float3(x: self.columns.3.x, 
                       y: self.columns.3.y, 
                       z: self.columns.3.z)
  }
}
