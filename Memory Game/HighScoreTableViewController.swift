//
//  HighScoreTableViewController.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 14.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit
import CoreData

class HighScoreTableViewController: UITableViewController {
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var viewModel: HighScoreViewModel?
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubview(toFront: self.activityIndicator)
        self.view.centerXAnchor.constraint(equalTo: self.activityIndicator.centerXAnchor).isActive = true
        self.view.centerYAnchor.constraint(equalTo: self.activityIndicator.centerYAnchor).isActive = true
        
        self.viewModel = HighScoreViewModel(fetchedResultsControllerDelegate: self)
    }

    @IBAction func closeAction(sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetAction(sender: AnyObject?) {
        let alert = UIAlertController(title: NSLocalizedString("Memory Game", comment: ""),
                                      message: NSLocalizedString("Do you really want to remove all records from high scores?", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                      style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""),
                                      style: .destructive, handler: { action in
                                        self.resetHighScores()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func resetHighScores() {
        guard let viewModel = self.viewModel else {
            return
        }
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.activityIndicator.startAnimating()
        viewModel.resetHighScores { (error) in
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.activityIndicator.stopAnimating()
                if let _ = error {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                                  message: NSLocalizedString("Unfortunately, an error occurred during high scores reset. Please try again later.", comment: ""),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel?.numberOfSections() ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel?.numberOfRows() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = "\(indexPath.row + 1). \(self.viewModel?.playerName(at: indexPath) ?? "Player")"
        if let turnsCount = self.viewModel?.numberOfTurns(at: indexPath),
            let seconds = self.viewModel?.seconds(at: indexPath),
            let dateTime = self.viewModel?.dateTime(at: indexPath) {
            cell.detailTextLabel?.text = String(format: NSLocalizedString("%d turns ・ %d seconds\n%@", comment: ""),
                                                turnsCount, seconds, self.dateFormatter.string(from: dateTime))
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }

}

extension HighScoreTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        switch type {
        case .insert: self.tableView.insertRows(at: [indexPath], with: .automatic)
        case .delete: self.tableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let newIndexPath = newIndexPath else {
                return
            }
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update: self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete: self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move, .update: break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}
