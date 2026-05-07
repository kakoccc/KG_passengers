import '/components/new_tab_item/new_tab_item_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'main_model.dart';
export 'main_model.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  static String routeName = 'Main';
  static String routePath = '/main';

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  late MainModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MainModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  bool get _useLegacyMainCards => false;

  BoxDecoration _homeCardDecoration(BuildContext context, Color color) {
    return BoxDecoration(
      color: color,
      boxShadow: [
        BoxShadow(
          blurRadius: 3.0,
          color: Color(0x33000000),
          offset: Offset(0.0, 2.0),
          spreadRadius: 1.0,
        )
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

  List<Widget> _buildMainCards(
    BuildContext context, {
    required bool compactHeight,
  }) {
    final theme = FlutterFlowTheme.of(context);

    return [
      _cardSpacing(
        _responsiveInfoCard(
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
              TripsUserWidget.routeName,
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
        _responsiveInfoCard(
          context: context,
          color: theme.primary,
          title: 'Доставка посылок',
          subtitle: 'Из Калининграда в Германию и обратно',
          imagePath: 'assets/images/post.png',
          imageAspectRatio: 1.45,
          imageWidthFactor: 0.34,
          minImageWidth: 92.0,
          maxImageWidth: 146.0,
          imageScale: 1.28,
          compactHeight: compactHeight,
        ),
        compactHeight: compactHeight,
      ),
      _cardSpacing(
        _responsiveFeatureCards(context, compactHeight: compactHeight),
        compactHeight: compactHeight,
      ),
      _cardSpacing(
        _responsiveInfoCard(
          context: context,
          color: theme.primary,
          title: 'Вопросы',
          subtitle: 'Которые требуют ответа',
          imagePath: 'assets/images/686_.png',
          imageAspectRatio: 1.08,
          imageWidthFactor: 0.24,
          minImageWidth: 64.0,
          maxImageWidth: 96.0,
          imageScale: 1.28,
          subtitleMaxLines: 1,
          compactHeight: compactHeight,
        ),
        compactHeight: compactHeight,
      ),
      _cardSpacing(
        _responsiveInfoCard(
          context: context,
          color: theme.primaryText,
          title: 'Оставьте отзыв',
          subtitle: 'О вашей поездке',
          imagePath: 'assets/images/2ce86a.png',
          imageAspectRatio: 1.28,
          imageWidthFactor: 0.34,
          minImageWidth: 92.0,
          maxImageWidth: 146.0,
          imageScale: 1.28,
          subtitleMaxLines: 1,
          compactHeight: compactHeight,
          onTap: () {
            context.pushNamed(
              ReviewsWidget.routeName,
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

  Widget _responsiveInfoCard({
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
          decoration: _homeCardDecoration(context, color),
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

  Widget _responsiveFeatureCards(
    BuildContext context, {
    required bool compactHeight,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 40.0;
        final gap = width < 380.0 ? 12.0 : 16.0;

        if (width < 320.0) {
          return Column(
            children: [
              _responsiveFeatureCard(
                context: context,
                title: 'Наш\nАвтопарк',
                imagePath: 'assets/images/mercedes-vito-iii.png',
                imageWidthFactor: 1.08,
                maxImageWidth: 270.0,
                imageScale: 1.0,
                compactHeight: compactHeight,
              ),
              SizedBox(height: gap),
              _responsiveFeatureCard(
                context: context,
                title: 'Преимущества\nПеревозчика',
                imagePath: 'assets/images/10869928.png',
                imageWidthFactor: 0.9,
                maxImageWidth: 172.0,
                imageScale: 1.04,
                compactHeight: compactHeight,
              ),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _responsiveFeatureCard(
                context: context,
                title: 'Наш\nАвтопарк',
                imagePath: 'assets/images/mercedes-vito-iii.png',
                imageWidthFactor: 1.08,
                maxImageWidth: 270.0,
                imageScale: 1.0,
                compactHeight: compactHeight,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _responsiveFeatureCard(
                context: context,
                title: 'Преимущества\nПеревозчика',
                imagePath: 'assets/images/10869928.png',
                imageWidthFactor: 0.9,
                maxImageWidth: 172.0,
                imageScale: 1.04,
                compactHeight: compactHeight,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _responsiveFeatureCard({
    required BuildContext context,
    required String title,
    required String imagePath,
    required double imageWidthFactor,
    required double maxImageWidth,
    double imageScale = 1.0,
    bool compactHeight = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 40.0;
        final height = (width * (compactHeight ? 0.9 : 1.04))
            .clamp(compactHeight ? 142.0 : 166.0, compactHeight ? 188.0 : 220.0)
            .toDouble();
        final padding = (width * 0.065).clamp(8.0, 16.0).toDouble();
        final titleSize = (width / 7.8).clamp(18.0, 24.0).toDouble();
        final imageWidth =
            (width * imageWidthFactor).clamp(92.0, maxImageWidth).toDouble();

        return Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: _homeCardDecoration(
            context,
            FlutterFlowTheme.of(context).primaryText,
          ),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              padding,
              padding,
              padding,
              padding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoSizeText(
                  title,
                  maxLines: 2,
                  minFontSize: 14.0,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'TTNormsPro',
                        color: Colors.white,
                        fontSize: titleSize,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        lineHeight: 1.08,
                      ),
                ),
                SizedBox(height: width < 360.0 ? 6.0 : 10.0),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: imageWidth,
                        maxHeight: height * 0.66,
                      ),
                      child: Transform.scale(
                        scale: imageScale,
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.contain,
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
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Stack(
          alignment: AlignmentDirectional(0.0, 1.0),
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, viewportConstraints) {
                  final compactHeight = viewportConstraints.maxHeight < 840.0;
                  return SingleChildScrollView(
                    primary: false,
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsetsDirectional.fromSTEB(
                      20.0,
                      20.0,
                      20.0,
                      105.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 760.0,
                          minHeight: viewportConstraints.maxHeight > 125.0
                              ? viewportConstraints.maxHeight - 125.0
                              : 0.0,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ..._buildMainCards(
                              context,
                              compactHeight: compactHeight,
                            ),
                            if (_useLegacyMainCards) ...[
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 25.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                context.pushNamed(
                                  TripsUserWidget.routeName,
                                  extra: <String, dynamic>{
                                    '__transition_info__': TransitionInfo(
                                      hasTransition: true,
                                      transitionType: PageTransitionType.fade,
                                      duration: Duration(milliseconds: 0),
                                    ),
                                  },
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  minHeight: 112.0,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 3.0,
                                      color: Color(0x33000000),
                                      offset: Offset(
                                        0.0,
                                        2.0,
                                      ),
                                      spreadRadius: 1.0,
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Ближайшие поездки',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'TTNormsPro',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize:
                                                      MediaQuery.sizeOf(context)
                                                                  .width <
                                                              380.0
                                                          ? 17.0
                                                          : 19.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          Text(
                                            'Калининград - Германия',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'TTNormsPro',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize:
                                                      MediaQuery.sizeOf(context)
                                                                  .width <
                                                              380.0
                                                          ? 12.0
                                                          : 14.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 6.0)),
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(0.0),
                                      child: Image.asset(
                                        'assets/images/pngegg.png',
                                        width:
                                            MediaQuery.sizeOf(context).width <
                                                    380.0
                                                ? 96.0
                                                : 128.0,
                                        height:
                                            MediaQuery.sizeOf(context).width <
                                                    380.0
                                                ? 64.0
                                                : 82.0,
                                        fit: BoxFit.contain,
                                        alignment: Alignment(-1.0, 0.0),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 25.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              constraints: BoxConstraints(
                                minHeight: 112.0,
                              ),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 3.0,
                                    color: Color(0x33000000),
                                    offset: Offset(
                                      0.0,
                                      2.0,
                                    ),
                                    spreadRadius: 1.0,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          20.0, 0.0, 0.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Доставка посылок',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'TTNormsPro',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 19.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          Text(
                                            'Из Калининграда в Германию и обратно',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'TTNormsPro',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 6.0)),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 12.0, 0.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(0.0),
                                      child: Image.asset(
                                        'assets/images/post.png',
                                        width:
                                            MediaQuery.sizeOf(context).width <
                                                    380.0
                                                ? 96.0
                                                : 128.0,
                                        height:
                                            MediaQuery.sizeOf(context).width <
                                                    380.0
                                                ? 64.0
                                                : 82.0,
                                        fit: BoxFit.contain,
                                        alignment: Alignment(-1.0, 0.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 25.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    height: 165.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 3.0,
                                          color: Color(0x33000000),
                                          offset: Offset(
                                            0.0,
                                            2.0,
                                          ),
                                          spreadRadius: 1.0,
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 10.0, 0.0, 0.0),
                                          child: Text(
                                            'Наш',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'TTNormsPro',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 19.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 10.0),
                                          child: Text(
                                            'Автопарк',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'TTNormsPro',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 19.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.asset(
                                            'assets/images/mercedes-vito-iii.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.0),
                                Flexible(
                                  child: Container(
                                    height: 165.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 3.0,
                                          color: Color(0x33000000),
                                          offset: Offset(
                                            0.0,
                                            2.0,
                                          ),
                                          spreadRadius: 1.0,
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 10.0, 0.0, 0.0),
                                          child: Text(
                                            'Приемущества',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'TTNormsPro',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 19.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 10.0),
                                          child: Text(
                                            'Перевозчика',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'TTNormsPro',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryText,
                                                  fontSize: 19.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                        Align(
                                          alignment:
                                              AlignmentDirectional(0.0, 0.0),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.asset(
                                              'assets/images/10869928.png',
                                              width: 90.0,
                                              height: 90.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 25.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              constraints: BoxConstraints(
                                minHeight: 112.0,
                              ),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primary,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 3.0,
                                    color: Color(0x33000000),
                                    offset: Offset(
                                      0.0,
                                      2.0,
                                    ),
                                    spreadRadius: 1.0,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Вопросы',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'TTNormsPro',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 19.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          'Которые требуют ответа',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'TTNormsPro',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 6.0)),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        24.0, 0.0, 0.0, 0.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24.0),
                                      child: Image.asset(
                                        'assets/images/686_.png',
                                        width:
                                            MediaQuery.sizeOf(context).width <
                                                    380.0
                                                ? 78.0
                                                : 104.0,
                                        height:
                                            MediaQuery.sizeOf(context).width <
                                                    380.0
                                                ? 54.0
                                                : 68.0,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 25.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              constraints: BoxConstraints(
                                minHeight: 112.0,
                              ),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primaryText,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 3.0,
                                    color: Color(0x33000000),
                                    offset: Offset(
                                      0.0,
                                      2.0,
                                    ),
                                    spreadRadius: 1.0,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        20.0, 0.0, 0.0, 0.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Оставьте отзыв',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'TTNormsPro',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                fontSize: 19.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Text(
                                          'О вашей поездке',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                fontFamily: 'TTNormsPro',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                              ),
                                        ),
                                      ].divide(SizedBox(height: 6.0)),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 40.0, 0.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(0.0),
                                      child: Image.asset(
                                        'assets/images/2ce86a.png',
                                        width:
                                            MediaQuery.sizeOf(context).width <
                                                    380.0
                                                ? 96.0
                                                : 128.0,
                                        height:
                                            MediaQuery.sizeOf(context).width <
                                                    380.0
                                                ? 64.0
                                                : 82.0,
                                        fit: BoxFit.contain,
                                        alignment: Alignment(-1.0, 0.0),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 10.0),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 420.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 15.0,
                          color: Color(0x0E000000),
                          offset: Offset(0.0, 10.0),
                        )
                      ],
                      borderRadius: BorderRadius.circular(100.0),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(5.0, 0.0, 5.0, 0.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          wrapWithModel(
                            model: _model.newTabItemModel1,
                            updateCallback: () => safeSetState(() {}),
                            child: NewTabItemWidget(
                              index: 0,
                              label: 'Главная',
                              icon: FaIcon(
                                FontAwesomeIcons.houseUser,
                                color: FFAppState().currentTab == 0
                                    ? Colors.white
                                    : Color(0xFFADB4C9),
                                size: 24.0,
                              ),
                              onClickAction: () async {
                                context.goNamed(
                                  MainWidget.routeName,
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
                          ),
                          wrapWithModel(
                            model: _model.newTabItemModel2,
                            updateCallback: () => safeSetState(() {}),
                            child: NewTabItemWidget(
                              index: 1,
                              label: 'Заявки ',
                              icon: FaIcon(
                                FontAwesomeIcons.car,
                                color: FFAppState().currentTab == 1
                                    ? Colors.white
                                    : Color(0xFFADB4C9),
                                size: 24.0,
                              ),
                              onClickAction: () async {
                                context.goNamed(
                                  ApplicationsWidget.routeName,
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
                          ),
                          wrapWithModel(
                            model: _model.newTabItemModel3,
                            updateCallback: () => safeSetState(() {}),
                            child: NewTabItemWidget(
                              index: 2,
                              label: 'Профиль',
                              icon: Icon(
                                Icons.person_outline,
                                color: FFAppState().currentTab == 2
                                    ? Colors.white
                                    : Color(0xFFADB4C9),
                                size: 24.0,
                              ),
                              onClickAction: () async {
                                context.goNamed(
                                  ProfilWidget.routeName,
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
                          ),
                        ].divide(SizedBox(width: 8.0)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
