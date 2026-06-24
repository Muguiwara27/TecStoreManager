//
//  AuthService.swift
//  TecStoreManager
//
//  Servicio local de autenticacion basado en Core Data.
//

import CoreData
import Foundation

enum AuthServiceError: LocalizedError {
    case usuarioObligatorio
    case passwordObligatoria
    case nombreCompletoObligatorio
    case passwordMuyCorta
    case credencialesInvalidas
    case usuarioDuplicado(String)
    case guardadoFallido
    case consultaFallida

    var errorDescription: String? {
        switch self {
        case .usuarioObligatorio:
            return "El campo Usuario es obligatorio."
        case .passwordObligatoria:
            return "El campo Contraseña es obligatorio."
        case .nombreCompletoObligatorio:
            return "El nombre completo es obligatorio."
        case .passwordMuyCorta:
            return "La contraseña debe tener al menos 6 caracteres."
        case .credencialesInvalidas:
            return "Usuario o contraseña incorrectos."
        case .usuarioDuplicado(let nombreUsuario):
            return "El nombre de usuario '\(nombreUsuario)' ya existe."
        case .guardadoFallido:
            return "No se pudo guardar el usuario."
        case .consultaFallida:
            return "Error al consultar usuarios."
        }
    }
}

@MainActor
final class AuthService {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.context) {
        self.context = context
    }

    func login(usuario: String, password: String) throws -> Usuario {
        let nombreUsuario = usuario.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nombreUsuario.isEmpty else { throw AuthServiceError.usuarioObligatorio }
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthServiceError.passwordObligatoria
        }

        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(
            format: "nombreUsuario == %@ AND password == %@ AND estado == YES",
            nombreUsuario,
            password
        )
        request.fetchLimit = 1

        do {
            guard let usuario = try context.fetch(request).first else {
                throw AuthServiceError.credencialesInvalidas
            }
            return usuario
        } catch let error as AuthServiceError {
            throw error
        } catch {
            throw AuthServiceError.consultaFallida
        }
    }

    @discardableResult
    func registrarUsuario(
        nombreUsuario: String,
        password: String,
        nombreCompleto: String,
        estado: Bool
    ) throws -> Usuario {
        let usuarioNormalizado = nombreUsuario.trimmingCharacters(in: .whitespacesAndNewlines)
        let nombreCompletoNormalizado = nombreCompleto.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !usuarioNormalizado.isEmpty else { throw AuthServiceError.usuarioObligatorio }
        guard !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthServiceError.passwordObligatoria
        }
        guard !nombreCompletoNormalizado.isEmpty else {
            throw AuthServiceError.nombreCompletoObligatorio
        }
        guard password.count >= 6 else { throw AuthServiceError.passwordMuyCorta }
        guard try !existeUsuario(nombreUsuario: usuarioNormalizado) else {
            throw AuthServiceError.usuarioDuplicado(usuarioNormalizado)
        }

        let nuevo = Usuario(context: context)
        nuevo.idUsuario = UUID()
        nuevo.nombreUsuario = usuarioNormalizado
        nuevo.password = password
        nuevo.nombreCompleto = nombreCompletoNormalizado
        nuevo.estado = estado

        try guardarCambios()
        return nuevo
    }

    func editarUsuario(
        usuario: Usuario,
        nuevoNombreCompleto: String,
        nuevaPassword: String,
        nuevoEstado: Bool
    ) throws {
        let nombreCompleto = nuevoNombreCompleto.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nombreCompleto.isEmpty else { throw AuthServiceError.nombreCompletoObligatorio }
        guard !nuevaPassword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AuthServiceError.passwordObligatoria
        }

        usuario.nombreCompleto = nombreCompleto
        usuario.password = nuevaPassword
        usuario.estado = nuevoEstado

        try guardarCambios()
    }

    func fetchUsuarios() throws -> [Usuario] {
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nombreUsuario", ascending: true)]

        do {
            return try context.fetch(request)
        } catch {
            throw AuthServiceError.consultaFallida
        }
    }

    private func existeUsuario(nombreUsuario: String) throws -> Bool {
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "nombreUsuario == %@", nombreUsuario)

        do {
            return try context.count(for: request) > 0
        } catch {
            throw AuthServiceError.consultaFallida
        }
    }

    private func guardarCambios() throws {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            context.rollback()
            throw AuthServiceError.guardadoFallido
        }
    }
}
