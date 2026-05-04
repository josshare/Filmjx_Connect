#!/usr/bin/env bash
# Configura Firebase (FlutterFire) para este repo. Requiere sesión Google/Firebase
# (el CLI abrirá el flujo de login en el navegador la primera vez).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .firebaserc ]]; then
  echo "No existe .firebaserc." >&2
  echo "  cp .firebaserc.example .firebaserc" >&2
  echo "y cambiá \"your-firebase-project-id\" por el id del proyecto (Consola Firebase → ⚙️ Ajustes del proyecto)." >&2
  exit 1
fi

PROJECT="$(python3 -c "import json; print(json.load(open('.firebaserc'))['projects']['default'])")"
if [[ "$PROJECT" == "your-firebase-project-id" ]]; then
  echo "Editá .firebaserc: sustituí \"your-firebase-project-id\" por tu id de proyecto real." >&2
  exit 1
fi

dart pub get
dart run flutterfire_cli:flutterfire configure \
  -y \
  --project="$PROJECT" \
  --platforms=ios,android,macos \
  --ios-bundle-id=com.filmjx.filmjxConnect \
  --android-package-name=com.filmjx.filmjx_connect \
  --macos-bundle-id=com.filmjx.filmjxConnect

echo ""
echo "Si lib/main.dart aún usa Firebase.initializeApp() sin opciones, actualizalo a:"
echo "  import 'firebase_options.dart';"
echo "  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);"
