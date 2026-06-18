//
//  UbicacionViewModel.swift
//  TecStoreManager
//
//  MVVM ViewModel para GPS y Ubicaciones.
//  Pantalla SwiftUI: MapaView
//  Usa CoreLocation + MapKit.
//

import Foundation
import CoreData
import CoreLocation
import MapKit
import Combine

final class UbicacionViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    // MARK: - Published State
    @Published var ubicaciones: [Ubicacion] = []
    @Published var coordenadasActuales: CLLocationCoordinate2D?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428), // Lima, Perú
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var estadoUbicacion: String = "Obteniendo ubicación..."
    @Published var errorMessage: String = ""
    @Published var ubicacionGuardadaExitosamente: Bool = false

    private let locationManager = CLLocationManager()
    private let context = PersistenceController.shared.context

    // MARK: - Init
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        fetchUbicaciones()
    }

    // MARK: - Solicitar Permiso y Comenzar
    func solicitarUbicacion() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        estadoUbicacion = "Obteniendo ubicación..."
    }

    func detenerUbicacion() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.coordenadasActuales = location.coordinate
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            self.estadoUbicacion = String(
                format: "Lat: %.6f  Lon: %.6f",
                location.coordinate.latitude,
                location.coordinate.longitude
            )
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Error al obtener ubicación: \(error.localizedDescription)"
            self.estadoUbicacion = "Error al obtener ubicación"
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            errorMessage = "Permiso de ubicación denegado. Habilítalo en Ajustes."
            estadoUbicacion = "Sin permiso de ubicación"
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }

    // MARK: - Guardar Ubicación
    func guardarUbicacionActual(referencia: String) -> Bool {
        guard let coords = coordenadasActuales else {
            errorMessage = "Aún no se ha obtenido una ubicación válida."
            return false
        }

        let ubi = Ubicacion(context: context)
        ubi.idUbicacion = UUID()
        ubi.latitud = coords.latitude
        ubi.longitud = coords.longitude
        ubi.direccionReferencia = referencia.isEmpty ? "Sin referencia" : referencia
        ubi.fechaRegistro = Date()

        PersistenceController.shared.save()
        fetchUbicaciones()
        ubicacionGuardadaExitosamente = true
        errorMessage = ""
        return true
    }

    // MARK: - Fetch Ubicaciones Guardadas
    func fetchUbicaciones() {
        let request: NSFetchRequest<Ubicacion> = Ubicacion.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "fechaRegistro", ascending: false)]
        ubicaciones = (try? context.fetch(request)) ?? []
    }

    // MARK: - Eliminar Ubicación
    func eliminarUbicacion(_ ubi: Ubicacion) {
        context.delete(ubi)
        PersistenceController.shared.save()
        fetchUbicaciones()
    }

    // MARK: - Anotaciones para el mapa
    var anotaciones: [UbicacionAnotacion] {
        ubicaciones.map { ubi in
            UbicacionAnotacion(
                id: ubi.idUbicacion ?? UUID(),
                coordenada: CLLocationCoordinate2D(latitude: ubi.latitud, longitude: ubi.longitud),
                titulo: ubi.direccionReferenciaSafe,
                subtitulo: String(format: "%.5f, %.5f", ubi.latitud, ubi.longitud)
            )
        }
    }
}

// MARK: - Anotación de Mapa
struct UbicacionAnotacion: Identifiable {
    let id: UUID
    let coordenada: CLLocationCoordinate2D
    let titulo: String
    let subtitulo: String
}
