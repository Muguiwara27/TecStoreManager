//
//  AuthViewModel.swift
//  TecStoreManager
//
//  MVVM ViewModel para Login y Registro de Usuarios.
//  Pantallas UIKit: LoginViewController, RegistroUsuarioViewController
//

import Foundation
import CoreData
import Combine

final class AuthViewModel: ObservableObject {

    // MARK: - Published State
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: Usuario?

    private let context = PersistenceController.shared.context

    // MARK: - Login
    /// Valida credenciales contra Core Data. Devuelve true si fue exitoso.
    func login(usuario: String, password: String) -> Bool {
        // Validación de campos vacíos
        guard !usuario.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El campo Usuario es obligatorio."
            return false
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El campo Contraseña es obligatorio."
            return false
        }

        // Búsqueda en Core Data
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(
            format: "nombreUsuario == %@ AND password == %@ AND estado == YES",
            usuario, password
        )

        do {
            let results = try context.fetch(request)
            if let user = results.first {
                currentUser = user
                isAuthenticated = true
                errorMessage = ""
                return true
            } else {
                errorMessage = "Usuario o contraseña incorrectos."
                return false
            }
        } catch {
            errorMessage = "Error al verificar credenciales."
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
        guard !nombreUsuario.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El nombre de usuario es obligatorio."
            return false
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "La contraseña es obligatoria."
            return false
        }
        guard !nombreCompleto.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El nombre completo es obligatorio."
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            return false
        }

        // Verificar que no exista el mismo nombreUsuario
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "nombreUsuario == %@", nombreUsuario)
        let count = (try? context.count(for: request)) ?? 0
        guard count == 0 else {
            errorMessage = "El nombre de usuario '\(nombreUsuario)' ya existe."
            return false
        }

        let nuevo = Usuario(context: context)
        nuevo.idUsuario = UUID()
        nuevo.nombreUsuario = nombreUsuario
        nuevo.password = password
        nuevo.nombreCompleto = nombreCompleto
        nuevo.estado = estado

        PersistenceController.shared.save()
        errorMessage = ""
        return true
    }

    // MARK: - Editar Usuario
    func editarUsuario(
        usuario: Usuario,
        nuevoNombreCompleto: String,
        nuevaPassword: String,
        nuevoEstado: Bool
    ) -> Bool {
        guard !nuevoNombreCompleto.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El nombre completo es obligatorio."
            return false
        }
        guard !nuevaPassword.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "La contraseña es obligatoria."
            return false
        }
        usuario.nombreCompleto = nuevoNombreCompleto
        usuario.password = nuevaPassword
        usuario.estado = nuevoEstado
        PersistenceController.shared.save()
        errorMessage = ""
        return true
    }

    // MARK: - Consultar usuarios
    func fetchUsuarios() -> [Usuario] {
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nombreUsuario", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    // MARK: - Logout
    func logout() {
        currentUser = nil
        isAuthenticated = false
    }
}
