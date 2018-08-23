//
//  CustomSerializerTest.swift
//  Nativefier_Tests
//
//  Created by Nayanda Haberty on 20/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Nativefier
import Quick
import Nimble

var myStringNativefier : Nativefier<StringContainer> = NativefierBuilder.getForAnyObject().set(containerName: "string").set(maxRamCount: 2).set(maxDiskCount: 4).set(serializer: StringContainerSerializer()).set(fetcher: { key -> StringContainer in
    return StringContainer("its fetched")
}).build()

class StringContainer : Equatable {
    static func == (lhs: StringContainer, rhs: StringContainer) -> Bool {
        return lhs.value == rhs.value
    }
    
    
    var value : String
    
    init(_ value : String){
        self.value = value
    }
}

class StringContainerSerializer : NativefierSerializerProtocol {
    func serialize(obj: AnyObject) -> Data? {
        if let obj : StringContainer = obj as? StringContainer {
            return obj.value.data(using: .utf8)
        }
        return nil
    }
    
    func deserialize(data: Data) -> AnyObject? {
        if let value : String = String(data: data, encoding: .utf8) {
            return StringContainer(value)
        }
        return nil
    }
    
    init() {}
}

class ObjectNativefierSpec : QuickSpec {
    
    override func tearDown() {
        super.tearDown()
        myStringNativefier.clear()
    }
    
    override func spec() {
        describe("positive test"){
            it("can store"){
                let created = StringContainer("one")
                myStringNativefier["one"] = created
                let stored = myStringNativefier["one"]
                expect(stored == created) == true
                myStringNativefier.clear()
            }
            it("can store multiple item"){
                var created : [StringContainer] = []
                var n = 4
                while(n > 0){
                    let obj = StringContainer("\(n)")
                    myStringNativefier["\(n)"] = obj
                    created.append(obj)
                    n -= 1
                }
                n = 4
                while(n > 0){
                    let obj = myStringNativefier["\(n)"]
                    if let obj : StringContainer = obj {
                        expect(created.contains(obj)) == true
                    }
                    else {
                        fail()
                    }
                    n -= 1
                }
                myStringNativefier.clear()
            }
            it("will remove obj if full"){
                var n = 5
                while(n > 0){
                    let obj = StringContainer("\(n)")
                    myStringNativefier["\(n)"] = obj
                    n -= 1
                }
                let obj = myStringNativefier["5"]
                expect(obj == nil) == true
                myStringNativefier.clear()
            }
            it("will fetch if not found"){
                var n = 5
                while(n > 0){
                    let obj = StringContainer("\(n)")
                    myStringNativefier["\(n)"] = obj
                    n -= 1
                }
                let obj = myStringNativefier.getOrFetch(forKey: "5")
                expect(obj?.value) == "its fetched"
                myStringNativefier.clear()
            }
        }
        describe("negative test"){
            it("cannot stored object more than it should be"){
                var n = 5
                while(n > 0){
                    let obj = StringContainer("\(n)")
                    myStringNativefier["\(n)"] = obj
                    n -= 1
                }
                let obj = myStringNativefier["5"]
                expect(obj == nil) == true
                myStringNativefier.clear()
            }
        }
    }
}
