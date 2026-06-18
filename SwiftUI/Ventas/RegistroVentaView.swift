//
//  RegistroVentaView.swift
//  TecStoreManager
//
//  Pantalla SwiftUI: Registro de Venta
//  Componentes: Form, Picker (cliente/producto), TextField (cantidad), Text (cálculos auto), Button
//

import SwiftUI

struct RegistroVentaView: View {

    // MARK: - ViewModels
    @ObservedObject var ventaVM:    VentaViewModel
    @ObservedObject var clienteVM:  ClienteViewModel
    @ObservedObject var productoVM: ProductoViewModel

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State
    @State private var showAlert   = false
    @State private var alertMsg    = ""
    @State private var esExitoso   = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.14).ignoresSafeArea()

                Form {
                    // Sección: Selección de Cliente
                    Section {
                        // Picker — Cliente
                        Picker("Cliente", selection: $ventaVM.clienteSeleccionado) {
                            Text("Seleccionar cliente...").tag(Optional<Cliente>.none)
                            ForEach(clienteVM.clientes.filter { $0.estado }) { cliente in
                                Text(cliente.nombreCompleto).tag(Optional(cliente))
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .foregroundColor(.white)

                        if let cliente = ventaVM.clienteSeleccionado {
                            HStack {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                Text("DNI: \(cliente.dniSafe) · \(cliente.telefonoSafe)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    } header: {
                        Label("Cliente", systemImage: "person.fill")
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.white.opacity(0.07))

                    // Sección: Selección de Producto
                    Section {
                        // Picker — Producto
                        Picker("Producto", selection: $ventaVM.productoSeleccionado) {
                            Text("Seleccionar producto...").tag(Optional<Producto>.none)
                            ForEach(productoVM.productos.filter { $0.estado && $0.stock > 0 }) { producto in
                                VStack(alignment: .leading) {
                                    Text(producto.nombreSafe)
                                    Text("S/ \(String(format: "%.2f", producto.precio)) · Stock: \(producto.stock)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .tag(Optional(producto))
                            }
                        }
                        .pickerStyle(.navigationLink)
                        .foregroundColor(.white)

                        if let producto = ventaVM.productoSeleccionado {
                            HStack {
                                Image(systemName: "info.circle").foregroundColor(.blue)
                                Text("Precio: S/ \(String(format: "%.2f", producto.precio)) · Stock disponible: \(producto.stock)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    } header: {
                        Label("Producto", systemImage: "cube.box.fill")
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.white.opacity(0.07))

                    // Sección: Cantidad
                    Section {
                        HStack {
                            Image(systemName: "number").foregroundColor(.orange)
                            // TextField — Cantidad
                            TextField("Cantidad", text: $ventaVM.cantidadTexto)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                        }
                    } header: {
                        Label("Cantidad", systemImage: "tray.full")
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.white.opacity(0.07))

                    // Sección: Cálculos Automáticos (Text, solo lectura)
                    if ventaVM.productoSeleccionado != nil && !ventaVM.cantidadTexto.isEmpty {
                        Section {
                            calculoRow(label: "Subtotal", valor: ventaVM.subtotal, color: .white)
                            calculoRow(label: "IGV (18%)", valor: ventaVM.igv, color: Color(red: 0.93, green: 0.68, blue: 0.10))
                            Divider().background(Color.white.opacity(0.1))
                            calculoRow(label: "TOTAL", valor: ventaVM.total, color: Color(red: 0.25, green: 0.85, blue: 0.55))
                                .font(.system(size: 16, weight: .bold))
                        } header: {
                            Label("Resumen de Venta", systemImage: "receipt")
                                .foregroundColor(.gray)
                        }
                        .listRowBackground(Color.white.opacity(0.07))
                    }

                    // Button — Registrar Venta
                    Section {
                        Button {
                            handleRegistrar()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "cart.badge.plus")
                                Text("Registrar Venta")
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                        }
                        .background(Color(red: 0.93, green: 0.42, blue: 0.28))
                        .cornerRadius(10)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Registrar Venta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }.foregroundColor(.red)
                }
            }
            .alert(esExitoso ? "✅ Venta Registrada" : "⚠️ Error", isPresented: $showAlert) {
                Button("OK") {
                    if esExitoso { dismiss() }
                }
            } message: {
                Text(alertMsg)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Helpers
    private func handleRegistrar() {
        let ok = ventaVM.registrarVenta()
        esExitoso = ok
        alertMsg  = ok
            ? "La venta fue registrada exitosamente. El stock del producto fue actualizado."
            : ventaVM.errorMessage
        showAlert = true
    }

    private func calculoRow(label: String, valor: Double, color: Color) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(ventaVM.formatCurrency(valor))
                .foregroundColor(color)
                .fontWeight(.semibold)
        }
    }
}
