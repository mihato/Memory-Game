//
//  Game.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 15.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation
import UIKit

@objc enum GameState: Int {
    case ready
    case playing
    case paused
    case over
}

class Game: NSObject {
    
    typealias Turn = (firstTry: Int, secondTry: Int?)

    var currentTurn: Turn?
    
    private(set) var images: [UIImage]
    
    dynamic private(set) var seconds: Int = 0
    
    dynamic private(set) var turnsCount: Int = 0
    
    dynamic private(set) var state = GameState.ready
    
    fileprivate var timer: Timer?
    
    fileprivate var openImages = [Bool]()
    
    init(images: [UIImage]) {
        self.images = []
        self.images.append(contentsOf: images)
        self.images.append(contentsOf: images) // add images twice
        super.init()
        self.timer = Timer(timeInterval: 1, target: self, selector: #selector(timerHandler(timer:)), userInfo: nil, repeats: true)
        
        // shuffle images
        for i in self.images.startIndex ..< self.images.endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(self.images.endIndex - i))) + i
            if i != j {
                swap(&self.images[i], &self.images[j])
            }
        }
    }
    
    deinit {
        self.stop()
    }
    
    @objc fileprivate func timerHandler(timer: Timer) {
        if self.state == .playing {
            self.seconds += 1
        }
    }
    
    func start() {
        self.openImages = Array<Bool>(repeating: false, count: self.images.count)
        self.state = .playing
        if let timer = self.timer {
            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
        }
    }
    
    func stop() {
        self.state = .over
        if let timer = self.timer, timer.isValid {
            timer.invalidate()
        }
    }
    
    func testTurn(_ turn: Turn) -> Bool {
        guard self.state == .playing else {
            return false
        }
        assert(turn.firstTry < self.images.count)
        if self.currentTurn == nil {
            self.currentTurn = turn
            self.openImages[turn.firstTry] = true
            return true
        }
        guard let currentTurn = self.currentTurn,
            currentTurn.firstTry == turn.firstTry,
            let secondTry = turn.secondTry else {
                return false
        }
        assert(secondTry < self.images.count)
        let success = self.images[turn.firstTry] == self.images[secondTry]
        if !success {
            self.openImages[turn.firstTry] = false
            self.openImages[secondTry] = false
        } else {
            self.openImages[secondTry] = true
            if !self.openImages.contains(false) {
                self.stop()
            }
        }
        self.currentTurn = nil
        self.turnsCount += 1
        return success
    }
    
    func isImageFlipped(at index: Int) -> Bool {
        return self.openImages[index]
    }
}
