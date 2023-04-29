//
//  AdaptiveNavigator.swift
//
//
//  Created by Lagrange1813 on 4/25/23.
//

import UIKit

open class Placeholder: UIViewController {}

public class AdaptiveNavigator: UISplitViewController {
  private let embeddedTabBarController: EmbeddedTabBarController
  private let makePlaceholder: () -> Placeholder

  /// Init a new AdaptiveNavigator
  /// - Parameters:
  ///  - primary: The primary view controller
  ///  - placeholderProvider: A closure that returns a Placeholder
  public init(primary: EmbeddedTabBarController, placeholderProvider: @escaping () -> Placeholder) {
    embeddedTabBarController = primary
    makePlaceholder = placeholderProvider
    super.init(style: .doubleColumn)
    configure()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension AdaptiveNavigator {
  func configure() {
    delegate = self
    preferredDisplayMode = .oneBesideSecondary
    preferredSplitBehavior = .tile
    view.backgroundColor = .systemBackground
    
    embeddedTabBarController.delegate = self
    setViewController(embeddedTabBarController, for: .primary)
    setViewController(makeSecondaryStack(), for: .secondary)
    
    minimumPrimaryColumnWidth = 320
    maximumPrimaryColumnWidth = 320
  }

  func makeSecondaryStack() -> UINavigationController {
    UINavigationController(rootViewController: makePlaceholder())
  }
}

public extension AdaptiveNavigator {
  override func showDetailViewController(_ vc: UIViewController, sender: Any?) {
    if isCollapsed {
      
      guard
        viewControllers.count >= 1,
        let navController = viewControllers[0] as? EmbeddedTabBarController else { return }
      navController.pushViewController(vc, animated: true)
      navController.hideTabBar()
      
    } else {
      
      guard
        viewControllers.count >= 2,
        let navController = viewControllers[1] as? UINavigationController else { return }

      let isPlaceholderTop = navController.topViewController is Placeholder
      let isFromPrimary = (sender as? UIViewController) == (viewControllers[0] as? EmbeddedTabBarController)?.selectedViewController

      if isFromPrimary {
        navController.popToRootViewController(animated: false)
      }

      navController.pushViewController(vc, animated: isPlaceholderTop || !isFromPrimary)
    }
  }
}

extension AdaptiveNavigator: UISplitViewControllerDelegate {
  public func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
    guard
      svc.viewControllers.count >= 2,
      let primary = svc.viewControllers[0] as? EmbeddedTabBarController,
      let secondary = svc.viewControllers[1] as? UINavigationController
    else { return .primary }

    secondary.popToRootViewController(animated: false)?.forEach {
      primary.pushViewController($0, animated: false)
    }
    
    if primary.viewControllers.count > 1 {
      primary.hideTabBar()
    }
    
    return .primary
  }

  public func splitViewControllerDidExpand(_ svc: UISplitViewController) {
    guard
      svc.viewControllers.count >= 2,
      let primary = svc.viewControllers[0] as? EmbeddedTabBarController,
      let secondary = svc.viewControllers[1] as? UINavigationController
    else { return }

    primary.popToRootViewController(animated: false)?.forEach {
      secondary.pushViewController($0, animated: false)
    }
    
    primary.showTabBar()
  }
}

extension AdaptiveNavigator: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
    if isCollapsed {
      guard
        viewControllers.count == 1,
        let controller = viewControllers[0] as? EmbeddedTabBarController else { return }
      if controller.viewControllers.count == 1 {
        controller.showTabBar()
      }
    }
  }
}
