//
//  Venta+CoreDataProperties.swift
//  TecStoreManager
//

import Foundation
import CoreData

extension Venta {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Venta> {
        return NSFetchRequest<Venta>(entityName: "Venta")
    }

    @NSManaged public var idVenta: UUID?
    @NSManaged public var fechaVenta: Date?
    @NSManaged public var cantidad: Int32
    @NSManaged public var precio: Double
    @NSManaged public var subtotal: Double
    @NSManaged public var igv: Double
    @NSManaged public var total: Double
    @NSManaged public var cliente: Cliente?
    @NSManaged public var detalles: NSSet?
    @NSManaged public var producto: Producto?

    // Computed helpers
    var fechaVentaSafe: Date { fechaVenta ?? Date() }
    var detallesArray: [VentaDetalle] {
        let detalles = (detalles?.allObjects as? [VentaDetalle]) ?? []
        return detalles.sorted { $0.producto?.nombreSafe ?? "" < $1.producto?.nombreSafe ?? "" }
    }
    var productosResumen: String {
        let detalles = detallesArray
        guard !detalles.isEmpty else { return producto?.nombreSafe ?? "Producto desconocido" }
        if detalles.count == 1 {
            return detalles[0].producto?.nombreSafe ?? "Producto desconocido"
        }
        return "\(detalles.count) productos"
    }
    var cantidadTotal: Int32 {
        let detalles = detallesArray
        guard !detalles.isEmpty else { return cantidad }
        return detalles.reduce(Int32(0)) { $0 + $1.cantidad }
    }
}

extension Venta: Identifiable {
    public var id: UUID { idVenta ?? UUID() }
}
