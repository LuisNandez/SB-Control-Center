// lib/ui/dialogs/changelog_dialogs.dart
//
// - UpdateVersionCard: tarjeta "versión instalada → versión disponible".
// - ChangelogDialogs.showRelease: novedades de una versión (tras actualizar).
// - ChangelogDialogs.showHistory: historial de versiones (desde Ajustes).
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../services/github_update_service.dart';
import '../theme/ios_theme.dart';
import '../widgets/changelog_view.dart';
import '../widgets/ios_widgets.dart';

Future<void> _openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
}

// ---------------------------------------------------------------------------
// Tarjeta de versiones para el aviso de actualización
// ---------------------------------------------------------------------------

class UpdateVersionCard extends StatelessWidget {
  const UpdateVersionCard({
    super.key,
    required this.current,
    required this.latest,
    required this.currentLabel,
    required this.latestLabel,
    this.footer,
  });

  final String current;
  final String latest;
  final String currentLabel;
  final String latestLabel;
  final String? footer;

  Widget _column(String label, String value, Color color, FontWeight weight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 0.3,
            color: IosColors.secondaryLabel,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 22, fontWeight: weight, color: color),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0x14FFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x1FFFFFFF), width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _column(
                  currentLabel,
                  current,
                  IosColors.secondaryLabel,
                  FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: IosColors.tertiaryLabel,
              ),
              Expanded(
                child: _column(
                  latestLabel,
                  latest,
                  IosColors.blue,
                  FontWeight.w700,
                ),
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: 10),
            Text(
              footer!,
              style: const TextStyle(
                fontSize: 12,
                color: IosColors.secondaryLabel,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estructura común de los diálogos de changelog
// ---------------------------------------------------------------------------

class _ChangelogShell extends StatelessWidget {
  const _ChangelogShell({
    required this.title,
    required this.body,
    required this.actions,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<IosDialogButton> actions;

  @override
  Widget build(BuildContext context) {
    final double maxHeight =
        math.max(260.0, MediaQuery.of(context).size.height - 96);
    const Color line = Color(0x38FFFFFF);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 600, maxHeight: maxHeight),
      child: IosGlass(
        shadow: true,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                      color: IosColors.label,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: IosColors.secondaryLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(height: 0.5, color: line),
            Flexible(child: body),
            Container(height: 0.5, color: line),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    if (i > 0) Container(width: 0.5, color: line),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// API pública
// ---------------------------------------------------------------------------

class ChangelogDialogs {
  ChangelogDialogs._();

  /// Novedades de UNA versión (se usa justo después de actualizar).
  static Future<void> showRelease(
    BuildContext context, {
    required String title,
    String? subtitle,
    required String notes,
    String? url,
  }) {
    return showIosDialog<void>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return _ChangelogShell(
          title: title,
          subtitle: subtitle,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: ChangelogView(markdown: notes, emptyText: l10n.changelogEmpty),
          ),
          actions: [
            if (url != null && url.isNotEmpty)
              IosDialogButton(
                label: l10n.changelogViewOnGithub,
                onPressed: () => _openUrl(url),
              ),
            IosDialogButton(
              label: l10n.dialogActionClose,
              bold: true,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Historial de todas las versiones publicadas (se usa desde Ajustes).
  static Future<void> showHistory(
    BuildContext context, {
    required String currentVersion,
  }) {
    return showIosDialog<void>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return _ChangelogShell(
          title: l10n.changelogHistoryTitle,
          subtitle: currentVersion.isEmpty
              ? null
              : l10n.changelogInstalledVersion(currentVersion),
          body: _HistoryBody(currentVersion: currentVersion),
          actions: [
            IosDialogButton(
              label: l10n.changelogViewOnGithub,
              onPressed: () => _openUrl(
                'https://github.com/${GithubUpdateService.owner}/${GithubUpdateService.repo}/releases',
              ),
            ),
            IosDialogButton(
              label: l10n.dialogActionClose,
              bold: true,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Cuerpo del historial
// ---------------------------------------------------------------------------

class _HistoryBody extends StatefulWidget {
  const _HistoryBody({required this.currentVersion});
  final String currentVersion;

  @override
  State<_HistoryBody> createState() => _HistoryBodyState();
}

class _HistoryBodyState extends State<_HistoryBody> {
  List<ReleaseNotes> _releases = const <ReleaseNotes>[];
  bool _loading = true;
  bool _failed = false;
  final Set<String> _expanded = <String>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool retry = false}) async {
    if (retry) {
      setState(() {
        _loading = true;
        _failed = false;
      });
    }
    try {
      final list = await GithubUpdateService.fetchReleases();
      if (!mounted) return;
      ReleaseNotes? open;
      for (final r in list) {
        if (r.version == widget.currentVersion) {
          open = r;
          break;
        }
      }
      open ??= list.isNotEmpty ? list.first : null;
      setState(() {
        _releases = list;
        _loading = false;
        _expanded.clear();
        if (open != null) _expanded.add(open.tag);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Widget _badge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(46),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _section(ReleaseNotes r, AppLocalizations l10n) {
    final bool open = _expanded.contains(r.tag);
    final bool installed = r.version == widget.currentVersion;
    final String date =
        r.publishedAt == null
            ? ''
            : MaterialLocalizations.of(context).formatShortDate(r.publishedAt!);
    final bool showName = r.name.trim().isNotEmpty && !r.name.contains(r.version);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {
              if (open) {
                _expanded.remove(r.tag);
              } else {
                _expanded.add(r.tag);
              }
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: open ? 0.25 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: IosColors.secondaryLabel,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'v${r.version}${showName ? '  ·  ${r.name}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: IosColors.label,
                      ),
                    ),
                  ),
                  if (installed) _badge(l10n.changelogInstalledBadge, IosColors.blue),
                  if (r.prerelease)
                    _badge(l10n.changelogPrereleaseBadge, IosColors.orange),
                  const Spacer(),
                  if (date.isNotEmpty)
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: IosColors.secondaryLabel,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: ChangelogView(
              markdown: r.notes,
              emptyText: l10n.changelogEmpty,
            ),
          ),
        Container(height: 0.5, color: const Color(0x24FFFFFF)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_failed) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.changelogLoadFailed,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: IosColors.secondaryLabel,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _load(retry: true),
              child: Text(l10n.changelogRetry),
            ),
          ],
        ),
      );
    }

    if (_releases.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.changelogEmpty,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: IosColors.secondaryLabel),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [for (final r in _releases) _section(r, l10n)],
      ),
    );
  }
}
