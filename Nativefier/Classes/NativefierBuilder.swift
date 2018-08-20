//
//  NativefierBuilder.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 19/08/18.
//

import Foundation
import HandyJSON

public class NativefierBuilder {
    
    public static func getForAnyObject<T : AnyObject>() -> ObjectNativefierBuilder<T>{
        return ObjectNativefierBuilder<T>()
    }
    
    public static func getForImage() -> ImageNativefierBuilder {
        return ImageNativefierBuilder()
    }
    
    public static func getForHandyJSON<T>() -> HandyJSONNativefierBuilder<T> where T : HandyJSON, T : AnyObject{
        return HandyJSONNativefierBuilder<T>()
    }
    
}
