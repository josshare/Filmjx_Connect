# filmjx_connect

A new Flutter project.

## Firebase (FlutterFire)

Si `flutterfire configure` falla con **`FirebaseProjectRequiredException`**, hay que indicar el id del proyecto de Firebase con **`.firebaserc`** o con `--project=...`.

1. Copiá el ejemplo y editá el id (minúsculas, como en la consola de Firebase):

   `cp .firebaserc.example .firebaserc`

2. Desde la raíz del repo (con navegador disponible para iniciar sesión en Google la primera vez):

   `chmod +x tool/flutterfire_configure.sh && ./tool/flutterfire_configure.sh`

   Equivale a usar `dart run flutterfire_cli:flutterfire configure ...` con los bundle/package id de esta app.

3. En `lib/main.dart`, inicializá Firebase con las opciones generadas en `lib/firebase_options.dart`:

   ```dart
   import 'firebase_options.dart';
   // ...
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```

El archivo `.firebaserc` está en `.gitignore` para no subir el id del proyecto si no querés versionarlo.

### Repo público / GitHub (no exponer configs de Firebase)

Los archivos reales **`android/app/google-services.json`** e **`ios/Runner/GoogleService-Info.plist`** están en **`.gitignore`**. No los subas: copiá desde la consola de Firebase y dejalos solo en tu máquina.

Para nuevos clones, usá las plantillas (sin secretos):

- `android/app/google-services.json.example` → copiar a `google-services.json` y reemplazar valores.
- `ios/Runner/GoogleService-Info.plist.example` → copiar a `GoogleService-Info.plist` en el mismo directorio y reemplazar valores.

Además, en [Google Cloud Console](https://console.cloud.google.com/) restringí las **API keys** de Android/iOS por **paquete / bundle id** y activá reglas estrictas en **Firestore**.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
