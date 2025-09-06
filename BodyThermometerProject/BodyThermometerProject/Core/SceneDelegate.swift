//
//  SceneDelegate.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.06.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var appRouter: AppRouter?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        appRouter = AppRouter(windowScene: windowScene)
        appRouter?.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}

    

}
