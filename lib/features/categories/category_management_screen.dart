import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/category.dart';
import '../../core/utils/category_utils.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_form_sheet.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/delete_confirm_sheet.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/green_pill_button.dart';
import '../../core/widgets/icon_action_button.dart';
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
    final l10n = context.l10n;
    final controller = TextEditingController();
    await showAppFormSheet(
      context,
      title: l10n.catMgmtAddTitle,
      primaryLabel: l10n.catSaveButton,
      body: AppTextField(
        controller: controller,
        hintText: l10n.catMgmtAddHint,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.sentences,
      ),
      onSubmit: () async {
        final name = controller.text.trim();
        if (name.isEmpty) return false;
        try {
          await ref.read(categoryApiServiceProvider).create(name);
          ref.invalidate(_categoriesProvider);
          return true;
        } catch (_) {
          if (context.mounted) {
            showAppToast(context, l10n.catMgmtErrorSave,
                type: ToastType.error);
          }
          return false;
        }
      },
    );
    controller.dispose();
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
                CategoryUtils.iconForCategory(c.name, iconKey: c.icon),
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
            child: const Icon(CategoryUtils.customCategoryIcon, size: 18, color: Color(0xFF6B7280)),
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
    final l10n = context.l10n;
    final controller = TextEditingController(text: category.name);
    await showAppFormSheet(
      context,
      title: l10n.catMgmtRenameTitle,
      primaryLabel: l10n.catSaveChanges,
      body: AppTextField(
        controller: controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.sentences,
      ),
      onSubmit: () async {
        final name = controller.text.trim();
        if (name.isEmpty || name == category.name) return true;
        try {
          await ref.read(categoryApiServiceProvider).rename(category.id, name);
          ref.invalidate(_categoriesProvider);
          return true;
        } catch (_) {
          if (context.mounted) {
            showAppToast(context, l10n.catMgmtErrorSave,
                type: ToastType.error);
          }
          return false;
        }
      },
    );
    controller.dispose();
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

