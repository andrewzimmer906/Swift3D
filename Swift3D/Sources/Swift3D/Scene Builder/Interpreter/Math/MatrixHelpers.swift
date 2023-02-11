//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import simd
import GLKit

extension simd_quatf {
  public static var identity: Self {
    simd_quatf(ix: 0, iy: 0, iz: 0, r: 1)
  }
}

// MARK: - simd_float3

extension simd_packed_float4 {
  public static var up: simd_packed_float4 {
    .init(x: 0, y: 1, z: 0, w: 0)
  }
  public static var down: simd_packed_float4 {
    .init(x: 0, y: -1, z: 0, w: 0)
  }
  public static var right: simd_packed_float4 {
    .init(x: 1, y: 0, z: 0, w: 0)
  }
  public static var left: simd_packed_float4 {
    .init(x: -1, y: 0, z: 0, w: 0)
  }
  public static var forward: simd_packed_float4 {
    .init(x: 0, y: 0, z: -1, w: 0)
  }
  public static var back: simd_packed_float4 {
    .init(x: 0, y: 0, z: 1, w: 0)
  }
}

extension simd_float3 {
  public static var up: simd_float3 {
    simd_float3(x: 0, y: 1, z: 0)
  }
  public static var down: simd_float3 {
    simd_float3(x: 0, y: -1, z: 0)
  }
  public static var right: simd_float3 {
    simd_float3(x: 1, y: 0, z: 0)
  }
  public static var left: simd_float3 {
    simd_float3(x: -1, y: 0, z: 0)
  }
  public static var forward: simd_float3 {
    simd_float3(x: 0, y: 0, z: -1)
  }
  public static var back: simd_float3 {
    simd_float3(x: 0, y: 0, z: 1)
  }
}

// MARK: - float4x4

extension float4x4 {
  public static var length: Int {
    MemoryLayout<Float>.size * 16
  }
  
  public static var identity: float4x4 {
    float4x4(1)
  }
  
  public static func translated(_ trans: simd_float3) -> float4x4 {
    return unsafeBitCast(GLKMatrix4MakeTranslation(trans.x, trans.y, trans.z), to: float4x4.self)
  }
  
  public static func rotated(angle: Float, axis: simd_float3) -> float4x4 {
    let quat = simd_quatf(angle: angle, axis: axis)
    return float4x4(quat)
  }
  
  public static func scaled(_ scale: simd_float3) -> float4x4 {
    return unsafeBitCast(GLKMatrix4MakeScale(scale.x, scale.y, scale.z), to: float4x4.self)
  }
  
  public static func TRS(trans: simd_float3, rot: simd_quatf, scale: simd_float3) -> float4x4 {
    return translated(trans) * simd_float4x4(rot) * scaled(scale)
  }
  
  public static func lookAt(eye: simd_float3, look: simd_float3, up: simd_float3) -> float4x4 {
    let vLook = normalize(look)
    let vSide = cross(vLook, normalize(up))
    let vUp = cross(vSide, vLook)
    
    var m = float4x4(columns: (
      simd_float4(vSide, 0),
      simd_float4(vUp, 0),
      simd_float4(-vLook, 0),
      simd_float4(0,0,0,1)
    ))
    m = m.transpose
    
    let eyeInv = -(m * simd_float4(eye, 0))
    m[3][0] = eyeInv.x
    m[3][1] = eyeInv.y
    m[3][2] = eyeInv.z
    
    return m
  }
  
  public static func makePerspective(fovyRadians: Float, _ aspect: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
    let ys = 1 / tanf(fovyRadians * 0.5)
    let xs = ys / aspect
    let zs = farZ / (nearZ - farZ)
    return float4x4(columns: (.init(x:xs, y:0, z:0, w:0),
                              .init(x:0, y:ys, z:0, w:0),
                              .init(x:0, y:0, z:zs, w:-1),
                              .init(x:0, y:0, z:zs * nearZ, w:0)))
    /*return Mat4([
      Vec4(xs,  0, 0,   0),
      Vec4( 0, ys, 0,   0),
      Vec4( 0,  0, zs, -1),
      Vec4( 0,  0, zs * nearZ, 0)
    ])
    */
    
    // return unsafeBitCast(GLKMatrix4MakePerspective(fovyRadians, aspect, nearZ, farZ), to: float4x4.self)
  }

  public static func makeFrustum(left: Float, _ right: Float, _ bottom: Float, _ top: Float, _ nearZ: Float, _ farZ: Float) -> float4x4 {
    return unsafeBitCast(GLKMatrix4MakeFrustum(left, right, bottom, top, nearZ, farZ), to: float4x4.self)
  }

  public static func makeOrthographic(left: Float, right: Float, bottom: Float, top: Float, nearZ: Float, farZ: Float) -> float4x4 {

    // Left Hand
    /*float4x4(rows: [
      .init(x: 2 / (right - left), y: 0, z: 0, w: (left + right) / (left - right)),
      .init(x: 0, y: 2 / (top - bottom), z: 0, w: (top + bottom) / (bottom - top)),
      .init(x: 0, y: 0, z: 1 / (farZ - nearZ), w: nearZ / (nearZ - farZ)),
      .init(x: 0, y: 0, z: 0, w: 1)
    ])*/

    // Right Hand
    float4x4(rows: [
      .init(x: 2 / (right - left), y: 0, z: 0, w: (left + right) / (left - right)),
      .init(x: 0, y: 2 / (top - bottom), z: 0, w: (top + bottom) / (bottom - top)),
      .init(x: 0, y: 0, z: -1 / (farZ - nearZ), w: nearZ / (nearZ - farZ)),
      .init(x: 0, y: 0, z: 0, w: 1)
    ])

      /*return float4x4(
          [ 2 / (right - left), 0, 0, 0],
          [0, 2 / (top - bottom), 0, 0],
          [0, 0, 1 / (far - near), 0],
          [(left + right) / (left - right), (top + bottom) / (bottom - top), near / (near - far), 1]
      )*/
  }

  // MARK: - Instance
  
  public var scale: simd_float3 {
    let x = simd_length(simd_float3(x: self.columns.0.x, y: self.columns.0.y, z: self.columns.0.z))
    let y = simd_length(simd_float3(x: self.columns.1.x, y: self.columns.1.y, z: self.columns.1.z))
    let z = simd_length(simd_float3(x: self.columns.2.x, y: self.columns.2.y, z: self.columns.2.z))
    
    return 
      .init(x: x, y: y, z: z)
  }
  
  public var rotation: simd_quatf {
    return simd_quatf(self)
  }
  
  public var translation: simd_float3 {
    return simd_float3(x: self.columns.3.x, 
                       y: self.columns.3.y, 
                       z: self.columns.3.z)
  }
}
