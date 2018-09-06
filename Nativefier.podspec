#
# Be sure to run `pod lib lint Nativefier.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Nativefier'
  s.version          = '0.1.2'
  s.summary          = 'Cache library for iOS'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
    Features
      
      - Builder pattern
      - Default Cache for Image and any HandyJSON object <https://github.com/alibaba/HandyJSON>
      - Support synchronous or asynchronous operation
      - Delegate when object is about to removed from cache
      - Custom fetcher closure to get object if object is not present in the cache
      - Dual cache on Disk and Memory
    
    Requirements
      
      - Swift 3.2 or higher
      
    About Nativefier
    
      The basic algorithm of nativefier is very simple
      
      Stored object
      1. Object will be stored on memory and then disk asynchronously
      2. If memory is already full, the least and oldest accessed object will be removed to give room for the new object
      3. If Disk is already full, the least and oldest accessed object will be removed to give room for the new object
      
      Getting the object
      1. It will be return the stored object if the object is already in memory
      2. If the object is not present in the memory, it will be search in the disk and will stored the object found in the memory as new object
      3. If the object is not found, it will return nil
      4. If you're using the getOrFetch method, then it will fetch the object using your custom fetcher if the object is not found anywhere and stored the object from fetcher as new object to memory and disk
      
    Usage Example
      HandyJSON and Image
      Build the object using HttpRequestBuilder and then execute
      
      - containerName is name of cache folder in disk
      - maxRamCount is max number of object can stored in memory
      - maxDiskCount is max number of object can stored in disk
      
      code :
      //HandyJSON object cache
      let handyJSONCache = NativefierBuilder.getForHandyJSON<MyObject>().set(containerName: "myobject").set(maxRamCount: 100).set(maxDiskCount: 200).build()
      
      //Image cache
      let imageCache = NativefierBuilder.getForImage().set(maxRamCount: 100).set(maxDiskCount: 200).build()
      
      
      Any Object
      If you prefer custom object you can create your own serializer for your cache
      
      code:
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
      
      And then create your cache
      
      code:
      let handyJSONCache = NativefierBuilder.getForAnyObject<MyObject>().set(containerName: "myobject").set(maxRamCount: 100).set(maxDiskCount: 200).set(serializer: MyOwnSerializer()).build()
      
      
      Create Fetcher
      Fetcher is closure that will be executed if the object you want to get is not present in memory or disk. The object returned from the fetcher will be stored in cache
      
      code:
      let handyJSONCache = NativefierBuilder.getForAnyObject<MyObject>().set(containerName: "myobject").set(maxRamCount: 100).set(maxDiskCount: 200).set(serializer: MyOwnSerializer())
      .set(fetcher: { key in
           //ANY CODE TO FETCH THE OBJECT USING THE GIVEN KEY
           return fetchedObject
           }).build()
           
           
      Using The Nativefier
      Using the nativefier is very easy. just use it like you use Dictionary object.
      But remember, if you want to using fetcher, its better to do it asynchronously so it wouldn't block your execution if fetch take to long
               
      code:
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
      
                                
      Using Delegate
      If you need to use delegate, you need to implement the delegate and then put it in your cache is it will executed by the cache.
      The delegate method you can use is :
      - nativefier(_ nativefier : Any , onFailedFecthFor key: String) -> Any?
        will be executed if fetcher failed to get the object, you can return any default object and it will not stored in the cache
      - nativefier(_ nativefier : Any, memoryWillRemove singleObject: Any, for key: String)
        will be executed if nativefier is about to remove some object from memory
      - nativefierWillClearMemory(_ nativefier : Any)
        will be executed if nativefier will clear the memory
      - nativefier(_ nativefier : Any, diskWillRemove singleObject: Any, for key: String)
        will be executed if nativefier is about to remove some object from disk
      - nativefierWillClearDisk(_ nativefier : Any)
        will be executed if nativefier will clear the disk
        
      All method are optional, use the one you need
                                
      code:
      // on build
      let imageCache = NativefierBuilder.getForImage().set(maxRamCount: 100).set(maxDiskCount: 200).set(delegate : self).build()
                                
      // or directly to the Nativefier Object
      imageCache.delegate = self

                       DESC

  s.homepage         = 'https://github.com/nayanda1/iOSNativefier'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'nayanda1' => 'nayanda1@outlook.com' }
  s.source           = { :git => 'https://github.com/nayanda1/iOSNativefier.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Nativefier/Classes/**/*'
  
  s.swift_version = '3.2'
  
  # s.resource_bundles = {
  #   'Nativefier' => ['Nativefier/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'HandyJSON', '~> 4.1.1'
end
