//
//  VentaViewModel.swift
//  TecStoreManager
//
//  MVVM ViewModel para Ventas.
//  Pantallas SwiftUI: VentasListView, RegistroVentaView
//

import Foundation
import CoreData
import Combine

final class VentaViewModel: ObservableObject {

    // MARK: - Published State
    @Published var ventas: [Venta] = []
    @Published var errorMessage: String = ""

    // Estado del formulario de registro
    @Published var clienteSeleccionado: Cliente?
    @Published var productoSeleccionado: Producto?
    @Published var cantidadTexto: String = ""

    // Cálculos automáticos (read-only derivados)
    var cantidad: Int32    { Int32(cantidadTexto) ?? 0 }
    var subtotal: Double   { Double(cantidad) * (productoSeleccionado?.precio ?? 0) }
    var igv: Double        { subtotal * 0.18 }
    var total: Double      { subtotal + igv }

    private let context = PersistenceController.shared.context

    // MARK: - Init
    init() { fetchVentas() }

    // MARK: - Fetch
    func fetchVentas() {
        let request: NSFetchRequest<Venta> = Venta.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "fechaVenta", ascending: false)]
        ventas = (try? context.fetch(request)) ?? []
    }

    // MARK: - Registrar Venta
    func registrarVenta() -> Bool {
        // Validar cliente
        guard let cliente = clienteSeleccionado else {
            errorMessage = "Debe seleccionar un cliente."
            return false
        }

        // Validar producto
        guard let producto = productoSeleccionado else {
            errorMessage = "Debe seleccionar un producto."
            return false
        }

        // Validar cantidad
        guard cantidad > 0 else {
            errorMessage = "La cantidad debe ser mayor a 0."
            return false
        }

        // Validar stock suficiente
        guard producto.stock >= cantidad else {
            errorMessage = "Stock insuficiente. Disponible: \(producto.stock) unidades."
            return false
        }

        // Crear la venta
        let venta = Venta(context: context)
        venta.idVenta = UUID()
        venta.fechaVenta = Date()
        venta.cantidad = cantidad
        venta.precio = producto.precio
        venta.subtotal = subtotal
        venta.igv = igv
        venta.total = total
        venta.cliente = cliente
        venta.producto = producto

        // Descontar stock automáticamente
        producto.stock -= cantidad

        PersistenceController.shared.save()
        fetchVentas()
        resetFormulario()
        errorMessage = ""
        return true
    }

    // MARK: - Eliminar Venta
    func eliminarVenta(_ venta: Venta) {
        context.delete(venta)
        PersistenceController.shared.save()
        fetchVentas()
    }

    // MARK: - Reset Form
    func resetFormulario() {
        clienteSeleccionado = nil
        productoSeleccionado = nil
        cantidadTexto = ""
    }

    // MARK: - Estadísticas para Reportes
    var totalVentas: Int        { ventas.count }
    var montoTotalVendido: Double { ventas.reduce(0) { $0 + $1.total } }

    // Formateadores
    func formatCurrency(_ value: Double) -> String {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.currencyCode = "PEN"
        fmt.currencySymbol = "S/"
        return fmt.string(from: NSNumber(value: value)) ?? "S/0.00"
    }
}
