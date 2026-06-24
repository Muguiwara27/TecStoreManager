//
//  AuthViewModel.swift
//  TecStoreManager
//
//  MVVM ViewModel para Login y Registro de Usuarios.
//  Pantallas UIKit: LoginViewController, RegistroUsuarioViewController
//

import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Published State
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: Usuario?

    private let authService: AuthService

    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService()
    }

    // MARK: - Login
    /// Valida credenciales contra Core Data. Devuelve true si fue exitoso.
    func login(usuario: String, password: String) -> Bool {
        do {
            currentUser = try authService.login(usuario: usuario, password: password)
            isAuthenticated = true
            errorMessage = ""
            return true
        } catch {
            currentUser = nil
            isAuthenticated = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Registro
    func registrarUsuario(
        nombreUsuario: String,
        password: String,
        nombreCompleto: String,
        estado: Bool
    ) -> Bool {
        do {
            try authService.registrarUsuario(
                nombreUsuario: nombreUsuario,
                password: password,
                nombreCompleto: nombreCompleto,
                estado: estado
            )
            errorMessage = ""
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Editar Usuario
    func editarUsuario(
        usuario: Usuario,
        nuevoNombreCompleto: String,
        nuevaPassword: String,
        nuevoEstado: Bool
    ) -> Bool {
        do {
            try authService.editarUsuario(
                usuario: usuario,
                nuevoNombreCompleto: nuevoNombreCompleto,
                nuevaPassword: nuevaPassword,
                nuevoEstado: nuevoEstado
            )
            errorMessage = ""
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Consultar usuarios
    func fetchUsuarios() -> [Usuario] {
        do {
            return try authService.fetchUsuarios()
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }

    // MARK: - Logout
    func logout() {
        currentUser = nil
        isAuthenticated = false
        errorMessage = ""
    }
}
