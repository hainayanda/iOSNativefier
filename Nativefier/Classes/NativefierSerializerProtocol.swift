//
//  NativefierSerializerProtocol.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 18/08/18.
//

import Foundation

public protocol NativefierSerializerProtocol{
    
    func serialize(obj : AnyObject) -> Data?
    func deserialize(data : Data) -> AnyObject?
    
}
