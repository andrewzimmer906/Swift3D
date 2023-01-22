import Foundation
import UIKit
import Metal

public class MetalRenderer: ObservableObject {
  private let commandQueue: MTLCommandQueue

  private var _metalDevice: MTLDevice?
  public var metalDevice: MTLDevice? {
    _metalDevice
  }
  
  // private var pipe: MetalPipeline?

  // private var command: MetalRenderCommand?
  // private var command2: MetalRenderCommand?
  
  public init(device: MTLDevice) {
    guard let cq = device.makeCommandQueue() else {
      fatalError()        
    }    
    commandQueue = cq    
  }
  
  func render(layerDrawable: CAMetalDrawable, commands: [DrawCommand]) {
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
    
    commands.forEach { command in
      guard command.needsRender else {
        return 
      }
      
      guard let encoder = buffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
        fatalError()
      }
      
      command.render(encoder: encoder)
    }

    buffer.present(layerDrawable)
    buffer.commit()
  }
  
  
  /*
  public func build() {
    _metalDevice = MTLCreateSystemDefaultDevice()
    commandQueue = _metalDevice?.makeCommandQueue()

    if let device = _metalDevice {
      let pipe = MetalPipeline(library: device.makeDefaultLibrary()!, device: device)
      //let pipe2 = MetalPipeline(library: device.makeDefaultLibrary()!, device: device)


      command = MetalRenderCommand(device: device, pipeline: pipe,
                                   vertices: [
        0.0,  0.75, 0.0,
        -0.75, -0.75, 0.0,
        0.75, -0.75, 0.0
     ])

    command2 = MetalRenderCommand(device: device, pipeline: pipe,
                                 vertices: [
      -1.0,  -1.0, 0.0,
      -0.75, -0.75, 0.0,
       -1.0, -0.75, 0.0
   ])
  }

    ready = true
    timeline.start(callback: render)
  }


  private func render(time: CFTimeInterval) {
    guard let layer = layer,
          let drawable = layer.nextDrawable(),
          let commandBuffer = commandQueue?.makeCommandBuffer() else {
      print("error failed to render")
      return
    }

    // Pass Descriptors
    let clearPassDescriptor = MTLRenderPassDescriptor()
    clearPassDescriptor.colorAttachments[0].texture = drawable.texture
    clearPassDescriptor.colorAttachments[0].loadAction = .clear
    clearPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(
      red: 0.15,
      green: 0.15,
      blue: 0.15,
      alpha: 1.0)

    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .load

    // Clear Pass
    let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: clearPassDescriptor)!
    renderEncoder.endEncoding()

    // Encoder
    if let command = self.command {
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
      command.render(encoder: renderEncoder)
    }

    if let command = self.command2 {
      let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
      command.render(encoder: renderEncoder)
    }

    commandBuffer.present(drawable)
    commandBuffer.commit()
    
    print("render complete")
  }*/
}
