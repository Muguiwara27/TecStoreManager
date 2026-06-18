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
    @NSManaged public var producto: Producto?

    // Computed helpers
    var fechaVentaSafe: Date { fechaVenta ?? Date() }
}

extension Venta: Identifiable {
    public var id: UUID { idVenta ?? UUID() }
}
