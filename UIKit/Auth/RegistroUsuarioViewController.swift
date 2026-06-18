//
//  RegistroUsuarioViewController.swift
//  TecStoreManager
//
//  Pantalla UIKit: Registro de Usuario — conectada al Main.storyboard
//  Componentes IBOutlet: UIScrollView, UITextField (×4), UISwitch, UILabel, UIButton
//  Componentes IBAction: handleGuardar
//

import UIKit

class RegistroUsuarioViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel = AuthViewModel()

    // MARK: - IBOutlets (conectados desde el Storyboard)
    @IBOutlet weak var scrollView: UIScrollView!                        // UIScrollView
    @IBOutlet weak var nombreUsuarioTextField: UITextField!             // UITextField — Nombre usuario
    @IBOutlet weak var passwordTextField: UITextField!                   // UITextField — Contraseña
    @IBOutlet weak var confirmPasswordTextField: UITextField!            // UITextField — Confirmar contraseña
    @IBOutlet weak var nombreCompletoTextField: UITextField!             // UITextField — Nombre completo
    @IBOutlet weak var estadoSwitch: UISwitch!                          // UISwitch — Estado activo
    @IBOutlet weak var errorLabel: UILabel!                             // UILabel — Mensaje error
    @IBOutlet weak var guardarButton: UIButton!                         // UIButton — Registrar

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nuevo Usuario"
        setupBackground()
        styleUIElements()
        registerForKeyboardNotifications()
        setupTapGesture()
    }

    // MARK: - Background
    private func setupBackground() {
        view.backgroundColor = UIColor(red: 0.063, green: 0.063, blue: 0.122, alpha: 1.0)
    }

    // MARK: - Estilizado de IBOutlets
    private func styleUIElements() {
        // UITextField — estilo glassmorphism
        for tf in [nombreUsuarioTextField, passwordTextField, confirmPasswordTextField, nombreCompletoTextField] {
            guard let tf = tf else { continue }
            tf.backgroundColor = UIColor(white: 1, alpha: 0.08)
            tf.textColor = .white
            tf.attributedPlaceholder = NSAttributedString(
                string: tf.placeholder ?? "",
                attributes: [.foregroundColor: UIColor.systemGray3]
            )
            tf.layer.cornerRadius = 12
            tf.layer.borderWidth  = 1
            tf.layer.borderColor  = UIColor(white: 1, alpha: 0.15).cgColor
            let pad = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
            tf.leftView = pad
            tf.leftViewMode = .always
        }

        // UISwitch
        estadoSwitch?.onTintColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)

        // UILabel — Error
        errorLabel?.textColor = .systemRed
        errorLabel?.text = ""

        // UIButton
        guardarButton?.backgroundColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        guardarButton?.layer.cornerRadius = 14
        guardarButton?.setTitleColor(.white, for: .normal)
        guardarButton?.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
    }

    // MARK: - IBAction

    /// Acción del UIButton "Registrar Usuario" — conectado en Storyboard
    @IBAction func handleGuardar(_ sender: UIButton) {
        let nombreUsuario   = nombreUsuarioTextField?.text ?? ""
        let password        = passwordTextField?.text ?? ""
        let confirmPassword = confirmPasswordTextField?.text ?? ""
        let nombreCompleto  = nombreCompletoTextField?.text ?? ""
        let estado          = estadoSwitch?.isOn ?? true

        // Verificar que las contraseñas coincidan
        guard password == confirmPassword else {
            mostrarAlerta(titulo: "Error", mensaje: "Las contraseñas no coinciden.")
            return
        }

        let exitoso = viewModel.registrarUsuario(
            nombreUsuario: nombreUsuario,
            password: password,
            nombreCompleto: nombreCompleto,
            estado: estado
        )

        errorLabel?.text = viewModel.errorMessage

        if exitoso {
            // UIAlertController — Éxito
            let alert = UIAlertController(
                title: "✅ Usuario Registrado",
                message: "El usuario '\(nombreUsuario)' fue creado exitosamente.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(alert, animated: true)
        } else {
            mostrarAlerta(titulo: "Error de Validación", mensaje: viewModel.errorMessage)
        }
    }

    // MARK: - Helpers
    private func mostrarAlerta(titulo: String, mensaje: String) {
        let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    // MARK: - Keyboard Avoidance
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ n: Notification) {
        if let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            scrollView?.contentInset.bottom = frame.height + 20
        }
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        scrollView?.contentInset.bottom = 0
    }
}
