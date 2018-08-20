//
//  ImageSerializer.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 18/08/18.
//

import Foundation
import UIKit

public class ImageSerializer : NativefierSerializerProtocol {
    public func serialize(obj: AnyObject) -> Data? {
        if let img : UIImage = obj as? UIImage {
            return UIImagePNGRepresentation(img)
        }
        return nil
    }
    
    public func deserialize(data: Data) -> AnyObject? {
        return UIImage(data: data)
    }
}
