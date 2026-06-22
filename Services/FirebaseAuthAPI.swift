//
//  FirebaseAuthAPI.swift
//  TecStoreManager
//

import Foundation

struct FirebaseAuthSession {
    let idToken: String
    let refreshToken: String
    let localId: String
    let email: String
    let expiresIn: TimeInterval
}

enum FirebaseAuthAPIError: LocalizedError {
    case missingAPIKey
    case invalidConfiguration
    case invalidResponse
    case firebaseMessage(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Configura FirebaseConfig.local.plist con tu FIREBASE_WEB_API_KEY."
        case .invalidConfiguration:
            return "La configuración de Firebase no es válida."
        case .invalidResponse:
            return "Firebase devolvió una respuesta inválida."
        case .firebaseMessage(let message):
            return message
        }
    }
}

final class FirebaseAuthAPI {
    static let shared = FirebaseAuthAPI()

    private let session: URLSession
    private let apiKeyProvider: () throws -> String

    init(
        session: URLSession = .shared,
        apiKeyProvider: @escaping () throws -> String = FirebaseAuthAPI.loadAPIKey
    ) {
        self.session = session
        self.apiKeyProvider = apiKeyProvider
    }

    func signIn(email: String, password: String) async throws -> FirebaseAuthSession {
        try await authenticate(endpoint: "accounts:signInWithPassword", email: email, password: password)
    }

    func signUp(email: String, password: String) async throws -> FirebaseAuthSession {
        try await authenticate(endpoint: "accounts:signUp", email: email, password: password)
    }

    private func authenticate(endpoint: String, email: String, password: String) async throws -> FirebaseAuthSession {
        let apiKey = try apiKeyProvider()
        guard var components = URLComponents(string: "https://identitytoolkit.googleapis.com/v1/\(endpoint)") else {
            throw FirebaseAuthAPIError.invalidConfiguration
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let url = components.url else { throw FirebaseAuthAPIError.invalidConfiguration }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(AuthRequest(email: email, password: password, returnSecureToken: true))

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FirebaseAuthAPIError.invalidResponse
        }

        if (200..<300).contains(httpResponse.statusCode) {
            let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
            return FirebaseAuthSession(
                idToken: authResponse.idToken,
                refreshToken: authResponse.refreshToken,
                localId: authResponse.localId,
                email: authResponse.email,
                expiresIn: TimeInterval(authResponse.expiresIn) ?? 0
            )
        }

        let errorResponse = try? JSONDecoder().decode(FirebaseErrorResponse.self, from: data)
        let code = errorResponse?.error.message ?? "UNKNOWN_ERROR"
        throw FirebaseAuthAPIError.firebaseMessage(Self.userMessage(for: code))
    }

    private static func loadAPIKey() throws -> String {
        guard let url = Bundle.main.url(forResource: "FirebaseConfig", withExtension: "plist"),
              let dictionary = NSDictionary(contentsOf: url) as? [String: Any] else {
            throw FirebaseAuthAPIError.missingAPIKey
        }

        guard let apiKey = dictionary["FIREBASE_WEB_API_KEY"] as? String else {
            throw FirebaseAuthAPIError.invalidConfiguration
        }

        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "REEMPLAZA_CON_TU_API_KEY" else {
            throw FirebaseAuthAPIError.missingAPIKey
        }
        return trimmed
    }

    private static func userMessage(for code: String) -> String {
        switch code {
        case "EMAIL_NOT_FOUND":
            return "No existe una cuenta con ese correo."
        case "INVALID_PASSWORD":
            return "La contraseña es incorrecta."
        case "USER_DISABLED":
            return "La cuenta está deshabilitada en Firebase."
        case "EMAIL_EXISTS":
            return "Ya existe una cuenta con ese correo."
        case "OPERATION_NOT_ALLOWED":
            return "Habilita Email/Password en Firebase Authentication."
        case "TOO_MANY_ATTEMPTS_TRY_LATER":
            return "Demasiados intentos. Intenta nuevamente más tarde."
        case "INVALID_EMAIL":
            return "El correo electrónico no es válido."
        case "WEAK_PASSWORD : Password should be at least 6 characters":
            return "La contraseña debe tener al menos 6 caracteres."
        default:
            return "Error de Firebase: \(code)"
        }
    }
}

private struct AuthRequest: Encodable {
    let email: String
    let password: String
    let returnSecureToken: Bool
}

private struct AuthResponse: Decodable {
    let idToken: String
    let refreshToken: String
    let localId: String
    let email: String
    let expiresIn: String
}

private struct FirebaseErrorResponse: Decodable {
    let error: FirebaseError

    struct FirebaseError: Decodable {
        let message: String
    }
}
