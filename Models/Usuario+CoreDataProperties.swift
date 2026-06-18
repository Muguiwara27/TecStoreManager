//
//  Usuario+CoreDataProperties.swift
//  TecStoreManager
//

import Foundation
import CoreData

extension Usuario {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Usuario> {
        return NSFetchRequest<Usuario>(entityName: "Usuario")
    }

    @NSManaged public var idUsuario: UUID?
    @NSManaged public var nombreUsuario: String?
    @NSManaged public var password: String?
    @NSManaged public var nombreCompleto: String?
    @NSManaged public var estado: Bool

    // Computed helpers
    var nombreUsuarioSafe: String   { nombreUsuario ?? "" }
    var passwordSafe: String        { password ?? "" }
    var nombreCompletoSafe: String  { nombreCompleto ?? "" }
}

extension Usuario: Identifiable {
    public var id: UUID { idUsuario ?? UUID() }
}
