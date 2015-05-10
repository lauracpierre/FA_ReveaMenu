//
//  FrontViewController.swift
//  FA_RevealMenu
//
//  Created by Pierre LAURAC on 09/05/2015.
//  Copyright (c) 2015 Front. All rights reserved.
//

import UIKit

class FrontViewController: UIViewController {
    
    @IBOutlet weak var boutton: UIButton!
    override func viewDidLoad() {
        var parent = self.FA_RevealMenu()
        if parent != nil {
            self.boutton.addTarget(parent, action: Selector("toggleLeftPanel"), forControlEvents: .TouchUpInside)
        }
    }
    
    func showModal(text: String) {
        let controller = UIAlertController(title: "Alert!",message: text, preferredStyle: .Alert)
        

        
        controller.addAction(UIAlertAction(title: "Ok!", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
}

extension FrontViewController: FA_FrontViewMinimalImplementation {
    func selectionChangedInMenu(object: AnyObject?) {
        self.showModal("Apparenlty something changed in menu")
    }
}
