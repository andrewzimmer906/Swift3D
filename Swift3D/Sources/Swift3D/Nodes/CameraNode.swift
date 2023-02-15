//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation
import SwiftUI
import simd

struct OrthographicSettings {
  let left: Float
  let right: Float
  let top: Float
  let bottom: Float

  let nearZ: Float
  let farZ: Float
}

struct PerspectiveSettings {
  let fov: Float
  let zNear: Float
  let zFar: Float

  static var standard: Self {
    .init(fov: 1.0472, zNear: 0.1, zFar: 100)
  }
}

enum CameraProjection {
  case orthographic(OrthographicSettings)
  case perspective(PerspectiveSettings)

  func matrix(aspect: Float) -> float4x4 {
    switch self {
    case .orthographic(let settings):
      return float4x4.makeOrthographic(left: settings.left,
                                       right:settings.right,
                                       bottom: settings.bottom,
                                       top: settings.top,
                                       nearZ: settings.nearZ,
                                       farZ: settings.farZ)
    case .perspective(let settings):
      return float4x4.makePerspective(fovYRadians: settings.fov,
                                      aspect: aspect,
                                      nearZ: settings.zNear,
                                      farZ: settings.zFar)
    }
  }
}

public struct CameraNode: Node {
  public let id: String
  public init(id: String) {
    self.id = id
  }
  
  public var drawCommands: [any MetalDrawable] {
    [PlaceCamera(id: id, 
                 transform: .identity,
                 projection: .perspective(.standard),
                 shaderPipeline: nil,
                 animations: nil,
                 storage: PlaceCamera.Storage())]
  }
}

// MARK: -  Camera Modifier Support

public protocol CameraNodeModifiable: Node {
  func skybox(_ shader: any MetalDrawable_Shader) -> ModifiedNodeContent<Self, ShaderModifier>
  func perspective(fov: Float, zNear: Float, zFar: Float) -> ModifiedNodeContent<Self, ProjectionModifier>
  func orthographic(viewSpace: CGRect, zNear: Float, zFar: Float) -> ModifiedNodeContent<Self, ProjectionModifier>
}

extension CameraNodeModifiable {
  public func skybox(_ shader: any MetalDrawable_Shader) -> ModifiedNodeContent<Self, ShaderModifier> {
    return self.modifier(ShaderModifier(shader: shader))
  }

  public func perspective(fov: Float = 1.0472, zNear: Float = 0.1, zFar: Float = 100) -> ModifiedNodeContent<Self, ProjectionModifier> {
    self.modifier(ProjectionModifier(value: .perspective(.init(fov: fov, zNear: zNear, zFar: zFar))))
  }

  public func orthographic(viewSpace: CGRect, zNear: Float = 0.1, zFar: Float = 100) -> ModifiedNodeContent<Self, ProjectionModifier> {
    self.modifier(ProjectionModifier(value: .orthographic(.init(left: Float(viewSpace.minX),
                                                                right: Float(viewSpace.maxX),
                                                                top: Float(viewSpace.maxY),
                                                                bottom: Float(viewSpace.minY),
                                                                nearZ: zNear,
                                                                farZ: zFar))))
  }
}

extension CameraNode: CameraNodeModifiable { }
extension ModifiedNodeContent: CameraNodeModifiable where Content: CameraNodeModifiable, Modifier: NodeModifier { }
