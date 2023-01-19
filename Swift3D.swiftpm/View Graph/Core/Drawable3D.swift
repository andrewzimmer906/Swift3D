//
//  Drawable3D.swift
//  
//
//  Created by Andrew Zimmer on 1/18/23.
//

import Foundation
import Metal

// MARK: - Drawable3D 

protocol Drawable3D: Transform3D {
  var vertices: [Float] { get }
  func drawCommand(pipelineState: MTLRenderPipelineState, vertexBuffer: MTLBuffer) -> DrawCommand
}

extension Drawable3D {
  func drawCommand(pipelineState: MTLRenderPipelineState, vertexBuffer: MTLBuffer) -> DrawCommand {
    TrianglesDrawCommand(pipelineState: pipelineState, vertices: vertexBuffer, vertexCount: vertices.count)
  }
}

// MARK: - Draw Commands

protocol DrawCommand {
  func render(encoder: MTLRenderCommandEncoder)
}

struct TrianglesDrawCommand: DrawCommand {
  let pipelineState: MTLRenderPipelineState
  let vertices: MTLBuffer
  let vertexCount: Int
  
  func render(encoder: MTLRenderCommandEncoder) {
    encoder.setRenderPipelineState(pipelineState)
    encoder.setVertexBuffer(vertices, offset: 0, index: 0)
    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount / 3)
    encoder.endEncoding()
  }
}


