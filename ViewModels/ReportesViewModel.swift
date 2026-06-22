//
//  ReportesViewModel.swift
//  TecStoreManager
//
//  MVVM ViewModel para la pantalla de Reportes.
//  Pantalla SwiftUI: ReportesView
//

import Foundation
import CoreData
import Combine

final class ReportesViewModel: ObservableObject {

    // MARK: - Published State
    @Published var totalVentas: Int = 0
    @Published var montoTotalVendido: Double = 0
    @Published var totalClientes: Int = 0
    @Published var totalProductos: Int = 0
    @Published var productosActivos: Int = 0
    @Published var productosInactivos: Int = 0
    @Published var productoMenorStock: Producto?
    @Published var ventasPorDia: [(fecha: String, total: Double)] = []
    @Published var topProductos: [(nombre: String, cantidad: Int32)] = []

    private let context = PersistenceController.shared.context

    // MARK: - Init
    init() { cargarReportes() }

    // MARK: - Cargar Todos los Reportes
    func cargarReportes() {
        cargarEstadisticasVentas()
        cargarEstadisticasClientes()
        cargarEstadisticasProductos()
        cargarVentasPorDia()
        cargarTopProductos()
    }

    // MARK: - Ventas
    private func cargarEstadisticasVentas() {
        let request: NSFetchRequest<Venta> = Venta.fetchRequest()
        let ventas = (try? context.fetch(request)) ?? []
        totalVentas = ventas.count
        montoTotalVendido = ventas.reduce(0) { $0 + $1.total }
    }

    // MARK: - Clientes
    private func cargarEstadisticasClientes() {
        let request: NSFetchRequest<Cliente> = Cliente.fetchRequest()
        totalClientes = (try? context.count(for: request)) ?? 0
    }

    // MARK: - Productos
    private func cargarEstadisticasProductos() {
        let request: NSFetchRequest<Producto> = Producto.fetchRequest()
        let all = (try? context.fetch(request)) ?? []
        totalProductos = all.count
        productosActivos = all.filter { $0.estado }.count
        productosInactivos = all.filter { !$0.estado }.count
        productoMenorStock = all.filter { $0.estado }.min(by: { $0.stock < $1.stock })
    }

    // MARK: - Ventas por Día (últimos 7 días)
    private func cargarVentasPorDia() {
        let request: NSFetchRequest<Venta> = Venta.fetchRequest()
        let ventas = (try? context.fetch(request)) ?? []

        let calendar = Calendar.current
        let fmt = DateFormatter()
        fmt.dateFormat = "dd/MM"

        var dict: [String: Double] = [:]
        for venta in ventas {
            let key = fmt.string(from: venta.fechaVentaSafe)
            dict[key, default: 0] += venta.total
        }

        ventasPorDia = dict.sorted { a, b in a.key < b.key }
                          .map { (fecha: $0.key, total: $0.value) }
        _ = calendar // evitar warning de importación
    }

    // MARK: - Top Productos más vendidos
    private func cargarTopProductos() {
        let request: NSFetchRequest<Venta> = Venta.fetchRequest()
        let ventas = (try? context.fetch(request)) ?? []

        var dict: [String: Int32] = [:]
        for venta in ventas {
            let detalles = venta.detallesArray
            if detalles.isEmpty {
                let nombre = venta.producto?.nombreSafe ?? "Desconocido"
                dict[nombre, default: 0] += venta.cantidad
            } else {
                for detalle in detalles {
                    let nombre = detalle.producto?.nombreSafe ?? "Desconocido"
                    dict[nombre, default: 0] += detalle.cantidad
                }
            }
        }

        topProductos = dict.sorted { $0.value > $1.value }
                          .prefix(5)
                          .map { (nombre: $0.key, cantidad: $0.value) }
    }

    // MARK: - Formateo
    func formatCurrency(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = "PEN"
        fmt.currencySymbol = "S/"
        return fmt.string(from: NSNumber(value: value)) ?? "S/0.00"
    }
}
