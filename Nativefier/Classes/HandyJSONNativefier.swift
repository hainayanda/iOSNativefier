//
//  ObjectNativefierBuilder.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 19/08/18.
//

import Foundation
import HandyJSON

public class HandyJSONNativefier<T> : Nativefier<T> where T : AnyObject, T : HandyJSON {
    
    init(maxRamCount : Int, maxDiskCount : Int, containerName: String) {
        super.init(maxRamCount: maxRamCount, maxDiskCount: maxDiskCount, containerName: containerName, serializer: HandyJSONSerializer<T>())
    }
    
    init(maxCount: Int, containerName: String) {
        super.init(maxRamCount: maxCount/2, maxDiskCount: maxCount, containerName: containerName, serializer: HandyJSONSerializer<T>())
    }
    
}
