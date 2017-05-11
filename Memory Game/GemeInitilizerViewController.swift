//
//  GemeInitilizerViewController.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 15.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit

class GemeInitilizerViewController: UIViewController {
    
    @IBOutlet var infoLabel: UILabel?
    
    @IBOutlet var startButton: UIButton?
    
    @IBOutlet var progressView: UIProgressView?
    
    var viewModel = GameInitilizerViewModel()
    
    var gameLayout = Layout(containerSize: .zero)
    
    struct KVOContext {
        static var viewModelContext = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.infoLabel?.text = ""
        
        self.viewModel.addObserver(self, forKeyPath: "progress", options: .new, context: &KVOContext.viewModelContext)
    }
    
    deinit {
        self.viewModel.removeObserver(self, forKeyPath: "progress", context: &KVOContext.viewModelContext)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initializeGame()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &KVOContext.viewModelContext {
            if keyPath == "progress", let newValue = change?[.newKey] as? Float {
                DispatchQueue.main.async {
                    self.progressView?.progress = newValue
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    func initializeGame() {
        self.infoLabel?.text = NSLocalizedString("Loading images...", comment: "")
        self.progressView?.progress = 0
        self.gameLayout = Layout(containerSize: self.view.bounds.size)
        let imagesToLoad = self.gameLayout.imagesCount / 2 // we need to load only half of images
        self.viewModel.beginInitialization(imagesCount: imagesToLoad) { (error) in
            DispatchQueue.main.async {
                if let _ = error {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                                  message: NSLocalizedString("Unfortunately, an error occurred during game initialization.", comment: ""),
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("Try again", comment: ""), style: .default, handler: { (action) in
                        self.initializeGame()
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.infoLabel?.text = NSLocalizedString("Ready? Press start!", comment: "")
                    self.startButton?.isHidden = false
                    self.progressView?.isHidden = true
                }
            }
        }
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "game" {
            if let controller = segue.destination as? GameViewController {
                controller.viewModel = GameViewModel(game: Game(images: self.viewModel.images))
            }
        }
    }

}
