//
//  MemoryManager.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 18/08/18.
//

import Foundation

class MemoryManager<T : AnyObject> {
    
    fileprivate let memoryCache : NSCache<NSString, T>
    var willRemoveClosure : ((String, T) -> Void)?
    var willClearClosure : (()->Void)?
    init(maxCount : Int) {
        memoryCache = NSCache<NSString, T>()
        memoryCache.countLimit = maxCount
    }
    
    subscript(key : String) -> T? {
        get{
            return get(forKey: key)
        }
        set{
            if let newValue : T = newValue {
                put(key: key, obj: newValue)
            }
        }
    }
    
    func get(forKey key: String) -> T? {
        return memoryCache.object(forKey: key as NSString)
    }
    
    func put(key: String, obj : T){
        memoryCache.setObject(obj, forKey: key as NSString)
    }
    
    func remove(forKey key: String){
        if let action: ((String, T) -> Void) = willRemoveClosure, isExist(key: key), let obj : T = get(forKey: key) {
            action(key, obj)
        }
        memoryCache.removeObject(forKey: key as NSString)
    }
    
    func clear(){
        if let action : (()->Void) = willClearClosure {
            action()
        }
        memoryCache.removeAllObjects()
    }
    
    func isExist(key: String) -> Bool {
        return memoryCache.object(forKey: key as NSString) != nil
    }
    
}
