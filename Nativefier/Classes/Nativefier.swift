//
//  Nativefier.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 18/08/18.
//

import Foundation

public class Nativefier<T : AnyObject> : NSObject {
    
    fileprivate let memoryManager : MemoryManager<T>
    fileprivate let diskManager : DiskManager<T>
    public var fetcher : ((_ key: String) -> T?)?
    fileprivate var _delegate : NativefierDelegate?
    public var delegate : NativefierDelegate? {
        get {
            return _delegate
        }
        set {
            _delegate = newValue
            guard let _ : NativefierDelegate = _delegate else {
                memoryManager.willClearClosure = nil
                memoryManager.willRemoveClosure = nil
                diskManager.willClearClosure = nil
                diskManager.willRemoveClosure = nil
                return
            }
            memoryManager.willClearClosure = { self.delegate?.nativefierWillClearMemory?(self) }
            memoryManager.willRemoveClosure = { obj in self.delegate?.nativefier?(self, memoryWillRemove: obj)}
            diskManager.willClearClosure = { self.delegate?.nativefierWillClearDisk?(self) }
            diskManager.willRemoveClosure = { obj in self.delegate?.nativefier?(self, diskWillRemove: obj)}
        }
    }
    
    init(maxRamCount : Int, maxDiskCount : Int, containerName : String, serializer : NativefierSerializerProtocol) {
        self.memoryManager = MemoryManager(maxCount: maxRamCount)
        self.diskManager = DiskManager(maxCount: maxDiskCount, containerName: containerName, serializer: serializer)
    }
    
    init(maxCount : Int, containerName : String, serializer : NativefierSerializerProtocol) {
        self.memoryManager = MemoryManager(maxCount: maxCount / 2)
        self.diskManager = DiskManager(maxCount: maxCount, containerName: containerName, serializer: serializer)
    }
    
    public subscript(key : String) -> T? {
        get{
            return get(forKey: key)
        }
        set{
            if let newValue : T = newValue {
                put(key: key, obj: newValue)
            }
        }
    }
    
    public func get(forKey key: String) -> T? {
        if memoryManager.isExist(key: key), let obj : T = memoryManager[key]{
            return obj
        }
        else if diskManager.isExist(key: key), let obj : T = diskManager[key] {
            memoryManager[key] = obj
            return obj
        }
        else {
            return nil
        }
    }
    
    public func getOrFetch(forKey key : String) -> T? {
        if let obj : T = get(forKey: key) {
            return obj
        }
        if fetcher != nil {
            if let obj : T = fetcher!(key){
                memoryManager[key] = obj
                diskManager[key] = obj
                return obj
            }
            else if let obj : T = delegate?.nativefier?(self, onFailedFecthFor: key) as? T {
                return obj
            }
            else {
                return nil
            }
        }
        return nil
    }
    
    public func asyncGet(forKey key: String, onComplete : @escaping (T?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let obj = self.getOrFetch(forKey: key)
            onComplete(obj)
        }
    }
    
    public func put(key: String, obj : T){
        memoryManager[key] = obj
        diskManager[key] = obj
    }
    
    public func remove(forKey key: String){
        memoryManager.remove(forKey: key)
        diskManager.remove(forKey: key)
    }
    
    public func clear(){
        memoryManager.clear()
        diskManager.clear()
    }
    
    public func isExist(key: String) -> Bool {
        if memoryManager.isExist(key: key) {
            return true
        }
        return diskManager.isExist(key: key)
    }
    
}
