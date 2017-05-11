//
//  Layout.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 17.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation
import CoreGraphics

struct Layout {
    
    fileprivate static let maxImageWidth: CGFloat = 140
    
    fileprivate static let minImagesInRow = 4
    
    fileprivate static let maxRowsCount = 6
    
    private(set) var margin: CGFloat
    
    private(set) var rows: Int
    
    private(set) var cols: Int
    
    private(set) var imageSize: CGSize
    
    private(set) var containerSize: CGSize
    
    private(set) var imagesCount: Int
    
    var itemsInRow: Int {
        return self.imagesCount / Layout.maxRowsCount
    }
    
    init(containerSize: CGSize, margin: CGFloat = 3) {
        self.containerSize = containerSize
        self.margin = margin
        
        let itemsInRow = max(Int(floor(containerSize.width / Layout.maxImageWidth)), Layout.minImagesInRow)
        self.imagesCount = itemsInRow * Layout.maxRowsCount
        self.rows = Layout.maxRowsCount
        self.cols = self.imagesCount / Layout.maxRowsCount
        
        let width = (self.containerSize.width - self.margin * CGFloat(self.cols + 1)) / CGFloat(self.cols)
        let height = (self.containerSize.height - self.margin * CGFloat(self.rows + 1)) / CGFloat(self.rows)
//        return CGSize(width: min(width, height), height: min(width, height))
        self.imageSize = CGSize(width: min(width, height), height: min(width, height))
    }
    
    fileprivate func calculateImageSize() -> CGSize {
        let width = (self.containerSize.width - self.margin * CGFloat(self.cols + 1)) / CGFloat(self.cols)
        let height = (self.containerSize.height - self.margin * CGFloat(self.rows + 1)) / CGFloat(self.rows)
        return CGSize(width: min(width, height), height: min(width, height))
    }
    
//    func imagesCount(containerSize: CGSize) -> Int {
//        let itemsInRow = max(Int(floor(Float(containerSize.width) / Layout.maxImageWidth)), Layout.minImagesInRow)
//        return itemsInRow * Layout.maxRowsCount 
//    }
}
