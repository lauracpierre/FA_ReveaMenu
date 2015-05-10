//
//  LeftMenuController.swift
//  FA_RevealMenu
//
//  Created by Pierre LAURAC on 09/05/2015.
//  Copyright (c) 2015 Front. All rights reserved.
//

import UIKit

class LeftMenuController: UIViewController, FA_MenuMinimalImplementation {
    
    var delegate: FA_MenuSelectionProtocol?
    
    @IBAction func test(sender: AnyObject) {
        self.delegate?.selectionWasMade(self, object: ["FOO":"BAR"])
    }
    override func viewDidLoad() {

    }
    
}