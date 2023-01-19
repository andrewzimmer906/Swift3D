//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/17/23.
//

import Foundation

// MARK: - Empty

struct Empty {
}

extension Empty: Transform3D {
  var id: String { "" }
  
  func build() -> [(String, any Transform3D)] {
    []
  }
}

// MARK: - Array Print Description
extension Array where Element == Scene3DElement {
  var description: String {
    var output = ""
    self.forEach { (id, drawable) in
      output.append("\(id): \(type(of: drawable))\n")
    }
    
    return output
  }
}


