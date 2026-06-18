//
//  SceneDelegate.swift
//  TecStoreManager
//
//  Carga el Main.storyboard como punto de entrada.
//  El NavigationController inicial ya tiene LoginViewController como rootViewController.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // ── Cargar desde Main.storyboard ──────────────────────────────────
        // El storyboard tiene un UINavigationController como initialViewController
        // que embebe LoginViewController como rootViewController.
        let storyboard     = UIStoryboard(name: "Main", bundle: nil)
        let initialVC      = storyboard.instantiateInitialViewController()!
        styleNavigationBar()

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = initialVC
        window?.makeKeyAndVisible()
    }

    // MARK: - Estilo de la Navigation Bar (global)
    private func styleNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor  = UIColor(red: 0.08, green: 0.08, blue: 0.15, alpha: 1.0)
        appearance.titleTextAttributes      = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor            = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
    }
}
