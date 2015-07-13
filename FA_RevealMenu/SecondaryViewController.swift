//
//  SecondaryViewController.swift
//  FA_RevealMenu
//
//  Created by Pierre LAURAC on 13/07/2015.
//  Copyright (c) 2015 Front. All rights reserved.
//

import Foundation
import UIKit

class SecondaryViewController: UIViewController {
    
    @IBOutlet weak var button: UIButton!
    override func viewDidAppear(animated: Bool) {
        var parent = self.FA_RevealMenu()
        if parent != nil {
            self.button.addTarget(parent, action: Selector("toggleLeftPanel"), forControlEvents: .TouchUpInside)
        }
    }
}