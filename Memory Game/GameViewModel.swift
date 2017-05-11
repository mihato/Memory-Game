//
//  GameViewModel.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 16.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit
import CoreData

class GameViewModel: NSObject {
    
    private(set) var game: Game
    
    var imagesCount: Int {
        return self.game.images.count
    }
    
    var currentTurn: Game.Turn?
    
    init(game: Game) {
        self.game = game
    }
    
    func testImage(at position: Int) -> Bool {
        if let turn = self.currentTurn {
            let result = self.game.testTurn((firstTry: turn.firstTry, secondTry: position))
            self.currentTurn = nil
            return result
        } else {
            let turn = Game.Turn(firstTry: position, secondTry: nil)
            self.currentTurn = turn
            return self.game.testTurn(turn)
        }
    }
    
    func writeResultsToHighScores(playerName: String?) {
        if let containerName = Settings<String>(key: .persistentContainerName)?.value {
            let container = NSPersistentContainer(name: containerName)
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                guard error == nil else {
                    return
                }
            })
            container.performBackgroundTask({ (context) in
                if let score = NSEntityDescription.insertNewObject(forEntityName: Score.entityName, into: context) as? Score {
                    score.playerName = playerName
                    score.numberOfTurns = NSNumber(value: self.game.turnsCount)
                    score.dateTime = Date()
                    score.seconds = NSNumber(value: self.game.seconds)
                    do {
                        try context.save()
                    } catch _ {
                        assert(false)
                    }
                }
            })
        }
    }
}
