import Foundation
import UIKit
import Metal
import simd

public class MetalRenderer: ObservableObject {
  private let commandQueue: MTLCommandQueue
  let metalDevice: MTLDevice
  
  private lazy var defaultProjViewBuffer: MTLBuffer? = {
    let buff = metalDevice.makeBuffer(length: MemoryLayout<ViewProjectionUniform>.size)
    guard let buff = buff else {
      fatalError()
    }
    
    let vpUniform = ViewProjectionUniform(projectionMatrix: float4x4.identity, viewMatrix: float4x4.identity)          
    buff.contents().storeBytes(of: vpUniform, as: ViewProjectionUniform.self)
    
    return buff
  }()
  
  public init(device: MTLDevice) {
    guard let cq = device.makeCommandQueue() else {
      fatalError()        
    }   
    
    commandQueue = cq
    metalDevice = device
  }
  
  func render(_ time: CFTimeInterval, 
              layerDrawable: CAMetalDrawable, 
              commands: [any MetalDrawable]) {
    guard let buffer = commandQueue.makeCommandBuffer() else {
      fatalError()
    }
    
    // Clear Pass
    let clearPassDescriptor = MTLRenderPassDescriptor()
    clearPassDescriptor.colorAttachments[0].texture = layerDrawable.texture
    clearPassDescriptor.colorAttachments[0].loadAction = .clear
    clearPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
      red: 0.15,
      green: 0.15,
      blue: 0.15,
      alpha: 1.0)

    
    let renderEncoder = buffer.makeRenderCommandEncoder(descriptor: clearPassDescriptor)!
    renderEncoder.endEncoding()
    
    // Render Command Pass
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = layerDrawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .load
    
    var viewProjBuffer: MTLBuffer? = nil
    if let cameraCommand = commands.first(where: { $0 is PlaceCamera }) {      
      viewProjBuffer = cameraCommand.storage.viewProjBuffer
    }
    
    commands.forEach { command in
      command.update(time: time)
      
      guard command.needsRender else {
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
      
      command.render(encoder: encoder)
    }

    buffer.present(layerDrawable)
    buffer.commit()
  }
}
