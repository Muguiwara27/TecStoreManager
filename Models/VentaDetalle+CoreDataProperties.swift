//
//  VentaDetalle+CoreDataProperties.swift
//  TecStoreManager
//

import Foundation
import CoreData

extension VentaDetalle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VentaDetalle> {
        return NSFetchRequest<VentaDetalle>(entityName: "VentaDetalle")
    }

    @NSManaged public var idDetalle: UUID?
    @NSManaged public var cantidad: Int32
    @NSManaged public var precioUnitario: Double
    @NSManaged public var subtotal: Double
    @NSManaged public var producto: Producto?
    @NSManaged public var venta: Venta?

    var productoNombre: String { producto?.nombreSafe ?? "Producto desconocido" }
}

extension VentaDetalle: Identifiable {
    public var id: UUID { idDetalle ?? UUID() }
}
