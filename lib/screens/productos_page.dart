import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/producto.dart';
import '../services/firebase_service.dart';

/// Pantalla MVP: listado en tiempo real, FAB con formulario, edición y deslizar para borrar.
class ProductosPage extends StatefulWidget {
  const ProductosPage({super.key, required this.service});

  final FirebaseService service;

  @override
  State<ProductosPage> createState() => _ProductosPageState();
}

class _ProductosPageState extends State<ProductosPage> {
  Future<void> _openProductoSheet({Producto? existing}) async {
    final formKey = GlobalKey<FormState>();
    final codigoCtrl = TextEditingController(text: existing?.codigo ?? '');
    final nombreCtrl = TextEditingController(text: existing?.nombre ?? '');
    final precioCtrl = TextEditingController(
      text: existing != null ? existing.precio.toString() : '',
    );
    final proveedorCtrl = TextEditingController(text: existing?.proveedor ?? '');
    final unidadesCtrl = TextEditingController(
      text: existing != null ? existing.unidades.toString() : '',
    );

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? 'Nuevo producto' : 'Editar producto',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: codigoCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Código',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: precioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requerido';
                      final n = double.tryParse(v.replaceAll(',', '.'));
                      if (n == null) return 'Número inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: proveedorCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Proveedor',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: unidadesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Unidades',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Requerido';
                      final n = int.tryParse(v);
                      if (n == null) return 'Entero inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final precio = double.parse(
                        precioCtrl.text.trim().replaceAll(',', '.'),
                      );
                      final unidades = int.parse(unidadesCtrl.text.trim());
                      final producto = Producto(
                        id: existing?.id ?? '',
                        codigo: codigoCtrl.text.trim(),
                        nombre: nombreCtrl.text.trim(),
                        precio: precio,
                        proveedor: proveedorCtrl.text.trim(),
                        unidades: unidades,
                      );
                      try {
                        if (existing == null) {
                          await widget.service.addProducto(producto);
                        } else {
                          await widget.service.updateProducto(producto);
                        }
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      } catch (e) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    child: Text(existing == null ? 'Guardar' : 'Actualizar'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    codigoCtrl.dispose();
    nombreCtrl.dispose();
    precioCtrl.dispose();
    proveedorCtrl.dispose();
    unidadesCtrl.dispose();

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existing == null ? 'Producto creado' : 'Producto actualizado'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pageContext = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FilmCrew — Productos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<List<Producto>>(
        stream: widget.service.getProductos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error al cargar:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Text('No hay productos.\nToca + para agregar.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final p = list[index];
              return Dismissible(
                key: Key(p.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Theme.of(context).colorScheme.error,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar producto'),
                      content: Text('¿Eliminar "${p.nombre}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (ok != true) return false;
                  try {
                    await widget.service.deleteProducto(p.id);
                    if (!pageContext.mounted) return true;
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      const SnackBar(content: Text('Producto eliminado')),
                    );
                    return true;
                  } catch (e) {
                    if (!pageContext.mounted) return false;
                    ScaffoldMessenger.of(pageContext).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                    return false;
                  }
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(p.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      '${p.codigo} · ${p.proveedor}\n'
                      '\$${p.precio.toStringAsFixed(2)} · ${p.unidades} u.',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _openProductoSheet(existing: p),
                      tooltip: 'Editar',
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openProductoSheet(),
        tooltip: 'Agregar producto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
