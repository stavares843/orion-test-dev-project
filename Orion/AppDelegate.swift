import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create window
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        // Create TabBarController and set it as root view controller
        let tabBarController = UITabBarController()
        let viewController1 = BrowserViewController()
        let viewController2 = TableViewController()
        tabBarController.viewControllers = [viewController1, viewController2]
        window?.rootViewController = tabBarController

        // Change the tint color of the tab bar items to white
        UITabBar.appearance().tintColor = .white

        // Change the background color of the tab bar to black
        UITabBar.appearance().barTintColor = .black

        // Change the font and font size of the tab bar item titles
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Arial", size: 18)]
        UITabBarItem.appearance().setTitleTextAttributes(attributes as [NSAttributedString.Key: Any], for: .normal)

        return true
    }
}
