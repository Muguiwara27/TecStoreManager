//
//  MapaView.swift
//  TecStoreManager
//
//  Pantalla SwiftUI: Mapa GPS
//  Componentes: Map, Text (coordenadas), Button, Sheet (ubicaciones guardadas), NavigationStack
//

import SwiftUI
import MapKit

struct MapaView: View {

    // MARK: - ViewModel
    @ObservedObject var viewModel: UbicacionViewModel

    // MARK: - State
    @State private var showGuardarSheet    = false
    @State private var showUbicacionesSheet = false
    @State private var referenciaTexto     = ""
    @State private var showSuccessAlert    = false
    @State private var showErrorAlert      = false
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Map — MapKit
                Map(position: $cameraPosition) {
                    UserAnnotation()
                    ForEach(viewModel.anotaciones) { anotacion in
                        Annotation(anotacion.titulo, coordinate: anotacion.coordenada) {
                            MapPinView(titulo: anotacion.titulo)
                        }
                    }
                }
                .onReceive(viewModel.$region) { region in
                    cameraPosition = .region(region)
                }
                .ignoresSafeArea(edges: .bottom)

                // Overlay superior — Coordenadas actuales
                VStack {
                    // Text — Coordenadas
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(Color(red: 0.55, green: 0.34, blue: 0.96))
                        Text(viewModel.estadoUbicacion)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        Spacer()
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    Spacer()

                    // Controles inferiores
                    VStack(spacing: 10) {

                        // Contador de ubicaciones guardadas
                        if !viewModel.ubicaciones.isEmpty {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(Color(red: 0.55, green: 0.34, blue: 0.96))
                                Text("\(viewModel.ubicaciones.count) ubicaciones guardadas")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Spacer()
                                // Button — Ver ubicaciones guardadas
                                Button("Ver todas") {
                                    showUbicacionesSheet = true
                                }
                                .font(.caption)
                                .foregroundColor(Color(red: 0.55, green: 0.34, blue: 0.96))
                            }
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }

                        HStack(spacing: 10) {
                            // Button — Obtener Ubicación
                            Button {
                                viewModel.solicitarUbicacion()
                            } label: {
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                    Text("Mi ubicación")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.55, green: 0.34, blue: 0.96))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }

                            // Button — Guardar Ubicación
                            Button {
                                if viewModel.coordenadasActuales != nil {
                                    referenciaTexto = ""
                                    showGuardarSheet = true
                                } else {
                                    showErrorAlert = true
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                    Text("Guardar")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color(red: 0.25, green: 0.85, blue: 0.55))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Mapa GPS")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.solicitarUbicacion()
                viewModel.fetchUbicaciones()
            }
            .onDisappear { viewModel.detenerUbicacion() }

            // Sheet — Guardar Ubicación
            .sheet(isPresented: $showGuardarSheet) {
                GuardarUbicacionSheet(
                    referenciaTexto: $referenciaTexto,
                    coordenadas: viewModel.estadoUbicacion,
                    onGuardar: {
                        let ok = viewModel.guardarUbicacionActual(referencia: referenciaTexto)
                        showGuardarSheet = false
                        if ok { showSuccessAlert = true }
                    },
                    onCancelar: { showGuardarSheet = false }
                )
            }

            // Sheet — Lista de Ubicaciones Guardadas
            .sheet(isPresented: $showUbicacionesSheet) {
                UbicacionesGuardadasSheet(
                    ubicaciones: viewModel.ubicaciones,
                    onEliminar: { viewModel.eliminarUbicacion($0) },
                    onDismiss: { showUbicacionesSheet = false }
                )
            }

            .alert("✅ Ubicación Guardada", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("La ubicación fue registrada exitosamente en Core Data.")
            }

            .alert("⚠️ Sin Ubicación", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Primero presiona 'Mi ubicación' para obtener tu posición actual.")
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - MapPinView
struct MapPinView: View {
    let titulo: String

    var body: some View {
        VStack(spacing: 0) {
            Text(titulo)
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color(red: 0.55, green: 0.34, blue: 0.96))
                .cornerRadius(6)
            Image(systemName: "mappin")
                .font(.title2)
                .foregroundColor(Color(red: 0.55, green: 0.34, blue: 0.96))
        }
    }
}

// MARK: - GuardarUbicacionSheet
struct GuardarUbicacionSheet: View {
    @Binding var referenciaTexto: String
    let coordenadas: String
    let onGuardar: () -> Void
    let onCancelar: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.14).ignoresSafeArea()

                VStack(spacing: 20) {
                    // Text — Coordenadas actuales
                    VStack(spacing: 6) {
                        Image(systemName: "location.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color(red: 0.55, green: 0.34, blue: 0.96))
                        Text("Coordenadas Actuales")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(coordenadas)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(14)

                    // TextField — Referencia
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Descripción de referencia")
                            .font(.caption)
                            .foregroundColor(.gray)
                        TextField("Ej: Tienda principal, Almacén...", text: $referenciaTexto)
                            .padding(12)
                            .background(Color.white.opacity(0.08))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Button — Guardar
                    Button {
                        onGuardar()
                    } label: {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text("Guardar Ubicación")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.55, green: 0.34, blue: 0.96))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Guardar Ubicación")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { onCancelar() }.foregroundColor(.red)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - UbicacionesGuardadasSheet
struct UbicacionesGuardadasSheet: View {
    let ubicaciones: [Ubicacion]
    let onEliminar: (Ubicacion) -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.14).ignoresSafeArea()

                List(ubicaciones) { ubi in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ubi.direccionReferenciaSafe)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text(String(format: "Lat: %.5f   Lon: %.5f", ubi.latitud, ubi.longitud))
                            .font(.caption)
                            .foregroundColor(.gray)
                        if let fecha = ubi.fechaRegistro {
                            let fmt: DateFormatter = {
                                let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .short; return f
                            }()
                            Text(fmt.string(from: fecha))
                                .font(.caption2)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    .listRowSeparatorTint(Color.white.opacity(0.08))
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            onEliminar(ubi)
                        } label: {
                            Label("Eliminar", systemImage: "trash")
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Ubicaciones Guardadas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") { onDismiss() }
                        .foregroundColor(Color(red: 0.4, green: 0.7, blue: 1.0))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
