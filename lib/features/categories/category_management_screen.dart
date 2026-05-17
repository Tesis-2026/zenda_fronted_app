import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/category.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_sheet_container.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/delete_confirm_sheet.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/green_pill_button.dart';
import '../../core/widgets/icon_action_button.dart';
import '../../core/widgets/sheet_header.dart';
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
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header row: ← Back | Categories (centered)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                  Text(
                    l10n.catMgmtTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: categoriesAsync.when(
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
                data: (categories) => _CategoryList(
                  categories: categories,
                  onAddTap: () => _showAddSheet(context, ref),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddCategorySheet(
        onSave: (name) async {
          await ref.read(categoryApiServiceProvider).create(name);
          ref.invalidate(_categoriesProvider);
        },
      ),
    );
    if (saved == true && context.mounted) {
      // already invalidated inside the sheet
    }
  }
}

class _CategoryList extends ConsumerWidget {
  final List<CategoryModel> categories;
  final VoidCallback onAddTap;

  const _CategoryList({required this.categories, required this.onAddTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final system = categories.where((c) => !c.isCustom).toList();
    final custom = categories.where((c) => c.isCustom).toList();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_categoriesProvider),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          _SectionHeader(title: l10n.catMgmtSystemSection),
          const SizedBox(height: 10),
          _SystemCategoryGrid(categories: system),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SectionHeader(title: l10n.catMgmtCustomSection),
              ),
              GreenPillButton(
                label: l10n.catMgmtAddButton,
                onTap: onAddTap,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (custom.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.catMgmtEmpty,
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9CA3AF),
      ),
    );
  }
}

IconData _systemCategoryIcon(String name) {
  return switch (name.toLowerCase()) {
    'food' || 'comida' => Icons.restaurant_rounded,
    'transportation' || 'transporte' => Icons.directions_bus_rounded,
    'housing' || 'vivienda' => Icons.home_rounded,
    'utilities' || 'servicios' => Icons.bolt_rounded,
    'health' || 'salud' => Icons.favorite_rounded,
    'entertainment' || 'entretenimiento' => Icons.sports_esports_rounded,
    'shopping' || 'compras' => Icons.shopping_cart_rounded,
    'subscriptions' || 'suscripciones' => Icons.smartphone_rounded,
    'savings' || 'ahorro' => Icons.savings_rounded,
    _ => Icons.category_rounded,
  };
}

class _SystemCategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;

  const _SystemCategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final c = categories[index];
        return AppCard(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _systemCategoryIcon(c.name),
                size: 24,
                color: const Color(0xFF374151),
              ),
              const SizedBox(height: 6),
              Text(
                c.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CustomCategoryTile extends ConsumerWidget {
  final CategoryModel category;

  const _CustomCategoryTile({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.label_rounded, size: 18, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          IconActionButton(
            icon: Icons.edit_outlined,
            onTap: () => _showEditSheet(context, ref),
            backgroundColor: const Color(0xFFF3F4F6),
            iconColor: const Color(0xFF9CA3AF),
            size: 32,
            iconSize: 16,
          ),
          const SizedBox(width: 8),
          IconActionButton(
            icon: Icons.delete_outline,
            onTap: () => _confirmDelete(context, ref),
            backgroundColor: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFEF4444),
            size: 32,
            iconSize: 16,
          ),
        ],
      ),
    );
  }

  Future<void> _showEditSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditCategorySheet(
        category: category,
        onSave: (name) async {
          await ref.read(categoryApiServiceProvider).rename(category.id, name);
          ref.invalidate(_categoriesProvider);
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDeleteConfirmSheet(
      context,
      title: context.l10n.catDeleteTitle,
      message: context.l10n.catDeleteMessage,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(categoryApiServiceProvider).delete(category.id);
      ref.invalidate(_categoriesProvider);
    } catch (_) {
      if (context.mounted) {
        showAppToast(context, context.l10n.catMgmtErrorSave, type: ToastType.error);
        ref.invalidate(_categoriesProvider);
      }
    }
  }
}

// ── Add category bottom sheet ─────────────────────────────────────────────────

class _AddCategorySheet extends StatefulWidget {
  final Future<void> Function(String name) onSave;

  const _AddCategorySheet({required this.onSave});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(name);
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) {
        showAppToast(context, context.l10n.catMgmtErrorSave, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(
            title: l10n.catMgmtAddTitle,
            onClose: () => context.pop(),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _controller,
            hintText: l10n.catMgmtAddHint,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          AppPrimaryButton(
            label: l10n.catSaveButton,
            onPressed: _saving ? null : () => _submit(),
          ),
        ],
      ),
    );
  }
}

// ── Edit category bottom sheet ────────────────────────────────────────────────

class _EditCategorySheet extends StatefulWidget {
  final CategoryModel category;
  final Future<void> Function(String name) onSave;

  const _EditCategorySheet({
    required this.category,
    required this.onSave,
  });

  @override
  State<_EditCategorySheet> createState() => _EditCategorySheetState();
}

class _EditCategorySheetState extends State<_EditCategorySheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty || name == widget.category.name) {
      context.pop();
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.onSave(name);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        showAppToast(context, context.l10n.catMgmtErrorSave, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(
            title: l10n.catMgmtRenameTitle,
            onClose: () => context.pop(),
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _controller,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          AppPrimaryButton(
            label: l10n.catSaveChanges,
            onPressed: _saving ? null : () => _submit(),
          ),
        ],
      ),
    );
  }
}
