//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

public struct EmptyNode: Node {
  public var id: String { "" }
  
  public var body: some Node {
    self
  }
  
  public var printedTree: [String] {
    []  
  }
  
  public var drawCommands: [any MetalDrawable] {
    []
  }
}
