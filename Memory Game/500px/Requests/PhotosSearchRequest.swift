//
//  PhotosSearchRequest.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 09.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

struct PhotosSearchRequest: Request {
    
    public private(set) var method: String = "/photos/search"
    
    var params: [String: String] {
        var params = ["term": self.term,
                      "sort_direction": self.sortingOrder.rawValue,
                      "page": String(self.page),
                      "rpp": String(self.perPage)]
        if self.sorting != .none {
            params["sort"] = self.sorting.rawValue
        }
        if let categories = self.includeCategories {
            params["only"] = categories.map({ $0.rawValue.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "" }).joined(separator: ",")
        }
        if let categories = self.excludeCategories {
            params["exclude"] = categories.map({ $0.rawValue.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "" }).joined(separator: ",")
        }
        return params
    }
    
    var term: String
    
    var sorting = PhotosSorting.none
    
    var sortingOrder = SortingOrder.desc
    
    var page = 1
    
    var perPage = 50
    
    var includePhotoSizes = [PhotoImageSize.crop280]
    
    var includeCategories: [Category]?
    
    var excludeCategories: [Category]?
    
    var onSuccess: ((_ data: [String: Any]) -> ())?
    
    var onError: ((_ error: Error) -> ())? 
    
    init(searchPattern: String, page: Int = 1) {
        assert(searchPattern != "")
        self.term = searchPattern
        self.page = page
    }
    
}
