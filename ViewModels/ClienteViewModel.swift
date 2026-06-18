//
//  ClienteViewModel.swift
//  TecStoreManager
//
//  MVVM ViewModel para CRUD de Clientes.
//  Pantallas SwiftUI: ClientesListView, ClienteFormView
//

import Foundation
import CoreData
import Combine

final class ClienteViewModel: ObservableObject {

    // MARK: - Published State
    @Published var clientes: [Cliente] = []
    @Published var clientesFiltrados: [Cliente] = []
    @Published var errorMessage: String = ""
    @Published var searchText: String = "" {
        didSet { aplicarFiltros() }
    }
    @Published var filtroEstado: FiltroEstado = .todos {
        didSet { aplicarFiltros() }
    }

    enum FiltroEstado: String, CaseIterable {
        case todos = "Todos"
        case activos = "Activos"
        case inactivos = "Inactivos"
    }

    private let context = PersistenceController.shared.context

    // MARK: - Init
    init() { fetchClientes() }

    // MARK: - Fetch
    func fetchClientes() {
        let request: NSFetchRequest<Cliente> = Cliente.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nombres", ascending: true)]
        clientes = (try? context.fetch(request)) ?? []
        aplicarFiltros()
    }

    // MARK: - Filtros
    private func aplicarFiltros() {
        var resultado = clientes

        if !searchText.isEmpty {
            resultado = resultado.filter {
                $0.dniSafe.contains(searchText) ||
                $0.nombreCompleto.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch filtroEstado {
        case .todos:      break
        case .activos:    resultado = resultado.filter { $0.estado }
        case .inactivos:  resultado = resultado.filter { !$0.estado }
        }

        clientesFiltrados = resultado
    }

    // MARK: - Validar correo
    private func esCorreoValido(_ correo: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: correo)
    }

    // MARK: - Guardar / Crear
    func guardarCliente(
        dni: String,
        nombres: String,
        apellidos: String,
        telefono: String,
        correo: String,
        direccion: String,
        estado: Bool,
        clienteExistente: Cliente? = nil
    ) -> Bool {

        guard !dni.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El DNI es obligatorio."
            return false
        }
        guard dni.count == 8, dni.allSatisfy({ $0.isNumber }) else {
            errorMessage = "El DNI debe tener exactamente 8 dígitos numéricos."
            return false
        }
        guard !nombres.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Los nombres son obligatorios."
            return false
        }
        guard !apellidos.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Los apellidos son obligatorios."
            return false
        }
        guard correo.isEmpty || esCorreoValido(correo) else {
            errorMessage = "El correo electrónico no es válido."
            return false
        }

        // Verificar DNI duplicado (solo en nuevo registro)
        if clienteExistente == nil {
            let request: NSFetchRequest<Cliente> = Cliente.fetchRequest()
            request.predicate = NSPredicate(format: "dni == %@", dni)
            let count = (try? context.count(for: request)) ?? 0
            if count > 0 {
                errorMessage = "Ya existe un cliente con el DNI \(dni)."
                return false
            }
        }

        let cliente = clienteExistente ?? Cliente(context: context)
        if clienteExistente == nil { cliente.idCliente = UUID() }
        cliente.dni = dni
        cliente.nombres = nombres
        cliente.apellidos = apellidos
        cliente.telefono = telefono
        cliente.correo = correo
        cliente.direccion = direccion
        cliente.estado = estado

        PersistenceController.shared.save()
        fetchClientes()
        errorMessage = ""
        return true
    }

    // MARK: - Eliminar
    func eliminarCliente(_ cliente: Cliente) {
        context.delete(cliente)
        PersistenceController.shared.save()
        fetchClientes()
    }

    // MARK: - Estadísticas
    var totalClientes: Int  { clientes.count }
    var clientesActivos: Int { clientes.filter { $0.estado }.count }
}
