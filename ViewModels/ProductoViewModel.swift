//
//  ProductoViewModel.swift
//  TecStoreManager
//
//  MVVM ViewModel para CRUD de Productos.
//  Pantallas UIKit: ProductosListViewController, ProductoFormViewController, ProductoDetalleViewController
//

import Foundation
import CoreData
import Combine

final class ProductoViewModel: ObservableObject {

    // MARK: - Published State
    @Published var productos: [Producto] = []
    @Published var productosFiltrados: [Producto] = []
    @Published var errorMessage: String = ""
    @Published var searchText: String = "" {
        didSet { aplicarFiltros() }
    }
    @Published var categoriaSeleccionada: String = "Todas" {
        didSet { aplicarFiltros() }
    }
    @Published var filtroStock: FiltroStock = .todos {
        didSet { aplicarFiltros() }
    }

    enum FiltroStock: String, CaseIterable {
        case todos = "Todos"
        case conStock = "Con stock"
        case sinStock = "Sin stock"
    }

    static let categorias = ["Todas", "Computadoras", "Celulares", "Tablets", "Accesorios", "Audio", "Gaming", "Otros"]

    private let context = PersistenceController.shared.context

    // MARK: - Init
    init() { fetchProductos() }

    // MARK: - Fetch
    func fetchProductos() {
        let request: NSFetchRequest<Producto> = Producto.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        productos = (try? context.fetch(request)) ?? []
        aplicarFiltros()
    }

    // MARK: - Filtros
    private func aplicarFiltros() {
        var resultado = productos

        // Filtro por nombre
        if !searchText.isEmpty {
            resultado = resultado.filter {
                $0.nombreSafe.localizedCaseInsensitiveContains(searchText) ||
                $0.codigoSafe.localizedCaseInsensitiveContains(searchText)
            }
        }

        // Filtro por categoría
        if categoriaSeleccionada != "Todas" {
            resultado = resultado.filter { $0.categoriaSafe == categoriaSeleccionada }
        }

        // Filtro por stock
        switch filtroStock {
        case .todos:      break
        case .conStock:   resultado = resultado.filter { $0.stock > 0 }
        case .sinStock:   resultado = resultado.filter { $0.stock == 0 }
        }

        productosFiltrados = resultado
    }

    // MARK: - Guardar / Crear
    func guardarProducto(
        codigo: String,
        nombre: String,
        categoria: String,
        precio: Double,
        stock: Int32,
        estado: Bool,
        productoExistente: Producto? = nil
    ) -> Bool {

        // Validaciones
        guard !codigo.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El código del producto es obligatorio."
            return false
        }
        guard !nombre.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "El nombre del producto es obligatorio."
            return false
        }
        guard precio > 0 else {
            errorMessage = "El precio debe ser mayor a 0."
            return false
        }
        guard stock >= 0 else {
            errorMessage = "El stock no puede ser negativo."
            return false
        }

        let producto = productoExistente ?? Producto(context: context)
        if productoExistente == nil {
            producto.idProducto = UUID()
            producto.fechaRegistro = Date()
        }
        producto.codigo = codigo
        producto.nombre = nombre
        producto.categoria = categoria
        producto.precio = precio
        producto.stock = stock
        producto.estado = estado

        PersistenceController.shared.save()
        fetchProductos()
        errorMessage = ""
        return true
    }

    // MARK: - Eliminar
    func eliminarProducto(_ producto: Producto) {
        context.delete(producto)
        PersistenceController.shared.save()
        fetchProductos()
    }

    // MARK: - Descontar Stock (al registrar venta)
    func descontarStock(producto: Producto, cantidad: Int32) -> Bool {
        guard producto.stock >= cantidad else {
            errorMessage = "Stock insuficiente. Disponible: \(producto.stock)"
            return false
        }
        producto.stock -= cantidad
        PersistenceController.shared.save()
        fetchProductos()
        return true
    }

    // MARK: - Estadísticas para Reportes
    var totalProductosActivos: Int   { productos.filter { $0.estado }.count }
    var totalProductosInactivos: Int { productos.filter { !$0.estado }.count }
    var productoMenorStock: Producto? {
        productos.filter { $0.estado && $0.stock > 0 }.min(by: { $0.stock < $1.stock })
    }
}
