//
//  EmbeddedTabBarControllerDelegate.swift
//
//
//  Created by Lagrange1813 on 4/27/23.
//

import UIKit

@objc @MainActor public protocol EmbeddedTabBarControllerDelegate: NSObjectProtocol {
  @objc optional func tabBarController(
    _ tabBarController: EmbeddedTabBarController,
    shouldSelect viewController: UIViewController
  ) -> Bool
  @objc optional func tabBarController(
    _ tabBarController: EmbeddedTabBarController,
    didSelect viewController: UIViewController
  )
}
