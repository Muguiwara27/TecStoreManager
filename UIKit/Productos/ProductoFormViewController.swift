//
//  ProductoFormViewController.swift
//  TecStoreManager
//
//  Pantalla UIKit: Formulario de Producto (Crear / Editar)
//  Componentes: UILabel, UITextField (×5), UISwitch, UIButton, UIAlertController, UISegmentedControl (categoría)
//

import UIKit

class ProductoFormViewController: UIViewController {

    // MARK: - Dependencias
    private let viewModel: ProductoViewModel
    private let producto: Producto? // nil = crear nuevo
    var onSave: (() -> Void)?

    init(viewModel: ProductoViewModel, producto: Producto?) {
        self.viewModel = viewModel
        self.producto  = producto
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - UI
    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    private let codigoLabel  = TSLabel(text: "Código *", style: .fieldLabel)
    private let codigoTF     = TSTextField(placeholder: "Ej: PROD-001", icon: "barcode")

    private let nombreLabel  = TSLabel(text: "Nombre *", style: .fieldLabel)
    private let nombreTF     = TSTextField(placeholder: "Nombre del producto", icon: "cube.box")

    private let precioLabel  = TSLabel(text: "Precio (S/) *", style: .fieldLabel)
    private let precioTF: TSTextField = {
        let tf = TSTextField(placeholder: "0.00", icon: "dollarsign.circle")
        tf.keyboardType = .decimalPad
        return tf
    }()

    private let stockLabel   = TSLabel(text: "Stock inicial", style: .fieldLabel)
    private let stockTF: TSTextField = {
        let tf = TSTextField(placeholder: "0", icon: "tray.full")
        tf.keyboardType = .numberPad
        return tf
    }()

    // UISegmentedControl — Categoría
    private let categoriaLabel = TSLabel(text: "Categoría", style: .fieldLabel)
    private let categoriaSegmented: UISegmentedControl = {
        let cats = ["Computad.", "Celulares", "Tablets", "Accesorios"]
        let sc = UISegmentedControl(items: cats)
        sc.selectedSegmentIndex = 0
        sc.selectedSegmentTintColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11)], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11)], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    private let categoriaSegmented2: UISegmentedControl = {
        let cats = ["Audio", "Gaming", "Otros"]
        let sc = UISegmentedControl(items: cats)
        sc.selectedSegmentIndex = -1
        sc.selectedSegmentTintColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11)], for: .normal)
        sc.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11)], for: .selected)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()

    // UISwitch — Estado
    private let estadoLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Producto Activo"
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private let estadoSwitch: UISwitch = {
        let sw = UISwitch()
        sw.isOn = true
        sw.onTintColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()

    private let errorLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .systemRed
        lbl.font = UIFont.systemFont(ofSize: 12)
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // UIButton — Guardar
    private let guardarButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        btn.layer.cornerRadius = 14
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // Categorías del primer segmented
    private let categorias1 = ["Computadoras", "Celulares", "Tablets", "Accesorios"]
    private let categorias2 = ["Audio", "Gaming", "Otros"]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = producto == nil ? "Nuevo Producto" : "Editar Producto"
        guardarButton.setTitle(producto == nil ? "Guardar Producto" : "Actualizar Producto", for: .normal)

        setupBackground()
        setupScrollView()
        setupLayout()
        setupActions()
        precargarDatos()
    }

    // MARK: - Precargar datos (modo edición)
    private func precargarDatos() {
        guard let p = producto else { return }
        codigoTF.text   = p.codigoSafe
        nombreTF.text   = p.nombreSafe
        precioTF.text   = String(format: "%.2f", p.precio)
        stockTF.text    = "\(p.stock)"
        estadoSwitch.isOn = p.estado

        let cat = p.categoriaSafe
        if let idx = categorias1.firstIndex(of: cat) {
            categoriaSegmented.selectedSegmentIndex = idx
        } else if let idx = categorias2.firstIndex(of: cat) {
            categoriaSegmented.selectedSegmentIndex = -1
            categoriaSegmented2.selectedSegmentIndex = idx
        }
    }

    // MARK: - Background
    private func setupBackground() {
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.14, alpha: 1.0)
    }

    // MARK: - ScrollView
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Layout
    private func setupLayout() {
        let switchRow = makeSwitchRow()
        let stack = UIStackView(arrangedSubviews: [
            codigoLabel, codigoTF,
            nombreLabel, nombreTF,
            precioLabel, precioTF,
            stockLabel, stockTF,
            categoriaLabel, categoriaSegmented, categoriaSegmented2,
            switchRow,
            errorLabel,
            guardarButton
        ])
        stack.axis = .vertical
        stack.spacing = 8
        stack.setCustomSpacing(16, after: codigoTF)
        stack.setCustomSpacing(16, after: nombreTF)
        stack.setCustomSpacing(16, after: precioTF)
        stack.setCustomSpacing(16, after: stockTF)
        stack.setCustomSpacing(4, after: categoriaSegmented)
        stack.setCustomSpacing(16, after: categoriaSegmented2)
        stack.setCustomSpacing(16, after: switchRow)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let card = UIView()
        card.backgroundColor = UIColor(white: 1, alpha: 0.05)
        card.layer.cornerRadius = 20
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)
        contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),

            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),

            codigoTF.heightAnchor.constraint(equalToConstant: 50),
            nombreTF.heightAnchor.constraint(equalToConstant: 50),
            precioTF.heightAnchor.constraint(equalToConstant: 50),
            stockTF.heightAnchor.constraint(equalToConstant: 50),
            guardarButton.heightAnchor.constraint(equalToConstant: 52),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    private func makeSwitchRow() -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(estadoLabel)
        row.addSubview(estadoSwitch)
        NSLayoutConstraint.activate([
            estadoLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            estadoLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            estadoSwitch.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            estadoSwitch.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            row.heightAnchor.constraint(equalToConstant: 44)
        ])
        return row
    }

    // MARK: - Actions
    private func setupActions() {
        guardarButton.addTarget(self, action: #selector(handleGuardar), for: .touchUpInside)
        categoriaSegmented.addTarget(self, action: #selector(seg1Changed), for: .valueChanged)
        categoriaSegmented2.addTarget(self, action: #selector(seg2Changed), for: .valueChanged)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancelar", style: .plain, target: self, action: #selector(handleCancelar)
        )
    }

    @objc private func seg1Changed() { categoriaSegmented2.selectedSegmentIndex = -1 }
    @objc private func seg2Changed() { categoriaSegmented.selectedSegmentIndex = -1 }

    @objc private func handleGuardar() {
        let codigo  = codigoTF.text ?? ""
        let nombre  = nombreTF.text ?? ""
        let precioStr = precioTF.text?.replacingOccurrences(of: ",", with: ".") ?? ""
        let precio  = Double(precioStr) ?? 0
        let stock   = Int32(stockTF.text ?? "0") ?? 0
        let estado  = estadoSwitch.isOn

        // Determinar categoría seleccionada
        var categoria = "Otros"
        if categoriaSegmented.selectedSegmentIndex >= 0 {
            categoria = categorias1[categoriaSegmented.selectedSegmentIndex]
        } else if categoriaSegmented2.selectedSegmentIndex >= 0 {
            categoria = categorias2[categoriaSegmented2.selectedSegmentIndex]
        }

        let exitoso = viewModel.guardarProducto(
            codigo: codigo, nombre: nombre, categoria: categoria,
            precio: precio, stock: stock, estado: estado,
            productoExistente: producto
        )

        if exitoso {
            let alert = UIAlertController(
                title: "✅ Éxito",
                message: "El producto fue \(producto == nil ? "registrado" : "actualizado") correctamente.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.onSave?()
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        } else {
            errorLabel.text = viewModel.errorMessage
            let alert = UIAlertController(title: "Error", message: viewModel.errorMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    @objc private func handleCancelar() { dismiss(animated: true) }
    @objc private func dismissKeyboard() { view.endEditing(true) }
}
