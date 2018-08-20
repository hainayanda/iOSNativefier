//
//  ImageNativefier.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 19/08/18.
//

import Foundation
import UIKit

public class ImageNativefier : Nativefier<UIImage> {
    
    init(maxRamCount : Int, maxDiskCount : Int) {
        super.init(maxRamCount: maxRamCount, maxDiskCount: maxDiskCount, containerName: "image", serializer: ImageSerializer())
    }
    
    init(maxCount: Int) {
        super.init(maxRamCount: maxCount/2, maxDiskCount: maxCount, containerName: "image", serializer: ImageSerializer())
    }
    
}
