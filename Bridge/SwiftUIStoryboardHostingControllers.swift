//
//  SwiftUIStoryboardHostingControllers.swift
//  TecStoreManager
//

import SwiftUI
import UIKit

final class ClientesHostingViewController: UIHostingController<ClientesListView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: ClientesListView(viewModel: ClienteViewModel()))
        title = "Clientes"
    }
}

final class VentasHostingViewController: UIHostingController<VentasListView> {
    required init?(coder: NSCoder) {
        super.init(
            coder: coder,
            rootView: VentasListView(
                ventaVM: VentaViewModel(),
                clienteVM: ClienteViewModel(),
                productoVM: ProductoViewModel()
            )
        )
        title = "Ventas"
    }
}

final class MapaHostingViewController: UIHostingController<MapaView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: MapaView(viewModel: UbicacionViewModel()))
        title = "Mapa GPS"
    }
}

final class ReportesHostingViewController: UIHostingController<ReportesView> {
    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: ReportesView(viewModel: ReportesViewModel()))
        title = "Reportes"
    }
}
