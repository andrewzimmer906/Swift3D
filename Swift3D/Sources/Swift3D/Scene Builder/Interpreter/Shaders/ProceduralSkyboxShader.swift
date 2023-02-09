//
//  ProceduralSkybox.swift
//  
//
//  Created by Andrew Zimmer on 2/6/23.
//

import Foundation
import Metal
import SwiftUI
import UIKit
import simd

// MARK: - Init Helper

extension MetalDrawable_Shader where Self == ProceduralSkyboxShader {
  public static func skybox(low: Color = Color(hex: 0x999999),
                     mid: Color = Color(hex: 0xF9F9F9),
                     high: Color = Color(hex: 0xcccccc)) -> ProceduralSkyboxShader {
    let properties = ProceduralSkyboxShader.Properties(time: .zero, colLow: low.components, colMid: mid.components, colHigh: high.components)
    return .init(storage: ProceduralSkyboxShader.Storage(properties: properties))
  }
}

// MARK: - Shader

public struct ProceduralSkyboxShader: MetalDrawable_Shader {
  static let startTime = CACurrentMediaTime()
  let functions: (String, String) = ("procedural_skybox_vertex", "procedural_skybox_fragment")
  let storage: Storage

  public func build(device: MTLDevice, library: MetalShaderLibrary) {
    // We store and use library directly because it does a lot of the reuse and caching of
    // shaders & textures for us.
    self.storage.library = library
  }

  public func setupEncoder(encoder: MTLRenderCommandEncoder) {
    guard
      let library = storage.library else {
      return
    }

    // Shaders
    let time = Float(CACurrentMediaTime() - Self.startTime)
    storage.properties = storage.properties.with(time: simd_float4(x: time, y: 0, z: 0, w: 0))

    encoder.setFragmentBytes(&storage.properties, length: MemoryLayout<Properties>.size, index: 2)
    encoder.setRenderPipelineState(library.pipeline(for: functions.0, fragment: functions.1, needsDescriptor: false))
  }
}


extension ProceduralSkyboxShader {
  struct Properties {
    let time: simd_float4
    let colLow: simd_float4
    let colMid: simd_float4
    let colHigh: simd_float4

    static var none: Properties {
      return Properties(time: .zero, colLow: .zero, colMid: .zero, colHigh: .zero)
    }

    func with(time: simd_float4) -> Properties {
      return .init(time: time, colLow: self.colLow, colMid: self.colMid, colHigh: self.colHigh)
    }
  }

  class Storage {
    var properties: Properties
    fileprivate var library: MetalShaderLibrary?

    init(properties: Properties = .none) {
      self.properties = properties
    }
  }
}
