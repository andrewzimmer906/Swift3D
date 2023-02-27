//
//  MetalShaderLibrary.swift
//  
//
//  Created by Andrew Zimmer on 1/18/23.
//

import Foundation
import Metal
import MetalKit
import UIKit
import simd

public class MetalShaderLibrary {
  // TODO: Limit the size of this fella.
  private var pipelines: [String: MTLRenderPipelineState] = [:]
  private var colorTextures: [simd_float4: MTLTexture] = [:]
  private var imageTextures: [CGImage: MTLTexture] = [:]
  private var cubeTextures: [UIImage: MTLTexture] = [:]

  private lazy var defaultVertexDescriptor: MTLVertexDescriptor = {
    let vd = MTLVertexDescriptor()

    vd.attributes[0].format = MTLVertexFormat.float3
    vd.attributes[0].offset = 0
    vd.attributes[0].bufferIndex = 0

    vd.attributes[1].format = MTLVertexFormat.float3
    vd.attributes[1].offset = 12
    vd.attributes[1].bufferIndex = 0

    vd.attributes[2].format = MTLVertexFormat.float2
    vd.attributes[2].offset = 24
    vd.attributes[2].bufferIndex = 0

    vd.layouts[0].stepFunction = MTLVertexStepFunction.perVertex
    vd.layouts[0].stride = 32

    return vd
  }()

  let device: MTLDevice
  let library: MTLLibrary

  public init(device: MTLDevice) {
    guard let lib = try? device.makeDefaultLibrary(bundle: Bundle.module) else {
      fatalError()
    }
    
    self.device = device
    self.library = lib
  }
  
  func pipeline(for vertex: String, fragment: String, vertexDescriptor: MTLVertexDescriptor? = nil) -> MTLRenderPipelineState {
    let key = "\(vertex).\(fragment).\(String(describing:vertexDescriptor))"
    if let pipe = pipelines[key] {
      return pipe
    }
    
    let vertexProgram = library.makeFunction(name: vertex)
    let fragmentProgram = library.makeFunction(name: fragment)

    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.vertexDescriptor = vertexDescriptor

    pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float_stencil8
    
    do {
      let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
      pipelines[key] = pipelineState
      return pipelineState
    } catch {
      print("Shader Compile Error: \(error)")
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

  func cubeTexture(image: UIImage) -> MTLTexture {
    if let tex = cubeTextures[image] {
      return tex
    }

    let texture = Self.cubeTexture(device, image: image)
    cubeTextures[image] = texture
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

  // I went ahead and used metalkit here. I was initially doing things without the kit, but
  // I've already got plenty texture loading code in here after all.
  static func cubeTexture(_ device: MTLDevice, image: UIImage) -> MTLTexture  {
    let loader = MTKTextureLoader(device: device)
    let cubeTextureOptions: [MTKTextureLoader.Option : Any] = [
      .textureUsage : MTLTextureUsage.shaderRead.rawValue,
      .textureStorageMode : MTLStorageMode.private.rawValue,
      .generateMipmaps : true,
      .cubeLayout : MTKTextureLoader.CubeLayout.vertical,
    ]

    let data = image.pngData()!
    do {
      let texture = try loader.newTexture(data: data, options: cubeTextureOptions)
      return texture
    } catch {
      print("error:\(error)")
      fatalError()
    }
  }
}
