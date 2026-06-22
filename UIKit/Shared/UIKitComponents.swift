//
//  UIKitComponents.swift
//  TecStoreManager
//

import UIKit

final class TSLabel: UILabel {
    enum Style {
        case fieldLabel
    }

    init(text: String, style: Style) {
        super.init(frame: .zero)
        self.text = text
        translatesAutoresizingMaskIntoConstraints = false
        apply(style)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        apply(.fieldLabel)
    }

    private func apply(_ style: Style) {
        switch style {
        case .fieldLabel:
            font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            textColor = .systemGray2
        }
    }
}

final class TSTextField: UITextField {
    init(placeholder: String, icon: String? = nil) {
        super.init(frame: .zero)
        self.placeholder = placeholder
        translatesAutoresizingMaskIntoConstraints = false
        applyStyle(icon: icon)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        applyStyle(icon: nil)
    }

    private func applyStyle(icon: String?) {
        backgroundColor = UIColor(white: 1, alpha: 0.08)
        textColor = .white
        tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [.foregroundColor: UIColor.systemGray3]
        )
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.15).cgColor

        let container = UIView(frame: CGRect(x: 0, y: 0, width: icon == nil ? 16 : 42, height: 0))
        if let icon {
            let imageView = UIImageView(image: UIImage(systemName: icon))
            imageView.tintColor = .systemGray3
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 14, y: 0, width: 18, height: 18)
            imageView.center.y = 25
            container.addSubview(imageView)
        }
        leftView = container
        leftViewMode = .always
    }
}

final class ProductoTableViewCell: UITableViewCell {
    private let iconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "cube.box.fill"))
        imageView.tintColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nombreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let detalleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let precioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor(red: 0.25, green: 0.85, blue: 0.55, alpha: 1.0)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stockLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        accessoryType = .none
    }

    func configure(with producto: Producto) {
        nombreLabel.text = producto.nombreSafe
        detalleLabel.text = "\(producto.codigoSafe) - \(producto.categoriaSafe)"
        precioLabel.text = String(format: "S/ %.2f", producto.precio)
        stockLabel.text = "Stock: \(producto.stock)"
        stockLabel.textColor = producto.stock > 0 ? .systemGreen : .systemRed
        accessoryType = .disclosureIndicator
    }

    private func configureLayout() {
        backgroundColor = .clear
        contentView.backgroundColor = UIColor(white: 1, alpha: 0.04)
        selectionStyle = .none

        contentView.addSubview(iconView)
        contentView.addSubview(nombreLabel)
        contentView.addSubview(detalleLabel)
        contentView.addSubview(precioLabel)
        contentView.addSubview(stockLabel)

        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            iconView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 34),
            iconView.heightAnchor.constraint(equalToConstant: 34),

            nombreLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            nombreLabel.trailingAnchor.constraint(lessThanOrEqualTo: precioLabel.leadingAnchor, constant: -12),
            nombreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),

            detalleLabel.leadingAnchor.constraint(equalTo: nombreLabel.leadingAnchor),
            detalleLabel.trailingAnchor.constraint(lessThanOrEqualTo: stockLabel.leadingAnchor, constant: -12),
            detalleLabel.topAnchor.constraint(equalTo: nombreLabel.bottomAnchor, constant: 4),

            precioLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            precioLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            precioLabel.widthAnchor.constraint(equalToConstant: 90),

            stockLabel.trailingAnchor.constraint(equalTo: precioLabel.trailingAnchor),
            stockLabel.topAnchor.constraint(equalTo: precioLabel.bottomAnchor, constant: 4),
            stockLabel.widthAnchor.constraint(equalToConstant: 90),
        ])
    }
}
