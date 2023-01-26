//
//  Node.swift
//  
//
//  Created by Andrew Zimmer on 1/21/23.
//

import Foundation

protocol Node {  
  var id: String { get }  
  func desc() -> [String]
  var drawCommands: [any MetalDrawable] { get }
}
