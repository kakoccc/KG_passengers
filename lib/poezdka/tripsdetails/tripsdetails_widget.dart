import '/auth/supabase_auth/auth_util.dart';
import '/backend/booking_live_refresh.dart';
import '/backend/supabase/supabase.dart';
import '/components/success_booking_dialog/success_booking_dialog_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/ux_reliability.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tripsdetails_model.dart';
export 'tripsdetails_model.dart';

class TripsdetailsWidget extends StatefulWidget {
  const TripsdetailsWidget({
    super.key,
    required this.tripItem,
  });

  final TripsViewRow? tripItem;

  static String routeName = 'tripsdetails';
  static String routePath = '/tripsdetails';

  @override
  State<TripsdetailsWidget> createState() => _TripsdetailsWidgetState();
}

class _TripsdetailsWidgetState extends State<TripsdetailsWidget> {
  late TripsdetailsModel _model;
  late Future<List<BookingsRow>> _bookingsFuture;
  BookingsRow? _currentUserActiveBooking;
  bool _bookingsLoaded = false;
  BookingLiveRefresh? _bookingLiveRefresh;
  bool _isRefreshingBookings = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _loadBookings() {
    final tripId = widget.tripItem?.id;
    _bookingsLoaded = false;
    _currentUserActiveBooking = null;
    if (tripId == null || tripId.isEmpty) {
      _bookingsFuture = Future.value(<BookingsRow>[]);
      _bookingsLoaded = true;
      return;
    }

    _bookingsFuture = BookingsTable().queryRows(
      queryFn: (q) => q
          .eqOrNull(
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
    );
    _bookingsFuture.then((bookings) {
      if (!mounted || widget.tripItem?.id != tripId) {
        return;
      }
      safeSetState(() {
        _currentUserActiveBooking = _currentUserBooking(bookings);
        if (_currentUserActiveBooking != null) {
          _model.selectedSeat = null;
        }
        _bookingsLoaded = true;
      });
    }).catchError((_) {
      if (!mounted || widget.tripItem?.id != tripId) {
        return;
      }
      safeSetState(() {
        _bookingsLoaded = false;
      });
    });
  }

  Future<void> _refreshBookingsInPlace() async {
    final tripId = widget.tripItem?.id;
    if (!mounted || _isRefreshingBookings || tripId == null || tripId.isEmpty) {
      return;
    }

    _isRefreshingBookings = true;
    _bookingsLoaded = false;
    try {
      final refreshFuture = BookingsTable().queryRows(
        queryFn: (q) => q
            .eqOrNull(
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
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _bookingsFuture = refreshFuture;
      });

      final bookings = await refreshFuture;
      if (!mounted || widget.tripItem?.id != tripId) {
        return;
      }
      safeSetState(() {
        _currentUserActiveBooking = _currentUserBooking(bookings);
        if (_currentUserActiveBooking != null) {
          _model.selectedSeat = null;
        }
        _bookingsLoaded = true;
      });
    } catch (_) {
      if (!mounted || widget.tripItem?.id != tripId) {
        return;
      }
      safeSetState(() {
        _bookingsLoaded = true;
      });
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
      channelName: 'bookings:trip:$tripId',
      tripId: tripId,
      onRefresh: _refreshBookingsInPlace,
    )..start();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TripsdetailsModel());
    _loadBookings();
    _startBookingLiveRefresh();

    _model.userCommentTextController ??= TextEditingController();
    _model.userCommentFocusNode ??= FocusNode();
  }

  @override
  void didUpdateWidget(covariant TripsdetailsWidget oldWidget) {
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

  void _showSeatBusySnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Это место уже занято!',
          style: TextStyle(
            color: FlutterFlowTheme.of(context).primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 24.0,
          ),
        ),
        duration: Duration(milliseconds: 2000),
        backgroundColor: Color(0xFFE53935),
      ),
    );
  }

  String _ownSeatSnackText(String? status) {
    switch (status) {
      case 'confirmed':
        return 'Это ваше место';
      case 'cancel_requested':
        return 'По этому месту запрошена отмена';
      case 'pending':
      default:
        return 'Это место занято вами. Оно в обработке';
    }
  }

  void _showOwnSeatSnack(BuildContext context, String? status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _ownSeatSnackText(status),
          style: TextStyle(
            color: FlutterFlowTheme.of(context).primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 24.0,
          ),
        ),
        duration: Duration(milliseconds: 2000),
        backgroundColor: Color(0xFFFFD54F),
      ),
    );
  }

  BookingsRow? _currentUserBooking(List<BookingsRow> bookings) {
    if (currentUserUid.isEmpty) {
      return null;
    }

    for (final booking in bookings) {
      if (booking.userId == currentUserUid) {
        return booking;
      }
    }

    return null;
  }

  String _currentBookingNoticeText(BookingsRow booking) {
    switch (booking.status) {
      case 'confirmed':
        return 'Это ваша бронь. У вас уже есть занятое место ${booking.seatNumber}.';
      case 'cancel_requested':
        return 'Ваша бронь. По месту ${booking.seatNumber} запрошена отмена. Мы свяжемся с вами.';
      case 'pending':
      default:
        return 'Ваша бронь. У вас уже есть заявка на место ${booking.seatNumber}. Оно в обработке, ждите подтверждения.';
    }
  }

  Color _ownSeatBackgroundColor(BuildContext context, String? status) {
    switch (status) {
      case 'confirmed':
        return FlutterFlowTheme.of(context).primary;
      case 'cancel_requested':
        return Color(0xFFFFD8DE);
      case 'pending':
      default:
        return Color(0xFFFFF4CC);
    }
  }

  Color _ownSeatContentColor(BuildContext context, String? status) {
    switch (status) {
      case 'confirmed':
        return Colors.white;
      case 'cancel_requested':
        return FlutterFlowTheme.of(context).tertiary;
      case 'pending':
      default:
        return FlutterFlowTheme.of(context).secondary;
    }
  }

  Color _ownSeatPriceColor(BuildContext context, String? status) {
    switch (status) {
      case 'confirmed':
        return Colors.white;
      case 'cancel_requested':
        return FlutterFlowTheme.of(context).tertiary;
      case 'pending':
      default:
        return FlutterFlowTheme.of(context).alternate;
    }
  }

  Widget _buildCurrentBookingNotice(
    BuildContext context,
    BookingsRow booking,
  ) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Color(0xFFFFD54F),
            width: 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            _currentBookingNoticeText(booking),
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontStyle:
                        FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: FlutterFlowTheme.of(context).secondary,
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerSeatTile(
    BuildContext context, {
    required int seatNumber,
    required bool occupied,
    required bool ownedByCurrentUser,
    String? bookingStatus,
    required bool bookingLocked,
    required double tileSize,
  }) {
    final isSelected = !bookingLocked && _model.selectedSeat == seatNumber;
    final seatTextColor = ownedByCurrentUser
        ? _ownSeatContentColor(context, bookingStatus)
        : occupied
            ? FlutterFlowTheme.of(context).secondary
            : (isSelected
                ? Colors.white
                : FlutterFlowTheme.of(context).secondary);
    final priceTextColor = ownedByCurrentUser
        ? _ownSeatPriceColor(context, bookingStatus)
        : occupied
            ? FlutterFlowTheme.of(context).secondary
            : (isSelected ? Colors.white : Color(0xFF1976D2));
    final seatBackgroundColor = ownedByCurrentUser
        ? _ownSeatBackgroundColor(context, bookingStatus)
        : occupied
            ? FlutterFlowTheme.of(context).tertiary
            : (isSelected ? Color(0xFF1976D2) : Colors.white);

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () async {
        if (ownedByCurrentUser) {
          _showOwnSeatSnack(context, bookingStatus);
          return;
        }
        if (occupied) {
          _showSeatBusySnack(context);
          return;
        }
        if (bookingLocked) {
          return;
        }
        _model.selectedSeat = seatNumber;
        safeSetState(() {});
      },
      child: Container(
        width: tileSize,
        height: tileSize,
        decoration: BoxDecoration(
          color: seatBackgroundColor,
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
          ].divide(SizedBox(height: 2.0)),
        ),
      ),
    );
  }

  Widget _buildDriverSeatTile(BuildContext context,
      {required double tileSize}) {
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

                                        final currentUserBooking =
                                            _currentUserBooking(snapshot.data!);
                                        final currentUserSeat =
                                            currentUserBooking?.seatNumber;
                                        final occupiedSeats = snapshot.data!
                                            .where(
                                              (booking) =>
                                                  booking.seatNumber > 0,
                                            )
                                            .map(
                                                (booking) => booking.seatNumber)
                                            .toSet();
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
                                              _buildDriverSeatTile(
                                                context,
                                                tileSize: tileSize,
                                              ),
                                              _buildEmptySeatSlot(
                                                tileSize: tileSize,
                                              ),
                                              if (seatNumbers.isNotEmpty)
                                                _buildPassengerSeatTile(
                                                  context,
                                                  seatNumber: seatNumbers.first,
                                                  occupied:
                                                      occupiedSeats.contains(
                                                          seatNumbers.first),
                                                  ownedByCurrentUser:
                                                      currentUserSeat ==
                                                          seatNumbers.first,
                                                  bookingStatus: bookingsBySeat[
                                                          seatNumbers.first]
                                                      ?.status,
                                                  bookingLocked:
                                                      currentUserBooking !=
                                                          null,
                                                  tileSize: tileSize,
                                                ),
                                              ...seatNumbers.skip(1).map(
                                                    (seatNumber) =>
                                                        _buildPassengerSeatTile(
                                                      context,
                                                      seatNumber: seatNumber,
                                                      occupied: occupiedSeats
                                                          .contains(seatNumber),
                                                      ownedByCurrentUser:
                                                          currentUserSeat ==
                                                              seatNumber,
                                                      bookingStatus:
                                                          bookingsBySeat[
                                                                  seatNumber]
                                                              ?.status,
                                                      bookingLocked:
                                                          currentUserBooking !=
                                                              null,
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
                          if (_bookingsLoaded &&
                              _currentUserActiveBooking != null)
                            _buildCurrentBookingNotice(
                              context,
                              _currentUserActiveBooking!,
                            ),
                          if (_bookingsLoaded &&
                              _currentUserActiveBooking == null)
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Theme(
                                    data: ThemeData(
                                      checkboxTheme: CheckboxThemeData(
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      unselectedWidgetColor:
                                          FlutterFlowTheme.of(context)
                                              .primaryBackground,
                                    ),
                                    child: Checkbox(
                                      value: _model.checkboxValue ??= false,
                                      onChanged: (newValue) async {
                                        safeSetState(() =>
                                            _model.checkboxValue = newValue!);
                                      },
                                      side: BorderSide(
                                        width: 2,
                                        color: FlutterFlowTheme.of(context)
                                            .primaryBackground,
                                      ),
                                      activeColor:
                                          FlutterFlowTheme.of(context).primary,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 1.5),
                                    child: Text(
                                      'Багаж',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: FlutterFlowTheme.of(context)
                                                .secondary,
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ].divide(SizedBox(width: 8.0)),
                              ),
                            ),
                          if (_bookingsLoaded &&
                              _currentUserActiveBooking == null)
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Примечания для диспетчера',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    child: TextFormField(
                                      controller:
                                          _model.userCommentTextController,
                                      focusNode: _model.userCommentFocusNode,
                                      autofocus: false,
                                      enabled: true,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        labelStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                        hintText:
                                            'Доп. информация для диспетчера...',
                                        hintStyle: FlutterFlowTheme.of(context)
                                            .labelMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .labelMedium
                                                        .fontStyle,
                                              ),
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryBackground,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0xFFF0F1F5),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Color(0x00000000),
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: FlutterFlowTheme.of(context)
                                                .error,
                                            width: 1.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.all(16.0),
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                      maxLines: 4,
                                      minLines: 1,
                                      cursorColor: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      enableInteractiveSelection: true,
                                      validator: _model
                                          .userCommentTextControllerValidator
                                          .asValidator(context),
                                    ),
                                  ),
                                ].divide(SizedBox(height: 8.0)),
                              ),
                            ),
                          if (_bookingsLoaded &&
                              _currentUserActiveBooking == null)
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Итоговая приблизительная цена:',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.inter(
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryBackground,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                          fontWeight: FontWeight.w500,
                                          fontStyle:
                                              FlutterFlowTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                  RichText(
                                    textScaler:
                                        MediaQuery.of(context).textScaler,
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: formatPriceValue(
                                            widget.tripItem?.ticketPrice,
                                          ),
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondary,
                                                fontSize: 20.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.w500,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                        ),
                                        TextSpan(
                                          text: ' €',
                                          style: TextStyle(
                                            color: FlutterFlowTheme.of(context)
                                                .secondary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 20.0,
                                          ),
                                        )
                                      ],
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.inter(
                                              fontWeight: FontWeight.w500,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                            color: Color(0xFF1976D2),
                                            fontSize: 20.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle:
                                                FlutterFlowTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_bookingsLoaded &&
                              _currentUserActiveBooking == null)
                            Builder(
                              builder: (context) => Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 0.0, 16.0, 20.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    if (_model.selectedSeat != null) {
                                      try {
                                        _model.checkExistingBooking =
                                            await BookingsTable().queryRows(
                                          queryFn: (q) => q
                                              .eqOrNull(
                                                'trip_id',
                                                widget.tripItem?.id,
                                              )
                                              .eqOrNull(
                                                'user_id',
                                                currentUserUid,
                                              )
                                              .inFilterOrNull(
                                            'status',
                                            [
                                              'pending',
                                              'confirmed',
                                              'cancel_requested'
                                            ],
                                          ),
                                        );
                                      } catch (_) {
                                        if (!context.mounted) {
                                          return;
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Не удалось проверить заявку. Проверьте интернет и попробуйте ещё раз.',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.black,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            duration:
                                                Duration(milliseconds: 4000),
                                            backgroundColor: Color(0xFFFFCACA),
                                          ),
                                        );
                                        return;
                                      }
                                      if (!context.mounted) {
                                        return;
                                      }
                                      if (_model.checkExistingBooking!.length >
                                          0) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Вы уже забронировали место в этой поездке!',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: Colors.black,
                                                fontSize: 25.0,
                                              ),
                                            ),
                                            duration:
                                                Duration(milliseconds: 4000),
                                            backgroundColor: Color(0xFFFFCACA),
                                          ),
                                        );
                                      } else {
                                        try {
                                          await BookingsTable().insert({
                                            'trip_id': widget.tripItem?.id,
                                            'seat_number': _model.selectedSeat,
                                            'status': 'pending',
                                            'has_luggage': _model.checkboxValue,
                                            'passenger_count': 1,
                                            'user_comment': _model
                                                .userCommentTextController.text,
                                            'total_price':
                                                widget.tripItem?.ticketPrice,
                                            'user_id': currentUserUid,
                                          });
                                        } on PostgrestException catch (e) {
                                          if (!context.mounted) {
                                            return;
                                          }
                                          final dbError =
                                              e.message.toLowerCase();
                                          if (e.code == '23505' ||
                                              dbError.contains('duplicate') ||
                                              dbError.contains('unique')) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Вы уже забронировали место в этой поездке!',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.black,
                                                    fontSize: 25.0,
                                                  ),
                                                ),
                                                duration: Duration(
                                                    milliseconds: 4000),
                                                backgroundColor:
                                                    Color(0xFFFFCACA),
                                              ),
                                            );
                                            safeSetState(() {
                                              _loadBookings();
                                            });
                                            return;
                                          }
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Не удалось отправить заявку. Проверьте данные и попробуйте ещё раз.',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              duration:
                                                  Duration(milliseconds: 4000),
                                              backgroundColor:
                                                  Color(0xFFFFCACA),
                                            ),
                                          );
                                          return;
                                        }
                                        if (!context.mounted) {
                                          return;
                                        }
                                        await showDialog(
                                          barrierColor: Color(0x99000000),
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (dialogContext) {
                                            return Dialog(
                                              elevation: 0,
                                              insetPadding: EdgeInsets.zero,
                                              backgroundColor:
                                                  Colors.transparent,
                                              alignment:
                                                  AlignmentDirectional(0.0, 0.0)
                                                      .resolve(
                                                          Directionality.of(
                                                              context)),
                                              child: GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(dialogContext)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child:
                                                    SuccessBookingDialogWidget(
                                                  bookingID:
                                                      valueOrDefault<String>(
                                                    functions.getShortId(
                                                        valueOrDefault<String>(
                                                      widget.tripItem?.id,
                                                      'id',
                                                    )),
                                                    'id',
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Пожалуйста, выберите место',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              color: Colors.black,
                                              fontSize: 25.0,
                                            ),
                                          ),
                                          duration:
                                              Duration(milliseconds: 4000),
                                          backgroundColor: Color(0xFFFFCACA),
                                        ),
                                      );
                                    }

                                    safeSetState(() {});
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 1.0,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1976D2),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(50.0),
                                        topRight: Radius.circular(50.0),
                                        bottomLeft: Radius.circular(50.0),
                                        bottomRight: Radius.circular(50.0),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          27.5, 18.5, 27.5, 18.5),
                                      child: Text(
                                        'Подтвердить бронь',
                                        textAlign: TextAlign.center,
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              font: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                              ),
                                              color: Colors.white,
                                              fontSize: 16.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium
                                                      .fontStyle,
                                            ),
                                      ),
                                    ),
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
