//
//  Util.swift
//  Nativefier_Tests
//
//  Created by Nayanda Haberty on 20/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

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
