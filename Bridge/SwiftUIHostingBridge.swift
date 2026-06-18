//
//  SwiftUIHostingBridge.swift
//  TecStoreManager
//
//  Capa de Bridge entre UIKit y SwiftUI.
//
//  PATRÓN 1: UIHostingController
//  ─────────────────────────────
//  Se usa en DashboardViewController para navegar hacia pantallas SwiftUI.
//  El Dashboard crea una instancia de la vista SwiftUI, la envuelve en un
//  UIHostingController y la empuja al UINavigationController:
//
//      let swiftUIView = ClientesListView(viewModel: vm)
//      let hostingVC   = UIHostingController(rootView: swiftUIView)
//      navigationController?.pushViewController(hostingVC, animated: true)
//
//  PATRÓN 2: UIViewControllerRepresentable
//  ────────────────────────────────────────
//  Si una vista SwiftUI necesita incrustar un ViewController UIKit,
//  se usa UIViewControllerRepresentable. Ver UIKitRepresentable.swift.
//
//  Este archivo centraliza los wrappers de UIHostingController para
//  mayor claridad y mantenibilidad del proyecto.
//

import UIKit
import SwiftUI

// MARK: - Wrapper: Clientes
/// Crea y devuelve un UIHostingController con ClientesListView.
func makeClientesHostingController() -> UIHostingController<ClientesListView> {
    let vm   = ClienteViewModel()
    let view = ClientesListView(viewModel: vm)
    return UIHostingController(rootView: view)
}

// MARK: - Wrapper: Ventas
/// Crea y devuelve un UIHostingController con VentasListView.
func makeVentasHostingController() -> UIHostingController<VentasListView> {
    let ventaVM    = VentaViewModel()
    let clienteVM  = ClienteViewModel()
    let productoVM = ProductoViewModel()
    let view = VentasListView(
        ventaVM: ventaVM,
        clienteVM: clienteVM,
        productoVM: productoVM
    )
    return UIHostingController(rootView: view)
}

// MARK: - Wrapper: Reportes
/// Crea y devuelve un UIHostingController con ReportesView.
func makeReportesHostingController() -> UIHostingController<ReportesView> {
    let vm   = ReportesViewModel()
    let view = ReportesView(viewModel: vm)
    return UIHostingController(rootView: view)
}

// MARK: - Wrapper: Mapa GPS
/// Crea y devuelve un UIHostingController con MapaView.
func makeMapaHostingController() -> UIHostingController<MapaView> {
    let vm   = UbicacionViewModel()
    let view = MapaView(viewModel: vm)
    return UIHostingController(rootView: view)
}

// MARK: - Wrapper: Búsquedas Avanzadas
func makeBusquedasHostingController() -> UIHostingController<BusquedasAvanzadasView> {
    let clienteVM  = ClienteViewModel()
    let productoVM = ProductoViewModel()
    let view = BusquedasAvanzadasView(
        clienteVM: clienteVM,
        productoVM: productoVM
    )
    return UIHostingController(rootView: view)
}

/*
 ────────────────────────────────────────────────────────────
 EXPLICACIÓN TÉCNICA: Comunicación UIKit ↔ SwiftUI
 ────────────────────────────────────────────────────────────

 1. UIKit → SwiftUI (UIHostingController)
    El DashboardViewController (UIKit) navega hacia pantallas SwiftUI
    envolviendo la vista en UIHostingController y usándolo como un
    UIViewController normal dentro del UINavigationController.

    Ventajas:
    - La vista SwiftUI queda completamente integrada en la jerarquía UIKit.
    - El ciclo de vida (viewDidAppear, etc.) funciona correctamente.
    - El ViewModel se inyecta en el momento de la creación del Hosting.

 2. SwiftUI → UIKit (UIViewControllerRepresentable)
    Para incrustar un UIViewController UIKit dentro de una vista SwiftUI,
    se crea un struct que implementa UIViewControllerRepresentable.
    Ver: UIKitRepresentable.swift

 3. Compartición de datos (MVVM)
    Los ViewModels son ObservableObject. Se crean en el momento de la
    navegación y se pasan a las vistas SwiftUI. Los cambios en Core Data
    se propagan automáticamente vía @Published + objectWillChange.

 ────────────────────────────────────────────────────────────
*/
