//
//  MockDispatchOperationsBuilder.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 14.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation
@testable import Memory_Game

class MockDispatchOperationsBuilder: DispatchOperationsBuilder {
    
    func build(url: URL, callback: @escaping (_ data: Data?, _ error: Error?) -> ()) -> Operation {
        if let range = url.path.range(of: "v1/") {
            let filename = url.path.substring(from: range.upperBound).replacingOccurrences(of: "/", with: ".")
            let bundle = Bundle(for: type(of: self))
            if let fileUrl = bundle.url(forResource: filename, withExtension: "json") {
                do {
                    let data = try Data(contentsOf: fileUrl)
                    return BlockOperation(block: {
                        callback(data, nil)
                    })
                } catch _ {
                    return BlockOperation(block: {
                        callback(nil, PXError.unexpectedResponse)
                    })
                }
            } else {
                return BlockOperation(block: {
                    callback(nil, PXError.invalidRequest)
                })
            }
        } else {
            return BlockOperation(block: {
                callback(nil, PXError.invalidRequest)
            })
        }
    }
    
}
