//
//  Util.swift
//  Nativefier_Tests
//
//  Created by Nayanda Haberty on 20/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {
    
    static func == (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
        if lhs.count != rhs.count {
            return false
        }
        for member in lhs {
            if !rhs.contains(member){
                return false
            }
        }
        return true
    }
    
    static func == (lhs: Array<Element>?, rhs: Array<Element>) -> Bool {
        if let lhs : Array<Element> = lhs {
            return lhs == rhs
        }
        return false
    }
    
    static func == (lhs: Array<Element>, rhs: Array<Element>?) -> Bool {
        if let rhs : Array<Element> = rhs {
            return lhs == rhs
        }
        return false
    }
}

func == <T : Equatable>(lhs: Array<T>?, rhs: Array<T>?) -> Bool {
    if let lhs : Array<T> = lhs, let rhs : Array<T> = rhs {
        return lhs == rhs
    }
    if lhs == nil && rhs == nil {
        return true
    }
    return false
}
