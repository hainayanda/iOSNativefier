//
//  NativefierDelegate.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 18/08/18.
//

import Foundation

@objc public protocol NativefierDelegate {
    @objc optional func nativefier(_ nativefier : Any , onFailedFecthFor key: String) -> Any?
    @objc optional func nativefier(_ nativefier : Any, memoryWillRemove singleObject: Any, for key: String)
    @objc optional func nativefierWillClearMemory(_ nativefier : Any)
    @objc optional func nativefier(_ nativefier : Any, diskWillRemove singleObject: Any, for key: String)
    @objc optional func nativefierWillClearDisk(_ nativefier : Any)
}
