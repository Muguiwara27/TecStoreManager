//
//  BusquedasAvanzadasView.swift
//  TecStoreManager
//
//  Pantalla SwiftUI: Búsquedas Avanzadas
//  Componentes: NavigationStack, TextField, List, Picker, Button, Text
//

import SwiftUI

struct BusquedasAvanzadasView: View {

    // MARK: - ViewModels
    @ObservedObject var clienteVM:  ClienteViewModel
    @ObservedObject var productoVM: ProductoViewModel

    // MARK: - State
    @State private var busquedaTexto = ""
    @State private var moduloSeleccionado: Modulo = .clientes
    @State private var resultadosClientes:  [Cliente]  = []
    @State private var resultadosProductos: [Producto] = []

    enum Modulo: String, CaseIterable {
        case clientes  = "Clientes"
        case productos = "Productos"
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.06, green: 0.06, blue: 0.12),
                             Color(red: 0.08, green: 0.12, blue: 0.22)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 12) {
                    // Picker — Módulo
                    Picker("Módulo", selection: $moduloSeleccionado) {
                        ForEach(Modulo.allCases, id: \.self) { m in
                            Text(m.rawValue).tag(m)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    // TextField — Búsqueda
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField(
                            moduloSeleccionado == .clientes
                                ? "Buscar por nombre o DNI..."
                                : "Buscar por nombre o código...",
                            text: $busquedaTexto
                        )
                        .foregroundColor(.white)
                        .autocorrectionDisabled()
                        .onChange(of: busquedaTexto) { _ in buscar() }

                        if !busquedaTexto.isEmpty {
                            Button {
                                busquedaTexto = ""
                                buscar()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)

                    // Button — Buscar
                    Button {
                        buscar()
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
                        )
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Buscar")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.25, green: 0.52, blue: 0.96))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)

                    // Resultados
                    Group {
                        if moduloSeleccionado == .clientes {
                            resultadosClientesView
                        } else {
                            resultadosProductosView
                        }
                    }
                }
            }
            .navigationTitle("Búsquedas")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                clienteVM.fetchClientes()
                productoVM.fetchProductos()
                buscar()
            }
            .onChange(of: moduloSeleccionado) { _ in
                busquedaTexto = ""
                buscar()
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Resultados Clientes
    private var resultadosClientesView: some View {
        Group {
            if resultadosClientes.isEmpty && !busquedaTexto.isEmpty {
                Spacer()
                Text("Sin resultados para '\(busquedaTexto)'")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(resultadosClientes) { cliente in
                    ClienteRowView(cliente: cliente)
                        .listRowBackground(Color.white.opacity(0.05))
                        .listRowSeparatorTint(Color.white.opacity(0.08))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Resultados Productos
    private var resultadosProductosView: some View {
        Group {
            if resultadosProductos.isEmpty && !busquedaTexto.isEmpty {
                Spacer()
                Text("Sin resultados para '\(busquedaTexto)'")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(resultadosProductos) { producto in
                    ProductoRowView(producto: producto)
                        .listRowBackground(Color.white.opacity(0.05))
                        .listRowSeparatorTint(Color.white.opacity(0.08))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }

    // MARK: - Buscar
    private func buscar() {
        let q = busquedaTexto.trimmingCharacters(in: .whitespaces)
        if moduloSeleccionado == .clientes {
            if q.isEmpty {
                resultadosClientes = clienteVM.clientes
            } else {
                resultadosClientes = clienteVM.clientes.filter {
                    $0.dniSafe.contains(q) ||
                    $0.nombreCompleto.localizedCaseInsensitiveContains(q)
                }
            }
        } else {
            if q.isEmpty {
                resultadosProductos = productoVM.productos
            } else {
                resultadosProductos = productoVM.productos.filter {
                    $0.nombreSafe.localizedCaseInsensitiveContains(q) ||
                    $0.codigoSafe.localizedCaseInsensitiveContains(q)
                }
            }
        }
    }
}

// MARK: - ProductoRowView (SwiftUI)
struct ProductoRowView: View {
    let producto: Producto

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.25, green: 0.52, blue: 0.96).opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: "cube.box.fill")
                    .foregroundColor(Color(red: 0.25, green: 0.52, blue: 0.96))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(producto.nombreSafe)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text("Cód: \(producto.codigoSafe) · \(producto.categoriaSafe)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("S/ \(String(format: "%.2f", producto.precio))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 0.25, green: 0.85, blue: 0.55))
                Text("Stock: \(producto.stock)")
                    .font(.caption2)
                    .foregroundColor(producto.stock > 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}
