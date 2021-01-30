# This Project is Not Maintained and Updated to [Vellum](https://github.com/nayanda1/Vellum)
# iOSNativefier
Cache library for iOS

---
## Changelog
for changelog check [here](CHANGELOG.md)

---
## Features

- [x] Builder pattern
- [x] Default Cache for Image and any HandyJSON object <https://github.com/alibaba/HandyJSON>
- [x] Support synchronous or asynchronous operation
- [x] Delegate when object is about to remove from cache
- [x] Custom fetcher closure to get object if object is not present in the cache
- [x] Dual cache on Disk and Memory
---
## Requirements

- Swift 4.2 or higher

---
## Installation
### CocoaPods
pod 'Nativefier', '~> 0.1.3'

**or just**

pod 'Nativefier'

### Manually
1. Clone this repository.
2. Added to your project.
3. Congratulation!

## About Nativefier
The basic algorithm of nativefier is very simple

### Stored object
1. Object will be stored on memory and then disk asynchronously
2. If memory is already full, the least and oldest accessed object will be removed to give room for the new object
3. If Disk is already full, the least and oldest accessed object will be removed to give room for the new object

### Getting the object
1. It will be return the stored object if the object is already in memory
2. If the object is not present in the memory, it will be search in the disk and will stored the object found in the memory as new object
3. If the object is not found, it will return nil
4. If you're using the getOrFetch method, then it will fetch the object using your custom fetcher if the object is not found anywhere and stored the object from fetcher as new object to memory and disk

## Usage Example
### HandyJSON and Image
Build the object using NativefierBuilder

- containerName is name of cache folder in disk
- maxRamCount is max number of object can stored in memory
- maxDiskCount is max number of object can stored in disk

```swift
//HandyJSON object cache
let handyJSONCache = NativefierBuilder.getForHandyJSON<MyObject>().set(containerName: "myobject").set(maxRamCount: 100).set(maxDiskCount: 200).build()

//Image cache
let imageCache = NativefierBuilder.getForImage().set(maxRamCount: 100).set(maxDiskCount: 200).build()
```

### Any Object
If you prefer custom object you can create your own serializer for your cache

```swift
class MyOwnSerializer : NativefierSerializerProtocol{
    
    func serialize(obj : AnyObject) -> Data? {
        guard let myObject : MyObject = obj as? MyObject else {
            return nil
        }
        //ANY CODE TO CONVERT YOUR OBJECT TO DATA
        return serializedData
    }
    
    func deserialize(data : Data) -> AnyObject? {
        //ANY CODE TO CONVERT DATA TO YOUR OBJECT
        return deserializedObject
    }
    
}
```

And then create your cache

```swift
let myObjectCache = NativefierBuilder.getForAnyObject<MyObject>().set(containerName: "myobject").set(maxRamCount: 100).set(maxDiskCount: 200).set(serializer: MyOwnSerializer()).build()
```

### Create Fetcher
Fetcher is closure that will be executed if the object you want to get is not present in memory or disk. The object returned from the fetcher will be stored in cache

```swift
let myObjectCache = NativefierBuilder.getForAnyObject<MyObject>().set(containerName: "myobject").set(maxRamCount: 100).set(maxDiskCount: 200).set(serializer: MyOwnSerializer())
    .set(fetcher: { key in
        //ANY CODE TO FETCH THE OBJECT USING THE GIVEN KEY
        return fetchedObject
    }).build()
```

Fetch will be considered failed if it's return nil, you can make nativefier automatically retry if fetch is failed on the builder or the object itself

```swift
let myObjectCache = NativefierBuilder.getForAnyObject<MyObject>().set(containerName: "myobject").set(maxRamCount: 100).set(maxDiskCount: 200).set(serializer: MyOwnSerializer())
    .set(fetcher: { key in
        //ANY CODE TO FETCH THE OBJECT USING THE GIVEN KEY
        return fetchedObject
    })
    .set(maxRetryCount: 3) //RETRY 3 TIMES
    .build()

myObjectCache.maxRetryCount = 5 //RETRY 5 TIMES
```

### Using The Nativefier
Using the nativefier is very easy. just use it like you use Dictionary object.
But remember, if you want to using fetcher, its better to do it asynchronously so it wouldn't block your execution if fetch take to long

```swift
let object = myCache["myKey"]
myCache["newKey"] = myNewObject

//Using fetcher if its not found anywhere
let fetchedObject = myCache.getOrFetch(forKey : "myKey")

//Using async, it will automatically using fetcher if the object is not found anywhere and you have fetcher.
myCache.asyncGet(forKey: "myKey", onComplete: { object in
    guad let object : MyObject = object as? MyObject else {
        return
    }
    //DO SOMETHING WITH YOUR OBJECT
})
```

### Using Delegate
If you need to use delegate, you need to implement the delegate and then put it in your cache is it will executed by the cache.
The delegate method you can use is :
- **nativefier(_ nativefier : Any , onFailedFecthFor key: String) -> Any?**

will be executed if fetcher failed to get the object, you can return any default object and it will not stored in the cache
- **nativefier(_ nativefier : Any, memoryWillRemove singleObject: Any)**

will be executed if nativefier is about to remove some object from memory
- **nativefierWillClearMemory(_ nativefier : Any)**

will be executed if nativefier will clear the memory
- **nativefier(_ nativefier : Any, diskWillRemove singleObject: Any)**

will be executed if nativefier is about to remove some object from disk
- **nativefierWillClearDisk(_ nativefier : Any)**

will be executed if nativefier will clear the disk
<br>
<br>
All method are optional, use the one you need

```swift
// on build
let imageCache = NativefierBuilder.getForImage().set(maxRamCount: 100).set(maxDiskCount: 200).set(delegate : self).build()

// or directly to the Nativefier Object
imageCache.delegate = self
```

---
## Contribute
We would love you for the contribution to **iOSNativefier**, just contact me to nayanda1@outlook.com or just pull request
