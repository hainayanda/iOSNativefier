//
//  MemoryManager.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 18/08/18.
//

import Foundation

class MemoryManager<T : AnyObject> : NSObject, NSCacheDelegate {
    
    fileprivate let memoryCache : NSCache<NSString, T>
    var _willRemoveClosure : ((T) -> Void)?
    var willRemoveClosure : ((T) -> Void)? {
        get {
            return _willRemoveClosure
        }
        set {
            _willRemoveClosure = newValue
            if willRemoveClosure != nil {
                memoryCache.delegate = self
            }
            else {
                memoryCache.delegate = nil
            }
        }
    }
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
        if let action: ((T) -> Void) = willRemoveClosure, let obj : T = get(forKey: key) {
            action(obj)
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
    
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if let action : (T) -> Void = willRemoveClosure, let obj : T = obj as? T {
            action(obj)
        }
    }
    
}
