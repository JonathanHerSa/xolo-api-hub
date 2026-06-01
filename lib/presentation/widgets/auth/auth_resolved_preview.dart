import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/services/auth_resolver_service.dart';

class AuthResolvedPreview extends ConsumerWidget {
  final String? requestAuthType;
  final String? requestAuthData;
  final int? collectionId;

  const AuthResolvedPreview({
    super.key,
    this.requestAuthType,
    this.requestAuthData,
    this.collectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authResolver = ref.watch(authResolverServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.visibility_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Resolved Authorization',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<ResolvedAuth>(
          future: authResolver.resolveAuth(
            requestAuthType: requestAuthType,
            requestAuthData: requestAuthData,
            collectionId: collectionId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 2,
                child: LinearProgressIndicator(),
              );
            }

            final resolved = snapshot.data;
            if (resolved == null || resolved.type == null) {
              return _buildInfoCard(
                context,
                'No Authentication',
                'This request will be sent without any authorization headers.',
                Icons.no_accounts_outlined,
              );
            }

            String sourceText = 'Directly set on request';
            if (resolved.source == 'folder') {
              sourceText = 'Inherited from Folder';
            } else if (resolved.source == 'project') {
              sourceText = 'Inherited from Project';
            }

            final String typeText = resolved.type!.toUpperCase();
            IconData icon = Icons.key;
            if (resolved.type == 'bearer') icon = Icons.badge_outlined;
            if (resolved.type == 'basic') icon = Icons.lock_person_outlined;

            return _buildInfoCard(
              context,
              '$typeText ($sourceText)',
              'Authentication active. Credentials will be correctly injected into the request.',
              icon,
              isHighlighted: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    bool isHighlighted = false,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
            : theme.dividerColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlighted ? theme.colorScheme.primary : null),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
