import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de producto para la colección Firestore `productos`.
class Producto {
  const Producto({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.precio,
    required this.proveedor,
    required this.unidades,
  });

  final String id;
  final String codigo;
  final String nombre;
  final double precio;
  final String proveedor;
  final int unidades;

  Map<String, dynamic> toFirestore() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'precio': precio,
      'proveedor': proveedor,
      'unidades': unidades,
    };
  }

  factory Producto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return Producto(
      id: doc.id,
      codigo: data['codigo'] as String? ?? '',
      nombre: data['nombre'] as String? ?? '',
      precio: (data['precio'] as num?)?.toDouble() ?? 0,
      proveedor: data['proveedor'] as String? ?? '',
      unidades: (data['unidades'] as num?)?.toInt() ?? 0,
    );
  }

  Producto copyWith({
    String? id,
    String? codigo,
    String? nombre,
    double? precio,
    String? proveedor,
    int? unidades,
  }) {
    return Producto(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      proveedor: proveedor ?? this.proveedor,
      unidades: unidades ?? this.unidades,
    );
  }
}
