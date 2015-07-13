//
//  LeftMenuController.swift
//  FA_RevealMenu
//
//  Created by Pierre LAURAC on 09/05/2015.
//  Copyright (c) 2015 Front. All rights reserved.
//

import UIKit

enum selectedMenuType {
    case MainView
    case SecondaryView
}

class LeftMenuController: UIViewController {
    
    var lastSelectedMenuItem: selectedMenuType = .MainView
    
    var currentSelectedMenuItem: selectedMenuType = .MainView
    
    @IBOutlet weak var mainViewButton: UIButton!

    @IBOutlet weak var secondaryViewButton: UIButton!
    override func viewDidLoad() {
        
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if let button = sender as? UIButton {
            if button == mainViewButton {
                currentSelectedMenuItem = .MainView
            } else {
                currentSelectedMenuItem = .SecondaryView
            }
        }
        
        
        return true
    }
    
}

extension LeftMenuController: FA_MenuSelectionProtocol {
    
    func selectionWasMade() -> AnyObject {
        return "Could be anything"
    }
    
    func shouldReplaceWithNewViewController() -> Bool {
        let should = lastSelectedMenuItem != currentSelectedMenuItem
        lastSelectedMenuItem = currentSelectedMenuItem
        return should
    }
}