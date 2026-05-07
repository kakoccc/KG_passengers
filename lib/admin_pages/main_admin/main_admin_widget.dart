import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'main_admin_model.dart';
export 'main_admin_model.dart';

class MainAdminWidget extends StatefulWidget {
  const MainAdminWidget({super.key});

  static String routeName = 'MainAdmin';
  static String routePath = '/mainAdmin';

  @override
  State<MainAdminWidget> createState() => _MainAdminWidgetState();
}

class _MainAdminWidgetState extends State<MainAdminWidget> {
  late MainAdminModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainAdminModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  BoxDecoration _adminCardDecoration(BuildContext context, Color color) {
    return BoxDecoration(
      color: color,
      boxShadow: [
        BoxShadow(
          blurRadius: 3.0,
          color: Color(0x33000000),
          offset: Offset(0.0, 2.0),
          spreadRadius: 1.0,
        ),
      ],
      borderRadius: BorderRadius.circular(24.0),
    );
  }

  Widget _cardSpacing(Widget child, {required bool compactHeight}) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        0.0,
        0.0,
        0.0,
        compactHeight ? 12.0 : 20.0,
      ),
      child: child,
    );
  }

  List<Widget> _buildAdminCards(
    BuildContext context, {
    required bool compactHeight,
  }) {
    final theme = FlutterFlowTheme.of(context);

    return [
      _cardSpacing(
        _responsiveAdminCard(
          context: context,
          color: theme.primaryText,
          title: 'Ближайшие поездки',
          subtitle: 'Калининград - Германия',
          imagePath: 'assets/images/pngegg.png',
          imageAspectRatio: 1.55,
          imageWidthFactor: 0.35,
          minImageWidth: 92.0,
          maxImageWidth: 142.0,
          imageScale: 1.18,
          subtitleMaxLines: 1,
          compactHeight: compactHeight,
          onTap: () {
            context.pushNamed(
              TripsAdminWidget.routeName,
              extra: <String, dynamic>{
                '__transition_info__': TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );
          },
        ),
        compactHeight: compactHeight,
      ),
      _cardSpacing(
        _responsiveAdminCard(
          context: context,
          color: theme.primary,
          title: 'Создать поездку',
          subtitle: 'Калининград - Германия',
          imagePath: 'assets/images/pngegg.png',
          imageAspectRatio: 1.55,
          imageWidthFactor: 0.35,
          minImageWidth: 92.0,
          maxImageWidth: 142.0,
          imageScale: 1.18,
          subtitleMaxLines: 1,
          compactHeight: compactHeight,
          onTap: () {
            context.pushNamed(
              AdminPoezdkaWidget.routeName,
              extra: <String, dynamic>{
                '__transition_info__': TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );
          },
        ),
        compactHeight: compactHeight,
      ),
    ];
  }

  Widget _responsiveAdminCard({
    required BuildContext context,
    required Color color,
    required String title,
    required String subtitle,
    required String imagePath,
    required double imageAspectRatio,
    double imageWidthFactor = 0.33,
    double minImageWidth = 80.0,
    double maxImageWidth = 170.0,
    double imageScale = 1.0,
    int subtitleMaxLines = 2,
    bool compactHeight = false,
    VoidCallback? onTap,
  }) {
    final card = LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 40.0;
        final compact = width < 360.0;
        final wide = width >= 560.0;
        final sidePadding = compact ? 14.0 : (wide ? 24.0 : 18.0);
        final verticalPadding = compact ? 8.0 : (wide ? 14.0 : 10.0);
        final gap = compact ? 0.0 : (wide ? 10.0 : 6.0);
        final cardHeight = (width * (wide ? 0.22 : (compactHeight ? 0.255 : 0.29)))
            .clamp(compactHeight ? 78.0 : 88.0, compactHeight ? 106.0 : 126.0)
            .toDouble();
        final titleSize = (width / 16.5).clamp(18.0, 24.0).toDouble();
        final subtitleSize = (width / 23.5).clamp(12.0, 17.0).toDouble();
        final contentHeight = cardHeight - (verticalPadding * 2);
        final imageWidth = (width * imageWidthFactor)
            .clamp(minImageWidth, maxImageWidth)
            .toDouble();
        final imageHeight =
            contentHeight.clamp(52.0, imageWidth / imageAspectRatio).toDouble();

        return Container(
          width: double.infinity,
          height: cardHeight,
          clipBehavior: Clip.antiAlias,
          decoration: _adminCardDecoration(context, color),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              sidePadding,
              verticalPadding,
              sidePadding,
              verticalPadding,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        title,
                        maxLines: 1,
                        minFontSize: 12.0,
                        stepGranularity: 0.2,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'TTNormsPro',
                              color: Colors.white,
                              fontSize: titleSize,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                              lineHeight: 1.08,
                            ),
                      ),
                      SizedBox(height: compact ? 5.0 : 7.0),
                      AutoSizeText(
                        subtitle,
                        maxLines: subtitleMaxLines,
                        minFontSize: 9.0,
                        stepGranularity: 0.2,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'TTNormsPro',
                              color: Colors.white,
                              fontSize: subtitleSize,
                              letterSpacing: 0.0,
                              lineHeight: 1.12,
                            ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: gap),
                SizedBox(
                  width: imageWidth,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: SizedBox(
                      height: imageHeight,
                      child: Transform.scale(
                        scale: imageScale,
                        alignment: Alignment.centerRight,
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(24.0),
      onTap: onTap,
      child: card,
    );
  }

  Future<void> _signOut(BuildContext context) async {
    GoRouter.of(context).prepareAuthEvent(true);
    await authManager.signOut();
    if (!context.mounted) {
      return;
    }
    GoRouter.of(context).clearRedirectLocation();

    context.goNamedAuth(
      LoginNewWidget.routeName,
      context.mounted,
      extra: <String, dynamic>{
        '__transition_info__': TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 0),
        ),
      },
      ignoreRedirect: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, viewportConstraints) {
              final compactHeight = viewportConstraints.maxHeight < 840.0;

              return SingleChildScrollView(
                primary: false,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 32.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 760.0,
                      minHeight: viewportConstraints.maxHeight > 52.0
                          ? viewportConstraints.maxHeight - 52.0
                          : 0.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ..._buildAdminCards(
                          context,
                          compactHeight: compactHeight,
                        ),
                        Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 22.0, 0.0, 0.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => _signOut(context),
                        child: Text(
                          'Выйти с аккаунта',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Inter',
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
