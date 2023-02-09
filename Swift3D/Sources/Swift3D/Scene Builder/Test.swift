//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/20/23.
//

import Foundation



func makeCode(@SceneBuilder _ content: () -> any Node) -> any Node {
  content()
}

func testBuilder() {
  // let yes = true
  // let no = false

  let tree = makeCode {
    GroupNode(id: "one") {
      TriangleNode(id: "tri1")
    }
    TriangleNode(id: "tris")
  }
  
  print("\n")
  print(tree)
  print("\n")
  print(tree.printedTree.reduce("", { partialResult, str in
    partialResult + "\n" + str
  }))
}

