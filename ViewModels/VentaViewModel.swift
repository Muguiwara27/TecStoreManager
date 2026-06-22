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

struct VentaItem: Identifiable {
    let id = UUID()
    let producto: Producto
    var cantidad: Int32

    var subtotal: Double { Double(cantidad) * producto.precio }
}

final class VentaViewModel: ObservableObject {

    // MARK: - Published State
    @Published var ventas: [Venta] = []
    @Published var errorMessage: String = ""

    // Estado del formulario de registro
    @Published var clienteSeleccionado: Cliente?
    @Published var productoSeleccionado: Producto?
    @Published var cantidadTexto: String = ""
    @Published var items: [VentaItem] = []

    // Cálculos automáticos (read-only derivados)
    var cantidad: Int32    { Int32(cantidadTexto) ?? 0 }
    var subtotal: Double   { Double(cantidad) * (productoSeleccionado?.precio ?? 0) }
    var subtotalVenta: Double { items.reduce(0) { $0 + $1.subtotal } }
    var igv: Double        { subtotalVenta * 0.18 }
    var total: Double      { subtotalVenta + igv }

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

        guard !items.isEmpty else {
            errorMessage = "Agrega al menos un producto a la venta."
            return false
        }

        for item in items {
            guard item.producto.stock >= item.cantidad else {
                errorMessage = "Stock insuficiente para \(item.producto.nombreSafe). Disponible: \(item.producto.stock)"
                return false
            }
        }

        // Crear la venta
        let venta = Venta(context: context)
        venta.idVenta = UUID()
        venta.fechaVenta = Date()
        venta.cantidad = items.reduce(Int32(0)) { $0 + $1.cantidad }
        venta.precio = 0
        venta.subtotal = subtotalVenta
        venta.igv = igv
        venta.total = total
        venta.cliente = cliente
        venta.producto = items.first?.producto

        // Crear detalles y descontar stock automáticamente
        for item in items {
            let detalle = VentaDetalle(context: context)
            detalle.idDetalle = UUID()
            detalle.cantidad = item.cantidad
            detalle.precioUnitario = item.producto.precio
            detalle.subtotal = item.subtotal
            detalle.producto = item.producto
            detalle.venta = venta
            item.producto.stock -= item.cantidad
        }

        PersistenceController.shared.save()
        fetchVentas()
        resetFormulario()
        errorMessage = ""
        return true
    }

    // MARK: - Eliminar Venta
    func eliminarVenta(_ venta: Venta) {
        let detalles = venta.detallesArray
        if detalles.isEmpty, let producto = venta.producto {
            producto.stock += venta.cantidad
        } else {
            detalles.forEach { detalle in
                detalle.producto?.stock += detalle.cantidad
            }
        }
        context.delete(venta)
        PersistenceController.shared.save()
        fetchVentas()
    }

    // MARK: - Reset Form
    func resetFormulario() {
        clienteSeleccionado = nil
        productoSeleccionado = nil
        cantidadTexto = ""
        items = []
    }

    // MARK: - Items
    func agregarProductoSeleccionado() -> Bool {
        guard let producto = productoSeleccionado else {
            errorMessage = "Debe seleccionar un producto."
            return false
        }
        guard cantidad > 0 else {
            errorMessage = "La cantidad debe ser mayor a 0."
            return false
        }

        let cantidadActual = items.first(where: { $0.producto.objectID == producto.objectID })?.cantidad ?? 0
        guard producto.stock >= cantidadActual + cantidad else {
            errorMessage = "Stock insuficiente. Disponible: \(producto.stock), ya agregado: \(cantidadActual)."
            return false
        }

        if let index = items.firstIndex(where: { $0.producto.objectID == producto.objectID }) {
            items[index].cantidad += cantidad
        } else {
            items.append(VentaItem(producto: producto, cantidad: cantidad))
        }
        productoSeleccionado = nil
        cantidadTexto = ""
        errorMessage = ""
        return true
    }

    func eliminarItem(_ item: VentaItem) {
        items.removeAll { $0.id == item.id }
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
