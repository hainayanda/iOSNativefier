//
//  File.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 18/08/18.
//

import Foundation

class DiskManager<T : AnyObject> {
    
    fileprivate let maxCount : Int
    fileprivate let diskPath : String
    fileprivate let indexUrl : URL
    fileprivate let serializer : NativefierSerializerProtocol
    fileprivate let fileManager : FileManager
    fileprivate var index : SynchronizedArray<String> = SynchronizedArray()
    fileprivate var pendingWrite : [String : T] = [:]
    fileprivate var pendingRemove : SynchronizedArray<String> = SynchronizedArray()
    var willRemoveClosure : ((T) -> Void)?
    var willClearClosure : (()->Void)?
    
    init(maxCount : Int, containerName : String, serializer : NativefierSerializerProtocol) {
        self.maxCount = maxCount
        self.serializer = serializer
        self.fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let cacheDirectory = paths[0] as NSString
        self.diskPath = cacheDirectory.appendingPathComponent(containerName)
        let indexPath = (diskPath as NSString).appendingPathComponent("index.dat")
        self.indexUrl = URL(fileURLWithPath: indexPath)
        if !isDirectoryExist(path: diskPath) {
            do {
                try createDirectory(path: diskPath)
            }
            catch{
                print("Nativefier ERROR : Failed to create directory at \(diskPath) for \(containerName)")
            }
        }
        if !isFileExist(fileName: "index.dat") {
            createEmptyFile(fileName: "index.dat")
        }
        else {
            do {
                try index = readFileAsArrayOfString(fileName: "index.dat")
            }
            catch{
                print("Nativefier ERROR : Failed to read index for \(containerName)")
            }
        }
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
        let fileName = key + ".ch"
        if(!isExist(key: key)) {
            return nil
        }
        if(isFileExist(fileName: fileName)){
            do{
                let data = try readFile(fileName: fileName)
                let obj = serializer.deserialize(data: data)
                if let result : T = obj as? T{
                    addToIndex(key: key)
                    return result
                }
                else{
                    return nil
                }
            }
            catch{
                return nil
            }
        }
        else if let obj : T = pendingWrite[key] {
            return obj
        }
        else {
            return nil
        }
    }
    
    func put(key: String, obj : T){
        if let _ : Data = serializer.serialize(obj: obj){
            addToIndex(key: key)
            pendingWrite.removeValue(forKey: key)
            pendingWrite[key] = obj
            asyncWrite()
        }
        
    }
    
    func remove(forKey key: String){
        pendingWrite.removeValue(forKey: key)
        pendingRemove.append(key)
        asyncRemove()
    }
    
    func clear(){
        willClearClosure?()
        index.removeAll()
        for key in index {
            pendingWrite.removeValue(forKey: key)
            pendingRemove.append(key)
        }
        asyncRemove()
        updateIndex()
    }
    
    fileprivate var isRemoving = false
    fileprivate func asyncRemove(){
        if(isRemoving) { return }
        isRemoving = true
        DispatchQueue.global(qos: .background).async {
            while(self.pendingRemove.count > 0){
                let pending = self.pendingRemove
                self.pendingRemove.removeAll()
                for key in pending {
                    let fileName = key + ".ch"
                    do{
                        try self.deleteFile(fileName: fileName)
                    }
                    catch {}
                }
                self.isRemoving = false
            }
        }
    }
    
    fileprivate var isWriting = false
    fileprivate func asyncWrite(){
        if(isWriting) { return }
        isWriting = true
        DispatchQueue.global(qos: .background).async{
            while(self.pendingWrite.count > 0){
                let pending = self.pendingWrite
                self.pendingWrite.removeAll()
                for biConsumer in pending {
                    let fileName = biConsumer.key + ".ch"
                    do{
                        if self.isFileExist(fileName: fileName){
                            try self.deleteFile(fileName: fileName)
                        }
                        if let data : Data = self.serializer.serialize(obj: biConsumer.value) {
                            self.createFile(fileName: fileName, data: data)
                        }
                    }
                    catch{}
                }
            }
            self.isWriting = false
        }
    }
    
    fileprivate var isUpdating = false
    fileprivate func updateIndex(){
        if isUpdating { return }
        isUpdating = true
        let data = self.index.count > 0 ? self.index.joined(separator: "\n") : ""
        DispatchQueue.global(qos: .background).async {
            do{
                try data.write(to: self.indexUrl, atomically: true, encoding: .utf8)
            }
            catch{}
            self.isUpdating = false
        }
    }
    
    func isExist(key: String) -> Bool {
        return index.contains(key)
    }
    
    fileprivate func addToIndex(key: String){
        removeFromIndex(key: key)
        index.append(key)
        while index.count > maxCount {
            index.removeFirst()
        }
        updateIndex()
    }
    
    fileprivate func removeFromIndex(key : String){
        if(isExist(key: key)){
            if let i : Int = index.index(of: key){
                index.remove(at: i)
            }
        }
    }
    
    fileprivate func removeFromIndexAndUpdate(key : String){
        if(isExist(key: key)){
            if let i : Int = index.index(of: key){
                index.remove(at: i)
                updateIndex()
            }
        }
    }
    
    fileprivate func isDirectoryExist(path: String) -> Bool{
        var isDirectory : ObjCBool = false
        let isExist = fileManager.fileExists(atPath: diskPath, isDirectory: &isDirectory)
        return isDirectory.boolValue && isExist
    }
    
    fileprivate func isFileExist(fileName: String) -> Bool {
        let path = (diskPath as NSString).appendingPathComponent(fileName)
        var isDirectory : ObjCBool = false
        let isExist = fileManager.fileExists(atPath: path, isDirectory: &isDirectory)
        return !isDirectory.boolValue && isExist
    }
    
    fileprivate func createDirectory(path : String) throws {
        let url = URL(fileURLWithPath: path)
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }
    
    fileprivate func createEmptyFile(fileName : String) {
        let path = (diskPath as NSString).appendingPathComponent(fileName)
        fileManager.createFile(atPath: path, contents: nil, attributes: nil)
    }
    
    fileprivate func createFile(fileName : String, data : Data) {
        let path = (diskPath as NSString).appendingPathComponent(fileName)
        fileManager.createFile(atPath: path, contents: data, attributes: nil)
    }
    
    fileprivate func deleteFile(fileName : String) throws {
        let path = (diskPath as NSString).appendingPathComponent(fileName)
        let url = URL(fileURLWithPath: path)
        if let action: ((T) -> Void) = willRemoveClosure {
            do {
                let data = try Data.init(contentsOf: url)
                if let obj : T = serializer.deserialize(data: data) as? T {
                    action(obj)
                }
            }
            catch{}
        }
        try fileManager.removeItem(at: url)
    }
    
    fileprivate func readFile(fileName: String) throws -> Data{
        let path = (diskPath as NSString).appendingPathComponent(fileName)
        let url = URL(fileURLWithPath: path)
        return try Data.init(contentsOf: url)
    }
    
    fileprivate func readFileAsString(fileName: String) throws -> String{
        let path = (diskPath as NSString).appendingPathComponent(fileName)
        let url = URL(fileURLWithPath: path)
        return try String.init(contentsOf: url)
    }
    
    fileprivate func readFileAsArrayOfString(fileName: String) throws -> SynchronizedArray<String> {
        let data = try readFileAsString(fileName: fileName)
        return SynchronizedArray.init(array: data.components(separatedBy: .newlines))
    }
    
}
