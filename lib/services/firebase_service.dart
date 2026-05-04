import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/producto.dart';

/// Servicio CRUD para la colección `productos` en Firestore.
class FirebaseService {
  FirebaseService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const String _collectionName = 'productos';

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(_collectionName);

  /// Escucha en tiempo real todos los documentos de [productos].
  Stream<List<Producto>> getProductos() {
    return _col.snapshots().map(
          (snapshot) => snapshot.docs.map(Producto.fromFirestore).toList(),
        );
  }

  /// Crea un documento nuevo. El ID lo asigna Firestore.
  Future<String> addProducto(Producto p) async {
    final doc = await _col.add(p.toFirestore());
    return doc.id;
  }

  /// Actualiza un documento existente por [p.id].
  Future<void> updateProducto(Producto p) async {
    await _col.doc(p.id).update(p.toFirestore());
  }

  /// Elimina el documento con el [id] indicado.
  Future<void> deleteProducto(String id) async {
    await _col.doc(id).delete();
  }
}
