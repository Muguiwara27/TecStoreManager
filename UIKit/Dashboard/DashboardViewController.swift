//
//  DashboardViewController.swift
//  TecStoreManager
//
//  Pantalla UIKit: Dashboard — conectada al Main.storyboard
//  Componentes IBOutlet: UILabel, UIImageView, UIButton (×7)
//  Componentes IBAction: goToProductos, goToClientes, goToVentas, goToMapa,
//                        goToReportes, goToConfiguracion, goToAcercaDe
//  Integración: Navega a SwiftUI vía UIHostingController
//

import UIKit
import SwiftUI

class DashboardViewController: UIViewController {

    // MARK: - Propiedades
    var currentUser: Usuario?

    // MARK: - IBOutlets (conectados desde el Storyboard)
    @IBOutlet weak var welcomeLabel: UILabel!           // UILabel — "Hola, [nombre]!"
    @IBOutlet weak var subtitleLabel: UILabel!          // UILabel — Subtítulo
    @IBOutlet weak var avatarImageView: UIImageView!    // UIImageView — Ícono de perfil

    // UIButton × 7 — Tarjetas del menú
    @IBOutlet weak var productosButton: UIButton!
    @IBOutlet weak var clientesButton: UIButton!
    @IBOutlet weak var ventasButton: UIButton!
    @IBOutlet weak var mapaButton: UIButton!
    @IBOutlet weak var reportesButton: UIButton!
    @IBOutlet weak var configuracionButton: UIButton!
    @IBOutlet weak var acercaDeButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        styleUIElements()
        setupLogoutButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        welcomeLabel?.text = "Hola, \(currentUser?.nombreCompletoSafe ?? "Usuario")! 👋"
    }

    // MARK: - Background
    private func setupBackground() {
        view.backgroundColor = UIColor(red: 0.063, green: 0.063, blue: 0.122, alpha: 1.0)
    }

    // MARK: - Estilizado de IBOutlets
    private func styleUIElements() {
        // UIImageView
        avatarImageView?.image = UIImage(systemName: "person.circle.fill")
        avatarImageView?.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)

        // UILabel
        subtitleLabel?.text      = "¿Qué deseas gestionar hoy?"
        subtitleLabel?.textColor = .systemGray2
        welcomeLabel?.textColor  = .white

        // Estilizar cada UIButton del menú
        styleMenuButton(productosButton,    title: "Productos",     icon: "cube.box.fill",      r: 0.25, g: 0.52, b: 0.96)
        styleMenuButton(clientesButton,     title: "Clientes",      icon: "person.2.fill",      r: 0.18, g: 0.72, b: 0.55)
        styleMenuButton(ventasButton,       title: "Ventas",        icon: "cart.fill",          r: 0.93, g: 0.42, b: 0.28)
        styleMenuButton(mapaButton,         title: "Mapa GPS",      icon: "map.fill",           r: 0.55, g: 0.34, b: 0.96)
        styleMenuButton(reportesButton,     title: "Reportes",      icon: "chart.bar.fill",     r: 0.93, g: 0.68, b: 0.10)
        styleMenuButton(configuracionButton,title: "Configuración", icon: "gearshape.fill",     r: 0.40, g: 0.40, b: 0.50)
        styleMenuButton(acercaDeButton,     title: "Acerca de",     icon: "info.circle.fill",   r: 0.25, g: 0.75, b: 0.85)
    }

    private func styleMenuButton(_ btn: UIButton?, title: String, icon: String, r: Double, g: Double, b: Double) {
        guard let btn = btn else { return }
        btn.backgroundColor = UIColor(red: r * 0.25, green: g * 0.25, blue: b * 0.25, alpha: 1.0)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth  = 1
        btn.layer.borderColor  = UIColor(red: r, green: g, blue: b, alpha: 0.3).cgColor
        btn.tintColor          = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        if let img = UIImage(systemName: icon) {
            btn.setImage(img, for: .normal)
        }
    }

    // MARK: - Logout
    private func setupLogoutButton() {
        let logoutBtn = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain, target: self, action: #selector(handleLogout)
        )
        logoutBtn.tintColor = .systemRed
        navigationItem.rightBarButtonItem = logoutBtn
    }

    // MARK: - IBActions — Navegación UIKit → UIKit / SwiftUI

    /// UIKit → UIKit
    @IBAction func goToProductos(_ sender: UIButton) {
        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
        let productosVC = storyboard.instantiateViewController(withIdentifier: "ProductosListVC")
        navigationController?.pushViewController(productosVC, animated: true)
    }

    /// UIKit → SwiftUI via UIHostingController
    @IBAction func goToClientes(_ sender: UIButton) {
        let hostingVC = makeClientesHostingController()
        hostingVC.title = "Clientes"
        navigationController?.pushViewController(hostingVC, animated: true)
    }

    /// UIKit → SwiftUI via UIHostingController
    @IBAction func goToVentas(_ sender: UIButton) {
        let hostingVC = makeVentasHostingController()
        hostingVC.title = "Ventas"
        navigationController?.pushViewController(hostingVC, animated: true)
    }

    /// UIKit → SwiftUI via UIHostingController
    @IBAction func goToMapa(_ sender: UIButton) {
        let hostingVC = makeMapaHostingController()
        hostingVC.title = "Mapa GPS"
        navigationController?.pushViewController(hostingVC, animated: true)
    }

    /// UIKit → SwiftUI via UIHostingController
    @IBAction func goToReportes(_ sender: UIButton) {
        let hostingVC = makeReportesHostingController()
        hostingVC.title = "Reportes"
        navigationController?.pushViewController(hostingVC, animated: true)
    }

    /// UIKit → UIKit
    @IBAction func goToConfiguracion(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ConfigVC") as? ConfiguracionViewController {
            navigationController?.pushViewController(vc, animated: true)
        } else {
            navigationController?.pushViewController(ConfiguracionViewController(), animated: true)
        }
    }

    /// UIKit → UIKit
    @IBAction func goToAcercaDe(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AcercaDeVC")
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func handleLogout() {
        let alert = UIAlertController(
            title: "Cerrar Sesión",
            message: "¿Deseas salir de TecStore Manager?",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Cerrar Sesión", style: .destructive) { [weak self] _ in
            self?.navigationController?.setNavigationBarHidden(true, animated: true)
            self?.navigationController?.popToRootViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }
}
