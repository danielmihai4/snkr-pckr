//
//  AnimatedTabBarController.swift
//  snkr-pckr
//
//  Created by Daniel Mihai on 20/07/2019.
//  Copyright © 2019 Daniel Mihai. All rights reserved.
//

import UIKit

class AnimatedTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AnimatedTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard
            let tabViewControllers = tabBarController.viewControllers,
            let targetIndex = tabViewControllers.firstIndex(where: { (item) -> Bool in item == viewController }),
            let targetView = tabViewControllers[targetIndex].view,
            let currentViewController = selectedViewController,
            let currentIndex = tabViewControllers.firstIndex(where: { (item) -> Bool in item == currentViewController })
            else { return false }
        
        if currentIndex != targetIndex {
            animateToView(targetView, as: targetIndex, from: currentViewController.view, at: currentIndex);
        }
        
        NSLog("HEREE!!!")
        
        return true
    }
}

private extension AnimatedTabBarController {
    
    func animateToView(_ toView: UIView, as toIndex: Int, from fromView: UIView, at fromIndex: Int) {
        let screenWidth = UIScreen.main.bounds.size.width
        let offset = toIndex > fromIndex ? screenWidth : -screenWidth
        
        toView.frame.origin = CGPoint(x: toView.frame.origin.x + offset, y: toView.frame.origin.y)
        fromView.superview?.addSubview(toView)
        
        view.isUserInteractionEnabled = false
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0.0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.5,
            options: .curveEaseInOut,
            animations: {
                fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y)
                toView.center = CGPoint(x: toView.center.x - offset, y: toView.center.y)},
            completion: { _ in
                fromView.removeFromSuperview()
                self.selectedIndex = toIndex
                self.view.isUserInteractionEnabled = true})
    }
}
