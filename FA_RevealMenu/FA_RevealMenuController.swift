//
//  FA_RevealMenuController.swift
//  FA_RevealMenu
//
//  Created by Pierre LAURAC on 09/05/2015.
//  Copyright (c) 2015 Front. All rights reserved.
//

import UIKit

enum SlideOutState {
    case Collapsed
    case LeftPanelExpanded
}

// MARK: - Back menu delegate protocol
protocol FA_MenuSelectionProtocol {
    func selectionWasMade(sender: UIViewController, object: AnyObject?)
}

// MARK: - Minimum implementation for back menu
protocol FA_MenuMinimalImplementation {
    var delegate: FA_MenuSelectionProtocol? {get set}
}

// MARK: - Minimum implementation for front menu
protocol FA_FrontViewMinimalImplementation {
    func selectionChangedInMenu(object: AnyObject?)
}

// MARK: - That's where the magic starts to happen
class FA_RevealMenuController: UIViewController {
    
    //var centerNavigationController: UINavigationController!
    
    var centerViewController: UIViewController!
    
    var leftViewController: UIViewController?
    
    let expandViewSizePercentage: CGFloat = 0.8
    
    var maxExpandSize: CGFloat? = nil
    
    let panGestureXLocationStart: CGFloat = 70.0
    
    var currentState: SlideOutState = .Collapsed {
        didSet {
            let shouldShowShadow = currentState != .Collapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.performSegueWithIdentifier(FASegueFrontIdentifier, sender: nil)
        self.performSegueWithIdentifier(FASegueLeftIdentifier, sender: nil)
        
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        //centerNavigationController = UINavigationController(rootViewController: centerViewController)
        
        addChildViewController(centerViewController)
        view.addSubview(centerViewController.view)
        addChildSidePanelController(leftViewController!)
        
        if var left = leftViewController as? FA_MenuMinimalImplementation {
            left.delegate = self
        }
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
        panGestureRecognizer.delegate = self
        centerViewController.view.addGestureRecognizer(panGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tapGestureRecognizer.delegate = self
        centerViewController.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
}

// MARK: - Front and back view animation management
extension FA_RevealMenuController {
    func toggleLeftPanel() {
        animateLeftPanel(shouldExpand: (currentState != .LeftPanelExpanded))
    }
    
    func collapseSidePanels() {
        toggleLeftPanel()
    }
    
    
    func animateLeftPanel(#shouldExpand: Bool) {
        
        if (shouldExpand) {
            self.currentState = .LeftPanelExpanded
            
            var viewSize = self.view.frame.size
            var smallestSize = min(viewSize.height, viewSize.width)
            let targetSize = maxExpandSize != nil ? maxExpandSize! : (smallestSize * self.expandViewSizePercentage)
            animateCenterPanelXPosition(targetPosition: targetSize)
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .Collapsed
            }
        }
    }
    
    func animateCenterPanelXPosition(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerViewController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func addChildSidePanelController(sidePanelController: UIViewController) {
        view.insertSubview(sidePanelController.view, atIndex: 0)
        addChildViewController(sidePanelController)
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerViewController.view.layer.shadowOpacity = 0.8
        } else {
            centerViewController.view.layer.shadowOpacity = 0.0
        }
    }
    
}

// MARK: - Gesture recognizer
extension FA_RevealMenuController: UIGestureRecognizerDelegate {
    
    
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        // Only want gesture from the side of the screen
        if currentState == .Collapsed && recognizer.locationInView(centerViewController.view).x > self.panGestureXLocationStart {
            return
        }
        
        
        // Checking if menu is closed and blocking any gesture beside left to right
        let gestureIsDraggingFromLeftToRight = (recognizer.velocityInView(centerViewController.view).x > 80)
        if currentState == .Collapsed && !gestureIsDraggingFromLeftToRight {
            return
        }
        
        // Checking if menu is open and blocking any gesting beside right to left
        let gestureIsDraggingFromRightToLeft = (recognizer.velocityInView(centerViewController.view).x < 10)
        if currentState == .LeftPanelExpanded && !gestureIsDraggingFromRightToLeft {
            return
        }
        
        // Simple gesture with no drag and drop
        switch(recognizer.state) {
            
        case .Changed:
            animateLeftPanel(shouldExpand: currentState == .Collapsed)
            break
        default:
            break
        }
    }
    
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
        
        self.collapseSidePanels()
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer is UITapGestureRecognizer {
            // We have to "disable" tap gesture when collapse otherwise we will prevent
            // the view to handle normal tap gesture (like on UITableView)
            if currentState == .Collapsed {
                return false
            }
        }
        
        return true
    }
    
}

// MARK: - FA_MenuSelectionProtocol delegate method
extension FA_RevealMenuController: FA_MenuSelectionProtocol {
    func selectionWasMade(sender: UIViewController, object: AnyObject?) {
        // Closing menu
        if currentState != .Collapsed {
            self.collapseSidePanels()
        }
        
        
        // Trying to infomr the front view controller a selection was made based
        // on the type of the front view controller.
        
        // Could add support for more like TabViewController
        
        // Simple case where the centerViewController is the UIViewController
        if let front = centerViewController as? FA_FrontViewMinimalImplementation {
            front.selectionChangedInMenu(object)
        }
            // It could be a navigation controller. In that case, the rootViewController might implement the protocol?
        else if let nav = centerViewController as? UINavigationController,
            let root = nav.viewControllers[0] as? FA_FrontViewMinimalImplementation {
                root.selectionChangedInMenu(object)
        }
    }
}

// MARK: - UIViewController extension
extension UIViewController {
    
    func FA_RevealMenu() -> FA_RevealMenuController? {
        var parent: UIViewController = self
        
        while(!(parent is FA_RevealMenuController)) {
            if(parent.parentViewController == nil) {
                break
            }
            parent = parent.parentViewController!
        }
        
        return parent as? FA_RevealMenuController;
    }
}

let FASegueFrontIdentifier = "fa_front"

let FASegueLeftIdentifier = "fa_left"

// MARK: - Custom Segue
class FA_ReavealMenuSegueSetController: UIStoryboardSegue {
    
    override func perform() {
        let identifier = self.identifier;
        
        if let container = self.sourceViewController as? FA_RevealMenuController,
            let destination = self.destinationViewController as? UIViewController
        {
            if identifier == FASegueFrontIdentifier {
                container.centerViewController = destination
                
            } else if identifier == FASegueLeftIdentifier {
                container.leftViewController = destination
            }
        }
        
    }
}
