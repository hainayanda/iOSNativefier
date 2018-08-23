// https://github.com/Quick/Quick

import Quick
import Nimble
import Nativefier
import HandyJSON

var myObjectNativefier : HandyJSONNativefier<MyObject> = NativefierBuilder.getForHandyJSON().set(containerName: "myObject").set(fetcher: { (key) -> MyObject in
    return objectCreator(string: "fetched", number: 5)
})
.set(maxRamCount: 2).set(maxDiskCount: 4).build()

extension Array where Element : Equatable {
    
    static func == (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
        if lhs.count != rhs.count {
            return false
        }
        for member in lhs {
            if !rhs.contains(member){
                return false
            }
        }
        return true
    }
    
    static func == (lhs: Array<Element>?, rhs: Array<Element>) -> Bool {
        if let lhs : Array<Element> = lhs {
            return lhs == rhs
        }
        return false
    }
    
    static func == (lhs: Array<Element>, rhs: Array<Element>?) -> Bool {
        if let rhs : Array<Element> = rhs {
            return lhs == rhs
        }
        return false
    }
}

func == <T : Equatable>(lhs: Array<T>?, rhs: Array<T>?) -> Bool {
    if let lhs : Array<T> = lhs, let rhs : Array<T> = rhs {
        return lhs == rhs
    }
    if lhs == nil && rhs == nil {
        return true
    }
    return false
}

class SubObject : Equatable {
    static func == (lhs: SubObject, rhs: SubObject) -> Bool {
        return lhs.number == rhs.number && lhs.string == lhs.string
    }
    
    var string : String?
    var number : Int?
}

class MyObject : HandyJSON, Equatable {
    static func == (lhs: MyObject, rhs: MyObject) -> Bool {
        return lhs.bool == rhs.bool && rhs.number == lhs.number && rhs.string == lhs.string && rhs.obj == lhs.obj && lhs.arrInt == rhs.arrInt && lhs.arrObj == rhs.arrObj && lhs.arrStr == rhs.arrStr
    }
    
    required init() {
    }
    
    var string : String?
    var number : Int?
    var bool : Bool?
    var obj : SubObject?
    var arrStr : [String]?
    var arrInt : [Int]?
    var arrObj : [SubObject]?
}

func objectCreator(string : String, number : Int) -> MyObject{
    let myObject = MyObject()
    let objSub = SubObject()
    objSub.string = "\(string)\(number)"
    objSub.number = number
    
    myObject.string = "obj\(number)"
    myObject.number = number
    myObject.bool = number % 2 == 0
    myObject.obj = objSub
    
    var n = number
    myObject.arrStr = []
    myObject.arrInt = []
    myObject.arrObj = []
    while(n > 0) {
        let sub = SubObject()
        sub.string = "\(string)\(n)"
        sub.number = n
        myObject.arrObj?.append(sub)
        myObject.arrStr?.append("arr\(n)")
        myObject.arrInt?.append(n)
        n -= 1
    }
    return myObject
}

class MyObjectNativefierSpec : QuickSpec {
    override func setUp() {
        myObjectNativefier = NativefierBuilder.getForHandyJSON().set(containerName: "myObject").set(fetcher: { (key) -> MyObject in
            return objectCreator(string: "fetched", number: 5)
        })
        .set(maxRamCount: 2)
        .set(maxDiskCount: 4)
        .build()
    }
    
    override func spec() {
        describe("should pass"){
            it("can store"){
                let created = objectCreator(string: "one", number: 1)
                myObjectNativefier["one"] = created
                let stored = myObjectNativefier["one"]
                expect(stored == created) == true
                myObjectNativefier.clear()
            }
            it("can store multiple item"){
                var created : [MyObject] = []
                var n = 4
                while(n > 0){
                    let obj = objectCreator(string: "\(n)", number: n)
                    myObjectNativefier["\(n)"] = obj
                    created.append(obj)
                    n -= 1
                }
                n = 4
                while(n > 0){
                    n -= 1
                    let obj = myObjectNativefier["\(n)"]
                    expect(obj != nil) == true
                    expect(created.contains(obj!)) == true
                }
                myObjectNativefier.clear()
            }
            it("will remove obj if full"){
                var created : [MyObject] = []
                var n = 5
                while(n > 0){
                    let obj = objectCreator(string: "\(n)", number: n)
                    myObjectNativefier["\(n)"] = obj
                    created.append(obj)
                    n -= 1
                }
                let obj = myObjectNativefier["5"]
                expect(obj == nil) == true
                myObjectNativefier.clear()
            }
            it("will fetch if not found"){
                var n = 5
                while(n > 0){
                    let obj = objectCreator(string: "\(n)", number: n)
                    myObjectNativefier["\(n)"] = obj
                    n -= 1
                }
                let obj = myObjectNativefier.getOrFetch(forKey: "5")
                let shouldLike = objectCreator(string: "fetched", number: 5)
                expect(obj) == shouldLike
                myObjectNativefier.clear()
            }
        }
        describe("should fail"){
            it("cannot stored object more than it should be"){
                var n = 5
                while(n > 0){
                    let obj = objectCreator(string: "\(n)", number: n)
                    myObjectNativefier["\(n)"] = obj
                    n -= 1
                }
                let obj = myObjectNativefier["5"]
                expect(obj) == objectCreator(string: "5", number: 5)
                expect(obj == nil) == false
                myObjectNativefier.clear()
            }
            it("will fetch if not found"){
                var n = 5
                while(n > 0){
                    let obj = objectCreator(string: "\(n)", number: n)
                    myObjectNativefier["\(n)"] = obj
                    n -= 1
                }
                let obj = myObjectNativefier.getOrFetch(forKey: "5")
                expect(obj) == nil
                myObjectNativefier.clear()
            }
        }
    }
}
