import Foundation
import UIKit
import SwiftUI
import Metal
import MetalKit

public class MetalView: UIView {
  private let device: MTLDevice
  private var metalLayer: CAMetalLayer?
  private var metalDepthTexture: MTLTexture?
  
  private let renderer: MetalRenderer
  private let shaderLibrary: MetalShaderLibrary
  private let geometryLibrary: MetalGeometryLibrary

  private let scene: MetalScene3D
  
  private let timelineLoop = TimelineLoop(fps: 60)
  private var updateLoop: ((_ deltaTime: CFTimeInterval) -> Void)?
  private var lastUpdateTime: CFTimeInterval = 0
  private var preferredTimeBetweenUpdates: CFTimeInterval = 0

  private var content: (() -> any Node)?
  
  // MARK: Setup / Teardown
  
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override init(frame: CGRect) {
    if let d = MTLCreateSystemDefaultDevice() {
      device = d      
    }
    else {
      fatalError()
    }
    
    shaderLibrary = MetalShaderLibrary(device: device)
    geometryLibrary = MetalGeometryLibrary(device: device)
    scene = MetalScene3D(device: device)
    renderer = MetalRenderer(device: device)
    
    super.init(frame: frame)
    
    setupLayer()
    timelineLoop.start { [weak self] frameTime in
      self?.render(time: frameTime)
    }
  }
  
  private func setupLayer() {
    let ml = CAMetalLayer()
    
    ml.device = device
    ml.pixelFormat = .bgra8Unorm
    ml.framebufferOnly = true
    ml.frame = layer.frame
    layer.addSublayer(ml)
    
    self.metalLayer = ml
  }
  
  deinit {
    timelineLoop.stop()
  }
  
  // MARK: - Rendering and Content
  
  public func setUpdateLoop(_ updateLoop: ((_ deltaTime: CFTimeInterval) -> Void)?, preferredFps: Int) {
    self.lastUpdateTime = CACurrentMediaTime()
    self.updateLoop = updateLoop
    self.preferredTimeBetweenUpdates = 1.0 / Double(preferredFps)    
  }

  public func setContent(_ content: @escaping () -> any Node) {
    self.content = content
    scene.setContent(content(),
                     shaderLibrary: shaderLibrary,
                     geometryLibrary: geometryLibrary,
                     surfaceAspect: Float(layer.frame.size.width / layer.frame.size.height))
  }
  
  private func render(time: CFTimeInterval) {
    guard let drawable = metalLayer?.nextDrawable(),
          let depth = metalDepthTexture else {
      return
    }
    
    let curTime = CACurrentMediaTime()
    let delta = curTime - lastUpdateTime
    if delta >= preferredTimeBetweenUpdates {
      updateLoop?(delta)
      lastUpdateTime = curTime

      if let content = self.content {
        scene.setContent(content(),
                         shaderLibrary: shaderLibrary,
                         geometryLibrary: geometryLibrary,
                         surfaceAspect: Float(layer.frame.size.width / layer.frame.size.height))
      }
    }

    renderer.render(time, layerDrawable: drawable, depthTexture: depth, commands: scene.commands)
  }
  
  // MARK: - View Methods
  
  public override func layoutSubviews() {
    guard let layers = layer.sublayers else {
      return
    }

    for l in layers {
      l.frame = layer.frame
    }      
    
    // Reset content to reset the aspect ration on the projection matrix.
    scene.setContent(scene.content,
                     shaderLibrary: shaderLibrary,
                     geometryLibrary: geometryLibrary,
                     surfaceAspect: Float(layer.frame.size.width / layer.frame.size.height))
    
    
    // Remake our depth texture to size.
    let desc = MTLTextureDescriptor.texture2DDescriptor(
        pixelFormat: .depth32Float_stencil8,
        width: Int(layer.frame.size.width), height: Int(layer.frame.size.height), 
        mipmapped: false)
    desc.storageMode = .private
    desc.usage = .renderTarget    
    self.metalDepthTexture = device.makeTexture(descriptor: desc)
  }
}

// MARK: Update Loop

private class TimelineLoop {
  let fps: Float

  private var tick: ((CFTimeInterval) -> Void)?
  private var dp: CADisplayLink?

  init(fps: Float) {
    self.fps = fps
  }

  func start(callback: @escaping (CFTimeInterval) -> Void) {
    tick = callback

    dp = CADisplayLink(target: self, selector: #selector(update))
    dp?.preferredFrameRateRange = CAFrameRateRange(minimum: 10, maximum: fps, preferred: fps)
    dp?.add(to: .current, forMode: .common)
  }

  func stop() {
    dp?.invalidate()
  }

  @objc private func update() {
    if let tick = tick {
      autoreleasepool {
        tick(CACurrentMediaTime())
      }
    }
  }
}
