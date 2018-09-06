//
//  SynchronizedArray.swift
//  Nativefier
//
//  Copied from http://basememara.com/creating-thread-safe-arrays-in-swift/
//  Created by Nayanda Haberty on 18/08/18.
//

import Foundation

open class SynchronizedArray<T> : Sequence {
    
    
    fileprivate let queue = DispatchQueue(label: "nativefier.synchronized", attributes: .concurrent)
    fileprivate var array : [T] = []
    
    public init() {
    }
    
    public init(array: [T]) {
        self.array = array
    }
    
    public subscript(index: Int) -> T? {
        get {
            var result: T?
            queue.sync {
                guard self.array.startIndex..<self.array.endIndex ~= index else { return }
                result = self.array[index]
            }
            return result
        }
        set {
            guard let newValue = newValue else { return }
            queue.async(flags: .barrier) {
                self.array[index] = newValue
            }
        }
    }
    
    public var first: T? {
        var result: T?
        queue.sync { result = self.array.first }
        return result
    }
    
    public var last: T? {
        var result: T?
        queue.sync { result = self.array.last }
        return result
    }
    
    public var count: Int {
        var result = 0
        queue.sync { result = self.array.count }
        return result
    }
    
    public var isEmpty: Bool {
        var result = false
        queue.sync { result = self.array.isEmpty }
        return result
    }
    
    public var description: String {
        var result = ""
        queue.sync { result = self.array.description }
        return result
    }
    
    public func makeIterator() -> SynchronizedArray<T>.Iterator {
        return SynchronizedArray<T>.Iterator.init(self)
    }
    
    public func first(where predicate: (T) -> Bool) -> T? {
        var result: T?
        queue.sync { result = self.array.first(where: predicate) }
        return result
    }
    
    public func filter(_ isIncluded: (T) -> Bool) -> [T] {
        var result = [T]()
        queue.sync { result = self.array.filter(isIncluded) }
        return result
    }
    
    public func index(where predicate: (T) -> Bool) -> Int? {
        var result: Int?
        queue.sync { result = self.array.index(where: predicate) }
        return result
    }
    
    public func sorted(by areInIncreasingOrder: (T, T) -> Bool) -> [T] {
        var result = [T]()
        queue.sync { result = self.array.sorted(by: areInIncreasingOrder) }
        return result
    }
    
    public func flatMap<TOfResult>(_ transform: (T) -> TOfResult?) -> [TOfResult] {
        var result = [TOfResult]()
        queue.sync { result = self.array.compactMap(transform) }
        return result
    }
    
    public func forEach(_ body: (T) -> Void) {
        queue.sync { self.array.forEach(body) }
    }
    
    public func contains(where predicate: (T) -> Bool) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(where: predicate) }
        return result
    }
    
    public func append( _ element: T) {
        queue.async(flags: .barrier) {
            self.array.append(element)
        }
    }
    
    public func append( _ elements: [T]) {
        queue.async(flags: .barrier) {
            self.array += elements
        }
    }
    
    public func insert( _ element: T, at index: Int) {
        queue.async(flags: .barrier) {
            if self.array.count > index {
                self.array.insert(element, at: index)
            }
            else {
                self.array.append(element)
            }
        }
    }
    
    public func remove(at index: Int, completion: ((T) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            if self.array.count > index {
                let element = self.array.remove(at: index)
                DispatchQueue.main.async {
                    completion?(element)
                }
            }
        }
    }
    
    public func remove(where predicate: @escaping (T) -> Bool, completion: ((T) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            guard let index = self.array.index(where: predicate) else { return }
            let element = self.array.remove(at: index)
            
            DispatchQueue.main.async {
                completion?(element)
            }
        }
    }
    
    public func removeLast() {
        queue.async(flags: .barrier) {
            guard self.array.isEmpty else {
                self.array.removeLast()
                return
            }
        }
    }
    
    public func removeFirst() {
        queue.async(flags: .barrier) {
            guard self.array.isEmpty else {
                self.array.removeFirst()
                return
            }
        }
    }
    
    public func removeAll(completion: (([T]) -> Void)? = nil) {
        queue.async(flags: .barrier) {
            let elements = self.array
            self.array.removeAll()
            
            DispatchQueue.main.async {
                completion?(elements)
            }
        }
    }
    
    public static func +=(left: inout SynchronizedArray, right: T) {
        left.append(right)
    }
    
    public static func +=(left: inout SynchronizedArray, right: [T]) {
        left.append(right)
    }
    
    open class Iterator : IteratorProtocol {
        public typealias Element = T
        
        fileprivate var array : SynchronizedArray<T>
        fileprivate var index = 0
        
        init(_ arr : SynchronizedArray<T>) {
            self.array = arr
        }
        
        public func next() -> T? {
            let element = array.count > index ? array[index] : nil
            index += 1
            return element
        }
    }
    
}

public extension SynchronizedArray where T: Equatable {
    
    public func index(of element: T) -> Int? {
        var result: Int?
        queue.sync { result = self.array.index(of: element) }
        return result
    }
    
    public func contains(_ element: T) -> Bool {
        var result = false
        queue.sync { result = self.array.contains(element) }
        return result
    }
}
