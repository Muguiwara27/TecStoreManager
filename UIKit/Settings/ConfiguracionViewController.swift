//
//  ConfiguracionViewController.swift
//  TecStoreManager
//
//  Pantalla UIKit: Configuración
//  Componentes: UILabel, UISwitch, UITableView, UISegmentedControl
//

import UIKit

class ConfiguracionViewController: UIViewController {

    // MARK: - Data
    private struct ConfigItem {
        let icon: String
        let titulo: String
        let subtitulo: String
        var tipoControl: ControlType
        enum ControlType { case toggle(Bool), segmented([String], Int), none }
    }

    private var items: [ConfigItem] = [
        ConfigItem(icon: "bell.fill",        titulo: "Notificaciones",    subtitulo: "Activar alertas del sistema",    tipoControl: .toggle(true)),
        ConfigItem(icon: "moon.fill",        titulo: "Modo Oscuro",       subtitulo: "Interfaz oscura siempre activa", tipoControl: .toggle(true)),
        ConfigItem(icon: "wifi",             titulo: "Sincronización",    subtitulo: "Sync automático al conectar",    tipoControl: .toggle(false)),
        ConfigItem(icon: "lock.shield.fill", titulo: "Seguridad",         subtitulo: "Requerir biometría al abrir",    tipoControl: .toggle(false)),
        ConfigItem(icon: "globe",            titulo: "Idioma",            subtitulo: "Seleccionar idioma de la app",   tipoControl: .segmented(["Español", "English"], 0)),
        ConfigItem(icon: "textformat.size",  titulo: "Tamaño de texto",   subtitulo: "Ajustar tipografía",             tipoControl: .segmented(["Pequeño", "Mediano", "Grande"], 1)),
        ConfigItem(icon: "trash.fill",       titulo: "Limpiar caché",     subtitulo: "Eliminar datos temporales",      tipoControl: .none),
    ]

    // MARK: - UI
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = .clear
        tv.separatorColor = UIColor(white: 1, alpha: 0.08)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Configuración"
        view.backgroundColor = UIColor(red: 0.07, green: 0.07, blue: 0.14, alpha: 1.0)
        setupTableView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ConfigCell.self, forCellReuseIdentifier: "ConfigCell")
    }
}

// MARK: - UITableViewDataSource
extension ConfiguracionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 4 : 3
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Preferencias" : "Sistema"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigCell", for: indexPath) as! ConfigCell
        let item = items[indexPath.section * 4 + indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ConfiguracionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 72 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.section * 4 + indexPath.row]
        if case .none = item.tipoControl, item.titulo == "Limpiar caché" {
            let alert = UIAlertController(
                title: "Limpiar Caché",
                message: "¿Deseas eliminar todos los datos temporales?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Limpiar", style: .destructive))
            alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
            present(alert, animated: true)
        }
    }
}

// MARK: - ConfigCell
class ConfigCell: UITableViewCell {

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let tituloLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    private let subtituloLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = .systemGray3
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    // UISwitch (reutilizable por celda)
    private let toggleSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
    }()

    // UISegmentedControl (reutilizable por celda)
    private var segmentedControl: UISegmentedControl?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(white: 1, alpha: 0.04)
        selectionStyle = .none

        contentView.addSubview(iconView)
        contentView.addSubview(tituloLabel)
        contentView.addSubview(subtituloLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 26),
            iconView.heightAnchor.constraint(equalToConstant: 26),

            tituloLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            tituloLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            tituloLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -90),

            subtituloLabel.topAnchor.constraint(equalTo: tituloLabel.bottomAnchor, constant: 3),
            subtituloLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            subtituloLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -90),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: ConfiguracionViewController.ConfigItem) {
        iconView.image = UIImage(systemName: item.icon)
        tituloLabel.text = item.titulo
        subtituloLabel.text = item.subtitulo

        // Limpiar controles anteriores
        toggleSwitch.removeFromSuperview()
        segmentedControl?.removeFromSuperview()
        segmentedControl = nil

        switch item.tipoControl {
        case .toggle(let value):
            toggleSwitch.isOn = value
            contentView.addSubview(toggleSwitch)
            NSLayoutConstraint.activate([
                toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
        case .segmented(let opts, let sel):
            let sc = UISegmentedControl(items: opts)
            sc.selectedSegmentIndex = sel
            sc.selectedSegmentTintColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
            sc.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11)], for: .normal)
            sc.setTitleTextAttributes([.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 11)], for: .selected)
            sc.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(sc)
            NSLayoutConstraint.activate([
                sc.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
                sc.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
            segmentedControl = sc
        case .none:
            accessoryType = .disclosureIndicator
        }
    }
}
