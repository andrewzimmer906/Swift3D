//
//  File.swift
//  
//
//  Created by Andrew Zimmer on 1/30/23.
//

import Foundation

infix operator ++
infix operator --

extension Int {
    
    /// decrease the value by one
    ///
    /// - Parameter num: value to decrease
    static prefix func --(_ num: inout Int) -> Int {
        num -= 1
        return num
    }
    
    /// decrease the value by one
    ///
    /// - Parameter num: value to decrease
    static postfix func --(_ num: inout Int) -> Int {
        let oldValue = num
        num -= 1
        return oldValue
    }
    
    /// increase the value by one
    ///
    /// - Parameter num: value to increase
    static prefix func ++(_ num: inout Int) -> Int {
        num += 1
        return num
    }
    
    /// increase the value by one
    ///
    /// - Parameter num: value to increase
    static postfix func ++(_ num: inout Int) -> Int {
        let oldValue = num
        num += 1
        return oldValue
    }
}

extension Int16 {
    
    /// decrease the value by one
    ///
    /// - Parameter num: value to decrease
    static prefix func --(_ num: inout Int16) -> Int16 {
        num -= 1
        return num
    }
    
    /// decrease the value by one
    ///
    /// - Parameter num: value to decrease
    static postfix func --(_ num: inout Int16) -> Int16 {
        let oldValue = num
        num -= 1
        return oldValue
    }
    
    /// increase the value by one
    ///
    /// - Parameter num: value to increase
    static prefix func ++(_ num: inout Int16) -> Int16 {
        num += 1
        return num
    }
    
    /// increase the value by one
    ///
    /// - Parameter num: value to increase
    static postfix func ++(_ num: inout Int16) -> Int16 {
        let oldValue = num
        num += 1
        return oldValue
    }
}
