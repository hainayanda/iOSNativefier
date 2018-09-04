//
//  NativefierDelegate.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 18/08/18.
//

import Foundation

@objc public protocol NativefierDelegate {
    @objc optional func nativefier(_ nativefier : Any , onFailedFecthFor key: String) -> Any?
    @objc optional func nativefier(_ nativefier : Any , shouldRetryFetchFor key: String) -> Bool
    @objc optional func nativefier(_ nativefier : Any, memoryWillRemove singleObject: Any)
    @objc optional func nativefierWillClearMemory(_ nativefier : Any)
    @objc optional func nativefier(_ nativefier : Any, diskWillRemove singleObject: Any)
    @objc optional func nativefierWillClearDisk(_ nativefier : Any)
}
