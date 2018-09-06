// https://github.com/Quick/Quick

import Quick
import Nimble
import Nativefier
import HandyJSON

var myObjectNativefier : HandyJSONNativefier<MyObject> = NativefierBuilder.getForHandyJSON().set(containerName: "test").set(fetcher: { (key) -> MyObject in
    return objectCreator(string: "fetched", number: 5)
})
    .set(maxRamCount: 2).set(maxDiskCount: 4).build()

class SubObject : HandyJSON, Equatable {
    static func == (lhs: SubObject, rhs: SubObject) -> Bool {
        return lhs.number == rhs.number && lhs.string == lhs.string
    }
    
    required init() {
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
    
    override func tearDown() {
        super.tearDown()
        myObjectNativefier.clear()
    }
    
    override func spec() {
        describe("positive test"){
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
                Thread.sleep(until: Date(timeIntervalSinceNow: 0.5))
                n = 4
                while(n > 0){
                    let obj = myObjectNativefier["\(n)"]
                    if let obj : MyObject = obj {
                        expect(created.contains(obj)) == true
                    }
                    else {
                        print("Failed when get object \(n)")
                        fail()
                    }
                    n -= 1
                }
                myObjectNativefier.clear()
            }
            it("will remove obj if full"){
                var n = 5
                while(n > 0){
                    let obj = objectCreator(string: "\(n)", number: n)
                    myObjectNativefier["\(n)"] = obj
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
        describe("negative test"){
            it("cannot stored object more than it should be"){
                var n = 5
                while(n > 0){
                    let obj = objectCreator(string: "\(n)", number: n)
                    myObjectNativefier["\(n)"] = obj
                    n -= 1
                }
                let obj = myObjectNativefier["5"]
                expect(obj == nil) == true
                myObjectNativefier.clear()
            }
        }
        describe("async test"){
            it("can do async"){
                var created : [MyObject] = []
                var n = 4
                while(n > 0){
                    let obj = objectCreator(string: "\(n)", number: n)
                    myObjectNativefier["\(n)"] = obj
                    created.append(obj)
                    n -= 1
                }
                Thread.sleep(until: Date(timeIntervalSinceNow: 0.5))
                n = 4
                var completionsRun = [0, 0, 0, 0]
                var success = false
                while(n > 0){
                    var m = 5
                    while(m > 0){
                        let i = n - 1
                        myObjectNativefier.asyncGet(forKey: "\(n)", onComplete: { (obj) in
                            completionsRun[i] += 1
                            if let obj : MyObject = obj {
                                success = created.contains(obj)
                            }
                            else {
                                success = false
                                print("Failed when get object \(n)")
                                fail()
                            }
                        })
                        m -= 1
                    }
                    n -= 1
                }
                Thread.sleep(until: Date(timeIntervalSinceNow: 2))
                expect(success) == true
                expect(completionsRun[0]) == 5
                expect(completionsRun[1]) == 5
                expect(completionsRun[2]) == 5
                expect(completionsRun[3]) == 5
                myObjectNativefier.clear()
            }
        }
    }
}
