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
    
    // Clear Pass
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
    
    // Render Command Pass
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = layerDrawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .load
    renderPassDescriptor.depthAttachment.texture = depthTexture
    renderPassDescriptor.depthAttachment.loadAction = .load
    renderPassDescriptor.depthAttachment.storeAction = .store

    // Light Setup
    var lightsData: [Light] = defaultLighting

    let lightCommands = commands.compactMap { $0.0 as? PlaceLight }
    lightsData = lightCommands.map { $0.uniformValues }

    // Camera and Fragment uniforms setup
    var viewProjBuffer: MTLBuffer? = nil
    if let cameraCommand = commands.first(where: { $0.0 is PlaceCamera })?.0 as? PlaceCamera {
      viewProjBuffer = cameraCommand.storage.viewProjBuffer
      let uniform = StandardFragmentUniform(camPos: simd_float4(cameraCommand.transform.translation, 1),
                                            lightCount: simd_float4(x: Float(lightsData.count), y: 0, z: 0, w: 0))
      standardFragmentUniformBuffer.contents().storeBytes(of: uniform, as: StandardFragmentUniform.self)
    }

    commands.forEach { command in
      command.0.update(time: time, previous: command.1)
      
      guard command.0.needsRender else {
        return 
      }
      
      guard let encoder = buffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
        fatalError()
      }
      
      // Set the view / proj buffer if it exists
      if let viewProjBuffer = viewProjBuffer {
        encoder.setVertexBuffer(viewProjBuffer, offset: 0, index: 2)
      } else {
        encoder.setVertexBuffer(defaultProjViewBuffer, offset: 0, index: 2)
      }

      encoder.setFragmentBuffer(standardFragmentUniformBuffer, offset: 0, index: FragmentBufferIndex.uniform.rawValue)
      encoder.setFragmentBytes(lightsData, length: MemoryLayout<Light>.stride * lightsData.count, index: FragmentBufferIndex.lights.rawValue)

      command.0.render(encoder: encoder, depthStencil: depthStencilState)
    }

    buffer.present(layerDrawable)
    buffer.commit()
  }
}
