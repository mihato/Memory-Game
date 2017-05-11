//
//  GameInitilizerViewModel.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 15.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation
import UIKit

class GameInitilizerViewModel: NSObject {
    
    dynamic var progress: Float = 0
    
    var isLoading = false
    
    fileprivate var completionHandler: ((_ error: Error?) -> ())?
    
    fileprivate var loadedImages = [UIImage]()
    
    fileprivate var urlSession: URLSession?
    
    var images: [UIImage] {
        return self.loadedImages
    }
    
    func beginInitialization(imagesCount: Int, completion: @escaping ((_ error: Error?) -> ())) {
        if self.isLoading {
            return
        }
        /// experiment shows that there are always 1000 pages in response.
        /// so we use rand 1..100 to randomaze games. but it can be unsafe.
        let aTry = Int(arc4random_uniform(100) + 1)
        var request = PhotosSearchRequest(searchPattern: "kitten", page: aTry)
        request.perPage = imagesCount
        request.includePhotoSizes = [.crop140]
        request.onSuccess = { data in
            self.progress += self.progressStep(imagesCount: imagesCount)
            
            guard let photosData = data["photos"] as? [[String:Any]] else {
                self.completionHandler?(PXError.unexpectedResponse)
                return
            }
            
            var photos = [Photo]()
            for photoData in photosData {
                if let photo = Photo(data: photoData) {
                    photos.append(photo)
                }
            }
            if photos.count == imagesCount {
                self.loadImages(photos: photos)
            } else {
                self.completionHandler?(PXError.unexpectedResponse)
            }
        }
        request.onError = { error in
            self.completionHandler?(error)
        }
        self.completionHandler = completion
        self.isLoading = true
        self.loadedImages.removeAll()
        self.progress = 0
        Dispatcher.default.perform(request: request)
    }
    
    func loadImages(photos: [Photo]) {
        if let session = self.urlSession {
            session.invalidateAndCancel()
        }
        self.urlSession = URLSession(configuration: .default)
        for image in photos.map({ return $0.images.first }) {
            if let image = image {
                self.load(image: image, imagesCount: photos.count)
            }
        }
    }
    
    func load(image: PhotoImage, imagesCount: Int, attempsCount: Int = 1) {
        let task = self.urlSession?.downloadTask(with: image.secureUrl) { location, response, error in
            if let error = error {
                if attempsCount < 2 {
                    self.load(image: image, imagesCount: imagesCount, attempsCount: attempsCount + 1)
                    return
                } else {
                    self.handleImageLoadingError(error: error)
                    return
                }
            }
            if let url = location {
                self.progress += self.progressStep(imagesCount: imagesCount)
                do {
                    let data = try Data(contentsOf: url)
                    if let img = UIImage(data: data) {
                        self.loadedImages.append(img)
                        if self.loadedImages.count == imagesCount {
                            self.completionHandler?(nil)
                        }
                    } else {
                        self.handleImageLoadingError(error: PXError.emptyResponse)
                        return
                    }
                } catch _ {
                    self.handleImageLoadingError(error: PXError.unexpectedResponse)
                    return
                }
            }
        }
        task?.resume()
    }
    
    func handleImageLoadingError(error: Error) {
        if (error as NSError).domain == NSURLErrorDomain
            && (error as NSError).code == NSURLErrorCancelled
        {
            return // request was cancelled. nothing to do
        }
        self.urlSession?.invalidateAndCancel()
        self.urlSession = nil
        self.completionHandler?(error)
    }
    
    fileprivate func progressStep(imagesCount: Int) -> Float {
        return 1.0 / Float(imagesCount + 1) // 1 request to 500px and N images to load
    }
    
}
