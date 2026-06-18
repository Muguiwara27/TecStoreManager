//
//  ReportesView.swift
//  TecStoreManager
//
//  Pantalla SwiftUI: Reportes y Estadísticas
//  Componentes: NavigationStack, List, Text (tarjetas estadísticas)
//

import SwiftUI

struct ReportesView: View {

    // MARK: - ViewModel
    @ObservedObject var viewModel: ReportesViewModel

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

                ScrollView {
                    VStack(spacing: 16) {

                        // Encabezado
                        Text("Resumen General")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)

                        // Tarjetas principales (2 columnas)
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(
                                titulo: "Total Ventas",
                                valor: "\(viewModel.totalVentas)",
                                icono: "cart.fill",
                                color: Color(red: 0.93, green: 0.42, blue: 0.28)
                            )
                            StatCard(
                                titulo: "Monto Vendido",
                                valor: viewModel.formatCurrency(viewModel.montoTotalVendido),
                                icono: "banknote.fill",
                                color: Color(red: 0.25, green: 0.85, blue: 0.55)
                            )
                            StatCard(
                                titulo: "Total Clientes",
                                valor: "\(viewModel.totalClientes)",
                                icono: "person.2.fill",
                                color: Color(red: 0.18, green: 0.72, blue: 0.55)
                            )
                            StatCard(
                                titulo: "Total Productos",
                                valor: "\(viewModel.totalProductos)",
                                icono: "cube.box.fill",
                                color: Color(red: 0.25, green: 0.52, blue: 0.96)
                            )
                        }
                        .padding(.horizontal, 16)

                        // Productos Activos / Inactivos
                        Text("Estado de Inventario")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(
                                titulo: "Activos",
                                valor: "\(viewModel.productosActivos)",
                                icono: "checkmark.circle.fill",
                                color: .green
                            )
                            StatCard(
                                titulo: "Inactivos",
                                valor: "\(viewModel.productosInactivos)",
                                icono: "xmark.circle.fill",
                                color: .red
                            )
                        }
                        .padding(.horizontal, 16)

                        // Producto con menor stock
                        if let prod = viewModel.productoMenorStock {
                            Text("Alerta de Stock")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)

                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .frame(width: 52, height: 52)
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                        .font(.title3)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Menor stock disponible")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(prod.nombreSafe)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("\(prod.stock) unidades · S/ \(String(format: "%.2f", prod.precio))")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                Spacer()
                            }
                            .padding(16)
                            .background(Color.orange.opacity(0.08))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                        }

                        // Top Productos vendidos
                        if !viewModel.topProductos.isEmpty {
                            Text("Top Productos Vendidos")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)

                            VStack(spacing: 8) {
                                ForEach(Array(viewModel.topProductos.enumerated()), id: \.offset) { idx, item in
                                    HStack {
                                        Text("#\(idx + 1)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .frame(width: 28)
                                        Text(item.nombre)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("\(item.cantidad) uds.")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 0.25, green: 0.85, blue: 0.55))
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal, 16)
                        }

                        // Botón Actualizar
                        Button {
                            viewModel.cargarReportes()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Actualizar Reportes")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.25, green: 0.52, blue: 0.96))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Reportes")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { viewModel.cargarReportes() }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - StatCard
struct StatCard: View {
    let titulo: String
    let valor: String
    let icono: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.2))
                        .frame(width: 36, height: 36)
                    Image(systemName: icono)
                        .foregroundColor(color)
                        .font(.system(size: 16))
                }
                Spacer()
            }
            Text(valor)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .minimumScaleFactor(0.6)
            Text(titulo)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}
