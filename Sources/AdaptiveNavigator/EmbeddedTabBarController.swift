//
//  EmbeddedTabBarController.swift
//
//
//  Created by Lagrange1813 on 4/25/23.
//

import UIKit

public class EmbeddedTabBarController: UINavigationController {
  public init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var offset: CGFloat {
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

  private var topConstraint: NSLayoutConstraint?
  private let tabBar = UITabBar()
  private var isTabBarHidden = false
  
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
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    configure()
    layout()
  }
  
  override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
  }
}

extension EmbeddedTabBarController {
  func configure() {
    view.backgroundColor = .systemBackground
    tabBar.delegate = self
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
  
  private func replaceContent(with viewController: UIViewController) {
    setViewControllers([viewController], animated: false)
    selectedViewController = viewController
  }
}

extension EmbeddedTabBarController {
  public func hideTabBar() {
    if isTabBarHidden { return }
    isTabBarHidden = true
    
    UIView.animate(withDuration: 0.25) { [unowned self] in
      tabBar.alpha = 0
    }
  }
  
  public func showTabBar() {
    if !isTabBarHidden { return }
    isTabBarHidden = false
    
    UIView.animate(withDuration: 0.25) { [unowned self] in
      tabBar.alpha = 1
    }
  }
}
