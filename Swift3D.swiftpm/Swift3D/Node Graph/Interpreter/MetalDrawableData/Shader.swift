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

protocol MetalDrawable_Shader {
  func setupEncoder(encoder: MTLRenderCommandEncoder)
  func build(device: MTLDevice, library: MetalShaderLibrary)
}

// MARK: - Textures

protocol MetalDrawable_Texture {
  func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture?
}

extension Color: MetalDrawable_Texture {
  func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture? {
    return library.texture(color: self.components)
  }
}

extension UIImage: MetalDrawable_Texture {
  func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture? {
    guard let img = self.cgImage else {
      fatalError()
    }
    return library.texture(image: img)
  }
}

extension Optional<UIImage>: MetalDrawable_Texture {
  func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture? {
    guard let img = self?.cgImage else {
      fatalError()
    }
    return library.texture(image: img)
  }
}

struct CubeMap: MetalDrawable_Texture {
  let image: String

  func mtlTexture(_ library: MetalShaderLibrary) -> MTLTexture? {
    guard let img = UIImage(named: image) else {
      fatalError()
    }

    return library.cubeTexture(image: img)
  }

  static func cube(_ image: String) -> Self {
    return Self(image: image)
  }
}


