//
//  Cliente+CoreDataProperties.swift
//  TecStoreManager
//

import Foundation
import CoreData

extension Cliente {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cliente> {
        return NSFetchRequest<Cliente>(entityName: "Cliente")
    }

    @NSManaged public var idCliente: UUID?
    @NSManaged public var dni: String?
    @NSManaged public var nombres: String?
    @NSManaged public var apellidos: String?
    @NSManaged public var telefono: String?
    @NSManaged public var correo: String?
    @NSManaged public var direccion: String?
    @NSManaged public var estado: Bool
    @NSManaged public var ventas: NSSet?

    // Computed helpers
    var dniSafe: String       { dni ?? "" }
    var nombresSafe: String   { nombres ?? "" }
    var apellidosSafe: String { apellidos ?? "" }
    var telefonoSafe: String  { telefono ?? "" }
    var correoSafe: String    { correo ?? "" }
    var direccionSafe: String { direccion ?? "" }
    var nombreCompleto: String { "\(nombresSafe) \(apellidosSafe)".trimmingCharacters(in: .whitespaces) }
    var ventasArray: [Venta]  { (ventas?.allObjects as? [Venta]) ?? [] }
}

extension Cliente: Identifiable {
    public var id: UUID { idCliente ?? UUID() }
}
