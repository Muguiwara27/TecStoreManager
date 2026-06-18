//
//  UIKitRepresentable.swift
//  TecStoreManager
//
//  UIViewControllerRepresentable — Incrustar UIKit en SwiftUI.
//  Permite que una vista SwiftUI contenga cualquier UIViewController UIKit.
//

import SwiftUI
import UIKit

// MARK: - ProductosListRepresentable
/// Permite mostrar la pantalla UIKit de Productos dentro de una vista SwiftUI.
/// Ejemplo de uso en SwiftUI:
///     ProductosListRepresentable()
///         .navigationTitle("Productos")
struct ProductosListRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> ProductosListViewController {
        return ProductosListViewController()
    }

    func updateUIViewController(_ uiViewController: ProductosListViewController, context: Context) {
        // No se requieren actualizaciones externas; el VC gestiona su propio estado.
    }
}

// MARK: - ConfiguracionRepresentable
/// Permite mostrar la pantalla UIKit de Configuración dentro de una vista SwiftUI.
struct ConfiguracionRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> ConfiguracionViewController {
        return ConfiguracionViewController()
    }

    func updateUIViewController(_ uiViewController: ConfiguracionViewController, context: Context) {}
}

// MARK: - AcercaDeRepresentable
/// Permite mostrar la pantalla UIKit de Acerca de dentro de una vista SwiftUI.
struct AcercaDeRepresentable: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> AcercaDeViewController {
        return AcercaDeViewController()
    }

    func updateUIViewController(_ uiViewController: AcercaDeViewController, context: Context) {}
}

/*
 ────────────────────────────────────────────────────────────
 USO de UIViewControllerRepresentable en este proyecto:
 ────────────────────────────────────────────────────────────

 Para incrustar una pantalla UIKit dentro de SwiftUI:

     struct ContentView: View {
         var body: some View {
             ProductosListRepresentable()
         }
     }

 Para navegación dentro de NavigationStack SwiftUI:

     NavigationStack {
         NavigationLink("Ir a Productos") {
             ProductosListRepresentable()
                 .ignoresSafeArea()
         }
     }

 Coordinator Pattern (para comunicación bidireccional):
 Si se necesita que el UIViewController notifique a la vista SwiftUI,
 se implementa el Coordinator con un Binding o closure callback.

 Ejemplo:
     class Coordinator: NSObject {
         var parent: ProductosListRepresentable
         init(_ parent: ProductosListRepresentable) {
             self.parent = parent
         }
     }

     func makeCoordinator() -> Coordinator {
         return Coordinator(self)
     }

 ────────────────────────────────────────────────────────────
*/
