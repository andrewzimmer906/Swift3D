//
//  ForEach.swift
//  
//
//  Created by Andrew Zimmer on 2/14/23.
//

import Foundation

public struct ForEach3D<Data, Content> where Data: RandomAccessCollection {
  var data: Data
  var content: (Data.Element) -> Content
}

extension ForEach3D: Node where Content: Node {
  public var id: String { "" }

  public var printedTree: [String] {
    var strings: [String] = []
    for item in data {
      let node = content(item)
      strings.append(contentsOf: node.printedTree)
    }
    
    return strings
  }

  public var drawCommands: [any MetalDrawable] {
    var commands: [any MetalDrawable] = []

    for item in data {
      let node = content(item)
      commands.append(contentsOf: node.drawCommands)
    }

    return commands
  }
}

extension ForEach3D where Content: Node, Data.Element: Identifiable {
    public init(_ data: Data, @SceneBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }
}

extension ForEach3D where Data == Range<Int>, Content: Node {
    public init(_ data: Range<Int>, @SceneBuilder content: @escaping (Int) -> Content) {
        self.data = data
        self.content = content
    }
}
