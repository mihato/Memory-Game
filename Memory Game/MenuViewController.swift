//
//  MenuViewController.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 14.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass) {
        case (.compact, _), (_, .compact): return .portrait // no landscape for iphones
        default: return .all
        }
    }

}

