//
//  ProductoDetalleViewController.swift
//  TecStoreManager
//
//  Pantalla UIKit: Detalle del Producto
//  Componentes: UILabel (×8), UIImageView, UIButton (editar / eliminar)
//

import UIKit

class ProductoDetalleViewController: UIViewController {

    // MARK: - Dependencias
    private let producto: Producto
    private let viewModel: ProductoViewModel

    init(producto: Producto, viewModel: ProductoViewModel) {
        self.producto  = producto
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI

    // UIImageView — Ícono del producto
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "cube.box.fill")
        iv.tintColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // UILabel × 8
    private let nombreLabel   = makeDetailTitle()
    private let codigoLabel   = makeDetailSubtitle()
    private let categoriaLabel = makeInfoLabel(icon: "tag.fill")
    private let precioLabel    = makeInfoLabel(icon: "banknote")
    private let stockLabel     = makeInfoLabel(icon: "tray.full.fill")
    private let fechaLabel     = makeInfoLabel(icon: "calendar")
    private let estadoLabel    = makeInfoLabel(icon: "checkmark.circle.fill")
    private let ventasLabel    = makeInfoLabel(icon: "cart.fill")

    // UIButton — Editar
    private let editarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(" Editar Producto", for: .normal)
        btn.setImage(UIImage(systemName: "pencil"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // UIButton — Eliminar
    private let eliminarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(" Eliminar", for: .normal)
        btn.setImage(UIImage(systemName: "trash"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.systemRed.withAlphaComponent(0.75)
        btn.layer.cornerRadius = 12
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detalle"
        setupBackground()
        setupUI()
        cargarDatos()
        setupActions()
    }

    // MARK: - Background
    private func setupBackground() {
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.14, alpha: 1.0)
    }

    // MARK: - Setup UI
    private func setupUI() {
        let card = UIView()
        card.backgroundColor = UIColor(white: 1, alpha: 0.05)
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        let infoStack = UIStackView(arrangedSubviews: [
            categoriaLabel, precioLabel, stockLabel, fechaLabel, estadoLabel, ventasLabel
        ])
        infoStack.axis = .vertical
        infoStack.spacing = 12
        infoStack.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView(arrangedSubviews: [editarButton, eliminarButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(card)
        card.addSubview(iconImageView)
        card.addSubview(nombreLabel)
        card.addSubview(codigoLabel)
        card.addSubview(infoStack)
        view.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            iconImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            iconImageView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 64),
            iconImageView.heightAnchor.constraint(equalToConstant: 64),

            nombreLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            nombreLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            nombreLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            codigoLabel.topAnchor.constraint(equalTo: nombreLabel.bottomAnchor, constant: 4),
            codigoLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            codigoLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),

            infoStack.topAnchor.constraint(equalTo: codigoLabel.bottomAnchor, constant: 20),
            infoStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            infoStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            infoStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),

            buttonStack.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    // MARK: - Cargar datos
    private func cargarDatos() {
        nombreLabel.text   = producto.nombreSafe
        codigoLabel.text   = "Código: \(producto.codigoSafe)"
        categoriaLabel.text = "📦  Categoría: \(producto.categoriaSafe)"
        precioLabel.text    = "💰  Precio: S/ \(String(format: "%.2f", producto.precio))"
        stockLabel.text     = "🗂   Stock: \(producto.stock) unidades"
        if let fecha = producto.fechaRegistro {
            let fmt = DateFormatter()
            fmt.dateStyle = .medium
            fechaLabel.text = "📅  Registrado: \(fmt.string(from: fecha))"
        }
        estadoLabel.text = "✅  Estado: \(producto.estado ? "Activo" : "Inactivo")"
        ventasLabel.text = "🛒  Ventas realizadas: \(producto.ventasArray.count)"
    }

    // MARK: - Actions
    private func setupActions() {
        editarButton.addTarget(self, action: #selector(handleEditar), for: .touchUpInside)
        eliminarButton.addTarget(self, action: #selector(handleEliminar), for: .touchUpInside)
    }

    @objc private func handleEditar() {
        let formVC = ProductoFormViewController(viewModel: viewModel, producto: producto)
        formVC.onSave = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        let nav = UINavigationController(rootViewController: formVC)
        present(nav, animated: true)
    }

    @objc private func handleEliminar() {
        let alert = UIAlertController(
            title: "Eliminar Producto",
            message: "¿Estás seguro de eliminar '\(producto.nombreSafe)'? Esta acción no se puede deshacer.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.viewModel.eliminarProducto(self.producto)
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - Factory Methods (UILabel)
    private static func makeDetailTitle() -> UILabel {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    private static func makeDetailSubtitle() -> UILabel {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = UIColor.systemGray3
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    private static func makeInfoLabel(icon: String) -> UILabel {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }
}
