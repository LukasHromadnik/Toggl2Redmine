////
////  Request.swift
////  Toggl2Redmine
////
////  Created by Lukáš Hromadník on 04/03/2020.
////  Copyright © 2020 Lukáš Hromadník. All rights reserved.
////
//
//import Foundation
//
///// Makes a synchronous request
/////
///// - Parameters:
/////   - request: `URLRequest` which should be dispatched synchronously
///// - Returns: Response of the `request` decoded into Decodable object
//func makeSynchronous<T: Codable>(request: URLRequest) -> T {
//    let semaphore = DispatchSemaphore(value: 0)
//    var result: T!
//    make(request: request) { (data: T) in
//        result = data
//        semaphore.signal()
//    }
//    semaphore.wait()
//
//    return result
//}
//
///// Makes an asynchronous request
/////
///// - Parameters:
/////   - request: `URLRequest` which should be dispatched asynchronously
/////   - completion: Handler which takes the response data decoded in Decodable object
//func make<T: Codable>(request: URLRequest, completion: @escaping (T) -> Void) {
//    let task = URLSession.shared.dataTask(with: request) { data, response, error in
//        if let error = error {
//            print("[ERROR]", error.localizedDescription)
//            return
//        }
//
//        guard ignoreResponse == false else { return }
//        
//        guard let data = data else { return }
//
////        let json = try! JSONSerialization.jsonObject(with: data)
////        print(json)
//
//        let decoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .iso8601
//        let result = try! decoder.decode(T.self, from: data)
//        completion(result)
//    }
//    task.resume()
//}
