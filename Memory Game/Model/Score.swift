//
//  Score.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 14.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit
import CoreData

class Score: NSManagedObject {
    
    static let entityName = "Score"

    @NSManaged var playerName: String?

    @NSManaged var dateTime: Date?

    @NSManaged var numberOfTurns: NSNumber?

    @NSManaged var seconds: NSNumber?
    
}
