// Worker de drift para la versión web. Se compila a web/drift_worker.js con:
//   dart compile js -O4 web/drift_worker.dart -o web/drift_worker.js
import 'package:drift/wasm.dart';

void main() => WasmDatabase.workerMainForOpen();
