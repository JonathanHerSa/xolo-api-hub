import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xolo/core/services/biometric_service.dart';
import 'package:xolo/core/theme/xolo_design_tokens.dart';
import 'package:xolo/l10n/app_localizations.dart';
import 'package:xolo/presentation/widgets/xolo_brand_mark.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final service = ref.read(biometricServiceProvider);
    if (await service.disableIfUnavailable()) {
      if (mounted) {
        ref.read(isAppLockedProvider.notifier).set(false);
      }
      return;
    }
    await _authenticate(auto: true);
  }

  Future<void> _authenticate({bool auto = false}) async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      if (!auto) _errorMessage = null;
    });

    final l10n = AppLocalizations.of(context)!;
    final service = ref.read(biometricServiceProvider);

    if (!await service.isAvailable) {
      await service.setBiometricEnabled(false);
      if (mounted) {
        ref.read(isAppLockedProvider.notifier).set(false);
      }
      return;
    }

    final authenticated = await service.authenticate(
      reason: l10n.unlockReason,
      biometricOnly: false,
    );

    if (!mounted) return;

    if (authenticated) {
      ref.read(isAppLockedProvider.notifier).set(false);
      return;
    }

    setState(() {
      _isAuthenticating = false;
      _errorMessage = auto ? null : l10n.biometricAuthFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(XoloSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const XoloBrandMark(size: 44, showLabel: true),
                  const SizedBox(height: XoloSpacing.xxl),
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 56,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: XoloSpacing.lg),
                  Text(
                    l10n.biometricLockedTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: XoloSpacing.sm),
                  Text(
                    l10n.biometricVaultSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: XoloSpacing.lg),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: XoloSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isAuthenticating
                          ? null
                          : () => _authenticate(),
                      icon: _isAuthenticating
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.lock_open_rounded),
                      label: Text(l10n.unlock),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
