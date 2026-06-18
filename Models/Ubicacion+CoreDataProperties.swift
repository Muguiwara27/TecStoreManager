//
//  Ubicacion+CoreDataProperties.swift
//  TecStoreManager
//

import Foundation
import CoreData

extension Ubicacion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Ubicacion> {
        return NSFetchRequest<Ubicacion>(entityName: "Ubicacion")
    }

    @NSManaged public var idUbicacion: UUID?
    @NSManaged public var latitud: Double
    @NSManaged public var longitud: Double
    @NSManaged public var direccionReferencia: String?
    @NSManaged public var fechaRegistro: Date?

    var direccionReferenciaSafe: String { direccionReferencia ?? "" }
    var fechaRegistroSafe: Date         { fechaRegistro ?? Date() }
}

extension Ubicacion: Identifiable {
    public var id: UUID { idUbicacion ?? UUID() }
}
