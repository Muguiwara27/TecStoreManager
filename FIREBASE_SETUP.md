# Configurar Firebase Authentication

Esta app usa Firebase Authentication mediante la REST API, sin instalar el SDK de Firebase. Solo necesitas habilitar Email/Password y copiar la Web API Key en un plist local.

## 1. Crear o seleccionar el proyecto

1. Abre [Firebase Console](https://console.firebase.google.com/).
2. Crea un proyecto nuevo o selecciona uno existente.
3. Entra al panel del proyecto.

## 2. Habilitar Email/Password

1. En Firebase Console, ve a **Build > Authentication**.
2. Abre **Sign-in method**.
3. Selecciona **Email/Password**.
4. Activa **Email/Password** y guarda.

Referencia: [Firebase Email/Password Auth](https://firebase.google.com/docs/auth/ios/password-auth).

## 3. Obtener la Web API Key

Opcion recomendada:

1. En Firebase Console, entra a **Project settings** con el icono de engranaje.
2. En **General > Your apps**, agrega una app de Apple.
3. Usa este Bundle ID: `com.tecstore.manager`.
4. Descarga `GoogleService-Info.plist`.
5. Abre ese archivo y copia el valor de `API_KEY`.

Opcion alternativa:

1. Abre [Google Cloud Console Credentials](https://console.cloud.google.com/apis/credentials).
2. Selecciona el mismo proyecto Firebase.
3. Busca la API key asociada a Firebase.

Referencia: [Firebase API keys](https://firebase.google.com/docs/projects/api-keys).

## 4. Crear el plist local de la app

Desde la raiz del proyecto:

```bash
cp Resources/FirebaseConfig.example.plist Resources/FirebaseConfig.local.plist
```

Abre `Resources/FirebaseConfig.local.plist` y reemplaza:

```xml
REEMPLAZA_CON_TU_API_KEY
```

por tu Web API Key real.

`FirebaseConfig.local.plist` esta en `.gitignore`, por eso no se sube al repositorio.

## 5. Compilar y probar

Compila desde Xcode o con:

```bash
xcodebuild -project TecStoreManager.xcodeproj -scheme TecStoreManager -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Si no creas `FirebaseConfig.local.plist`, la app compila, pero al intentar login o registro mostrara:

```text
Configura FirebaseConfig.local.plist con tu FIREBASE_WEB_API_KEY.
```

## 6. Ver usuarios creados

1. Vuelve a Firebase Console.
2. Entra a **Build > Authentication > Users**.
3. Despues de registrar un usuario desde la app, deberia aparecer en esa lista.

## Notas importantes

- Esta integracion usa la REST API documentada en [Firebase Auth REST API](https://firebase.google.com/docs/reference/rest/auth).
- La Web API Key identifica tu proyecto Firebase; no reemplaza las reglas de seguridad ni las cuotas.
- Para produccion, revisa restricciones y monitoreo de uso desde Google Cloud Console.
