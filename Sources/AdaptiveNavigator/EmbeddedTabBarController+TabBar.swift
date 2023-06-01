//
//  EmbeddedTabBarController+TabBar.swift
//
//
//  Created by Lagrange1813 on 5/19/23.
//

import UIKit

public extension EmbeddedTabBarController {
  override func pushViewController(_ viewController: UIViewController, animated: Bool) {
    if navigationMode == .embedded {
      navigator?.showDetailViewController(viewController, sender: self)
    } else {
      countOfViewControllers += 1
      super.pushViewController(viewController, animated: animated)
    }
  }
  
  func rawPushViewController(_ viewController: UIViewController, animated: Bool) {
    countOfViewControllers += 1
    super.pushViewController(viewController, animated: animated)
  }
  
//  override func popViewController(animated: Bool) -> UIViewController? {
//    countOfViewControllers -= 1
//    return super.popViewController(animated: animated)
//  }
  
  override func popToRootViewController(animated: Bool) -> [UIViewController]? {
    countOfViewControllers = 1
    return super.popToRootViewController(animated: animated)
  }
}

extension EmbeddedTabBarController: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    if
      let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
      !navigationController.viewControllers.contains(poppedViewController)
    {
      countOfViewControllers -= 1
    }
  }
}

extension EmbeddedTabBarController: UITabBarDelegate {
  public func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
    let viewController = tabBarViewControllers[tabBar.items?.firstIndex(of: item) ?? 0]
    
    if
      let tabBarDelegate = tabBarDelegate,
      tabBarDelegate.responds(to: #selector(tabBarDelegate.tabBarController(_:shouldSelect:)))
    {
      if tabBarDelegate.tabBarController?(self, shouldSelect: viewController) ?? true {
        replaceContent(with: viewController)
      } else {
        tabBar.selectedItem = (selectedIndex != nil) ? tabBar.items?[selectedIndex ?? 0] : nil
      }
    } else {
      replaceContent(with: viewController)
    }
    
    tabBarDelegate?.tabBarController?(self, didSelect: viewController)
  }
  
  func replaceContent(with viewController: UIViewController) {
    setViewControllers([viewController], animated: false)
    countOfViewControllers = 1
    selectedViewController = viewController
  }
}

public extension EmbeddedTabBarController {
  func hideTabBar() {
    if isTabBarHidden { return }
    isTabBarHidden = true
    
    UIView.animate(withDuration: 0.25) { [unowned self] in
      tabBar.alpha = 0
    }
  }
  
  func showTabBar() {
    if !isTabBarHidden { return }
    isTabBarHidden = false
    
    UIView.animate(withDuration: 0.25) { [unowned self] in
      tabBar.alpha = 1
    }
  }
}
