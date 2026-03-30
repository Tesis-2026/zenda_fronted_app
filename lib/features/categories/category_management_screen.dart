import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/category.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/repositories_providers.dart';

final _categoriesProvider = FutureProvider.autoDispose<List<CategoryModel>>((ref) {
  return ref.read(categoryApiServiceProvider).getAll();
});

class CategoryManagementScreen extends ConsumerWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final categoriesAsync = ref.watch(_categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catMgmtTitle)),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.catMgmtErrorLoad),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_categoriesProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (categories) => _CategoryList(categories: categories),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.catMgmtAddTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(
            hintText: l10n.catMgmtAddHint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final name = controller.text.trim();
    if (name.isEmpty) return;

    try {
      await ref.read(categoryApiServiceProvider).create(name);
      ref.invalidate(_categoriesProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.catMgmtErrorSave)),
        );
      }
    }
  }
}

class _CategoryList extends ConsumerWidget {
  final List<CategoryModel> categories;

  const _CategoryList({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final system = categories.where((c) => !c.isCustom).toList();
    final custom = categories.where((c) => c.isCustom).toList();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_categoriesProvider),
      child: ListView(
        children: [
          _SectionHeader(title: l10n.catMgmtSystemSection),
          ...system.map((c) => _SystemCategoryTile(category: c)),
          _SectionHeader(title: l10n.catMgmtCustomSection),
          if (custom.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                l10n.catMgmtEmpty,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
          ...custom.map((c) => _CustomCategoryTile(category: c)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _SystemCategoryTile extends StatelessWidget {
  final CategoryModel category;

  const _SystemCategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.label_outline),
      title: Text(category.name),
      trailing: const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
    );
  }
}

class _CustomCategoryTile extends ConsumerWidget {
  final CategoryModel category;

  const _CustomCategoryTile({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Dismissible(
      key: ValueKey(category.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.txDeleteConfirmTitle),
            content: Text(l10n.catMgmtDeleteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: Text(l10n.catMgmtDeleteAction),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        try {
          await ref.read(categoryApiServiceProvider).delete(category.id);
          ref.invalidate(_categoriesProvider);
        } catch (_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.catMgmtErrorSave)),
            );
            ref.invalidate(_categoriesProvider);
          }
        }
      },
      child: ListTile(
        leading: const Icon(Icons.label),
        title: Text(category.name),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _showRenameDialog(context, ref),
        ),
      ),
    );
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: category.name);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.catMgmtRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final name = controller.text.trim();
    if (name.isEmpty || name == category.name) return;

    try {
      await ref.read(categoryApiServiceProvider).rename(category.id, name);
      ref.invalidate(_categoriesProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.catMgmtErrorSave)),
        );
      }
    }
  }
}
