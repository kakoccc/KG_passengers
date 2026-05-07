import '/backend/booking_live_refresh.dart';
import '/backend/supabase/supabase.dart';
import '/components/passager_detal_admin/passager_detal_admin_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/ux_reliability.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tripsdetails_admin_model.dart';
export 'tripsdetails_admin_model.dart';

class TripsdetailsAdminWidget extends StatefulWidget {
  const TripsdetailsAdminWidget({
    super.key,
    required this.tripItem,
  });

  final TripsViewRow? tripItem;

  static String routeName = 'tripsdetailsAdmin';
  static String routePath = '/tripsdetailsAdmin';

  @override
  State<TripsdetailsAdminWidget> createState() =>
      _TripsdetailsAdminWidgetState();
}

class _TripsdetailsAdminWidgetState extends State<TripsdetailsAdminWidget> {
  late TripsdetailsAdminModel _model;
  late Future<List<BookingsRow>> _bookingsFuture;
  static const Duration _bookingsQueryTimeout = Duration(seconds: 6);
  static final Map<String, List<BookingsRow>> _cachedBookingsByTripId =
      <String, List<BookingsRow>>{};

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDeletingTrip = false;
  BookingLiveRefresh? _bookingLiveRefresh;
  bool _isRefreshingBookings = false;

  void _loadBookings() {
    final tripId = widget.tripItem?.id;
    if (tripId == null || tripId.isEmpty) {
      _bookingsFuture = Future.value(<BookingsRow>[]);
      return;
    }

    _bookingsFuture = _queryBookingsWithRetry(tripId);
  }

  Future<void> _refreshBookingsInPlace() async {
    final tripId = widget.tripItem?.id;
    if (!mounted || _isRefreshingBookings || tripId == null || tripId.isEmpty) {
      return;
    }

    _isRefreshingBookings = true;
    try {
      final refreshFuture = _queryBookingsWithRetry(tripId);
      if (!mounted) {
        return;
      }
      setState(() {
        _bookingsFuture = refreshFuture;
      });
      await refreshFuture;
    } catch (_) {
      // FutureBuilder keeps showing cached bookings if background refresh fails.
    } finally {
      _isRefreshingBookings = false;
    }
  }

  void _startBookingLiveRefresh() {
    _bookingLiveRefresh?.dispose();
    final tripId = widget.tripItem?.id;
    if (tripId == null || tripId.isEmpty) {
      _bookingLiveRefresh = null;
      return;
    }

    _bookingLiveRefresh = BookingLiveRefresh(
      channelName: 'bookings:admin_trip:$tripId',
      tripId: tripId,
      onRefresh: _refreshBookingsInPlace,
    )..start();
  }

  Future<List<BookingsRow>> _queryBookings(String tripId) async {
    final rows = await BookingsTable()
        .queryRows(
          queryFn: (q) => q
              .eq(
            'trip_id',
            tripId,
          )
              .inFilterOrNull(
            'status',
            [
              'pending',
              'confirmed',
              'cancel_requested',
            ],
          ),
        )
        .timeout(_bookingsQueryTimeout);
    _cachedBookingsByTripId[tripId] = rows;
    return rows;
  }

  Future<List<BookingsRow>> _queryBookingsWithRetry(String tripId) async {
    try {
      return await _queryBookings(tripId);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 350));
      try {
        return await _queryBookings(tripId);
      } catch (_) {
        final cachedBookings = _cachedBookingsByTripId[tripId];
        if (cachedBookings != null) {
          return cachedBookings;
        }
        rethrow;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TripsdetailsAdminModel());
    _loadBookings();
    _startBookingLiveRefresh();
  }

  @override
  void didUpdateWidget(covariant TripsdetailsAdminWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tripItem?.id != widget.tripItem?.id) {
      _loadBookings();
      _startBookingLiveRefresh();
    }
  }

  @override
  void dispose() {
    _bookingLiveRefresh?.dispose();
    _model.dispose();

    super.dispose();
  }

  int _seatCountForTrip() {
    final seats = widget.tripItem?.totalSeats ?? 0;
    if (seats <= 0) {
      return 4;
    }
    return seats;
  }

  String _carSeatsTitle() {
    final carName = widget.tripItem?.carName?.trim();
    if (carName == null || carName.isEmpty) {
      return 'Места в авто';
    }
    return carName;
  }

  int _availableSeatsForTrip() {
    final availableSeats = widget.tripItem?.availableSeats;
    if (availableSeats != null) {
      return availableSeats;
    }
    return _seatCountForTrip();
  }

  String _tripStatusLabel(String? status) {
    switch (status) {
      case 'active':
        return 'Активен';
      case 'cancelled':
        return 'Отменён';
      case 'completed':
        return 'Завершён';
      default:
        return 'Статус не указан';
    }
  }

  Color _tripStatusColor(String? status) {
    switch (status) {
      case 'active':
        return Color(0xFF4CAF50);
      case 'cancelled':
        return Color(0xFFE53935);
      case 'completed':
        return Color(0xFF6B7280);
      default:
        return Color(0xFFFF9800);
    }
  }

  String _bookingStatusLabel(String? status) {
    switch (status) {
      case 'confirmed':
        return 'Подтверждена';
      case 'cancel_requested':
        return 'Запрошена отмена';
      case 'pending':
      default:
        return 'Ожидает';
    }
  }

  Color _bookingStatusColor(String? status) {
    switch (status) {
      case 'confirmed':
        return Color(0xFF4CAF50);
      case 'cancel_requested':
        return Color(0xFFE53935);
      case 'pending':
      default:
        return Color(0xFFFF9800);
    }
  }

  Color _seatBackgroundColor(BuildContext context, String? status) {
    switch (status) {
      case 'pending':
        return Color(0xFFFFF4CC);
      case 'cancel_requested':
        return Color(0xFFFFD8DE);
      case 'confirmed':
        return Color(0xFFDDF6E7);
      default:
        return FlutterFlowTheme.of(context).tertiary.withValues(alpha: 0.24);
    }
  }

  Widget _buildStatusChip(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.0),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(12.0, 6.0, 12.0, 6.0),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              fontFamily: 'Inter',
              color: color,
              fontSize: 12.0,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  void _showAdminMessage(
    BuildContext context,
    String message, {
    Color backgroundColor = const Color(0xFFDCF5E5),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> _deleteTrip(BuildContext context) async {
    if (_isDeletingTrip) {
      return;
    }

    final tripId = widget.tripItem?.id;
    if (tripId == null || tripId.isEmpty) {
      _showAdminMessage(
        context,
        'Не удалось определить рейс для удаления.',
        backgroundColor: Color(0xFFFFDADA),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text('Удалить рейс?'),
              content: Text(
                'Рейс и все связанные заявки будут удалены из базы. Пассажиры получат уведомление об отмене рейса.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text('Удалить'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!shouldDelete) {
      return;
    }

    setState(() => _isDeletingTrip = true);
    try {
      await TripsTable().delete(
        matchingRows: (rows) => rows.eq(
          'id',
          tripId,
        ),
      );
      if (!context.mounted) {
        return;
      }
      _showAdminMessage(context, 'Рейс удалён.');
      context.goNamed('tripsAdmin');
    } on PostgrestException catch (error) {
      if (!context.mounted) {
        return;
      }
      _showAdminMessage(
        context,
        'Не удалось удалить рейс: ${error.message}',
        backgroundColor: Color(0xFFFFDADA),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showAdminMessage(
        context,
        'Не удалось удалить рейс.',
        backgroundColor: Color(0xFFFFDADA),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeletingTrip = false);
      }
    }
  }

  Future<void> _openPassengerDetails(
    BuildContext context,
    BookingsRow booking,
  ) async {
    if (booking.userId == null) {
      return;
    }
    await showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: PassagerDetalAdminWidget(
              passengerId: booking.userId!,
              bookingId: booking.id,
              bookingStatus: booking.status,
              userComment: booking.userComment,
              adminComment: booking.adminComment,
              seatNumber: booking.seatNumber,
            ),
          ),
        );
      },
    ).then((value) {
      safeSetState(() {
        _loadBookings();
      });
    });
  }

  Widget _buildAdminSeatTile(
    BuildContext context, {
    required int seatNumber,
    required BookingsRow? booking,
    required double tileSize,
  }) {
    final isOccupied = booking != null;
    final bookingStatus = booking?.status;
    final seatTextColor = isOccupied
        ? _bookingStatusColor(bookingStatus)
        : FlutterFlowTheme.of(context).secondary;
    final priceTextColor =
        isOccupied ? FlutterFlowTheme.of(context).secondary : Color(0xFF1976D2);

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        final occupiedBooking = booking;
        if (occupiedBooking == null || occupiedBooking.userId == null) {
          return;
        }
        await _openPassengerDetails(context, occupiedBooking);
      },
      child: Container(
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          color: isOccupied
              ? _seatBackgroundColor(context, bookingStatus)
              : Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              seatNumber.toString(),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: seatTextColor,
                    fontSize: 20.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
            Text(
              formatEuroPrice(widget.tripItem?.ticketPrice, fallback: 'Цена €'),
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w500,
                      fontStyle:
                          FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: priceTextColor,
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w500,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
            if (isOccupied)
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
                child: Text(
                  _bookingStatusLabel(bookingStatus),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: _bookingStatusColor(bookingStatus),
                        fontSize: 10.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ].divide(SizedBox(height: 2.0)),
        ),
      ),
    );
  }

  Widget _buildAdminDriverSeatTile(
    BuildContext context, {
    required double tileSize,
  }) {
    return Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(0.0),
            child: Image.asset(
              'assets/images/Ic12345124ons.png',
              width: tileSize * 0.34,
              height: tileSize * 0.34,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 5.0),
          Text(
            'Водитель',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Inter',
                  color: Colors.white,
                  fontSize: 10.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySeatSlot({required double tileSize}) {
    return SizedBox(
      width: tileSize,
      height: tileSize,
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
                          'Подробнее',
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 16.0, 16.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 16.0),
                                  child: Text(
                                    'Маршрут',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          fontSize: 20.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 20.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(0.0),
                                        child: Image.asset(
                                          'assets/images/Frame_60.png',
                                          width: 8.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Flexible(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
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
                                                                "d MMMM y",
                                                                widget.tripItem
                                                                    ?.departureDate,
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
                                                                            .normal,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
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
                                                                            .normal,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
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
                                                                widget
                                                                    .tripItem
                                                                    ?.departureTimeOnly
                                                                    ?.time,
                                                                locale: FFLocalizations.of(
                                                                        context)
                                                                    .languageCode,
                                                              ),
                                                              'Время',
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
                                                                            .normal,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodyMedium
                                                                        .fontStyle,
                                                                  ),
                                                                  color: FlutterFlowTheme.of(
                                                                          context)
                                                                      .secondary,
                                                                  fontSize:
                                                                      14.0,
                                                                  letterSpacing:
                                                                      0.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
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
                                                Text(
                                                  valueOrDefault<String>(
                                                    widget.tripItem
                                                        ?.originCityName,
                                                    'Город отправления',
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Text(
                                                      valueOrDefault<String>(
                                                        dateTimeFormat(
                                                          "d MMMM y, HH:mm",
                                                          widget.tripItem
                                                              ?.calculatedArrivalTime,
                                                          locale:
                                                              FFLocalizations.of(
                                                                      context)
                                                                  .languageCode,
                                                        ),
                                                        'Время прибытия',
                                                      ),
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
                                                  ],
                                                ),
                                                Text(
                                                  valueOrDefault<String>(
                                                    widget.tripItem
                                                        ?.destinationCityName,
                                                    'Город прибытия',
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts.inter(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontStyle:
                                                              FlutterFlowTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        fontSize: 20.0,
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontStyle:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ].divide(SizedBox(height: 50.0)),
                                        ),
                                      ),
                                    ].divide(SizedBox(width: 16.0)),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      20.0, 0.0, 20.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: Image.asset(
                                              'assets/images/Ic2ons.png',
                                              width: 20.0,
                                              height: 20.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          RichText(
                                            textScaler: MediaQuery.of(context)
                                                .textScaler,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: valueOrDefault<String>(
                                                    widget.tripItem?.distanceKm
                                                        ?.toString(),
                                                    'Дистанция',
                                                  ),
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                                TextSpan(
                                                  text: ' км',
                                                  style: TextStyle(),
                                                )
                                              ],
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily: 'Inter',
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondary,
                                                        letterSpacing: 0.0,
                                                      ),
                                            ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                            child: Image.asset(
                                              'assets/images/Icon11123123s.png',
                                              width: 20.0,
                                              height: 20.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Text(
                                            valueOrDefault<String>(
                                              widget.tripItem?.travelTime,
                                              'Время',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 8.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 0.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFFF5F6FA),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: [
                                        _buildStatusChip(
                                          context,
                                          label: _tripStatusLabel(
                                              widget.tripItem?.status),
                                          color: _tripStatusColor(
                                              widget.tripItem?.status),
                                        ),
                                        _buildStatusChip(
                                          context,
                                          label:
                                              'Свободно ${_availableSeatsForTrip()}/${_seatCountForTrip()}',
                                          color: _availableSeatsForTrip() > 0
                                              ? Color(0xFF1976D2)
                                              : Color(0xFFE53935),
                                        ),
                                        _buildStatusChip(
                                          context,
                                          label: 'Ожидает',
                                          color: _bookingStatusColor('pending'),
                                        ),
                                        _buildStatusChip(
                                          context,
                                          label: 'Подтверждена',
                                          color:
                                              _bookingStatusColor('confirmed'),
                                        ),
                                        _buildStatusChip(
                                          context,
                                          label: 'Запрошена отмена',
                                          color: _bookingStatusColor(
                                              'cancel_requested'),
                                        ),
                                      ],
                                    ),
                                    FFButtonWidget(
                                      onPressed: _isDeletingTrip
                                          ? null
                                          : () async {
                                              await _deleteTrip(context);
                                            },
                                      text: 'Удалить рейс',
                                      iconData: Icons.delete_outline,
                                      options: FFButtonOptions(
                                        width: double.infinity,
                                        height: 46.0,
                                        color: Color(0xFFE53935),
                                        textStyle: FlutterFlowTheme.of(context)
                                            .titleSmall
                                            .override(
                                              fontFamily: 'Inter',
                                              color: Colors.white,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                        iconColor: Colors.white,
                                        iconSize: 18.0,
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                  ].divide(SizedBox(height: 12.0)),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                16.0, 0.0, 16.0, 16.0),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width * 1.0,
                              decoration: BoxDecoration(
                                color: Color(0xFFCFD3E2),
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 16.0),
                                      child: Text(
                                        _carSeatsTitle(),
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              fontSize: 20.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                    FutureBuilder<List<BookingsRow>>(
                                      future: _bookingsFuture,
                                      initialData: widget.tripItem?.id == null
                                          ? null
                                          : _cachedBookingsByTripId[
                                              widget.tripItem!.id],
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return KgErrorState(
                                            title: 'Не удалось загрузить места',
                                            message:
                                                'Проверьте подключение и попробуйте обновить схему.',
                                            icon: Icons.event_seat_outlined,
                                            onRetry: () {
                                              safeSetState(() {
                                                _loadBookings();
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
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        final bookingsBySeat =
                                            <int, BookingsRow>{};
                                        for (final booking in snapshot.data!) {
                                          if (booking.seatNumber > 0) {
                                            bookingsBySeat[booking.seatNumber] =
                                                booking;
                                          }
                                        }

                                        final totalSeats = _seatCountForTrip();
                                        final seatNumbers = List<int>.generate(
                                          totalSeats,
                                          (index) => index + 1,
                                        );

                                        return LayoutBuilder(
                                          builder: (context, constraints) {
                                            final tileSize =
                                                (((constraints.maxWidth -
                                                                40.0) /
                                                            3.0) -
                                                        5.0)
                                                    .clamp(67.0, 81.0)
                                                    .toDouble();
                                            final gridWidth =
                                                (tileSize * 3.0) + 40.0;
                                            final seatTiles = <Widget>[
                                              _buildAdminDriverSeatTile(
                                                context,
                                                tileSize: tileSize,
                                              ),
                                              _buildEmptySeatSlot(
                                                tileSize: tileSize,
                                              ),
                                              if (seatNumbers.isNotEmpty)
                                                _buildAdminSeatTile(
                                                  context,
                                                  seatNumber: seatNumbers.first,
                                                  booking: bookingsBySeat[
                                                      seatNumbers.first],
                                                  tileSize: tileSize,
                                                ),
                                              ...seatNumbers.skip(1).map(
                                                    (seatNumber) =>
                                                        _buildAdminSeatTile(
                                                      context,
                                                      seatNumber: seatNumber,
                                                      booking: bookingsBySeat[
                                                          seatNumber],
                                                      tileSize: tileSize,
                                                    ),
                                                  ),
                                            ];

                                            return SizedBox(
                                              width: gridWidth,
                                              child: Wrap(
                                                spacing: 20.0,
                                                runSpacing: 20.0,
                                                alignment: WrapAlignment.start,
                                                crossAxisAlignment:
                                                    WrapCrossAlignment.start,
                                                children: seatTiles,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ].divide(SizedBox(height: 20.0)),
                      ),
                    ),
                  ),
                ),
              ].divide(SizedBox(height: 24.0)),
            ),
          ),
        ),
      ),
    );
  }
}
