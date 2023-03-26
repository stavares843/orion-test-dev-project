import UIKit
import WebKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var tabBarController: UITabBarController?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Create a window programmatically
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()

        // Create tab bar controller with two tabs
        tabBarController = UITabBarController()
        tabBarController?.viewControllers = [createBrowserTab()]
        window?.rootViewController = tabBarController
    }

    func createBrowserTab() -> UINavigationController {
        let browserVC = BrowserViewController()
        browserVC.tabBarItem = UITabBarItem(title: "Browser", image: UIImage(systemName: "globe"), tag: 0)
        let navigationController = UINavigationController(rootViewController: browserVC)
        return navigationController
    }

}
