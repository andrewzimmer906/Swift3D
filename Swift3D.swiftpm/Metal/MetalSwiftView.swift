//
//  MetalSwiftView.swift
//  
//
//  Created by Andrew Zimmer on 1/18/23.
//

import UIKit
import SwiftUI

struct Swift3DView: UIViewRepresentable {
  let updateLoop: ((_ deltaTime: CFTimeInterval) -> Void)?
  let preferredFps: Int
  let content: () -> any Node
  
  init(preferredFps: Int = 30,
       updateLoop: ((_ deltaTime: CFTimeInterval) -> Void)? = nil,       
       @SceneBuilder _ content: @escaping () -> any Node) {
    self.updateLoop = updateLoop
    self.preferredFps = preferredFps
    self.content = content
  }

  func makeUIView(context: Context) -> UIView {
    // Needs initial frame to not be zero to create MTLDevice
    let view = MetalView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    view.setUpdateLoop(updateLoop, preferredFps: preferredFps)
    view.setContent(content())
    
    return view
  }

  func updateUIView(
    _ uiView: UIView,
    context: Context
  ) {
    if let view = uiView as? MetalView {
      view.setContent(content())
    }
  }
}
