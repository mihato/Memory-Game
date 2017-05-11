//
//  GetPhotosListRequest.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 09.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

struct GetPhotosListRequest: Request {
    
    public private(set) var method: String = "/photos"
    
    var params: [String: String] {
        var params = ["feature": self.feature.rawValue,
                      "sort_direction": self.sortingOrder.rawValue,
                      "page": String(self.page),
                      "rpp": String(self.perPage),
                      "include_store": "0",
                      "include_states": "0"]
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
    
    var sorting = PhotosSorting.none
    
    var sortingOrder = SortingOrder.desc
    
    var page = 1
    
    var perPage = 20
    
    var includePhotoSizes = [PhotoImageSize.crop280]
    
    var feature: PhotosFeature
    
    var includeCategories: [Category]?
    
    var excludeCategories: [Category]?
    
    var onSuccess: ((_ data: [String: Any]) -> ())?
    
    var onError: ((_ error: Error) -> ())? 
    
    init(feature: PhotosFeature, page: Int = 1) {
        self.feature = feature
        self.page = page
    }
    
}
