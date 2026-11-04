// UI test cases — transactions, categories in the form, filters, alerts and
// AI suggestions. Every step is recorded under build/test_recordings/<CP>/.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenda_fronted/core/models/transaction.dart';
import 'package:zenda_fronted/features/transactions/add_transaction_screen.dart';
import 'package:zenda_fronted/features/transactions/transaction_list_screen.dart';
import 'package:zenda_fronted/providers/repositories_providers.dart';

import 'support/fakes.dart';
import 'support/ui_harness.dart';

void main() {
  setUpAll(loadRecordingFonts);

  Future<RecordingTransactionService> openForm(
    WidgetTester tester, {
    RecordingTransactionService? service,
    StrictCategoryService? categories,
  }) async {
    final tx = service ?? RecordingTransactionService();
    await pumpScreen(
      tester,
      const AddTransactionScreen(),
      overrides: [
        transactionApiServiceProvider.overrideWithValue(tx),
        if (categories != null)
          categoryApiServiceProvider.overrideWithValue(categories),
      ],
    );
    return tx;
  }

  Future<void> pickCategory(WidgetTester tester, String label) async {
    await tapText(tester, 'Selecciona una categoría');
    await tapText(tester, label);
  }

  Future<void> save(WidgetTester tester) => tapText(tester, 'Guardar transacción');

  caseTest('CP001', 'Registro exitoso de ingreso', (tester, rec) async {
    final tx = await openForm(tester);
    await rec.step('1. Pantalla de registro abierta con campos vacíos');
    await tapText(tester, 'Ingreso');
    await typeInto(tester, 0, '1500');
    await pickCategory(tester, 'Beca');
    await rec.step('2. Se ingresa un ingreso de S/ 1500 en la categoría Beca');
    await save(tester);
    await rec.step('3. Se guarda y la app pasa a la confirmación del registro');
    expect(tx.created.single.kind, TransactionKind.income);
    expect(tx.created.single.amount, 1500);
    expect(find.text('Ruta: /transaction-saved'), findsOneWidget);
  });

  caseTest('CP002', 'Validación de monto inválido', (tester, rec) async {
    final tx = await openForm(tester);
    await tapText(tester, 'Ingreso');
    await pickCategory(tester, 'Beca');
    await rec.step('1. Ingreso sin monto (campo vacío)');
    await save(tester);
    await rec.step('2. Al guardar se muestra el error de monto y no se registra');
    expect(find.text('Ingresa un monto mayor a 0.'), findsOneWidget);
    await typeInto(tester, 0, '0');
    await save(tester);
    await rec.step('3. Con monto 0 también se rechaza');
    expect(find.text('Ingresa un monto mayor a 0.'), findsOneWidget);
    expect(tx.created, isEmpty);
  });

  caseTest('CP003', 'Registro exitoso de gasto', (tester, rec) async {
    final tx = await openForm(tester);
    await rec.step('1. Formulario de gasto abierto');
    await typeInto(tester, 0, '35.50');
    await pickCategory(tester, 'Comida');
    await rec.step('2. Gasto de S/ 35.50 en Comida');
    await save(tester);
    await rec.step('3. Gasto registrado; se muestra la confirmación');
    expect(tx.created.single.kind, TransactionKind.expense);
    expect(tx.created.single.amount, 35.5);
    expect(find.text('Ruta: /transaction-saved'), findsOneWidget);
  });

  caseTest('CP004', 'Validación de monto negativo o no numérico', (tester, rec) async {
    final tx = await openForm(tester);
    await pickCategory(tester, 'Comida');
    await typeInto(tester, 0, '-20');
    await rec.step('1. Se ingresa un monto negativo');
    await save(tester);
    await rec.step('2. Error de validación: no se permite guardar');
    expect(find.text('Ingresa un monto mayor a 0.'), findsOneWidget);
    await typeInto(tester, 0, 'abc');
    await save(tester);
    await rec.step('3. Texto no numérico: mismo error, nada se registra');
    expect(find.text('Ingresa un monto mayor a 0.'), findsOneWidget);
    expect(tx.created, isEmpty);
  });

  caseTest('CP009', 'Asignación de categoría a ingreso', (tester, rec) async {
    final tx = await openForm(tester);
    await tapText(tester, 'Ingreso');
    await typeInto(tester, 0, '300');
    await rec.step('1. Ingreso de S/ 300');
    await pickCategory(tester, 'Apoyo familiar');
    await rec.step('2. Se selecciona la categoría "Apoyo familiar"');
    await save(tester);
    await rec.step('3. El ingreso queda asociado a esa categoría');
    expect(tx.created.single.category, TransactionCategory.familia);
  });

  caseTest('CP010', 'Creación de categoría con nombre duplicado', (tester, rec) async {
    final categories = StrictCategoryService();
    await openForm(tester, categories: categories);
    await tapText(tester, 'Ingreso');
    await rec.step('1. Formulario de ingreso');
    await tapText(tester, 'Nueva categoría');
    await tester.enterText(find.byType(TextField).last, 'Comida');
    await rec.step('2. Se intenta crear una categoría con un nombre existente');
    await tapText(tester, 'Guardar categoría');
    await rec.step('3. Error: ya existe una categoría con ese nombre');
    expect(find.text('Ya existe una categoría con ese nombre.'), findsOneWidget);
    expect(categories.createdNames, isEmpty);
  });

  caseTest('CP011', 'Asignación de categoría a gasto', (tester, rec) async {
    final tx = await openForm(tester);
    await typeInto(tester, 0, '22');
    await pickCategory(tester, 'Transporte');
    await rec.step('1. Gasto de S/ 22 con categoría Transporte');
    await save(tester);
    await rec.step('2. El gasto queda vinculado a la categoría');
    expect(tx.created.single.category, TransactionCategory.transporte);
  });

  caseTest('CP012', 'Intento de guardar gasto sin categoría', (tester, rec) async {
    final tx = await openForm(tester);
    await typeInto(tester, 0, '20');
    await rec.step('1. Gasto con monto pero sin categoría');
    await save(tester);
    await rec.step('2. Mensaje: la categoría es obligatoria; no se registra');
    expect(find.text('Selecciona una categoría.'), findsOneWidget);
    expect(tx.created, isEmpty);
  });

  caseTest('CP031', 'Alerta al superar el umbral de gasto', (tester, rec) async {
    final tx = await openForm(
      tester,
      service: RecordingTransactionService(anomalyCategory: 'Comida'),
    );
    await typeInto(tester, 0, '200');
    await pickCategory(tester, 'Comida');
    await rec.step('1. Gasto inusualmente alto en Comida');
    await save(tester);
    await rec.step('2. Se notifica el aumento inusual del gasto');
    expect(tx.created, hasLength(1));
    expect(find.textContaining('supera tu promedio'), findsOneWidget);
  });

  caseTest('CP032', 'Sin alerta dentro del rango normal', (tester, rec) async {
    final tx = await openForm(tester);
    await typeInto(tester, 0, '45');
    await pickCategory(tester, 'Comida');
    await rec.step('1. Gasto dentro del rango habitual');
    await save(tester);
    await rec.step('2. Registro normal, sin alerta');
    expect(tx.created, hasLength(1));
    expect(find.textContaining('supera tu promedio'), findsNothing);
  });

  caseTest('CP035', 'Sugerencia automática de categoría', (tester, rec) async {
    await openForm(
      tester,
      service: RecordingTransactionService(
        classifyResult: (_) => (
          category: TransactionCategory.comida,
          categoryName: 'Food',
          confidence: 0.9,
        ),
      ),
    );
    await typeInto(tester, 0, '12');
    await typeInto(tester, 1, 'Almuerzo en el comedor');
    await rec.step('1. Se escribe una descripción reconocible');
    await tapText(tester, 'Sugerir categoría con IA');
    await rec.step('2. La IA sugiere "Comida" con opción de aplicarla');
    expect(find.text('Zenda sugiere: Comida'), findsOneWidget);
    await tapText(tester, 'Aplicar sugerencia');
    await rec.step('3. El usuario acepta la sugerencia');
    expect(find.text('Comida'), findsWidgets);
  });

  caseTest('CP036', 'Descripción ambigua sin sugerencia forzada', (tester, rec) async {
    await openForm(
      tester,
      service: RecordingTransactionService(classifyResult: (_) => null),
    );
    await typeInto(tester, 0, '12');
    await typeInto(tester, 1, 'qwerty zxcv');
    await rec.step('1. Descripción ambigua');
    await tapText(tester, 'Sugerir categoría con IA');
    await rec.step('2. La IA no fuerza ninguna categoría');
    expect(find.textContaining('Zenda sugiere'), findsNothing);
    expect(find.text('Selecciona una categoría'), findsOneWidget);
    await pickCategory(tester, 'Compras');
    await rec.step('3. El usuario elige la categoría manualmente');
  });

  // ── History (list) ──────────────────────────────────────────────────────

  Future<RecordingTransactionService> openHistory(
    WidgetTester tester,
    List<Map<String, dynamic>> rows,
  ) async {
    final tx = RecordingTransactionService(rows: rows);
    await pumpScreen(
      tester,
      const TransactionsScreen(),
      overrides: [transactionApiServiceProvider.overrideWithValue(tx)],
    );
    return tx;
  }

  List<Map<String, dynamic>> sampleRows() => [
    txRow(id: 't1', amount: 40, description: 'Almuerzo'),
    txRow(id: 't2', amount: 8, category: 'Transporte', description: 'Bus'),
    txRow(id: 't3', amount: 1200, type: 'INCOME', category: 'Beca', description: 'Beca'),
  ];

  caseTest('CP005', 'Edición exitosa de transacción', (tester, rec) async {
    final tx = await openHistory(tester, sampleRows());
    await rec.step('1. Historial de transacciones');
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await settle(tester);
    await rec.step('2. Se abre la edición de la transacción');
    await tester.enterText(find.byType(TextField).first, '60');
    await rec.step('3. Se cambia el monto a S/ 60');
    await tapText(tester, 'Guardar cambios');
    await rec.step('4. Cambios guardados');
    expect(tx.updated.single.amount, 60);
  });

  caseTest('CP006', 'Monto vacío al editar', (tester, rec) async {
    final tx = await openHistory(tester, sampleRows());
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await settle(tester);
    await rec.step('1. Edición abierta');
    await tester.enterText(find.byType(TextField).first, '');
    await rec.step('2. Se borra el monto');
    await tapText(tester, 'Guardar cambios');
    await rec.step('3. Error de validación; el valor original no cambia');
    expect(find.text('Ingresa un monto mayor a 0.'), findsOneWidget);
    expect(tx.updated, isEmpty);
  });

  caseTest('CP007', 'Eliminación exitosa tras confirmar', (tester, rec) async {
    final tx = await openHistory(tester, sampleRows());
    await rec.step('1. Historial con la transacción "Almuerzo"');
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await settle(tester);
    await rec.step('2. Diálogo de confirmación');
    await tapText(tester, 'Sí, eliminar');
    await rec.step('3. La transacción desaparece del historial');
    expect(tx.deleted, ['t1']);
    expect(find.text('Almuerzo'), findsNothing);
  });

  caseTest('CP008', 'Cancelación de eliminación', (tester, rec) async {
    final tx = await openHistory(tester, sampleRows());
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await settle(tester);
    await rec.step('1. Diálogo de confirmación de eliminación');
    await tapText(tester, 'Cancelar');
    await rec.step('2. Se cancela: la transacción sigue en el historial');
    expect(tx.deleted, isEmpty);
    expect(find.text('Almuerzo'), findsOneWidget);
  });

  caseTest('CP023', 'Filtrado por fecha y tipo', (tester, rec) async {
    final tx = await openHistory(tester, sampleRows());
    await rec.step('1. Historial completo');
    await tapText(tester, 'Gastos');
    await rec.step('2. Filtro por tipo: solo gastos');
    expect(find.text('Beca'), findsNothing);
    expect(tx.queries.last['type'], 'EXPENSE');
    await tapText(tester, 'Rango de fechas');
    // The label and the empty field both read "Desde"; the field is last.
    await tester.tap(find.text('Desde').last);
    await settle(tester);
    await rec.step('3. Selector de fecha "Desde"');
    await tester.tap(find.text('1').first);
    await settle(tester, frames: 3);
    await tapText(tester, 'ACEPTAR');
    await tapText(tester, 'Aplicar');
    await rec.step('4. Rango de fechas aplicado junto al tipo');
    expect(tx.queries.last['type'], 'EXPENSE');
    expect(tx.queries.last['from'], isNotNull);
  });

  caseTest('CP024', 'Estado vacío cuando no hay resultados', (tester, rec) async {
    await openHistory(tester, sampleRows());
    await tapText(tester, 'Más filtros');
    await tester.enterText(find.byType(TextField).first, '5000');
    await rec.step('1. Filtro que no coincide con ninguna transacción');
    await tapText(tester, 'Aplicar');
    await rec.step('2. Estado vacío: no se encontraron resultados');
    expect(find.text('Aún no hay transacciones'), findsOneWidget);
  });

  caseTest('CP077', 'Filtrado por categoría', (tester, rec) async {
    final tx = await openHistory(tester, sampleRows());
    await tapText(tester, 'Más filtros');
    await tapText(tester, 'Todas las categorías');
    await tapText(tester, 'Comida');
    await rec.step('1. Se elige la categoría Comida');
    await tapText(tester, 'Aplicar');
    await rec.step('2. Solo transacciones de esa categoría');
    expect(tx.queries.last['categoryId'], isNotNull);
  });

  caseTest('CP078', 'Filtrado por rango de monto', (tester, rec) async {
    final tx = await openHistory(tester, sampleRows());
    await tapText(tester, 'Más filtros');
    await tester.enterText(find.byType(TextField).at(0), '10');
    await tester.enterText(find.byType(TextField).at(1), '100');
    await rec.step('1. Rango de monto S/ 10 – S/ 100');
    await tapText(tester, 'Aplicar');
    await rec.step('2. Solo transacciones dentro del rango');
    expect(tx.queries.last['minAmount'], 10);
    expect(tx.queries.last['maxAmount'], 100);
    expect(find.text('Almuerzo'), findsOneWidget);
    expect(find.text('Bus'), findsNothing);
  });
}
