//
//  AcercaDeViewController.swift
//  TecStoreManager
//
//  Pantalla UIKit: Acerca de — conectada al Main.storyboard
//  Componentes IBOutlet: UIImageView, UILabel (×4)
//

import UIKit

class AcercaDeViewController: UIViewController {

    // MARK: - IBOutlets (conectados desde el Storyboard)
    @IBOutlet weak var logoImageView: UIImageView!  // UIImageView — Logo
    @IBOutlet weak var appNameLabel: UILabel!       // UILabel — Nombre de la app
    @IBOutlet weak var versionLabel: UILabel!       // UILabel — Versión
    @IBOutlet weak var descriptionLabel: UILabel!   // UILabel — Descripción
    @IBOutlet weak var techLabel: UILabel!          // UILabel — Tecnologías

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Acerca de"
        setupBackground()
        styleUIElements()
    }

    // MARK: - Background
    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.06, green: 0.06, blue: 0.12, alpha: 1.0).cgColor,
            UIColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1.0).cgColor
        ]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }

    // MARK: - Estilizado de IBOutlets
    private func styleUIElements() {
        // UIImageView
        logoImageView?.image    = UIImage(systemName: "laptopcomputer.and.iphone")
        logoImageView?.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)

        // UILabel × 4
        appNameLabel?.textColor     = .white
        versionLabel?.textColor     = .systemGray
        descriptionLabel?.textColor = UIColor.systemGray2
        techLabel?.textColor        = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)

        appNameLabel?.text     = "TecStore Manager"
        versionLabel?.text     = "Versión 1.0.0 · Build 2025"
        descriptionLabel?.text = "Aplicación académica para la gestión integral de una tienda tecnológica. Desarrollada con UIKit, SwiftUI, Core Data, MapKit y arquitectura MVVM."
        techLabel?.text        = "Swift · UIKit · SwiftUI · Core Data · MapKit · CoreLocation · MVVM"
    }
}
