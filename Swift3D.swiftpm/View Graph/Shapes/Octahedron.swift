//
//  Octahedron.swift
//  
//
//  Created by Andrew Zimmer on 1/30/23.
//

import Foundation
import simd

struct Octahedron<Geometry: MetalDrawable_Geometry> {
  static func get(divisions: Int) -> Geometry {
    fatalError()
  }
}

// Grabbed Math from :
// https://web.archive.org/web/20171218054621/http://www.binpress.com/tutorial/creating-an-octahedron-sphere/162
extension Octahedron where Geometry == StandardGeometry {  
  static func get(divisions: Int) -> Geometry {
    let data = create(for: divisions)
    let normalizedPos = data.0.map { normalize($0) }
    
    let normals = Self.normals(for: normalizedPos)
    let uvs = Self.uvs(for: normalizedPos)
    
    let vertices: [StandardGeometry.Vertex] = zip(zip(normalizedPos, normals), uvs).map { data in
        .init(position: data.0.0 * 0.5, uv: data.1, normal: data.0.1)
    }
    
    return StandardGeometry(vertices: vertices, indices: data.1)
  }
  
  private static func normals(for positions: [simd_float3]) -> [simd_float3] {
    positions.map {
      normalize($0)
    }
  }
  
  private static func uvs(for positions: [simd_float3]) -> [simd_float2] {
    positions.map {
      var x = atan2($0.x, $0.z) / (-2.0 * .pi)
      if x < 0 {
        x += 1
      }
      let y = asin($0.y) / .pi + 0.5
      
      return simd_float2(x: x, y: y)
    }
  }
  
  // MARK: - Create
  
  private static func numVerts(for resolution: Int) -> Int {
    (resolution + 1) * (resolution + 1) * 4 - (resolution * 2 - 1) * 3
  }
  
  private static func numIndices(for subdivisions: Int) -> Int {
    (1 << (subdivisions * 2 + 3)) * 3
  }
  
  private static func create(for subdivisions: Int) -> ([simd_float3], [Int16]) {
    let resolution = 1 << subdivisions
    var vertices = [simd_float3](repeating: .zero, count: numVerts(for: resolution))
    var triangles = [Int16](repeating: .zero, count: numIndices(for: subdivisions))
    
    var v: Int = 0
    var vBottom: Int16 = 0
    var t = 0
    
    let directions = [ simd_float3.left,
                       simd_float3.back,
                       simd_float3.right,
                       simd_float3.forward]
    
    for _ in 0..<4 {
      vertices[v++] = .down
    }
    
    for i in 1...resolution {
      let progress = Float(i) / Float(resolution)
      var to = simd_float3.lerp(.down, .forward, progress)
      vertices[v++] = to
      for d in 0..<4 {
        let from = to
        to = simd_float3.lerp(.down, directions[d], progress)
        t = OctahedronHelper.createLowerStrip(steps: i, vTop: Int16(v), vBottom: vBottom, t: t, triangles: &triangles)
        v = OctahedronHelper.createVertexLine(from: from, to: to, steps: i, v: v, vertices: &vertices)
        vBottom += Int16(i > 1 ? (i - 1) : 1)
      }
      vBottom = Int16(v - 1 - i * 4)
    }
    
    for i in (1..<resolution).reversed() {
      let progress = Float(i) / Float(resolution)
      var to = simd_float3.lerp(.up, .forward, progress)
      vertices[v++] = to
      
      for d in 0..<4 {
        let from = to
        to = simd_float3.lerp(.up, directions[d], progress)
        t = OctahedronHelper.createUpperStrip(steps: i, vTop: Int16(v), vBottom: vBottom, t: t, triangles: &triangles)
        v = OctahedronHelper.createVertexLine(from: from, to: to, steps: i, v: v, vertices: &vertices)
        vBottom += Int16(i + 1)
      }
      vBottom = Int16(v - 1 - i * 4)
    }
    
    for _ in 0..<4 {
      triangles[t++] = vBottom
      triangles[t++] = Int16(v)
      triangles[t++] = ++vBottom
      vertices[v++] = .up
    }
    
    return (vertices, triangles)
  }
}

  fileprivate enum OctahedronHelper {
  fileprivate static func createVertexLine(from: simd_float3, 
                                       to: simd_float3, 
                                       steps: Int, 
                                       v: Int, 
                                       vertices: inout[simd_float3]) -> Int {
    var v = v
    for i in 1...steps {
      vertices[v++] = simd_float3.lerp(from, to, Float(i) / Float(steps))
    }
    
    return v
  }
  
  fileprivate static func createLowerStrip(steps: Int, vTop: Int16, vBottom: Int16, t: Int, triangles: inout [Int16]) -> Int {
    var t = t
    var vBottom = vBottom
    var vTop = vTop
    
    for _ in 1..<steps {    
      triangles[t++] = vBottom;
      triangles[t++] = vTop - 1;
      triangles[t++] = vTop
      
      triangles[t++] = vBottom++
      triangles[t++] = vTop++
      triangles[t++] = vBottom
    }
    
    triangles[t++] = Int16(vBottom)
    triangles[t++] = vTop - 1
    triangles[t++] = vTop
    
    return t
  }
  
  fileprivate static func createUpperStrip(steps: Int, vTop: Int16, vBottom: Int16, t: Int, triangles: inout [Int16]) -> Int {
    var t = t
    var vBottom = vBottom
    var vTop = vTop
    
    triangles[t++] = vBottom
    triangles[t++] = vTop - 1
    triangles[t++] = ++vBottom
    
    for _ in 1...steps {
      triangles[t++] = vTop - 1
      triangles[t++] = vTop
      triangles[t++] = vBottom

      triangles[t++] = vBottom
      triangles[t++] = vTop++
      triangles[t++] = ++vBottom
    }

    return t
  }
}