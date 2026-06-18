//
//  ClientesListView.swift
//  TecStoreManager
//
//  Pantalla SwiftUI: Lista de Clientes
//  Componentes: NavigationStack, List, Text, Button, Sheet, TextField (búsqueda)
//

import SwiftUI

struct ClientesListView: View {

    // MARK: - ViewModel (MVVM)
    @ObservedObject var viewModel: ClienteViewModel

    // MARK: - State
    @State private var showForm     = false
    @State private var clienteEdit: Cliente?
    @State private var showSearch   = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo oscuro
                LinearGradient(
                    colors: [Color(red: 0.06, green: 0.06, blue: 0.12),
                             Color(red: 0.08, green: 0.12, blue: 0.22)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Barra de búsqueda
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Buscar por nombre o DNI...", text: $viewModel.searchText)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                    // Picker — Filtro Estado
                    Picker("Estado", selection: $viewModel.filtroEstado) {
                        ForEach(ClienteViewModel.FiltroEstado.allCases, id: \.self) { estado in
                            Text(estado.rawValue).tag(estado)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)

                    // Contador
                    HStack {
                        Text("\(viewModel.clientesFiltrados.count) clientes")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)

                    // Lista de Clientes
                    if viewModel.clientesFiltrados.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "person.2.slash")
                                .font(.system(size: 56))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("No se encontraron clientes")
                                .foregroundColor(.gray)
                                .font(.body)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.clientesFiltrados) { cliente in
                                ClienteRowView(cliente: cliente)
                                    .listRowBackground(Color.white.opacity(0.05))
                                    .listRowSeparatorTint(Color.white.opacity(0.08))
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            viewModel.eliminarCliente(cliente)
                                        } label: {
                                            Label("Eliminar", systemImage: "trash")
                                        }
                                        Button {
                                            clienteEdit = cliente
                                        } label: {
                                            Label("Editar", systemImage: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Clientes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        clienteEdit = nil
                        showForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                    }
                }
            }
            // Sheet — Formulario de Cliente
            .sheet(isPresented: $showForm, onDismiss: { viewModel.fetchClientes() }) {
                ClienteFormView(viewModel: viewModel, cliente: nil)
            }
            .sheet(item: $clienteEdit, onDismiss: { viewModel.fetchClientes() }) { cliente in
                ClienteFormView(viewModel: viewModel, cliente: cliente)
            }
            .onAppear { viewModel.fetchClientes() }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - ClienteRowView
struct ClienteRowView: View {
    let cliente: Cliente

    var body: some View {
        HStack(spacing: 14) {
            // Avatar circular
            ZStack {
                Circle()
                    .fill(Color(red: 0.18, green: 0.72, blue: 0.55).opacity(0.2))
                    .frame(width: 46, height: 46)
                Text(String(cliente.nombresSafe.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.18, green: 0.72, blue: 0.55))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(cliente.nombreCompleto)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text("DNI: \(cliente.dniSafe)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(cliente.correoSafe.isEmpty ? cliente.telefonoSafe : cliente.correoSafe)
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            // Estado badge
            Text(cliente.estado ? "Activo" : "Inactivo")
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(cliente.estado ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                .foregroundColor(cliente.estado ? .green : .red)
                .cornerRadius(8)
        }
        .padding(.vertical, 6)
    }
}
