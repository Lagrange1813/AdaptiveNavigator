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

  private var stackForExpanding: [UIViewController] = []
}

extension AdaptiveNavigator {
  func configure() {
    delegate = self
    preferredDisplayMode = .oneBesideSecondary
    preferredSplitBehavior = .tile
    view.backgroundColor = .systemBackground

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
      navController.rawPushViewController(vc, animated: true)

    } else {
      guard
        viewControllers.count >= 2,
        let primary = viewControllers[0] as? EmbeddedTabBarController,
        let navController = viewControllers[1] as? UINavigationController else { return }

      let isPlaceholderTop = navController.topViewController is Placeholder
      let isFromPrimary = (sender as? UIViewController) == (viewControllers[0] as? EmbeddedTabBarController)?.selectedViewController
        || (sender as? EmbeddedTabBarController === primary)

      if isFromPrimary {
        navController.popToRootViewController(animated: false)
      }

      navController.pushViewController(vc, animated: isPlaceholderTop || !isFromPrimary)
    }
  }
}

extension AdaptiveNavigator: UISplitViewControllerDelegate {
  // Collapse
  public func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
    guard
      svc.viewControllers.count >= 2,
      let primary = svc.viewControllers[0] as? EmbeddedTabBarController,
      let secondary = svc.viewControllers[1] as? UINavigationController
    else { return .primary }

    secondary.popToRootViewController(animated: false)?.forEach {
      primary.rawPushViewController($0, animated: false)
    }

    return .primary
  }

  // Expand
  public func splitViewController(_ svc: UISplitViewController, displayModeForExpandingToProposedDisplayMode proposedDisplayMode: UISplitViewController.DisplayMode) -> UISplitViewController.DisplayMode {
    guard
      let primary = svc.viewControllers[0] as? EmbeddedTabBarController
    else { return .oneBesideSecondary }

    primary.popToRootViewController(animated: false)?.forEach {
      stackForExpanding.append($0)
    }

    return .oneBesideSecondary
  }

  public func splitViewControllerDidExpand(_ svc: UISplitViewController) {
    guard
      svc.viewControllers.count >= 2,
      let secondary = svc.viewControllers[1] as? UINavigationController
    else { return }

    stackForExpanding.forEach {
      secondary.pushViewController($0, animated: false)
    }
    stackForExpanding = []
  }
}
