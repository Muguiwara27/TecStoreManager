//
//  VentasListView.swift
//  TecStoreManager
//
//  Pantalla SwiftUI: Lista de Ventas
//  Componentes: NavigationStack, List, Text, Button, DatePicker, Sheet
//

import SwiftUI

struct VentasListView: View {

    // MARK: - ViewModels
    @ObservedObject var ventaVM:    VentaViewModel
    @ObservedObject var clienteVM:  ClienteViewModel
    @ObservedObject var productoVM: ProductoViewModel

    // MARK: - State
    @State private var showRegistro = false
    @State private var fechaFiltro  = Date()
    @State private var usarFiltroFecha = false

    private var ventasFiltradas: [Venta] {
        guard usarFiltroFecha else { return ventaVM.ventas }
        let cal = Calendar.current
        return ventaVM.ventas.filter {
            cal.isDate($0.fechaVentaSafe, inSameDayAs: fechaFiltro)
        }
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

                VStack(spacing: 0) {
                    // Filtro por Fecha — DatePicker
                    VStack(alignment: .leading, spacing: 6) {
                        Toggle("Filtrar por fecha", isOn: $usarFiltroFecha)
                            .foregroundColor(.white)
                            .tint(Color(red: 0.93, green: 0.42, blue: 0.28))

                        if usarFiltroFecha {
                            DatePicker("Fecha", selection: $fechaFiltro, displayedComponents: .date)
                                .datePickerStyle(.compact)
                                .colorScheme(.dark)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(14)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    // Resumen rápido
                    HStack(spacing: 12) {
                        ResumeCard(
                            titulo: "Total ventas",
                            valor: "\(ventasFiltradas.count)",
                            icono: "cart.fill",
                            color: Color(red: 0.93, green: 0.42, blue: 0.28)
                        )
                        ResumeCard(
                            titulo: "Monto total",
                            valor: ventaVM.formatCurrency(ventasFiltradas.reduce(0) { $0 + $1.total }),
                            icono: "banknote",
                            color: Color(red: 0.25, green: 0.85, blue: 0.55)
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    // Lista de ventas
                    if ventasFiltradas.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "cart.badge.questionmark")
                                .font(.system(size: 56))
                                .foregroundColor(.gray.opacity(0.4))
                            Text("No hay ventas registradas")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(ventasFiltradas) { venta in
                                VentaRowView(venta: venta, formatCurrency: ventaVM.formatCurrency)
                                    .listRowBackground(Color.white.opacity(0.05))
                                    .listRowSeparatorTint(Color.white.opacity(0.08))
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            ventaVM.eliminarVenta(venta)
                                        } label: {
                                            Label("Eliminar", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Ventas")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        ventaVM.resetFormulario()
                        showRegistro = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.93, green: 0.42, blue: 0.28))
                    }
                }
            }
            // Sheet — Registro de Venta
            .sheet(isPresented: $showRegistro, onDismiss: { ventaVM.fetchVentas() }) {
                RegistroVentaView(ventaVM: ventaVM, clienteVM: clienteVM, productoVM: productoVM)
            }
            .onAppear {
                ventaVM.fetchVentas()
                clienteVM.fetchClientes()
                productoVM.fetchProductos()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - VentaRowView
struct VentaRowView: View {
    let venta: Venta
    let formatCurrency: (Double) -> String

    private var fmt: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.93, green: 0.42, blue: 0.28).opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: "cart.fill")
                    .foregroundColor(Color(red: 0.93, green: 0.42, blue: 0.28))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(venta.cliente?.nombreCompleto ?? "Cliente desconocido")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                Text(venta.productosResumen)
                    .font(.caption)
                    .foregroundColor(.gray)
                if venta.detallesArray.count > 1 {
                    Text(venta.detallesArray.map { "\($0.cantidad)x \($0.productoNombre)" }.joined(separator: " · "))
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.75))
                        .lineLimit(2)
                }
                Text(fmt.string(from: venta.fechaVentaSafe))
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(venta.total))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(red: 0.25, green: 0.85, blue: 0.55))
                Text("×\(venta.cantidadTotal)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 6)
    }
}

// MARK: - ResumeCard
struct ResumeCard: View {
    let titulo: String
    let valor: String
    let icono: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icono)
                .font(.title3)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo).font(.caption).foregroundColor(.gray)
                Text(valor).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.white.opacity(0.07))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
    }
}
