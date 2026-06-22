//
//  Producto+CoreDataProperties.swift
//  TecStoreManager
//

import Foundation
import CoreData

extension Producto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Producto> {
        return NSFetchRequest<Producto>(entityName: "Producto")
    }

    @NSManaged public var idProducto: UUID?
    @NSManaged public var codigo: String?
    @NSManaged public var nombre: String?
    @NSManaged public var categoria: String?
    @NSManaged public var precio: Double
    @NSManaged public var stock: Int32
    @NSManaged public var fechaRegistro: Date?
    @NSManaged public var estado: Bool
    @NSManaged public var ventas: NSSet?
    @NSManaged public var ventaDetalles: NSSet?

    // Computed helpers
    var codigoSafe: String    { codigo ?? "" }
    var nombreSafe: String    { nombre ?? "" }
    var categoriaSafe: String { categoria ?? "" }
    var ventasArray: [Venta]  { (ventas?.allObjects as? [Venta]) ?? [] }
    var ventaDetallesArray: [VentaDetalle] { (ventaDetalles?.allObjects as? [VentaDetalle]) ?? [] }
}

extension Producto: Identifiable {
    public var id: UUID { idProducto ?? UUID() }
}
