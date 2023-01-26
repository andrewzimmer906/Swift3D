//
//  Node.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

protocol Node {
  var id: String { get }  
  var printedTree: [String] { get }
  var drawCommands: [any MetalDrawable] { get }
}

extension Node {
  var printedTree: [String] {    
    ["\(id):\(String(describing:type(of: self)))"]
  }
}
