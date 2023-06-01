//
//  EmbeddedTabBarController.swift
//
//
//  Created by Lagrange1813 on 4/25/23.
//

import UIKit

public class EmbeddedTabBarController: UINavigationController {
  public enum NavigationMode {
    /// Used for integration with SplitView
    case embedded
    case alone
  }
  
  let navigationMode: NavigationMode
  public weak var navigator: AdaptiveNavigator?
  
  public init(mode: NavigationMode, navigator: AdaptiveNavigator? = nil) {
    self.navigationMode = mode
    self.navigator = navigator
    super.init(nibName: nil, bundle: nil)
    delegate = self
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  var offset: CGFloat {
    let device = UIDevice.current.userInterfaceIdiom
    switch device {
      case .phone:
        
        let screen = view.window?.windowScene?.screen ?? UIScreen()
        let screenWidth = screen.nativeBounds.width / screen.nativeScale
        
        if screenWidth < 400 {
          let orientation = UIDevice.current.orientation
          switch orientation {
            case .portrait:
              return 49
            case .landscapeLeft, .landscapeRight:
              return 32
            default:
              break
          }
        }
        
        return 49
        
      case .pad:
        return 50
      default:
        return 0
    }
  }

  var topConstraint: NSLayoutConstraint?
  let tabBar = UITabBar()
  var isTabBarHidden = false
  
  /// The currently selected view controller.
  public var selectedViewController: UIViewController? {
    didSet {
      if let selectedViewController {
        guard let index = tabBarViewControllers.firstIndex(of: selectedViewController) else { return }
        tabBar.selectedItem = tabBar.items?[index]
      } else {
        tabBar.selectedItem = nil
      }
    }
  }
  
  /// Index of the currently selected view controller.
  public var selectedIndex: Int? {
    get {
      guard
        let selectedViewController,
        let index = tabBarViewControllers.firstIndex(of: selectedViewController)
      else { return nil }
      return index
    }
    set {
      if let newValue {
        guard newValue < tabBarViewControllers.count else { return }
        selectedViewController = tabBarViewControllers[newValue]
        replaceWithSelectedViewController()
      } else {
        selectedViewController = nil
      }
    }
  }
  
  private func replaceWithSelectedViewController() {
    if let selectedViewController = selectedViewController {
      replaceContent(with: selectedViewController)
    }
  }
  
  /// The view controllers displayed by the tab bar.
  public var tabBarViewControllers: [UIViewController] = [] {
    didSet {
      tabBar.items = tabBarViewControllers.map {
        $0.tabBarItem ?? UITabBarItem(title: $0.title, image: nil, tag: 0)
      }
    }
  }
  
  public weak var tabBarDelegate: EmbeddedTabBarControllerDelegate?
  
  var countOfViewControllers: Int = 0 {
    didSet {
      if countOfViewControllers <= 1 {
        showTabBar()
      } else {
        hideTabBar()
      }
    }
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    configure()
    layout()
  }
  
  override public func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if countOfViewControllers == 1 {
      for viewController in tabBarViewControllers {
        viewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
      }
    }
  }
  
  override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    topConstraint?.constant = -offset
  }
}

extension EmbeddedTabBarController {
  func configure() {
    view.backgroundColor = .systemBackground
    tabBar.delegate = self
    tabBar.isTranslucent = true
  }
  
  func layout() {
    tabBar.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tabBar)

    topConstraint = tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -offset)
    
    guard let topConstraint else { return }
    
    NSLayoutConstraint.activate([
      tabBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topConstraint,
      tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
}
