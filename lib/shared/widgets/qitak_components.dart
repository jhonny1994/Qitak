import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:qitak_app/core/theme/app_theme.dart';

const EdgeInsets qitakPagePadding = EdgeInsets.all(24);
const EdgeInsets qitakPageHorizontalPadding = EdgeInsets.symmetric(
  horizontal: 24,
);

String qitakListingHeroTag(String listingId) =>
    'qitak-listing-media-$listingId';

class QitakPanel extends StatelessWidget {
  const QitakPanel({
    required this.child,
    super.key,
    this.padding,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.qitakTokens;
    final colorScheme = Theme.of(context).colorScheme;
    final decoration = BoxDecoration(
      color: backgroundColor ?? tokens.panel,
      borderRadius: BorderRadius.circular(tokens.panelRadius),
      border: Border.all(color: borderColor ?? tokens.stroke),
      boxShadow: [
        BoxShadow(
          color: tokens.glow,
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.alphaBlend(
            colorScheme.onSurface.withValues(alpha: 0.02),
            backgroundColor ?? tokens.panel,
          ),
          backgroundColor ?? tokens.panel,
        ],
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: decoration,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class QitakSectionHeader extends StatelessWidget {
  const QitakSectionHeader({
    required this.eyebrow,
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          SizedBox(width: tokens.screenPadding),
          trailing!,
        ],
      ],
    );
  }
}

class QitakChip extends StatelessWidget {
  const QitakChip({
    required this.label,
    super.key,
    this.leading,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final Widget? leading;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;
    final fill = selected
        ? Color.alphaBlend(
            theme.colorScheme.primary.withValues(alpha: 0.14),
            tokens.panel,
          )
        : tokens.panelMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.chipRadius),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(tokens.chipRadius),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withValues(alpha: 0.72)
                  : tokens.stroke,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leading != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  child: leading!,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QitakSignalStrip extends StatelessWidget {
  const QitakSignalStrip({
    required this.label,
    required this.value,
    super.key,
    this.status,
  });

  final String label;
  final String value;
  final String? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.panelMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.stroke),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: 12),
              Flexible(
                child: Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(tokens.chipRadius),
                      border: Border.all(color: theme.colorScheme.primary),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(
                        status!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class QitakPullToRefresh extends StatelessWidget {
  const QitakPullToRefresh({
    required this.onRefresh,
    this.slivers,
    this.child,
    super.key,
  }) : assert(
         (slivers != null) != (child != null),
         'Provide either slivers or child to QitakPullToRefresh.',
       );

  final RefreshCallback onRefresh;
  final List<Widget>? slivers;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      color: theme.colorScheme.primary,
      backgroundColor: context.qitakTokens.panel,
      onRefresh: onRefresh,
      child: QitakPageCanvas(
        child:
            child ??
            CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: slivers!,
            ),
      ),
    );
  }
}

class QitakPageCanvas extends StatelessWidget {
  const QitakPageCanvas({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.scaffoldBackgroundColor,
            Color.alphaBlend(
              theme.colorScheme.primary.withValues(alpha: 0.035),
              tokens.panelMuted,
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}

class QitakCollapsingSliverAppBar extends StatelessWidget {
  const QitakCollapsingSliverAppBar({
    required this.eyebrow,
    required this.title,
    super.key,
    this.subtitle,
    this.actions = const <Widget>[],
    this.expandedHeight = 188,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      toolbarHeight: 72,
      expandedHeight: expandedHeight,
      backgroundColor: Color.alphaBlend(
        theme.colorScheme.surface.withValues(alpha: 0.92),
        theme.scaffoldBackgroundColor,
      ),
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      titleSpacing: 0,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: tokens.stroke),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.alphaBlend(
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                  theme.scaffoldBackgroundColor,
                ),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QitakListingSurface extends StatelessWidget {
  const QitakListingSurface({
    required this.title,
    required this.price,
    required this.subtitle,
    super.key,
    this.imageUrl,
    this.mediaFallback,
    this.heroTag,
    this.ratingLabel,
    this.actions = const <Widget>[],
    this.badges = const <Widget>[],
  });

  final String title;
  final String price;
  final String subtitle;
  final String? imageUrl;
  final Widget? mediaFallback;
  final String? heroTag;
  final String? ratingLabel;
  final List<Widget> actions;
  final List<Widget> badges;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;

    return QitakPanel(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMedia(context, tokens),

          // ── Content section ───────────────────────────────
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            price,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (ratingLabel != null)
                      QitakChip(
                        label: ratingLabel!,
                        selected: true,
                        leading: const Icon(Icons.star_rounded),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(spacing: 8, runSpacing: 8, children: badges),
                ],
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: tokens.panelMuted,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: tokens.stroke),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Wrap(spacing: 8, runSpacing: 8, children: actions),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedia(BuildContext context, QitakThemeTokens tokens) {
    final media = ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(tokens.panelRadius),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? _QitakListingImage(
              imageUrl: imageUrl!,
              height: 200,
            )
          : mediaFallback ?? const _QitakImageFallback(height: 180),
    );

    if (heroTag == null) {
      return media;
    }

    return Hero(
      tag: heroTag!,
      child: media,
    );
  }
}

class QitakListingGallery extends StatefulWidget {
  const QitakListingGallery({
    super.key,
    this.imageUrls = const <String>[],
    this.primaryImageUrl,
    this.heroTag,
    this.height = 280,
  });

  final List<String> imageUrls;
  final String? primaryImageUrl;
  final String? heroTag;
  final double height;

  @override
  State<QitakListingGallery> createState() => _QitakListingGalleryState();
}

class _QitakListingGalleryState extends State<QitakListingGallery> {
  late final PageController _pageController;
  int _currentPage = 0;

  List<String> get _resolvedImages {
    final images = <String>[
      if (widget.primaryImageUrl != null && widget.primaryImageUrl!.isNotEmpty)
        widget.primaryImageUrl!,
      ...widget.imageUrls.where((url) => url.isNotEmpty),
    ];
    return images.toSet().toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;
    final images = _resolvedImages;

    if (images.isEmpty) {
      final fallback = ClipRRect(
        borderRadius: BorderRadius.circular(tokens.panelRadius),
        child: _QitakImageFallback(height: widget.height),
      );

      if (widget.heroTag == null) {
        return fallback;
      }

      return Hero(tag: widget.heroTag!, child: fallback);
    }

    final gallery = ClipRRect(
      borderRadius: BorderRadius.circular(tokens.panelRadius),
      child: SizedBox(
        height: widget.height,
        child: PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (value) => setState(() => _currentPage = value),
          itemBuilder: (context, index) {
            return _QitakNetworkImage(
              imageUrl: images[index],
              height: widget.height,
            );
          },
        ),
      ),
    );

    final media = widget.heroTag != null
        ? Hero(tag: widget.heroTag!, child: gallery)
        : gallery;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        media,
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.panelMuted,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tokens.stroke),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        for (var index = 0; index < images.length; index++) ...[
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              height: 4,
                              margin: EdgeInsetsDirectional.only(
                                end: index == images.length - 1 ? 0 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: index == _currentPage
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentPage + 1}/${images.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Branded fallback shown when no listing image is available.
class _QitakImageFallback extends StatelessWidget {
  const _QitakImageFallback({required this.height, this.isLoading = false});

  final double height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final tokens = context.qitakTokens;
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return QitakSkeletonBox(height: height, radius: 0);
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.panelMuted,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tokens.panelMuted,
            Color.alphaBlend(
              colorScheme.primary.withValues(alpha: 0.08),
              tokens.panelMuted,
            ),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 48,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _QitakNetworkImage extends StatelessWidget {
  const _QitakNetworkImage({
    required this.imageUrl,
    required this.height,
  });

  final String imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    return _QitakListingImage(imageUrl: imageUrl, height: height);
  }
}

class QitakListingThumbnail extends StatelessWidget {
  const QitakListingThumbnail({
    required this.imageUrl,
    super.key,
    this.width = 72,
    this.height = 72,
    this.borderRadius = 18,
  });

  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: url == null || url.isEmpty
            ? _QitakImageFallback(height: height)
            : _QitakListingImage(
                imageUrl: url,
                height: height,
              ),
      ),
    );
  }
}

class _QitakListingImage extends StatelessWidget {
  const _QitakListingImage({
    required this.imageUrl,
    required this.height,
  });

  final String imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (_usesTestWidgetsBinding) {
      return _QitakImageFallback(height: height);
    }

    if (imageUrl.startsWith('data:image/')) {
      final bytes = _decodeDataUri(imageUrl);
      if (bytes == null) {
        return _QitakImageFallback(height: height);
      }
      return SizedBox(
        height: height,
        width: double.infinity,
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _QitakImageFallback(height: height),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholderFadeInDuration: Duration.zero,
        placeholder: (context, url) =>
            _QitakImageFallback(height: height, isLoading: true),
        errorWidget: (context, url, error) =>
            _QitakImageFallback(height: height),
      ),
    );
  }

  Uint8List? _decodeDataUri(String value) {
    final commaIndex = value.indexOf(',');
    if (commaIndex == -1 || commaIndex == value.length - 1) {
      return null;
    }

    try {
      return base64Decode(value.substring(commaIndex + 1));
    } on FormatException {
      return null;
    }
  }

  bool get _usesTestWidgetsBinding =>
      WidgetsBinding.instance.runtimeType.toString().contains(
        'TestWidgetsFlutterBinding',
      );
}

class QitakTimelineBlock extends StatelessWidget {
  const QitakTimelineBlock({
    required this.title,
    required this.subtitle,
    super.key,
    this.isCurrent = false,
  });

  final String title;
  final String subtitle;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isCurrent
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: color.withValues(alpha: 0.35),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class QitakQueueRow extends StatelessWidget {
  const QitakQueueRow({
    required this.title,
    required this.meta,
    required this.status,
    super.key,
    this.trailing,
    this.variant = QitakQueueRowVariant.status,
  });

  final String title;
  final String meta;
  final String status;
  final Widget? trailing;
  final QitakQueueRowVariant variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: tokens.stroke),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            switch (variant) {
              QitakQueueRowVariant.status => _QitakStatusBadge(label: status),
              QitakQueueRowVariant.value => _QitakValueToken(label: status),
            },
            if (trailing != null) ...[
              const SizedBox(width: 12),
              IconTheme(
                data: IconThemeData(
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                child: trailing!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum QitakQueueRowVariant {
  status,
  value,
}

class _QitakStatusBadge extends StatelessWidget {
  const _QitakStatusBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;
    final fill = Color.alphaBlend(
      theme.colorScheme.primary.withValues(alpha: 0.14),
      tokens.panel,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(tokens.chipRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _QitakValueToken extends StatelessWidget {
  const _QitakValueToken({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;
    final fill = Color.alphaBlend(
      theme.colorScheme.primary.withValues(alpha: 0.06),
      tokens.panel,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(tokens.chipRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Animated shimmer skeleton box for loading states.
///
/// Uses a repeating gradient animation to create a subtle
/// pulsing shimmer effect that signals content is loading.
class QitakSkeletonBox extends StatefulWidget {
  const QitakSkeletonBox({
    required this.height,
    super.key,
    this.width,
    this.radius = 16,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  State<QitakSkeletonBox> createState() => _QitakSkeletonBoxState();
}

class _QitakSkeletonBoxState extends State<QitakSkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    unawaited(_controller.repeat());
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.qitakTokens;
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = tokens.panelMuted;
    final highlightColor = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.08),
      baseColor,
    );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _animation.value, 0),
              end: Alignment(1.0 + 2.0 * _animation.value, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class QitakStateMessage extends StatelessWidget {
  const QitakStateMessage({
    required this.title,
    required this.message,
    super.key,
    this.icon = Icons.info_outline_rounded,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: QitakPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class QitakConfirmationModal extends StatelessWidget {
  const QitakConfirmationModal({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    super.key,
    this.isDestructive = false,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.qitakTokens;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.panelRadius),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.all(24),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Text(
        body,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.45,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.onSurface,
          ),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

class QitakFormGroup extends StatelessWidget {
  const QitakFormGroup({
    required this.label,
    required this.child,
    super.key,
    this.helper,
    this.error,
    this.required = false,
    this.isValidating = false,
  });

  final String label;
  final Widget child;
  final String? helper;
  final String? error;
  final bool required;
  final bool isValidating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 6),
              if (isValidating)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.error,
                    ),
                  ),
                )
              else
                Text(
                  '*',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        child,
        if (helper != null || error != null) ...[
          const SizedBox(height: 6),
          Text(
            error ?? helper!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: error != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class QitakDropdownField<T> extends StatelessWidget {
  const QitakDropdownField({
    required this.items,
    super.key,
    this.value,
    this.onChanged,
    this.validator,
    this.errorText,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tokens = context.qitakTokens;

    return FormField<T>(
      initialValue: items.any((item) => item.value == value) ? value : null,
      validator: validator,
      builder: (state) {
        final currentValue = items.any((item) => item.value == state.value)
            ? state.value
            : null;
        final resolvedError = state.errorText ?? errorText;
        final hasError = resolvedError != null;
        final errorBorder = OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.fieldRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        );

        return InputDecorator(
          decoration: InputDecoration(
            errorText: resolvedError,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: hasError
                ? colorScheme.errorContainer.withValues(alpha: 0.08)
                : null,
            enabledBorder: hasError ? errorBorder : null,
            focusedBorder: hasError
                ? errorBorder.copyWith(
                    borderSide: BorderSide(
                      color: colorScheme.error,
                      width: 2,
                    ),
                  )
                : null,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder.copyWith(
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 2,
              ),
            ),
            errorStyle: TextStyle(color: colorScheme.error),
          ),
          isEmpty: currentValue == null,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: currentValue,
              isExpanded: true,
              isDense: true,
              borderRadius: BorderRadius.circular(20),
              items: items,
              onChanged: onChanged == null
                  ? null
                  : (next) {
                      state.didChange(next);
                      onChanged?.call(next);
                    },
            ),
          ),
        );
      },
    );
  }
}

class QitakDetailRow extends StatelessWidget {
  const QitakDetailRow({
    required this.label,
    required this.value,
    super.key,
    this.trailing,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: crossAxisAlignment,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
