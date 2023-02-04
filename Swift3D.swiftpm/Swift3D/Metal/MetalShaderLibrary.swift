//
//  MetalShaderLibrary.swift
//  
//
//  Created by Andrew Zimmer on 1/18/23.
//

import Foundation
import Metal
import UIKit
import simd

class MetalShaderLibrary {  
  // TODO: Limit the size of this fella.
  private var pipelines: [String: MTLRenderPipelineState] = [:]
  private var colorTextures: [simd_float4: MTLTexture] = [:]
  private var imageTextures: [CGImage: MTLTexture] = [:]

  let device: MTLDevice
  let library: MTLLibrary

  init(device: MTLDevice) {
    guard let lib = device.makeDefaultLibrary() else {
      fatalError()
    }
    
    self.device = device
    self.library = lib
  }
  
  func pipeline(for vertex: String, fragment: String) -> MTLRenderPipelineState {
    let key = vertex + "." + fragment
    if let pipe = pipelines[key] {
      return pipe
    }
    
    let vertexProgram = library.makeFunction(name: vertex)
    let fragmentProgram = library.makeFunction(name: fragment)

    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
    
    do {
      let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
      pipelines[key] = pipelineState
      return pipelineState
    } catch {
      fatalError()
    }
  }
  
  func texture(color: simd_float4) -> MTLTexture {
    if let tex = colorTextures[color] {
      return tex
    }
    
    let texture = Self.texture(device, from: color)
    colorTextures[color] = texture
    return texture
  }
  
  func texture(image: CGImage) -> MTLTexture {
    if let tex = imageTextures[image] {
      return tex
    }
    
    let texture = Self.texture(device, from: image)    
    imageTextures[image] = texture
    return texture    
  }
}

// MARK: - MTLTextureLoads

extension MetalShaderLibrary {
  static func texture(_ device: MTLDevice, from image: CGImage, flip: Bool = false) -> MTLTexture {    
    let bytesPerPixel = 4
    let bitsPerComponent = 8
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    let rowBytes = image.width * bytesPerPixel
    
    let context = CGContext(data: nil, 
                            width: image.width, 
                            height: image.height, 
                            bitsPerComponent: bitsPerComponent, 
                            bytesPerRow: rowBytes, 
                            space: colorSpace, 
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    guard let context = context else {
      fatalError()
    }
    
    context.clear(CGRect(x: 0, y: 0, width: image.width, height: image.height))
    
    if flip {
      context.translateBy(x: 0, y: CGFloat(image.height))
      context.scaleBy(x: 1.0, y: -1.0)
    }
    
    context.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
    
    let descriptor = MTLTextureDescriptor.texture2DDescriptor(
      pixelFormat: MTLPixelFormat.rgba8Unorm, 
      width: image.width, 
      height: image.height, 
      mipmapped: false)
    
    guard let texture = device.makeTexture(descriptor: descriptor),
          let pixelData = context.data else {
      fatalError()
    }
    
    let region = MTLRegionMake2D(0, 0, image.height, image.height)    
    texture.replace(region: region, mipmapLevel: 0, withBytes: pixelData, bytesPerRow: rowBytes)
    
    return texture    
  }
  
  static func texture(_ device: MTLDevice, from color: simd_float4) -> MTLTexture {

    let descriptor = MTLTextureDescriptor()
    descriptor.width = 8
    descriptor.height = 8
    descriptor.mipmapLevelCount = 1
    descriptor.storageMode = .shared
    descriptor.arrayLength = 1
    descriptor.sampleCount = 1
    descriptor.cpuCacheMode = .writeCombined
    descriptor.allowGPUOptimizedContents = false
    descriptor.pixelFormat = .rgba8Unorm
    descriptor.textureType = .type2D
    descriptor.usage = .shaderRead
    
    guard let texture = device.makeTexture(descriptor: descriptor) else {
      fatalError()
    }
    
    let origin = MTLOrigin(x: 0, y: 0, z: 0)
    let size = MTLSize(width: texture.width, height: texture.height, depth: texture.depth)
    let region = MTLRegion(origin: origin, size: size)
    let mappedColor = simd_uchar4(color * 255)
    
    Array<simd_uchar4>(repeating: mappedColor, count: 64).withUnsafeBytes { ptr in
      texture.replace(region: region, mipmapLevel: 0, withBytes: ptr.baseAddress!, bytesPerRow: 32)
    }
    
    return texture
  }
}
