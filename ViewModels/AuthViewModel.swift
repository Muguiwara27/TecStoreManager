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

@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Published State
    @Published var errorMessage: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: Usuario?
    @Published var currentFirebaseSession: FirebaseAuthSession?

    private let context = PersistenceController.shared.context
    private let firebaseAuthAPI: FirebaseAuthAPI

    init(firebaseAuthAPI: FirebaseAuthAPI = .shared) {
        self.firebaseAuthAPI = firebaseAuthAPI
    }

    // MARK: - Firebase Login
    func loginConFirebase(email: String, password: String) async -> Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard validarCredencialesFirebase(email: email, password: password) else { return false }

        do {
            let session = try await firebaseAuthAPI.signIn(email: email, password: password)
            currentFirebaseSession = session
            currentUser = upsertUsuarioFirebase(email: session.email, nombreCompleto: nil)
            isAuthenticated = true
            errorMessage = ""
            return true
        } catch {
            currentFirebaseSession = nil
            currentUser = nil
            isAuthenticated = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Firebase Registro
    func registrarUsuarioConFirebase(
        email: String,
        password: String,
        nombreCompleto: String,
        estado: Bool
    ) async -> Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard validarCredencialesFirebase(email: email, password: password) else { return false }
        guard !nombreCompleto.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El nombre completo es obligatorio."
            return false
        }

        do {
            let session = try await firebaseAuthAPI.signUp(email: email, password: password)
            currentFirebaseSession = session
            currentUser = upsertUsuarioFirebase(
                email: session.email,
                nombreCompleto: nombreCompleto,
                estado: estado
            )
            isAuthenticated = true
            errorMessage = ""
            return true
        } catch {
            currentFirebaseSession = nil
            isAuthenticated = false
            errorMessage = error.localizedDescription
            return false
        }
    }

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
        currentFirebaseSession = nil
        isAuthenticated = false
    }

    private func validarCredencialesFirebase(email: String, password: String) -> Bool {
        guard !email.isEmpty else {
            errorMessage = "El campo Correo es obligatorio."
            return false
        }
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Ingresa un correo electrónico válido."
            return false
        }
        guard !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El campo Contraseña es obligatorio."
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "La contraseña debe tener al menos 6 caracteres."
            return false
        }
        return true
    }

    private func upsertUsuarioFirebase(
        email: String,
        nombreCompleto: String?,
        estado: Bool = true
    ) -> Usuario {
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "nombreUsuario == %@", email)
        request.fetchLimit = 1

        let usuario = (try? context.fetch(request).first) ?? Usuario(context: context)
        if usuario.idUsuario == nil {
            usuario.idUsuario = UUID()
        }
        usuario.nombreUsuario = email
        usuario.password = "__firebase_auth__"
        if let nombreCompleto, !nombreCompleto.trimmingCharacters(in: .whitespaces).isEmpty {
            usuario.nombreCompleto = nombreCompleto
        } else if usuario.nombreCompletoSafe.isEmpty {
            usuario.nombreCompleto = email
        }
        usuario.estado = estado
        PersistenceController.shared.save()
        return usuario
    }
}
