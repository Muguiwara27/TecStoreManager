//
//  LoginViewController.swift
//  TecStoreManager
//
//  Pantalla UIKit: Login — conectada al Main.storyboard
//  Componentes IBOutlet: UILabel, UITextField, UIButton, UIImageView
//  Componentes IBAction: handleLogin, goToRegister
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - ViewModel (MVVM)
    private let viewModel = AuthViewModel()

    // MARK: - IBOutlets (conectados desde el Storyboard)
    @IBOutlet weak var logoImageView: UIImageView!      // UIImageView — Logo
    @IBOutlet weak var titleLabel: UILabel!             // UILabel — "TecStore Manager"
    @IBOutlet weak var subtitleLabel: UILabel!          // UILabel — Subtítulo
    @IBOutlet weak var usuarioLabel: UILabel!           // UILabel — "Usuario"
    @IBOutlet weak var usuarioTextField: UITextField!   // UITextField — Campo usuario
    @IBOutlet weak var passwordLabel: UILabel!          // UILabel — "Contraseña"
    @IBOutlet weak var passwordTextField: UITextField!  // UITextField — Campo contraseña
    @IBOutlet weak var errorLabel: UILabel!             // UILabel — Mensaje de error
    @IBOutlet weak var loginButton: UIButton!           // UIButton — "Ingresar"
    @IBOutlet weak var registerButton: UIButton!        // UIButton — "¿No tienes cuenta?"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        styleUIElements()
        setupTapGesture()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        errorLabel?.text = ""
    }

    // MARK: - Degradado de fondo
    private func setupGradientBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.06, green: 0.06, blue: 0.12, alpha: 1.0).cgColor,
            UIColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1.0).cgColor
        ]
        gradient.locations = [0, 1]
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }

    // MARK: - Estilizado de IBOutlets
    private func styleUIElements() {
        // UIImageView
        logoImageView?.image = UIImage(systemName: "laptopcomputer.and.iphone")
        logoImageView?.tintColor = UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0)

        // UILabel
        titleLabel?.textColor    = .white
        subtitleLabel?.textColor = .systemGray
        usuarioLabel?.textColor  = .systemGray2
        passwordLabel?.textColor = .systemGray2
        errorLabel?.textColor    = .systemRed

        // UITextField — estilo glassmorphism
        for tf in [usuarioTextField, passwordTextField] {
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

        // UIButton — Ingresar
        loginButton?.backgroundColor = UIColor(red: 0.25, green: 0.52, blue: 0.96, alpha: 1.0)
        loginButton?.layer.cornerRadius = 14
        loginButton?.setTitleColor(.white, for: .normal)
        loginButton?.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)

        // UIButton — Registro
        registerButton?.setTitleColor(UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0), for: .normal)
    }

    // MARK: - Tap para cerrar teclado
    private func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    // MARK: - IBActions

    /// Acción del UIButton "Ingresar" — conectado en Storyboard
    @IBAction func handleLogin(_ sender: UIButton) {
        let usuario  = usuarioTextField?.text ?? ""
        let password = passwordTextField?.text ?? ""

        let exitoso = viewModel.login(usuario: usuario, password: password)
        errorLabel?.text = viewModel.errorMessage

        if exitoso {
            // Navegar al Dashboard (UIKit)
            let storyboard   = UIStoryboard(name: "Main", bundle: nil)
            let dashboardVC  = storyboard.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardViewController
            dashboardVC.currentUser = viewModel.currentUser
            navigationController?.setNavigationBarHidden(false, animated: true)
            navigationController?.pushViewController(dashboardVC, animated: true)
        } else {
            // UIAlertController — Error de credenciales
            let alert = UIAlertController(
                title: "Error de Acceso",
                message: viewModel.errorMessage,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Intentar de nuevo", style: .default))
            present(alert, animated: true)
            if let utf = usuarioTextField { shakeView(utf) }
            if let ptf = passwordTextField { shakeView(ptf) }
        }
    }

    /// Acción del UIButton "¿No tienes cuenta?" — conectado en Storyboard
    @IBAction func goToRegister(_ sender: UIButton) {
        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
        let registroVC  = storyboard.instantiateViewController(withIdentifier: "RegistroVC")
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(registroVC, animated: true)
    }

    // MARK: - Animación Shake
    private func shakeView(_ view: UIView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.5
        anim.values   = [-10, 10, -8, 8, -5, 5, 0]
        view.layer.add(anim, forKey: "shake")
    }
}
