import Foundation
import UIKit
import Metal
import simd

// MARK: - Renderer

public class MetalRenderer: ObservableObject {
  private let commandQueue: MTLCommandQueue
  let metalDevice: MTLDevice
  let depthStencilState: MTLDepthStencilState?
  
  private lazy var defaultLighting: MTLBuffer? = {
    let buff = metalDevice.makeBuffer(length: MemoryLayout<LightsUniform>.size)
    guard let buff = buff else {
      fatalError()
    }
    
    let lightsUniform = LightsUniform(light1: simd_float4(x:0, y: 0, z: 0, w: 1), light1Col: .one * 0.35, 
                                      light2: simd_float4(x:0, y: 0, z: 0, w: 0), light2Col: .zero)
    buff.contents().storeBytes(of: lightsUniform, as: LightsUniform.self)
    return buff
  }()
  
  private lazy var defaultProjViewBuffer: MTLBuffer? = {
    let buff = metalDevice.makeBuffer(length: MemoryLayout<ViewProjectionUniform>.size)
    guard let buff = buff else {
      fatalError()
    }
    
    let vpUniform = ViewProjectionUniform(projectionMatrix: float4x4.identity, 
                                          viewMatrix: float4x4.identity,
                                          clipToViewMatrix: .identity)
    
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
    
    var viewProjBuffer: MTLBuffer? = nil
    if let cameraCommand = commands.first(where: { $0.0 is PlaceCamera })?.0 as? PlaceCamera {
      viewProjBuffer = cameraCommand.storage.viewProjBuffer
    }
    
    var lightsBuffer: MTLBuffer?
    let lightCommands = commands.filter({ $0.0 is PlaceLight })
    if !lightCommands.isEmpty {
      let storage = lightCommands.first?.0.storage as? PlaceLight.Storage
      let presentedCommands = lightCommands.map { (cur, prev) in
        cur.presentedDrawCommand(time: time, previous: prev)
      }
      storage?.set(presentedCommands)
      lightsBuffer = storage?.lightsUniform
    }
    else {
      lightsBuffer = defaultLighting
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
      
      encoder.setVertexBuffer(lightsBuffer, offset: 0, index: 3)
      command.0.render(encoder: encoder, depthStencil: depthStencilState)
    }

    buffer.present(layerDrawable)
    buffer.commit()
  }
}
