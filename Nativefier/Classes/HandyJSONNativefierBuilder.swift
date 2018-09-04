//
//  HandyJSONNativefierBuilder.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 19/08/18.
//

import Foundation
import HandyJSON

public class HandyJSONNativefierBuilder<T> where T : AnyObject, T : HandyJSON {
    fileprivate var maxRamCount : Int?
    fileprivate var maxDiskCount : Int?
    fileprivate var containerName : String?
    fileprivate var fetcher : ((_ key: String) -> T?)?
    fileprivate var delegate : NativefierDelegate?
    fileprivate var maxRetryCount : Int?
    init() {}
    
    public func set(maxRetryCount : Int) -> HandyJSONNativefierBuilder<T>{
        self.maxRetryCount = maxRetryCount
        return self
    }
    
    public func set(delegate : NativefierDelegate) -> HandyJSONNativefierBuilder<T>{
        self.delegate = delegate
        return self
    }
    
    public func set(fetcher : @escaping (_ key: String) -> T?) -> HandyJSONNativefierBuilder<T>{
        self.fetcher = fetcher
        return self
    }
    
    public func set(maxRamCount : Int) -> HandyJSONNativefierBuilder<T>{
        self.maxRamCount = maxRamCount
        return self
    }
    
    public func set(maxDiskCount : Int) -> HandyJSONNativefierBuilder<T>{
        self.maxDiskCount = maxDiskCount
        if maxRamCount == nil {
            maxRamCount = maxDiskCount / 2
        }
        return self
    }
    
    public func set(containerName : String) -> HandyJSONNativefierBuilder<T>{
        self.containerName = containerName
        return self
    }
    
    public func build() -> HandyJSONNativefier<T> {
        let nativefier : HandyJSONNativefier<T> = HandyJSONNativefier<T>.init(maxRamCount: maxRamCount!, maxDiskCount: maxDiskCount!, containerName: containerName!)
        nativefier.fetcher = self.fetcher
        nativefier.delegate = self.delegate
        nativefier.maxRetryCount = self.maxRetryCount ?? 1
        return nativefier
    }
}
