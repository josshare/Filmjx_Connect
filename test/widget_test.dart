import 'package:filmjx_connect/models/producto.dart';
import 'package:filmjx_connect/screens/productos_page.dart';
import 'package:filmjx_connect/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Servicio falso para pruebas sin Firebase.
class _FakeFirebaseService implements FirebaseService {
  @override
  Stream<List<Producto>> getProductos() => Stream.value(const []);

  @override
  Future<String> addProducto(Producto p) async => 'fake-id';

  @override
  Future<void> deleteProducto(String id) async {}

  @override
  Future<void> updateProducto(Producto p) async {}
}

void main() {
  testWidgets('Lista vacía de productos', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProductosPage(service: _FakeFirebaseService()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No hay productos'), findsOneWidget);
  });
}
