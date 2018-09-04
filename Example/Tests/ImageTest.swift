//
//  ImageTest.swift
//  Nativefier_Tests
//
//  Created by Nayanda Haberty on 23/08/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import Nativefier
import Quick
import Nimble

var imageNativefier : ImageNativefier = NativefierBuilder.getForImage().set(maxDiskCount: 4).set(maxRamCount: 2).set(fetcher: { _ -> UIImage in
    return imageCreator(with : 5)
}).build()

func imageCreator(with n: Int) -> UIImage {
    return UIImage.init(color: UIColor.init(red: CGFloat(255/n), green: CGFloat(255/n), blue: CGFloat(255/n), alpha: CGFloat(1/n)), size: CGSize(width: n, height: n))!
}

class ImageNativefierSpec : QuickSpec {
    
    override func tearDown() {
        super.tearDown()
        imageNativefier.clear()
    }
    
    override func spec() {
        describe("positive test"){
            it("can store"){
                let created = UIImage.init(color: UIColor.white, size: CGSize(width: 10, height: 10))
                imageNativefier["one"] = created
                let stored = imageNativefier["one"]
                expect(stored == created) == true
                imageNativefier.clear()
            }
            it("can store multiple item"){
                var created : [UIImage] = []
                var n = 4
                while(n > 0){
                    let obj = imageCreator(with: n)
                    imageNativefier["\(n)"] = obj
                    created.append(obj)
                    n -= 1
                }
                Thread.sleep(until: Date(timeIntervalSinceNow: 0.5))
                n = 4
                while(n > 0){
                    let obj = imageNativefier["\(n)"]
                    expect(obj != nil) == true
                    n -= 1
                }
                imageNativefier.clear()
            }
            it("will remove obj if full"){
                var n = 5
                while(n > 0){
                    let obj = imageCreator(with: n)
                    imageNativefier["\(n)"] = obj
                    n -= 1
                }
                let obj = imageNativefier["5"]
                expect(obj == nil) == true
                imageNativefier.clear()
            }
            it("will fetch if not found"){
                var n = 5
                while(n > 0){
                    let obj = imageCreator(with: n)
                    imageNativefier["\(n)"] = obj
                    n -= 1
                }
                let obj = imageNativefier.getOrFetch(forKey: "5")
                let shouldLike = imageCreator(with: 5)
                expect(obj?.size) == shouldLike.size
                imageNativefier.clear()
            }
        }
        describe("negative test"){
            it("cannot stored object more than it should be"){
                var n = 5
                while(n > 0){
                    let obj = imageCreator(with: 5)
                    imageNativefier["\(n)"] = obj
                    n -= 1
                }
                let obj = imageNativefier["5"]
                expect(obj == nil) == true
                imageNativefier.clear()
            }
        }
    }
}
