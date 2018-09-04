//
//  ObjectNativefierBuilder.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 19/08/18.
//

import Foundation

public class ObjectNativefierBuilder<T : AnyObject> {
    fileprivate var maxRamCount : Int?
    fileprivate var maxDiskCount : Int?
    fileprivate var containerName : String?
    fileprivate var serializer : NativefierSerializerProtocol?
    fileprivate var fetcher : ((_ key: String) -> T?)?
    fileprivate var delegate : NativefierDelegate?
    fileprivate var maxRetryCount : Int?
    init() {}
    
    public func set(maxRetryCount : Int) -> ObjectNativefierBuilder<T>{
        self.maxRetryCount = maxRetryCount
        return self
    }
    
    public func set(delegate : NativefierDelegate) -> ObjectNativefierBuilder<T>{
        self.delegate = delegate
        return self
    }
    
    public func set(fetcher : @escaping (_ key: String) -> T?) -> ObjectNativefierBuilder<T>{
        self.fetcher = fetcher
        return self
    }
    
    public func set(maxRamCount : Int) -> ObjectNativefierBuilder<T>{
        self.maxRamCount = maxRamCount
        return self
    }
    
    public func set(maxDiskCount : Int) -> ObjectNativefierBuilder<T>{
        self.maxDiskCount = maxDiskCount
        if maxRamCount == nil {
            maxRamCount = maxDiskCount / 2
        }
        return self
    }
    
    public func set(containerName : String) -> ObjectNativefierBuilder<T>{
        self.containerName = containerName
        return self
    }
    
    public func set(serializer : NativefierSerializerProtocol) -> ObjectNativefierBuilder<T> {
        self.serializer = serializer
        return self
    }
    
    public func build() -> Nativefier<T> {
        let nativefier : Nativefier<T> = Nativefier<T>.init(maxRamCount: maxRamCount!, maxDiskCount: maxDiskCount!, containerName: containerName!, serializer: serializer!)
        nativefier.fetcher = self.fetcher
        nativefier.delegate = self.delegate
        nativefier.maxRetryCount = self.maxRetryCount ?? 1
        return nativefier
    }
}
