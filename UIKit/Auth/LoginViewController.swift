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
        setupProgrammaticUIIfNeeded()
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
        usuarioLabel?.text = "Usuario"
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
        usuarioTextField?.placeholder = "Nombre de usuario"
        usuarioTextField?.keyboardType = .default
        usuarioTextField?.autocapitalizationType = .none
        usuarioTextField?.autocorrectionType = .no
        passwordTextField?.isSecureTextEntry = true

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

    private func setupProgrammaticUIIfNeeded() {
        guard usuarioTextField == nil else { return }

        let logo = UIImageView()
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.contentMode = .scaleAspectFit

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "TecStore Manager"
        title.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        title.textAlignment = .center

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Inicia sesión con tu cuenta"
        subtitle.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitle.textAlignment = .center

        let usuarioLabel = makeFieldLabel("Usuario")
        let usuarioField = makeTextField(placeholder: "Nombre de usuario")

        let passLabel = makeFieldLabel("Contraseña")
        let passField = makeTextField(placeholder: "Mínimo 6 caracteres")
        passField.isSecureTextEntry = true

        let error = UILabel()
        error.translatesAutoresizingMaskIntoConstraints = false
        error.font = UIFont.systemFont(ofSize: 13)
        error.numberOfLines = 0
        error.textAlignment = .center

        let login = UIButton(type: .system)
        login.translatesAutoresizingMaskIntoConstraints = false
        login.setTitle("Ingresar", for: .normal)
        login.addTarget(self, action: #selector(handleLogin(_:)), for: .touchUpInside)

        let register = UIButton(type: .system)
        register.translatesAutoresizingMaskIntoConstraints = false
        register.setTitle("¿No tienes cuenta? Regístrate", for: .normal)
        register.addTarget(self, action: #selector(goToRegister(_:)), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            logo, title, subtitle,
            usuarioLabel, usuarioField,
            passLabel, passField,
            error, login, register
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.setCustomSpacing(20, after: subtitle)
        stack.setCustomSpacing(18, after: passField)
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -28),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),

            logo.heightAnchor.constraint(equalToConstant: 78),
            usuarioField.heightAnchor.constraint(equalToConstant: 50),
            passField.heightAnchor.constraint(equalToConstant: 50),
            login.heightAnchor.constraint(equalToConstant: 52),
        ])

        logoImageView = logo
        titleLabel = title
        subtitleLabel = subtitle
        self.usuarioLabel = usuarioLabel
        usuarioTextField = usuarioField
        passwordLabel = passLabel
        passwordTextField = passField
        errorLabel = error
        loginButton = login
        registerButton = register
    }

    private func makeFieldLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        return label
    }

    private func makeTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.borderStyle = .none
        return textField
    }

    // MARK: - IBActions

    /// Acción del UIButton "Ingresar" — conectado en Storyboard
    @IBAction func handleLogin(_ sender: UIButton) {
        let usuario = usuarioTextField?.text ?? ""
        let password = passwordTextField?.text ?? ""
        setLoading(true)

        let exitoso = viewModel.login(usuario: usuario, password: password)
        setLoading(false)
        errorLabel?.text = viewModel.errorMessage

        if exitoso {
            navigationController?.setNavigationBarHidden(false, animated: true)
            performSegue(withIdentifier: "LoginToDashboardSegue", sender: sender)
        } else {
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
        navigationController?.setNavigationBarHidden(false, animated: true)
        performSegue(withIdentifier: "LoginToRegistroSegue", sender: sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToDashboardSegue",
           let dashboardVC = segue.destination as? DashboardViewController {
            dashboardVC.currentUser = viewModel.currentUser
        }
    }

    // MARK: - Animación Shake
    private func shakeView(_ view: UIView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.5
        anim.values   = [-10, 10, -8, 8, -5, 5, 0]
        view.layer.add(anim, forKey: "shake")
    }

    private func setLoading(_ loading: Bool) {
        loginButton?.isEnabled = !loading
        registerButton?.isEnabled = !loading
        loginButton?.alpha = loading ? 0.65 : 1
        loginButton?.setTitle(loading ? "Ingresando..." : "Ingresar", for: .normal)
    }
}
