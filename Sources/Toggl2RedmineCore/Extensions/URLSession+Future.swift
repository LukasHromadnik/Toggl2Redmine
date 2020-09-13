//
//  URLSession+Future.swift
//  Toggl2Redmine
//
//  Created by Lukáš Hromadník on 04/03/2020.
//  Copyright © 2020 Lukáš Hromadník. All rights reserved.
//

import Foundation

extension URLSession {
    func request(_ request: URLRequest) -> Future<Data> {
        // We'll start by constructing a Promise, that will later be
        // returned as a Future:
        let promise = Promise<Data>()

        // Perform a data task, just like we normally would:
        let task = dataTask(with: request) { data, response, error in
            Console.shared.log("\((response as? HTTPURLResponse)?.statusCode ?? 000) \(request.url!.absoluteString)")

            // Reject or resolve the promise, depending on the result:
            if let error = error {
                promise.reject(with: error)
            } else {
                promise.resolve(with: data ?? Data())
            }
        }

        task.resume()

        return promise
    }
}
