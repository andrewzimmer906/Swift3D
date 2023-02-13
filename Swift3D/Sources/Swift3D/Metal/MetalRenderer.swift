import Foundation
import UIKit
import Metal
import simd

// MARK: - Renderer

public class MetalRenderer: ObservableObject {
  private let commandQueue: MTLCommandQueue
  let metalDevice: MTLDevice
  let depthStencilState: MTLDepthStencilState?
  let standardFragmentUniformBuffer: MTLBuffer

  // Low Ambient Lighting
  private var defaultLighting: [Light] {
    [Light(position: simd_float4(.zero, 1), color: .one * 0.35)]
  }
  
  private lazy var defaultProjViewBuffer: MTLBuffer? = {
    let buff = metalDevice.makeBuffer(length: MemoryLayout<ViewProjectionUniform>.size)
    guard let buff = buff else {
      fatalError()
    }
    
    let vpUniform = ViewProjectionUniform(projectionMatrix: float4x4.identity, 
                                          viewMatrix: float4x4.identity)
    
    buff.contents().storeBytes(of: vpUniform, as: ViewProjectionUniform.self)
    return buff
  }()
  
  public init(device: MTLDevice) {
    guard let cq = device.makeCommandQueue() else {
      fatalError()        
    }   
    
    commandQueue = cq
    metalDevice = device
    
    let descriptor = MTLDepthStencilDescriptor()
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    
    self.depthStencilState = device.makeDepthStencilState(descriptor: descriptor)

    guard let buff = device.makeBuffer(length: MemoryLayout<StandardFragmentUniform>.size) else {
      fatalError()
    }

    self.standardFragmentUniformBuffer = buff
  }
  
  func render(_ time: CFTimeInterval, 
              layerDrawable: CAMetalDrawable, 
              depthTexture: MTLTexture,
              commands: [CommandAndPrevious]) {
    guard let buffer = commandQueue.makeCommandBuffer() else {
      fatalError()
    }

    // Clear the textures
    clearPass(buffer: buffer, layerDrawable: layerDrawable, depthTexture: depthTexture)
    
    // Render Command Pass
    let renderPassDescriptor = renderPassDescriptor(buffer: buffer, layerDrawable: layerDrawable, depthTexture: depthTexture)

    // Light Setup
    var lightsData: [Light] = defaultLighting
    let lightCommands = commands.compactMap { $0.0 as? PlaceLight }
    lightsData = lightCommands.map { $0.uniformValues }

    // Camera and Fragment uniforms setup
    let viewProjBuffer = viewProjectionBuffer(from: commands)
    var fragmentUniform = standardFragmentUniform(from: commands, lightCount: lightsData.count)

    commands.forEach { command in
      guard command.0.needsRender else {
        return 
      }
      
      guard let encoder = buffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
        fatalError()
      }

      // Add the needed data for GPU rendering
      if let viewProjBuffer = viewProjBuffer {
        encoder.setVertexBuffer(viewProjBuffer, offset: 0, index: 2)
      }

      encoder.setFragmentBytes(&fragmentUniform, length: MemoryLayout<StandardFragmentUniform>.size, index: FragmentBufferIndex.uniform.rawValue)
      encoder.setFragmentBytes(lightsData, length: MemoryLayout<Light>.stride * lightsData.count, index: FragmentBufferIndex.lights.rawValue)

      // Render!
      command.0.render(encoder: encoder, depthStencil: depthStencilState)
    }

    buffer.present(layerDrawable)
    buffer.commit()
  }

  //MARK: - Pass Helpers

  private func renderPassDescriptor(buffer: MTLCommandBuffer, layerDrawable: CAMetalDrawable, depthTexture: MTLTexture) -> MTLRenderPassDescriptor {
    // Render Command Pass
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = layerDrawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .load
    renderPassDescriptor.depthAttachment.texture = depthTexture
    renderPassDescriptor.depthAttachment.loadAction = .load
    renderPassDescriptor.depthAttachment.storeAction = .store

    return renderPassDescriptor
  }

  private func clearPass(buffer: MTLCommandBuffer, layerDrawable: CAMetalDrawable, depthTexture: MTLTexture) {
    let clearPassDescriptor = MTLRenderPassDescriptor()
    clearPassDescriptor.colorAttachments[0].texture = layerDrawable.texture
    clearPassDescriptor.colorAttachments[0].loadAction = .clear
    clearPassDescriptor.depthAttachment.texture = depthTexture
    clearPassDescriptor.depthAttachment.loadAction = .clear
    clearPassDescriptor.depthAttachment.storeAction = .store

    clearPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
      red: 1,
      green: 1,
      blue: 1,
      alpha: 1.0)

    let renderEncoder = buffer.makeRenderCommandEncoder(descriptor: clearPassDescriptor)!
    renderEncoder.endEncoding()
  }

  //MARK: - Data Helpers

  private func standardFragmentUniform(from commands: [CommandAndPrevious], lightCount: Int) -> StandardFragmentUniform {
    if let cameraCommand = commands.first(where: { $0.0 is PlaceCamera })?.0 as? PlaceCamera {
      return StandardFragmentUniform(camPos: simd_float4(cameraCommand.transform.value.translation, 1),
                                     lightCount: simd_float4(x: Float(lightCount), y: 0, z: 0, w: 0))
    }
    
    return StandardFragmentUniform(camPos: .zero, lightCount: simd_float4(x: Float(lightCount), y: 0, z: 0, w: 0))
  }

  private func viewProjectionBuffer(from commands: [CommandAndPrevious]) -> MTLBuffer? {
    if let cameraCommand = commands.first(where: { $0.0 is PlaceCamera })?.0 as? PlaceCamera {
      return cameraCommand.storage.viewProjBuffer
    }

    return defaultProjViewBuffer
  }
}
