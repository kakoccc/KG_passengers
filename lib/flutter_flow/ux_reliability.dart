import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_theme.dart';

bool kgHasUsableUrl(String? value) {
  final uri = Uri.tryParse(value?.trim() ?? '');
  return uri != null && uri.hasScheme && uri.host.isNotEmpty;
}

Widget kgImagePlaceholder(
  BuildContext context, {
  double? width,
  double? height,
  IconData icon = Icons.image_not_supported_outlined,
  double iconSize = 34.0,
}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: FlutterFlowTheme.of(context).primaryBackground,
      borderRadius: BorderRadius.circular(8.0),
    ),
    alignment: Alignment.center,
    child: Icon(
      icon,
      color: FlutterFlowTheme.of(context).secondaryBackground,
      size: iconSize,
    ),
  );
}

Widget kgNetworkImageOrPlaceholder(
  BuildContext context, {
  required String? imageUrl,
  double? width,
  double? height,
  BoxFit fit = BoxFit.contain,
  IconData placeholderIcon = Icons.image_not_supported_outlined,
  double placeholderIconSize = 34.0,
}) {
  if (!kgHasUsableUrl(imageUrl)) {
    return kgImagePlaceholder(
      context,
      width: width,
      height: height,
      icon: placeholderIcon,
      iconSize: placeholderIconSize,
    );
  }

  return Image.network(
    imageUrl!.trim(),
    width: width,
    height: height,
    fit: fit,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        return child;
      }
      return kgImagePlaceholder(
        context,
        width: width,
        height: height,
        icon: placeholderIcon,
        iconSize: placeholderIconSize,
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return kgImagePlaceholder(
        context,
        width: width,
        height: height,
        icon: placeholderIcon,
        iconSize: placeholderIconSize,
      );
    },
  );
}

String? kgLocalCarAssetFor({
  String? imageUrl,
  String? carName,
}) {
  final normalizedUrl = imageUrl?.toLowerCase().trim() ?? '';
  final normalizedName = carName?.toLowerCase().trim() ?? '';

  if (normalizedUrl.contains('caddy.png') ||
      normalizedUrl.contains('i-removebg-preview.png') ||
      normalizedName.contains('caddy') ||
      normalizedName.contains('volkswagen')) {
    return 'assets/images/i-removebg-preview.png';
  }

  if (normalizedUrl.contains('vito.png') ||
      normalizedUrl.contains('mercedes') ||
      normalizedUrl.contains('vito') ||
      normalizedUrl.contains('i__2_-removebg-preview.png') ||
      normalizedName.contains('mercedes') ||
      normalizedName.contains('vito')) {
    return 'assets/images/mercedes-vito-iii.png';
  }

  return null;
}

Widget kgTripCarImage(
  BuildContext context, {
  required String? imageUrl,
  required String? carName,
  BoxFit fit = BoxFit.contain,
  double placeholderIconSize = 34.0,
}) {
  final localAsset = kgLocalCarAssetFor(
    imageUrl: imageUrl,
    carName: carName,
  );

  Widget fallback() {
    if (localAsset == null) {
      return kgImagePlaceholder(
        context,
        icon: Icons.directions_car,
        iconSize: placeholderIconSize,
      );
    }

    return Image.asset(
      localAsset,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return kgImagePlaceholder(
          context,
          icon: Icons.directions_car,
          iconSize: placeholderIconSize,
        );
      },
    );
  }

  if (!kgHasUsableUrl(imageUrl)) {
    return fallback();
  }

  return Image.network(
    imageUrl!.trim(),
    fit: fit,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) {
        return child;
      }
      return fallback();
    },
    errorBuilder: (context, error, stackTrace) {
      return fallback();
    },
  );
}

class KgEmptyState extends StatelessWidget {
  const KgEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 48.0, 24.0, 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              size: 42.0,
            ),
            SizedBox(height: 14.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).secondary,
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 8.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class KgErrorState extends StatelessWidget {
  const KgErrorState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(24.0, 48.0, 24.0, 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: FlutterFlowTheme.of(context).error,
              size: 42.0,
            ),
            SizedBox(height: 14.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).secondary,
                    fontSize: 18.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 8.0),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Inter',
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                  ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 16.0),
              TextButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text('Повторить'),
                style: TextButton.styleFrom(
                  foregroundColor: FlutterFlowTheme.of(context).primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
