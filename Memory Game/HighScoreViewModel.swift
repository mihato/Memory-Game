//
//  HighScoreViewModel.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 14.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation
import CoreData

class HighScoreViewModel {
    
    fileprivate static let scoresCacheName = "high-scores-cache"
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Score>?
    
    fileprivate var persistentContainer: NSPersistentContainer?
    
    fileprivate lazy var fetchRequest: NSFetchRequest<Score> = {
        let fetchRequest = NSFetchRequest<Score>(entityName: Score.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "numberOfTurns", ascending: true),
                                        NSSortDescriptor(key: "seconds", ascending: true)]
        return fetchRequest
    }()
    
    init(fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate) {
        if let containerName = Settings<String>(key: .persistentContainerName)?.value {
            let container = NSPersistentContainer(name: containerName)
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                guard error == nil else {
                    return
                }
            })
            NSFetchedResultsController<Score>.deleteCache(withName: type(of: self).scoresCacheName)
            self.fetchedResultsController = NSFetchedResultsController<Score>(fetchRequest: self.fetchRequest, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: type(of: self).scoresCacheName)
            self.fetchedResultsController?.delegate = fetchedResultsControllerDelegate
            self.persistentContainer = container
            
            do {
                try self.fetchedResultsController?.performFetch()
            } catch _ {
                self.fetchedResultsController = nil
                self.persistentContainer = nil
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(notification:)), name: .NSManagedObjectContextDidSave, object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    @objc func contextDidSave(notification: Notification) {
        self.persistentContainer?.viewContext.mergeChanges(fromContextDidSave: notification)
    }
    
    func resetHighScores(completion: @escaping ((_ error: Error?) -> ())) {
        guard let container = self.persistentContainer else {
            return
        }
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: self.fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        container.performBackgroundTask { (context) in
            do {
                try context.execute(deleteRequest)
                try context.save()
                NSFetchedResultsController<Score>.deleteCache(withName: type(of: self).scoresCacheName)
                try self.fetchedResultsController?.performFetch()
                completion(nil)
            } catch let error {
                completion(error)
            }
        }
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func numberOfRows() -> Int {
        guard let section = self.fetchedResultsController?.sections?.first else {
            return 0
        }
        return section.numberOfObjects
    }
    
    func playerName(at indexPath: IndexPath) -> String? {
        return self.fetchedResultsController?.object(at: indexPath).playerName
    }
    
    func numberOfTurns(at indexPath: IndexPath) -> Int? {
        return self.fetchedResultsController?.object(at: indexPath).numberOfTurns?.intValue
    }
    
    func seconds(at indexPath: IndexPath) -> Int? {
        return self.fetchedResultsController?.object(at: indexPath).seconds?.intValue
    }
    
    func dateTime(at indexPath: IndexPath) -> Date? {
        return self.fetchedResultsController?.object(at: indexPath).dateTime
    }
}
