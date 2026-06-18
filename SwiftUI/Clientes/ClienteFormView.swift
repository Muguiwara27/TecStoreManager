//
//  ClienteFormView.swift
//  TecStoreManager
//
//  Pantalla SwiftUI: Formulario de Cliente (Crear / Editar)
//  Componentes: Form, TextField (×6), Toggle, Button
//

import SwiftUI

struct ClienteFormView: View {

    // MARK: - ViewModel
    @ObservedObject var viewModel: ClienteViewModel
    var cliente: Cliente? // nil = nuevo

    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss

    // MARK: - State del formulario
    @State private var dni        = ""
    @State private var nombres    = ""
    @State private var apellidos  = ""
    @State private var telefono   = ""
    @State private var correo     = ""
    @State private var direccion  = ""
    @State private var estado     = true
    @State private var showAlert  = false
    @State private var alertMsg   = ""
    @State private var exitoso    = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.07, green: 0.07, blue: 0.14).ignoresSafeArea()

                Form {
                    // Sección Datos Personales
                    Section {
                        // TextField — DNI
                        HStack {
                            Image(systemName: "creditcard").foregroundColor(.blue)
                            TextField("DNI (8 dígitos)", text: $dni)
                                .keyboardType(.numberPad)
                        }

                        // TextField — Nombres
                        HStack {
                            Image(systemName: "person").foregroundColor(.blue)
                            TextField("Nombres", text: $nombres)
                        }

                        // TextField — Apellidos
                        HStack {
                            Image(systemName: "person.fill").foregroundColor(.blue)
                            TextField("Apellidos", text: $apellidos)
                        }
                    } header: {
                        Label("Datos Personales", systemImage: "person.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.white.opacity(0.07))

                    // Sección Contacto
                    Section {
                        // TextField — Teléfono
                        HStack {
                            Image(systemName: "phone").foregroundColor(.green)
                            TextField("Teléfono", text: $telefono)
                                .keyboardType(.phonePad)
                        }

                        // TextField — Correo
                        HStack {
                            Image(systemName: "envelope").foregroundColor(.green)
                            TextField("Correo electrónico", text: $correo)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }

                        // TextField — Dirección
                        HStack {
                            Image(systemName: "mappin").foregroundColor(.green)
                            TextField("Dirección", text: $direccion)
                        }
                    } header: {
                        Label("Contacto", systemImage: "envelope.fill")
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.white.opacity(0.07))

                    // Sección Estado — Toggle
                    Section {
                        Toggle(isOn: $estado) {
                            Label("Cliente Activo", systemImage: "checkmark.shield.fill")
                        }
                        .tint(Color(red: 0.25, green: 0.52, blue: 0.96))
                    } header: {
                        Label("Estado", systemImage: "circle.fill")
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.white.opacity(0.07))

                    // Button — Guardar
                    Section {
                        Button {
                            handleGuardar()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: cliente == nil ? "plus.circle.fill" : "checkmark.circle.fill")
                                Text(cliente == nil ? "Registrar Cliente" : "Actualizar Cliente")
                                    .fontWeight(.bold)
                                Spacer()
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.25, green: 0.52, blue: 0.96))
                        .cornerRadius(10)
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(cliente == nil ? "Nuevo Cliente" : "Editar Cliente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.red)
                }
            }
            .onAppear { cargarDatos() }
            .alert(exitoso ? "✅ Éxito" : "⚠️ Error", isPresented: $showAlert) {
                Button("OK") {
                    if exitoso { dismiss() }
                }
            } message: {
                Text(alertMsg)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Cargar datos (edición)
    private func cargarDatos() {
        guard let c = cliente else { return }
        dni       = c.dniSafe
        nombres   = c.nombresSafe
        apellidos = c.apellidosSafe
        telefono  = c.telefonoSafe
        correo    = c.correoSafe
        direccion = c.direccionSafe
        estado    = c.estado
    }

    // MARK: - Guardar
    private func handleGuardar() {
        let ok = viewModel.guardarCliente(
            dni: dni, nombres: nombres, apellidos: apellidos,
            telefono: telefono, correo: correo, direccion: direccion,
            estado: estado, clienteExistente: cliente
        )
        exitoso   = ok
        alertMsg  = ok
            ? "El cliente \(nombres) \(apellidos) fue \(cliente == nil ? "registrado" : "actualizado") correctamente."
            : viewModel.errorMessage
        showAlert = true
    }
}
