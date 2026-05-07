import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/ux_reliability.dart';
import '/index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'trips_user_model.dart';
export 'trips_user_model.dart';

class TripsUserWidget extends StatefulWidget {
  const TripsUserWidget({super.key});

  static String routeName = 'tripsUser';
  static String routePath = '/tripsUser';

  @override
  State<TripsUserWidget> createState() => _TripsUserWidgetState();
}

class _TripsUserWidgetState extends State<TripsUserWidget> {
  static const String _tripCardBackgroundAsset = 'assets/images/Card.png';
  static const Duration _activeTripsQueryTimeout = Duration(seconds: 12);
  static List<TripsViewRow>? _cachedActiveTrips;

  late TripsUserModel _model;
  late Future<List<TripsViewRow>> _activeTripsFuture;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _loadActiveTrips() {
    _activeTripsFuture = _queryActiveTripsWithCacheFallback();
  }

  Future<List<TripsViewRow>> _queryActiveTrips() async {
    final rows = await TripsViewTable()
        .queryRows(
          queryFn: (q) => q.eqOrNull(
            'status',
            'active',
          ),
        )
        .timeout(_activeTripsQueryTimeout);
    _cachedActiveTrips = rows;
    return rows;
  }

  Future<List<TripsViewRow>> _queryActiveTripsWithCacheFallback() async {
    try {
      return await _queryActiveTrips();
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 350));
      try {
        return await _queryActiveTrips();
      } catch (_) {
        final cachedTrips = _cachedActiveTrips;
        if (cachedTrips != null) {
          return cachedTrips;
        }
        rethrow;
      }
    }
  }

  int _availableSeats(TripsViewRow trip) {
    final availableSeats = trip.availableSeats;
    if (availableSeats != null) {
      return availableSeats;
    }
    return trip.totalSeats ?? 0;
  }

  bool get _useAdaptiveTripCards => true;

  TextStyle _tripTextStyle(
    BuildContext context, {
    Color? color,
    double fontSize = 15.0,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return FlutterFlowTheme.of(context).bodyMedium.override(
          fontFamily: 'Inter',
          color: color ?? FlutterFlowTheme.of(context).secondary,
          fontSize: fontSize,
          letterSpacing: 0.0,
          fontWeight: fontWeight,
        );
  }

  String _tripDateTimeLabel(BuildContext context, TripsViewRow trip) {
    final date = valueOrDefault<String>(
      dateTimeFormat(
        "MMMd",
        trip.departureDate,
        locale: FFLocalizations.of(context).languageCode,
      ),
      'Дата',
    );
    final time = valueOrDefault<String>(
      dateTimeFormat(
        "Hm",
        trip.departureTimeOnly?.time,
        locale: FFLocalizations.of(context).languageCode,
      ),
      'Время',
    );
    return '$date, $time';
  }

  String _tripPriceLabel(TripsViewRow trip) {
    return formatEuroPrice(trip.ticketPrice, fallback: '100 €');
  }

  void _openTripDetails(TripsViewRow trip) {
    if (_availableSeats(trip) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'К сожалению, все места на этот рейс уже заняты!',
            style: TextStyle(
              color: FlutterFlowTheme.of(context).secondary,
              fontSize: 16.0,
            ),
          ),
          duration: Duration(milliseconds: 2000),
          backgroundColor: FlutterFlowTheme.of(context).tertiary,
        ),
      );
      return;
    }

    context.pushNamed(
      TripsdetailsWidget.routeName,
      queryParameters: {
        'tripItem': serializeParam(
          trip,
          ParamType.SupabaseRow,
        ),
      }.withoutNulls,
      extra: <String, dynamic>{
        '__transition_info__': TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 500),
        ),
      },
    );
  }

  Widget _buildTripCarImage(BuildContext context, TripsViewRow trip) {
    return kgTripCarImage(
      context,
      imageUrl: trip.carImage,
      carName: trip.carName,
      fit: BoxFit.contain,
    );
  }

  Widget _tripDetailRow(
    BuildContext context, {
    required String iconPath,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Image.asset(
          iconPath,
          width: 18.0,
          height: 18.0,
          fit: BoxFit.contain,
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: AutoSizeText(
            text,
            maxLines: 1,
            minFontSize: 11.0,
            overflow: TextOverflow.ellipsis,
            style: _tripTextStyle(
              context,
              color: FlutterFlowTheme.of(context).primaryText,
              fontSize: 13.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingButton(BuildContext context, TripsViewRow trip) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _openTripDetails(trip),
      child: Container(
        height: 52.0,
        alignment: Alignment.center,
        padding: EdgeInsetsDirectional.fromSTEB(14.0, 0.0, 14.0, 0.0),
        decoration: BoxDecoration(
          color: Color(0xFF1976D2),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: AutoSizeText(
          'Забронировать место',
          maxLines: 1,
          minFontSize: 12.0,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: _tripTextStyle(
            context,
            color: Colors.white,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingPanel(
    BuildContext context,
    TripsViewRow trip, {
    required bool compact,
  }) {
    final price = AutoSizeText(
      _tripPriceLabel(trip),
      maxLines: 1,
      minFontSize: 15.0,
      overflow: TextOverflow.ellipsis,
      style: _tripTextStyle(
        context,
        color: FlutterFlowTheme.of(context).primaryText,
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
      ),
    );

    if (compact) {
      return Container(
        width: double.infinity,
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 14.0),
        decoration: BoxDecoration(
          color: Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(34.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: price,
            ),
            SizedBox(height: 10.0),
            _buildBookingButton(context, trip),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.fromSTEB(10.0, 5.0, 5.0, 5.0),
      decoration: BoxDecoration(
        color: Color(0xFFF2F4F8),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: 78.0,
            child: price,
          ),
          SizedBox(width: 4.0),
          Expanded(
            child: _buildBookingButton(context, trip),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveTripCard(BuildContext context, TripsViewRow trip) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 40.0;
        final compact = cardWidth < 300.0;
        final cardHeight = (cardWidth / 1.28).clamp(214.0, 290.0);
        final horizontalPadding = compact ? 12.0 : 16.0;
        final topPadding = cardHeight * 0.09;
        final detailTop = cardHeight * 0.27;
        final imageWidth = (cardWidth * 0.33).clamp(82.0, 132.0);
        final imageHeight = (cardHeight * 0.34).clamp(58.0, 90.0);
        final bookingInset = (cardWidth * 0.065).clamp(18.0, 28.0);

        return SizedBox(
          width: double.infinity,
          height: cardHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Image.asset(
                  _tripCardBackgroundAsset,
                  fit: BoxFit.fill,
                ),
              ),
              PositionedDirectional(
                start: horizontalPadding + 2.0,
                end: cardWidth * 0.36,
                top: topPadding,
                child: AutoSizeText(
                  _tripDateTimeLabel(context, trip),
                  maxLines: 1,
                  minFontSize: 12.0,
                  overflow: TextOverflow.ellipsis,
                  style: _tripTextStyle(
                    context,
                    fontSize: 17.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              PositionedDirectional(
                end: (cardWidth * 0.004).clamp(1.0, 6.0),
                top: (cardHeight * 0.112) - 20.0,
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => _openTripDetails(trip),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        'Подробнее',
                        maxLines: 1,
                        minFontSize: 7.0,
                        style: _tripTextStyle(
                          context,
                          color: Color(0xFF1976D2),
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.0),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Color(0xFF1976D2),
                        size: 18.0,
                      ),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                start: horizontalPadding,
                end: horizontalPadding,
                top: detailTop,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _tripDetailRow(
                            context,
                            iconPath: 'assets/images/Ic2ons.png',
                            text: valueOrDefault<String>(
                              trip.destinationCityName,
                              'Город прибытия',
                            ),
                          ),
                          SizedBox(height: compact ? 9.0 : 11.0),
                          _tripDetailRow(
                            context,
                            iconPath: 'assets/images/Icon333s.png',
                            text: valueOrDefault<String>(
                              trip.carName,
                              'Машина',
                            ),
                          ),
                          SizedBox(height: compact ? 9.0 : 11.0),
                          _tripDetailRow(
                            context,
                            iconPath: 'assets/images/Ico5555ns.png',
                            text: 'Свободных мест: ${_availableSeats(trip)}',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.0),
                    SizedBox(
                      width: imageWidth,
                      height: imageHeight,
                      child: Align(
                        alignment: AlignmentDirectional.center,
                        child: _buildTripCarImage(context, trip),
                      ),
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                start: bookingInset,
                end: bookingInset,
                bottom: cardHeight * 0.075,
                child: _buildBookingPanel(
                  context,
                  trip,
                  compact: false,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TripsUserModel());
    _loadActiveTrips();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: double.infinity,
                  child: Stack(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    children: [
                      Align(
                        alignment: AlignmentDirectional(-1.0, 0.0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            context.safePop();
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                        ),
                      ),
                      Align(
                        alignment: AlignmentDirectional(0.0, 0.0),
                        child: Text(
                          'Поездки',
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Inter',
                                color: FlutterFlowTheme.of(context).secondary,
                                fontSize: 24.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: FutureBuilder<List<TripsViewRow>>(
                    future: _activeTripsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return KgErrorState(
                          title: 'Не удалось загрузить поездки',
                          message:
                              'Проверьте подключение и попробуйте обновить список.',
                          icon: Icons.directions_car_outlined,
                          onRetry: () {
                            safeSetState(() {
                              _loadActiveTrips();
                            });
                          },
                        );
                      }

                      if (!snapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                FlutterFlowTheme.of(context).primary,
                              ),
                            ),
                          ),
                        );
                      }
                      List<TripsViewRow> listViewTripsViewRowList =
                          snapshot.data!;

                      if (listViewTripsViewRowList.isEmpty) {
                        return KgEmptyState(
                          title: 'Поездок пока нет',
                          message:
                              'Когда появятся активные рейсы, они будут показаны здесь.',
                          icon: Icons.directions_car_outlined,
                        );
                      }

                      return ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: listViewTripsViewRowList.length,
                        separatorBuilder: (_, __) => SizedBox(height: 13.0),
                        itemBuilder: (context, listViewIndex) {
                          final listViewTripsViewRow =
                              listViewTripsViewRowList[listViewIndex];
                          return _useAdaptiveTripCards
                              ? _buildAdaptiveTripCard(
                                  context,
                                  listViewTripsViewRow,
                                )
                              : Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(minHeight: 300.0),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFCFD3E2),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Stack(
                                    alignment: AlignmentDirectional(0.0, -0.92),
                                    children: [
                                      Positioned.fill(
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Color(0xFFCFD3E2),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 5.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if (_availableSeats(
                                                        listViewTripsViewRow) <=
                                                    0) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'К сожалению, все места на этот рейс уже заняты!',
                                                        style: TextStyle(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondary,
                                                          fontSize: 24.0,
                                                        ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 2000),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .tertiary,
                                                    ),
                                                  );
                                                } else {
                                                  context.pushNamed(
                                                    TripsdetailsWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'tripItem':
                                                          serializeParam(
                                                        listViewTripsViewRow,
                                                        ParamType.SupabaseRow,
                                                      ),
                                                    }.withoutNulls,
                                                    extra: <String, dynamic>{
                                                      '__transition_info__':
                                                          TransitionInfo(
                                                        hasTransition: true,
                                                        transitionType:
                                                            PageTransitionType
                                                                .fade,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                      ),
                                                    },
                                                  );
                                                }
                                              },
                                              child: Text(
                                                'Подробнее',
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily: 'Inter',
                                                          color:
                                                              Color(0xFF1976D2),
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                            ),
                                            InkWell(
                                              splashColor: Colors.transparent,
                                              focusColor: Colors.transparent,
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () async {
                                                if (_availableSeats(
                                                        listViewTripsViewRow) <=
                                                    0) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'К сожалению, все места на этот рейс уже заняты!',
                                                        style: TextStyle(
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondary,
                                                          fontSize: 24.0,
                                                        ),
                                                      ),
                                                      duration: Duration(
                                                          milliseconds: 2000),
                                                      backgroundColor:
                                                          FlutterFlowTheme.of(
                                                                  context)
                                                              .tertiary,
                                                    ),
                                                  );
                                                } else {
                                                  context.pushNamed(
                                                    TripsdetailsWidget
                                                        .routeName,
                                                    queryParameters: {
                                                      'tripItem':
                                                          serializeParam(
                                                        listViewTripsViewRow,
                                                        ParamType.SupabaseRow,
                                                      ),
                                                    }.withoutNulls,
                                                    extra: <String, dynamic>{
                                                      '__transition_info__':
                                                          TransitionInfo(
                                                        hasTransition: true,
                                                        transitionType:
                                                            PageTransitionType
                                                                .fade,
                                                        duration: Duration(
                                                            milliseconds: 500),
                                                      ),
                                                    },
                                                  );
                                                }
                                              },
                                              child: Icon(
                                                Icons
                                                    .arrow_forward_ios_outlined,
                                                color: Color(0xFF1976D2),
                                                size: 20.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        alignment:
                                            AlignmentDirectional(-1.0, 0.0),
                                        child: Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 16.0, 0.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        0.0, 20.0, 0.0, 0.0),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    RichText(
                                                      textScaler:
                                                          MediaQuery.of(context)
                                                              .textScaler,
                                                      text: TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                valueOrDefault<
                                                                    String>(
                                                              dateTimeFormat(
                                                                "MMMd",
                                                                listViewTripsViewRow
                                                                    .departureDate,
                                                                locale: FFLocalizations.of(
                                                                        context)
                                                                    .languageCode,
                                                              ),
                                                              'Дата',
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  fontSize:
                                                                      20.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                          TextSpan(
                                                            text: ', ',
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  fontSize:
                                                                      20.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                                valueOrDefault<
                                                                    String>(
                                                              dateTimeFormat(
                                                                "Hm",
                                                                listViewTripsViewRow
                                                                    .departureTimeOnly
                                                                    ?.time,
                                                                locale: FFLocalizations.of(
                                                                        context)
                                                                    .languageCode,
                                                              ),
                                                              'Time',
                                                            ),
                                                            style: FlutterFlowTheme
                                                                    .of(context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  fontSize:
                                                                      20.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                          )
                                                        ],
                                                        style:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .override(
                                                                  font:
                                                                      GoogleFonts
                                                                          .inter(
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(0.0, 0.0,
                                                                20.0, 0.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/Ic2ons.png',
                                                                width: 20.0,
                                                                height: 20.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                listViewTripsViewRow
                                                                    .destinationCityName,
                                                                'Город прибытия',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 8.0)),
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/Icon333s.png',
                                                                width: 20.0,
                                                                height: 20.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                listViewTripsViewRow
                                                                    .carName,
                                                                'Машина',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 8.0)),
                                                        ),
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.max,
                                                          children: [
                                                            ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                              child:
                                                                  Image.asset(
                                                                'assets/images/Ico5555ns.png',
                                                                width: 20.0,
                                                                height: 20.0,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                            Text(
                                                              'Свободных мест: ',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                _availableSeats(
                                                                        listViewTripsViewRow)
                                                                    .toString(),
                                                                'Кол-во',
                                                              ),
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    letterSpacing:
                                                                        0.0,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              width: 8.0)),
                                                        ),
                                                      ].divide(SizedBox(
                                                          height: 18.0)),
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0.0),
                                                      child: kgTripCarImage(
                                                        context,
                                                        imageUrl:
                                                            listViewTripsViewRow
                                                                .carImage,
                                                        carName:
                                                            listViewTripsViewRow
                                                                .carName,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                decoration: BoxDecoration(
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryBackground,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(50.0),
                                                    topRight:
                                                        Radius.circular(50.0),
                                                    bottomLeft:
                                                        Radius.circular(50.0),
                                                    bottomRight:
                                                        Radius.circular(50.0),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .fromSTEB(
                                                          16.0, 0.0, 4.0, 0.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsetsDirectional
                                                                  .fromSTEB(
                                                                      0.0,
                                                                      20.0,
                                                                      0.0,
                                                                      20.0),
                                                          child: RichText(
                                                            textScaler:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .textScaler,
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      formatPriceValue(
                                                                    listViewTripsViewRow
                                                                        .ticketPrice,
                                                                    fallback:
                                                                        '100',
                                                                  ),
                                                                  style: FlutterFlowTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .override(
                                                                        font: GoogleFonts
                                                                            .inter(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontStyle: FlutterFlowTheme.of(context)
                                                                              .bodyMedium
                                                                              .fontStyle,
                                                                        ),
                                                                        fontSize:
                                                                            19.0,
                                                                        letterSpacing:
                                                                            0.0,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontStyle: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .fontStyle,
                                                                      ),
                                                                ),
                                                                TextSpan(
                                                                  text: ' €',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        19.0,
                                                                  ),
                                                                )
                                                              ],
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    fontSize:
                                                                        20.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                        splashColor:
                                                            Colors.transparent,
                                                        focusColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          if (_availableSeats(
                                                                  listViewTripsViewRow) <=
                                                              0) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Text(
                                                                  'К сожалению, все места на этот рейс уже заняты!',
                                                                  style:
                                                                      TextStyle(
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    fontSize:
                                                                        24.0,
                                                                  ),
                                                                ),
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        2000),
                                                                backgroundColor:
                                                                    FlutterFlowTheme.of(
                                                                            context)
                                                                        .tertiary,
                                                              ),
                                                            );
                                                          } else {
                                                            context.pushNamed(
                                                              TripsdetailsWidget
                                                                  .routeName,
                                                              queryParameters: {
                                                                'tripItem':
                                                                    serializeParam(
                                                                  listViewTripsViewRow,
                                                                  ParamType
                                                                      .SupabaseRow,
                                                                ),
                                                              }.withoutNulls,
                                                              extra: <String,
                                                                  dynamic>{
                                                                '__transition_info__':
                                                                    TransitionInfo(
                                                                  hasTransition:
                                                                      true,
                                                                  transitionType:
                                                                      PageTransitionType
                                                                          .fade,
                                                                  duration: Duration(
                                                                      milliseconds:
                                                                          500),
                                                                ),
                                                              },
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFF1976D2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      50.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      50.0),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      50.0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          50.0),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .fromSTEB(
                                                                        27.5,
                                                                        18.5,
                                                                        27.5,
                                                                        18.5),
                                                            child: Text(
                                                              'Забронировать место',
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .bodyMedium
                                                                          .fontStyle,
                                                                    ),
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16.0,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ].divide(
                                                        SizedBox(width: 10.0)),
                                                  ),
                                                ),
                                              ),
                                            ].divide(SizedBox(height: 24.0)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                        },
                      );
                    },
                  ),
                ),
              ].divide(SizedBox(height: 15.0)),
            ),
          ),
        ),
      ),
    );
  }
}
