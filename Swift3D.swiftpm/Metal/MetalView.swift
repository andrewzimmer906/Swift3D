import Foundation
import UIKit
import SwiftUI
import Metal
import MetalKit

class MetalView: UIView {
  private let device: MTLDevice
  private var metalLayer: CAMetalLayer?
  
  private let renderer: MetalRenderer
  private let library: MetalShaderLibrary
  private let scene: MetalScene3D
  
  private let timelineLoop = TimelineLoop(fps: 60)
  private var updateLoop: ((_ deltaTime: CFTimeInterval) -> Void)?
  private var lastUpdateTime: CFTimeInterval = 0
  
  // MARK: Setup / Teardown
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    if let d = MTLCreateSystemDefaultDevice() {
      device = d      
    }
    else {
      fatalError()
    }
    
    library = MetalShaderLibrary(device: device)
    scene = MetalScene3D(device: device)
    renderer = MetalRenderer(device: device)
    
    super.init(frame: frame)
    
    setupLayer()
    timelineLoop.start(callback: render)
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
  
  func setUpdateLoop(_ updateLoop: ((_ deltaTime: CFTimeInterval) -> Void)?) {
    self.lastUpdateTime = CACurrentMediaTime()
    self.updateLoop = updateLoop
  }
  
  func setContent(_ content: any Node) {
    scene.setContent(content, 
                     library: library,
                     surfaceAspect: Float(layer.frame.size.width / layer.frame.size.height))
  }
  
  private func render(time: CFTimeInterval) {
    guard let drawable = metalLayer?.nextDrawable() else {
      fatalError()
    }
    
    let curTime = CACurrentMediaTime()
    let delta = curTime - lastUpdateTime
    updateLoop?(delta)
    lastUpdateTime = curTime
    
    renderer.render(time, layerDrawable: drawable, commands: scene.commands)
  }
  
  // MARK: - View Methods
  
  override func layoutSubviews() {
    guard let layers = layer.sublayers else {
      return
    }

    for l in layers {
      l.frame = layer.frame
    }      
    
    // Reset content to reset the aspect ration on the projection matrix.
    scene.setContent(scene.content, 
                     library: library,
                     surfaceAspect: Float(layer.frame.size.width / layer.frame.size.height))
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
