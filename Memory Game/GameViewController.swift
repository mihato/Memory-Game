//
//  GameViewController.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 16.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    struct KVOContext {
        static var viewModelContext = 0
    }
    
    @IBOutlet var timerLabel: UILabel?
    
    @IBOutlet var turnsLabel: UILabel?
    
    @IBOutlet var containerView: UIView?
    
    @IBOutlet var menuButton: UIButton?
    
    var viewModel: GameViewModel?
    
    var constraints = [NSLayoutConstraint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.timerLabel?.text = NSLocalizedString("Time: ", comment: "") + "0"
        self.turnsLabel?.text = NSLocalizedString("Turns: ", comment: "") + "0"
        
        guard let viewModel = self.viewModel,
            let containerView = self.containerView else {
                self.dismiss(animated: true, completion: nil)
                return
        }
        viewModel.game.addObserver(self, forKeyPath: "seconds", options: .new, context: &KVOContext.viewModelContext)
        viewModel.game.addObserver(self, forKeyPath: "turnsCount", options: .new, context: &KVOContext.viewModelContext)
        viewModel.game.addObserver(self, forKeyPath: "state", options: .new, context: &KVOContext.viewModelContext)
        
        containerView.isHidden = true
        
    }
    
    deinit {
        guard let viewModel = self.viewModel else {
            return
        }
        viewModel.game.removeObserver(self, forKeyPath: "seconds", context: &KVOContext.viewModelContext)
        viewModel.game.removeObserver(self, forKeyPath: "turnsCount", context: &KVOContext.viewModelContext)
        viewModel.game.removeObserver(self, forKeyPath: "state", context: &KVOContext.viewModelContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &KVOContext.viewModelContext {
            DispatchQueue.main.async {
                switch (keyPath, change?[.newKey] as? Int) {
                case (.some("seconds"), let value):
                    self.timerLabel?.text = NSLocalizedString("Time: ", comment: "") + String(describing: value ?? 0)
                case (.some("turnsCount"), let value):
                    self.turnsLabel?.text = NSLocalizedString("Turns: ", comment: "") + String(describing: value ?? 0)
                default: break
                }
                if keyPath == "state",
                    let value = change?[.newKey] as? Int,
                    let state = GameState(rawValue: value),
                    state == .over
                {
                    self.finishGame()
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let viewModel = self.viewModel,
            let containerView = self.containerView else {
                self.dismiss(animated: true, completion: nil)
                return
        }
        
        for position in 0 ..< viewModel.imagesCount {
            let cardView = self.imageView(forPosition: position, frontImage: viewModel.game.images[position])
            containerView.addSubview(cardView)
        }
        
        let top = self.topLayoutGuide.length
        let bottom = self.view.frame.height - (self.menuButton?.frame.origin.y ?? 0)
        self.layoutImages(containerSize: CGSize(width: self.view.frame.width, height: self.view.frame.height - top - bottom))
        
        containerView.alpha = 0
        containerView.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            containerView.alpha = 1
            }) { (finished) in
                viewModel.game.start()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let top = self.topLayoutGuide.length
        let bottom = self.view.frame.height - (self.menuButton?.frame.origin.y ?? 0)
		
        self.layoutImages(containerSize: CGSize(width: size.width, height: size.height - top - bottom))
    }
    
    func layoutImages(containerSize: CGSize) {
        guard let viewModel = self.viewModel,
            let containerView = self.containerView else {
                return
        }
        NSLayoutConstraint.deactivate(self.constraints)
        self.constraints.removeAll()
        
        let layout = Layout(containerSize: containerSize)
        var hAnchor = containerView.leftAnchor
        var vAnchor = containerView.topAnchor
        for position in 0 ..< viewModel.imagesCount {
            guard let imageView = containerView.viewWithTag(position + 1) else {
                continue
            }
            self.constraints.append(imageView.widthAnchor.constraint(equalToConstant: layout.imageSize.width))
            self.constraints.append(imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor))
            self.constraints.append(containerView.bottomAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor))
            
            self.constraints.append(vAnchor.constraint(equalTo: imageView.topAnchor, constant: -CGFloat(layout.margin)))
            self.constraints.append(hAnchor.constraint(equalTo: imageView.leftAnchor, constant: -CGFloat(layout.margin)))
            hAnchor = imageView.rightAnchor
            
            if position % layout.itemsInRow == layout.itemsInRow - 1 {
                self.constraints.append(imageView.rightAnchor.constraint(equalTo: containerView.rightAnchor))
                hAnchor = containerView.leftAnchor
                vAnchor = imageView.bottomAnchor
            }
        }
        
        NSLayoutConstraint.activate(self.constraints)
    }
    
    @IBAction func showMenuAction(sender: AnyObject) {
        let menu = UIAlertController(title: NSLocalizedString("Memory Game", comment: ""), message: NSLocalizedString("Game paused.", comment: ""), preferredStyle: .actionSheet)
        menu.addAction(UIAlertAction(title: NSLocalizedString("End Game", comment: ""), style: .destructive, handler: { (action) in
            self.endGame()
        }))
        menu.addAction(UIAlertAction(title: NSLocalizedString("Resume", comment: ""), style: .default, handler: nil))
        menu.modalPresentationStyle = .popover
        menu.popoverPresentationController?.sourceView = self.menuButton
        menu.popoverPresentationController?.sourceRect = self.menuButton!.bounds
        self.present(menu, animated: true, completion: nil)
    }
    
    func tapHandler(tapRecognizer: UITapGestureRecognizer) {
        guard let viewModel = self.viewModel,
            let imageView = tapRecognizer.view as? CardView else {
                return
        }
        let position = imageView.tag - 1
        if viewModel.game.isImageFlipped(at: position) {
            return
        }
        imageView.flip()
        if !viewModel.testImage(at: position) {
            self.perform(#selector(resetImages), with: nil, afterDelay: 1)
        }
        
    }
    
    func endGame() {
        let alert = UIAlertController(title: NSLocalizedString("Memory Game", comment: ""), message: NSLocalizedString("Do you want to end the game?", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .destructive, handler: { action in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func finishGame() {
        let alert = UIAlertController(title: NSLocalizedString("Memory Game", comment: ""), message: NSLocalizedString("Enter your name to store results in high scores:", comment: ""), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = NSLocalizedString("Player Name", comment: "")
            textField.autocorrectionType = .no
            textField.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: { [weak alert] (_) in
            self.viewModel?.writeResultsToHighScores(playerName: alert?.textFields?.first?.text)
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imageView(forPosition position: Int, frontImage: UIImage?) -> CardView {
        let card = CardView(image: frontImage)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.isUserInteractionEnabled = true
        card.tag = position + 1
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(tapRecognizer:)))
        card.addGestureRecognizer(tapRecognizer)
        
        return card
    }
    
    @objc func resetImages() {
        guard let viewModel = self.viewModel,
            let containerView = self.containerView else {
                return
        }
        for i in 0 ..< viewModel.imagesCount {
            if let cardView = containerView.viewWithTag(i + 1) as? CardView,
                viewModel.game.isImageFlipped(at: i) != cardView.isFlipped
            {
                cardView.flip()
            }
        }
    }

}

