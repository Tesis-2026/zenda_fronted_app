import 'package:flutter/material.dart';
import '../../../core/models/account.dart';
import '../../../core/theme/zenda_theme_x.dart';
import '../../../l10n/l10n_extension.dart';

class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = Color(account.colorValue);

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(account.iconData, color: color, size: 20),
              ),
              const Spacer(),
              if (account.type == AccountType.credit)
                Icon(Icons.info_outline, size: 16, color: colors.textMuted),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            account.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textMuted,
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          if (account.type == AccountType.credit) ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${context.l10n.accountDebt} ${account.currency} ${account.creditDebt.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red[400],
                  fontSize: 13,
                  height: 1.05,
                ),
              ),
            ),
            Text(
              '${context.l10n.accountAvail} ${account.currency} ${account.creditAvailable.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 10,
                color: colors.textMuted,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '${account.currency} ${account.balance.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  height: 1.05,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
