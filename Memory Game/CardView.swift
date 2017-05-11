//
//  CardView.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 21.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit

class CardView: UIView {
    
    fileprivate var back: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    fileprivate var front: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var isFlipped: Bool {
        return self.back.superview == nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureSubviews()
    }
    
    init(image: UIImage?) {
        super.init(frame: .zero)
        self.front.image = image
        self.configureSubviews()
    }
    
    fileprivate func configureSubviews() {
        self.addSubview(self.back)
        NSLayoutConstraint.activate(self.constraintsFor(view: self.back))
    }
    
    fileprivate func constraintsFor(view: UIView) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": view]))
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": view]))
        return constraints
    }
    
    func flip() {
        let transition: (fromView: UIView, toView: UIView)
        if self.back.superview == nil {
            transition = (fromView: self.front, toView: self.back)
        } else {
            transition = (fromView: self.back, toView: self.front)
        }
        UIView.transition(with: self, duration: 0.35, options: .transitionFlipFromRight,
                          animations: {
                            transition.fromView.removeFromSuperview()
                            self.addSubview(transition.toView)
                            NSLayoutConstraint.activate(self.constraintsFor(view: transition.toView))
        }) 
    }

}
