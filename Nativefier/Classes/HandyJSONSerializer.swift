//
//  HandyJSONSerializer.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 18/08/18.
//

import Foundation
import HandyJSON

public class HandyJSONSerializer<T> : NativefierSerializerProtocol where T : AnyObject, T : HandyJSON {
    public func serialize(obj: AnyObject) -> Data? {
        if let obj : T = obj as? T{
            if let str : String = obj.toJSONString(){
                return str.data(using: .utf8)
            }
        }
        return nil
    }
    
    public func deserialize(data: Data) -> AnyObject? {
        let str = String.init(data: data, encoding: .utf8)
        if let obj : T = T.deserialize(from: str) {
            return obj as AnyObject
        }
        return nil
    }
    
}
