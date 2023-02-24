//
//  ShaderPipeline.swift
//  
//
//  Created by Andrew Zimmer on 1/27/23.
//

import Foundation
import Metal
import SwiftUI
import UIKit

// MARK: - Shader

public protocol MetalDrawable_Shader {
  func setupEncoder(encoder: MTLRenderCommandEncoder)
  func setTextures(encoder: MTLRenderCommandEncoder)

  func build(device: MTLDevice, library: MetalShaderLibrary, descriptor: MTLVertexDescriptor?)
}

// MARK: - Textures

public protocol MetalDrawable_Texture {
  func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture?
}

extension Color: MetalDrawable_Texture {
  public func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture? {
    return library.texture(color: self.components)
  }
}

extension UIImage: MetalDrawable_Texture {
  public func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture? {
    guard let img = self.cgImage else {
      fatalError()
    }
    return library.texture(image: img)
  }
}

extension Optional<UIImage>: MetalDrawable_Texture {
  public func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture? {
    guard let img = self?.cgImage else {
      fatalError()
    }
    return library.texture(image: img)
  }
}

public struct CubeMap: MetalDrawable_Texture {
  public let image: String

  public func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture? {
    guard let img = UIImage(named: image) else {
      fatalError()
    }

    return library.cubeTexture(image: img)
  }
}

public extension MetalDrawable_Texture where Self == CubeMap {
  static func cube(_ image: String) -> Self {
    return Self(image: image)
  }
}


