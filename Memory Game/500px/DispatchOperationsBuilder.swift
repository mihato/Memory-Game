//
//  DispatchOperationsBuilder.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 14.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

protocol DispatchOperationsBuilder {
    func build(url: URL, callback: @escaping (_ data: Data?, _ error: Error?) -> ()) -> Operation
}

struct RegularDispatchOperationsBuilder: DispatchOperationsBuilder {
    
    func build(url: URL, callback: @escaping (_ data: Data?, _ error: Error?) -> ()) -> Operation {
        return DispatchOperation(url: url, callback: callback)
    }
    
}
