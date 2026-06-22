//
//  CoreDataStack.swift
//  TecStoreManager
//
//  Singleton que expone el NSManagedObjectContext principal.
//

import CoreData
import Foundation

final class PersistenceController {

    // MARK: - Shared Instance
    static let shared = PersistenceController()

    // MARK: - Preview (SwiftUI Canvas)
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let ctx = controller.context

        // Seed de datos de prueba
        let usuario = Usuario(context: ctx)
        usuario.idUsuario = UUID()
        usuario.nombreUsuario = "admin"
        usuario.password = "admin123"
        usuario.nombreCompleto = "Administrador TecStore"
        usuario.estado = true

        let producto = Producto(context: ctx)
        producto.idProducto = UUID()
        producto.codigo = "PROD-001"
        producto.nombre = "Laptop Dell XPS 15"
        producto.categoria = "Computadoras"
        producto.precio = 1299.99
        producto.stock = 10
        producto.fechaRegistro = Date()
        producto.estado = true

        let cliente = Cliente(context: ctx)
        cliente.idCliente = UUID()
        cliente.dni = "12345678"
        cliente.nombres = "Juan"
        cliente.apellidos = "Pérez García"
        cliente.telefono = "987654321"
        cliente.correo = "juan.perez@email.com"
        cliente.direccion = "Av. Lima 123"
        cliente.estado = true

        try? ctx.save()
        return controller
    }()

    // MARK: - Container
    let container: NSPersistentContainer

    var context: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Init
    private init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TecStoreManager")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.persistentStoreDescriptions.forEach { description in
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }

        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                fatalError("❌ Error cargando Core Data: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: - Save
    func save() {
        let ctx = container.viewContext
        guard ctx.hasChanges else { return }
        do {
            try ctx.save()
        } catch {
            let nsError = error as NSError
            print("❌ Error guardando Core Data: \(nsError), \(nsError.userInfo)")
        }
    }

    // MARK: - Seed Inicial (crear usuario admin si no existe)
    func seedInitialDataIfNeeded() {
        let request: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        request.predicate = NSPredicate(format: "nombreUsuario == %@", "admin")
        let count = (try? context.count(for: request)) ?? 0
        guard count == 0 else { return }

        let admin = Usuario(context: context)
        admin.idUsuario = UUID()
        admin.nombreUsuario = "admin"
        admin.password = "admin123"
        admin.nombreCompleto = "Administrador TecStore"
        admin.estado = true
        save()
        print("✅ Usuario admin creado por defecto.")
    }
}
