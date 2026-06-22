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
        setupProgrammaticUIIfNeeded()
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

    private func setupProgrammaticUIIfNeeded() {
        guard productosButton == nil else { return }

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        let content = UIView()
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(content)

        let avatar = UIImageView()
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.contentMode = .scaleAspectFit

        let welcome = UILabel()
        welcome.translatesAutoresizingMaskIntoConstraints = false
        welcome.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        welcome.numberOfLines = 0

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.font = UIFont.systemFont(ofSize: 15, weight: .regular)

        let header = UIStackView(arrangedSubviews: [avatar, welcome, subtitle])
        header.axis = .vertical
        header.alignment = .center
        header.spacing = 10

        let productos = makeDashboardButton(action: #selector(goToProductos(_:)))
        let clientes = makeDashboardButton(action: #selector(goToClientes(_:)))
        let ventas = makeDashboardButton(action: #selector(goToVentas(_:)))
        let mapa = makeDashboardButton(action: #selector(goToMapa(_:)))
        let reportes = makeDashboardButton(action: #selector(goToReportes(_:)))
        let configuracion = makeDashboardButton(action: #selector(goToConfiguracion(_:)))
        let acerca = makeDashboardButton(action: #selector(goToAcercaDe(_:)))

        let buttons = UIStackView(arrangedSubviews: [
            productos, clientes, ventas, mapa, reportes, configuracion, acerca
        ])
        buttons.axis = .vertical
        buttons.spacing = 12

        let stack = UIStackView(arrangedSubviews: [header, buttons])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 26
        content.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scroll.widthAnchor),

            stack.topAnchor.constraint(equalTo: content.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -22),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -28),

            avatar.heightAnchor.constraint(equalToConstant: 76),
            avatar.widthAnchor.constraint(equalToConstant: 76),
        ])

        [productos, clientes, ventas, mapa, reportes, configuracion, acerca].forEach {
            $0.heightAnchor.constraint(equalToConstant: 58).isActive = true
        }

        avatarImageView = avatar
        welcomeLabel = welcome
        subtitleLabel = subtitle
        productosButton = productos
        clientesButton = clientes
        ventasButton = ventas
        mapaButton = mapa
        reportesButton = reportes
        configuracionButton = configuracion
        acercaDeButton = acerca
    }

    private func makeDashboardButton(action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
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
        performSegue(withIdentifier: "DashboardToProductosSegue", sender: sender)
    }

    /// UIKit → SwiftUI via storyboard-hosted UIHostingController
    @IBAction func goToClientes(_ sender: UIButton) {
        performSegue(withIdentifier: "DashboardToClientesSegue", sender: sender)
    }

    /// UIKit → SwiftUI via storyboard-hosted UIHostingController
    @IBAction func goToVentas(_ sender: UIButton) {
        performSegue(withIdentifier: "DashboardToVentasSegue", sender: sender)
    }

    /// UIKit → SwiftUI via storyboard-hosted UIHostingController
    @IBAction func goToMapa(_ sender: UIButton) {
        performSegue(withIdentifier: "DashboardToMapaSegue", sender: sender)
    }

    /// UIKit → SwiftUI via storyboard-hosted UIHostingController
    @IBAction func goToReportes(_ sender: UIButton) {
        performSegue(withIdentifier: "DashboardToReportesSegue", sender: sender)
    }

    /// UIKit → UIKit
    @IBAction func goToConfiguracion(_ sender: UIButton) {
        performSegue(withIdentifier: "DashboardToConfigSegue", sender: sender)
    }

    /// UIKit → UIKit
    @IBAction func goToAcercaDe(_ sender: UIButton) {
        performSegue(withIdentifier: "DashboardToAcercaDeSegue", sender: sender)
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
