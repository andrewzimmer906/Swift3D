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

func testTree() {
  let yes = true
  let no = false

  let tree = makeCode { 
    if no {
      TriangleNode(id: "yeah")
    }
    /*
    else {
      EmptyNode(id: "nah")
    }*/
    
    TriangleNode(id: "world").modifier(IdentityModifier(id: "hey"))
    TriangleNode(id: "fifty2").modified(id: "modification")
    
    
    
    /*
    TransformNode(id: "1") {
      TransformNode(id: "2") {
        DrawnNode(id: "3")
        //DrawnNode(id: "4")
      }
    }*/
  }
  
  print("\n")
  print(tree)
  print("\n")
  print(tree.desc().reduce("", { partialResult, str in
    partialResult + "\n" + str
  }))
}

