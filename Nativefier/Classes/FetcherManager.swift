//
//  File.swift
//  Nativefier
//
//  Created by Nayanda Haberty on 06/09/18.
//

import Foundation

class FetcherManager<T> {
    
    fileprivate var activeFetch : [String : [((T)-> Void, (()->Void)?)]] = [:]
    
    func fetch(for key : String, fetcher : (String) -> T?, onSuccess : @escaping (T)-> Void, onFailed : (()->Void)?, retry : Int?){
        let hasActiveFetch = activeFetch.contains { (pair) -> Bool in
            return pair.key == key
        }
        if hasActiveFetch {
            activeFetch[key]?.append((onSuccess, onFailed))
        }
        else{
            activeFetch[key] = [(onSuccess, onFailed)]
            let maxRetryCount = retry ?? 1
            var i = 0
            var obj : T?
            while obj == nil, i < maxRetryCount {
                obj = fetcher(key)
                i += 1
            }
            let completions : [String : [((T)-> Void, (()->Void)?)]] = self.activeFetch
            self.activeFetch.removeValue(forKey: key)
            guard let fetchCompletion : [((T)-> Void, (()->Void)?)] = completions[key] else {
                return
            }
            for completion in fetchCompletion {
                if let obj : T = obj{
                    completion.0(obj)
                }
                else {
                    completion.1?()
                }
            }
        }
    }
}
