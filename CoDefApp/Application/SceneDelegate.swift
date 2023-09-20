/*
 Construction Defect Tracker
 App for tracking construction defects 
 Copyright: Michael Rönnau mr@elbe5.de 2023
 */

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        //Log.info("SceneDelegate will connect start")
        FileController.initialize()
        //FileController.logFileInfo()
        AppState.load()
        AppData.load()
        AppState.shared.companyFilter.initFilter()
        guard let windowScene = (scene as? UIWindowScene) else { return }
        mainWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window = mainWindow
        mainWindow.windowScene = windowScene
        mainController = MainViewController()
        let navViewController = UINavigationController(rootViewController: mainController)
        mainWindow.rootViewController = navViewController
        mainWindow.makeKeyAndVisible()
        //Log.info("SceneDelegate will connect end")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        //Log.info("SceneDelegate did disconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        //Log.info("SceneDelegate did become active")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        AppState.shared.save()
        AppData.shared.save()
        //Log.info("SceneDelegate will resign active")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        //Log.info("SceneDelegate will enter foreground")
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        FileController.deleteTemporaryFiles()
        //Log.info("SceneDelegate did enter background")
    }

}

var mainWindow : UIWindow!
var mainController : MainViewController!

