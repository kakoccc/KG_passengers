import '/auth/supabase_auth/auth_util.dart';
import '/backend/booking_live_refresh.dart';
import '/backend/supabase/supabase.dart';
import '/components/new_tab_item/new_tab_item_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/ux_reliability.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'applications_model.dart';
export 'applications_model.dart';

class ApplicationsWidget extends StatefulWidget {
  const ApplicationsWidget({super.key});

  static String routeName = 'Applications';
  static String routePath = '/applications';

  @override
  State<ApplicationsWidget> createState() => _ApplicationsWidgetState();
}

class _ApplicationsWidgetState extends State<ApplicationsWidget> {
  late ApplicationsModel _model;
  late Future<List<BookingsRow>> _bookingsFuture;
  final Map<String, Future<List<TripsViewRow>>> _tripFuturesById =
      <String, Future<List<TripsViewRow>>>{};

  final scaffoldKey = GlobalKey<ScaffoldState>();
  static const Duration _bookingsQueryTimeout = Duration(seconds: 12);
  static List<BookingsRow>? _cachedBookings;
  static const String _fallbackManagerPhone = '+791100000001';
  final Set<String> _cancelRequestInProgress = <String>{};
  final Set<String> _expandedBookingIds = <String>{};
  late final BookingLiveRefresh _bookingLiveRefresh;
  bool _isRefreshingBookings = false;

  void _loadBookings() {
    _bookingsFuture = _queryBookingsWithCacheFallback();
    _tripFuturesById.clear();
  }

  Future<void> _refreshBookingsInPlace() async {
    if (!mounted || _isRefreshingBookings || currentUserUid.isEmpty) {
      return;
    }

    _isRefreshingBookings = true;
    try {
      final refreshFuture = _queryBookingsWithCacheFallback();
      if (!mounted) {
        return;
      }
      setState(() {
        _bookingsFuture = refreshFuture;
      });
      await refreshFuture;
    } catch (_) {
      // The FutureBuilder keeps showing cached data if a background refresh fails.
    } finally {
      _isRefreshingBookings = false;
    }
  }

  Future<List<BookingsRow>> _queryBookings() async {
    if (currentUserUid.isEmpty) {
      _cachedBookings = <BookingsRow>[];
      return _cachedBookings!;
    }

    final rows = await BookingsTable()
        .queryRows(
          queryFn: (q) => q.eqOrNull(
            'user_id',
            currentUserUid,
          ),
        )
        .timeout(_bookingsQueryTimeout);
    _cachedBookings = rows;
    return rows;
  }

  Future<List<BookingsRow>> _queryBookingsWithCacheFallback() async {
    try {
      return await _queryBookings();
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 350));
      try {
        return await _queryBookings();
      } catch (_) {
        final cachedBookings = _cachedBookings;
        if (cachedBookings != null) {
          return cachedBookings;
        }
        rethrow;
      }
    }
  }

  Widget _centeredApplicationsState(
    double height,
    Widget child,
  ) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Center(child: child),
    );
  }

  Widget _loadingApplicationsState(
    BuildContext context,
    double height,
  ) {
    return _centeredApplicationsState(
      height,
      SizedBox(
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

  Future<List<TripsViewRow>> _tripFutureForBooking(BookingsRow booking) {
    final tripId = booking.tripId;
    if (tripId == null || tripId.isEmpty) {
      return Future.value(<TripsViewRow>[]);
    }

    return _tripFuturesById.putIfAbsent(
      tripId,
      () => TripsViewTable().querySingleRow(
        queryFn: (q) => q.eqOrNull(
          'id',
          tripId,
        ),
      ),
    );
  }

  bool _canRequestCancellation(String? status) =>
      status == 'pending' || status == 'confirmed';

  void _showMessage(
    String message, {
    Color? backgroundColor,
  }) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  String _normalizePhone(String? rawPhone) {
    if (rawPhone == null) {
      return '';
    }
    final trimmed = rawPhone.trim();
    if (trimmed.isEmpty) {
      return '';
    }

    final cleaned = trimmed.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.isEmpty) {
      return '';
    }

    if (cleaned.startsWith('+')) {
      final withoutExtraPluses = cleaned.substring(1).replaceAll('+', '');
      return withoutExtraPluses.isEmpty ? '' : '+$withoutExtraPluses';
    }

    if (cleaned.startsWith('00') && cleaned.length > 2) {
      return '+${cleaned.substring(2)}';
    }

    if (cleaned.startsWith('8') && cleaned.length == 11) {
      return '+7${cleaned.substring(1)}';
    }

    return '+$cleaned';
  }

  Future<String> _resolveManagerPhone(String? tripId) async {
    try {
      if (tripId == null || tripId.isEmpty) {
        return _fallbackManagerPhone;
      }

      final tripRows = await TripsTable().querySingleRow(
        queryFn: (q) => q.eqOrNull(
          'id',
          tripId,
        ),
      );
      final managerId = tripRows.firstOrNull?.createdBy;
      if (managerId == null || managerId.isEmpty) {
        return _fallbackManagerPhone;
      }

      final managerRows = await UsersTable().querySingleRow(
        queryFn: (q) => q.eqOrNull(
          'id',
          managerId,
        ),
      );
      final managerPhone = _normalizePhone(managerRows.firstOrNull?.phone);
      if (managerPhone.isEmpty) {
        return _fallbackManagerPhone;
      }

      return managerPhone;
    } catch (_) {
      return _fallbackManagerPhone;
    }
  }

  Future<bool> _enqueueAdminCancelRequestedEvent(BookingsRow booking) async {
    try {
      await NotificationEventsTable().insert({
        'event_type': 'booking_cancel_requested',
        'recipient_role': 'admin',
        'booking_id': booking.id,
        'trip_id': booking.tripId,
        'actor_user_id': currentUserUid,
        'payload': {
          'source': 'passenger_app',
          'status': 'cancel_requested',
        },
      });
      return true;
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _callManager(BookingsRow booking) async {
    try {
      final managerPhone = await _resolveManagerPhone(booking.tripId);
      await launchURL('tel:$managerPhone');
    } catch (_) {
      _showMessage(
        'Не удалось открыть звонок. Попробуйте ещё раз.',
        backgroundColor: const Color(0xFFB3261E),
      );
    }
  }

  Future<void> _requestCancellation(
    BookingsRow booking,
  ) async {
    final bookingId = booking.id;
    if (_cancelRequestInProgress.contains(bookingId)) {
      return;
    }

    final alreadyRequested = booking.status == 'cancel_requested';
    if (!alreadyRequested && !_canRequestCancellation(booking.status)) {
      _showMessage('Для этой заявки отмена сейчас недоступна.');
      return;
    }

    setState(() => _cancelRequestInProgress.add(bookingId));
    var bookingChanged = false;
    try {
      if (!alreadyRequested) {
        await BookingsTable().update(
          data: {
            'status': 'cancel_requested',
          },
          matchingRows: (rows) => rows.eqOrNull(
            'id',
            bookingId,
          ),
        );
        bookingChanged = true;
      }
      final adminNotificationEnqueued =
          await _enqueueAdminCancelRequestedEvent(booking);
      if (!alreadyRequested) {
        _showMessage(
          adminNotificationEnqueued
              ? 'Запрос на отмену отправлен администратору.'
              : 'Отмена сохранена. Админ увидит статус в заявке.',
        );
      } else {
        _showMessage(
          adminNotificationEnqueued
              ? 'Заявка уже в статусе "Запрос на отмену". Администратор уведомлён.'
              : 'Заявка уже в статусе "Запрос на отмену".',
        );
      }
    } catch (e) {
      _showMessage(
        'Не удалось отправить запрос. Попробуйте ещё раз.',
        backgroundColor: const Color(0xFFB3261E),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cancelRequestInProgress.remove(bookingId);
          if (bookingChanged) {
            _loadBookings();
          }
        });
      }
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'confirmed':
        return 'Подтверждено';
      case 'cancel_requested':
        return 'Запрос на отмену';
      case 'pending':
      default:
        return 'В обработке';
    }
  }

  Color _statusColor(BuildContext context, String? status) {
    switch (status) {
      case 'confirmed':
        return Color(0xFF2EAD4F);
      case 'cancel_requested':
        return FlutterFlowTheme.of(context).tertiary;
      case 'pending':
      default:
        return FlutterFlowTheme.of(context).alternate;
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ApplicationsModel());
    _loadBookings();
    _bookingLiveRefresh = BookingLiveRefresh(
      channelName: 'bookings:user:$currentUserUid',
      userId: currentUserUid,
      onRefresh: _refreshBookingsInPlace,
    )..start();
  }

  @override
  void dispose() {
    _bookingLiveRefresh.dispose();
    _model.dispose();

    super.dispose();
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
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 0.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableHeight = constraints.maxHeight.isFinite
                          ? constraints.maxHeight
                          : MediaQuery.sizeOf(context).height - 180.0;
                      final stateHeight = (availableHeight - 42.0)
                          .clamp(320.0, 720.0)
                          .toDouble();

                      return SingleChildScrollView(
                        primary: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Stack(
                                alignment: AlignmentDirectional(0.0, 0.0),
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Text(
                                      'Мои поездки',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context)
                                                .secondary,
                                            fontSize: 24.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FutureBuilder<List<BookingsRow>>(
                              future: _bookingsFuture,
                              initialData: _cachedBookings,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return _centeredApplicationsState(
                                    stateHeight,
                                    KgErrorState(
                                      title: 'Не удалось загрузить заявки',
                                      message:
                                          'Проверьте подключение и попробуйте обновить список.',
                                      icon: Icons.event_seat_outlined,
                                      onRetry: () {
                                        safeSetState(() {
                                          _loadBookings();
                                        });
                                      },
                                    ),
                                  );
                                }

                                if (!snapshot.hasData) {
                                  return _loadingApplicationsState(
                                    context,
                                    stateHeight,
                                  );
                                }
                                List<BookingsRow> listViewBookingsRowList =
                                    snapshot.data!;

                                if (listViewBookingsRowList.isEmpty) {
                                  return _centeredApplicationsState(
                                    stateHeight,
                                    KgEmptyState(
                                      title: 'Заявок пока нет',
                                      message:
                                          'Выберите рейс и место, чтобы поездка появилась в этом разделе.',
                                      icon: Icons.event_seat_outlined,
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: listViewBookingsRowList.length,
                                  itemBuilder: (context, listViewIndex) {
                                    final listViewBookingsRow =
                                        listViewBookingsRowList[listViewIndex];
                                    return FutureBuilder<List<TripsViewRow>>(
                                      future: _tripFutureForBooking(
                                          listViewBookingsRow),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return KgErrorState(
                                            title: 'Не удалось загрузить рейс',
                                            message:
                                                'Обновите список заявок и попробуйте ещё раз.',
                                            icon: Icons.directions_car_outlined,
                                            onRetry: () {
                                              final tripId =
                                                  listViewBookingsRow.tripId;
                                              safeSetState(() {
                                                if (tripId != null &&
                                                    tripId.isNotEmpty) {
                                                  _tripFuturesById
                                                      .remove(tripId);
                                                }
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
                                        List<TripsViewRow>
                                            containerTripsViewRowList =
                                            snapshot.data!;

                                        final containerTripsViewRow =
                                            containerTripsViewRowList.isNotEmpty
                                                ? containerTripsViewRowList
                                                    .first
                                                : null;
                                        final isCancelBusy =
                                            _cancelRequestInProgress.contains(
                                                listViewBookingsRow.id);
                                        final isExpanded = _expandedBookingIds
                                            .contains(listViewBookingsRow.id);
                                        final bookingTitle =
                                            'KG - ${valueOrDefault<String>(containerTripsViewRow?.destinationCityName, 'Город назначения')}';
                                        final isCompactWidth =
                                            MediaQuery.sizeOf(context).width <
                                                380.0;
                                        final cardPadding =
                                            isCompactWidth ? 14.0 : 18.0;
                                        final cardGap =
                                            isCompactWidth ? 12.0 : 14.0;
                                        final detailFontSize =
                                            isCompactWidth ? 13.0 : 14.0;
                                        final titleFontSize =
                                            isCompactWidth ? 15.0 : 16.0;
                                        final metaFontSize =
                                            isCompactWidth ? 11.0 : 12.0;
                                        final fieldPadding =
                                            isCompactWidth ? 8.0 : 10.0;

                                        return Container(
                                          margin: EdgeInsets.only(
                                            bottom: listViewIndex ==
                                                    listViewBookingsRowList
                                                            .length -
                                                        1
                                                ? 0.0
                                                : 12.0,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                          ),
                                          child: Padding(
                                            padding:
                                                EdgeInsets.all(cardPadding),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  focusColor:
                                                      Colors.transparent,
                                                  hoverColor:
                                                      Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () {
                                                    setState(() {
                                                      if (isExpanded) {
                                                        _expandedBookingIds
                                                            .remove(
                                                          listViewBookingsRow
                                                              .id,
                                                        );
                                                      } else {
                                                        _expandedBookingIds.add(
                                                          listViewBookingsRow
                                                              .id,
                                                        );
                                                      }
                                                    });
                                                  },
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              bookingTitle,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .labelLarge
                                                                  .override(
                                                                    font: GoogleFonts
                                                                        .inter(
                                                                      fontWeight: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .fontWeight,
                                                                      fontStyle: FlutterFlowTheme.of(
                                                                              context)
                                                                          .labelLarge
                                                                          .fontStyle,
                                                                    ),
                                                                    color: FlutterFlowTheme.of(
                                                                            context)
                                                                        .secondary,
                                                                    fontSize:
                                                                        titleFontSize,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .fontWeight,
                                                                    fontStyle: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelLarge
                                                                        .fontStyle,
                                                                  ),
                                                            ),
                                                            Text(
                                                              valueOrDefault<
                                                                  String>(
                                                                _statusLabel(
                                                                    listViewBookingsRow
                                                                        .status),
                                                                'Статус заявки',
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .visible,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                  .bodyMedium
                                                                  .override(
                                                                    fontFamily:
                                                                        'Inter',
                                                                    color:
                                                                        _statusColor(
                                                                      context,
                                                                      listViewBookingsRow
                                                                          .status,
                                                                    ),
                                                                    fontSize:
                                                                        detailFontSize,
                                                                    letterSpacing:
                                                                        0.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                            ),
                                                          ].divide(SizedBox(
                                                              height: 4.0)),
                                                        ),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: isCancelBusy
                                                                ? null
                                                                : () async {
                                                                    await _requestCancellation(
                                                                      listViewBookingsRow,
                                                                    );
                                                                  },
                                                            child: Container(
                                                              width: 32.0,
                                                              height: 32.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: isCancelBusy
                                                                    ? FlutterFlowTheme.of(
                                                                            context)
                                                                        .primaryBackground
                                                                    : Color(
                                                                        0xFFFFEEEE),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child:
                                                                  isCancelBusy
                                                                      ? SizedBox(
                                                                          width:
                                                                              15.0,
                                                                          height:
                                                                              15.0,
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            strokeWidth:
                                                                                2.0,
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(
                                                                              FlutterFlowTheme.of(context).tertiary,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .delete_outline,
                                                                          color:
                                                                              FlutterFlowTheme.of(context).tertiary,
                                                                          size:
                                                                              18.0,
                                                                        ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            splashColor: Colors
                                                                .transparent,
                                                            focusColor: Colors
                                                                .transparent,
                                                            hoverColor: Colors
                                                                .transparent,
                                                            highlightColor:
                                                                Colors
                                                                    .transparent,
                                                            onTap: () async {
                                                              await _callManager(
                                                                listViewBookingsRow,
                                                              );
                                                            },
                                                            child: Container(
                                                              width: 32.0,
                                                              height: 32.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary
                                                                    .withValues(
                                                                        alpha:
                                                                            0.12),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              alignment:
                                                                  AlignmentDirectional(
                                                                      0.0, 0.0),
                                                              child: Icon(
                                                                Icons
                                                                    .phone_outlined,
                                                                color: FlutterFlowTheme.of(
                                                                        context)
                                                                    .primary,
                                                                size: 18.0,
                                                              ),
                                                            ),
                                                          ),
                                                          AnimatedRotation(
                                                            turns: isExpanded
                                                                ? 0.5
                                                                : 0.0,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    220),
                                                            curve: Curves
                                                                .easeInOutCubic,
                                                            child: Icon(
                                                              Icons
                                                                  .keyboard_arrow_down_rounded,
                                                              color: FlutterFlowTheme
                                                                      .of(context)
                                                                  .secondary,
                                                              size: 26.0,
                                                            ),
                                                          ),
                                                        ].divide(SizedBox(
                                                            width:
                                                                isCompactWidth
                                                                    ? 6.0
                                                                    : 8.0)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                AnimatedSize(
                                                  duration: Duration(
                                                      milliseconds: 260),
                                                  curve: Curves.easeInOutCubic,
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: isExpanded
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: cardGap),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .stretch,
                                                            children: [
                                                              Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceAround,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children:
                                                                            [
                                                                          Icon(
                                                                            Icons.location_on_outlined,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
                                                                            size:
                                                                                20.0,
                                                                          ),
                                                                          RichText(
                                                                            textScaler:
                                                                                MediaQuery.of(context).textScaler,
                                                                            text:
                                                                                TextSpan(
                                                                              children: [
                                                                                TextSpan(
                                                                                  text: valueOrDefault<String>(
                                                                                    containerTripsViewRow?.distanceKm?.toString(),
                                                                                    'Растояние',
                                                                                  ),
                                                                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                        fontFamily: 'Inter',
                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                        fontSize: detailFontSize,
                                                                                        letterSpacing: 0.0,
                                                                                      ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: ' Км',
                                                                                  style: TextStyle(
                                                                                    fontSize: detailFontSize,
                                                                                  ),
                                                                                )
                                                                              ],
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    fontFamily: 'Inter',
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    fontSize: detailFontSize,
                                                                                    letterSpacing: 0.0,
                                                                                  ),
                                                                            ),
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                      Row(
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children:
                                                                            [
                                                                          Icon(
                                                                            Icons.schedule_rounded,
                                                                            color:
                                                                                FlutterFlowTheme.of(context).secondaryText,
                                                                            size:
                                                                                20.0,
                                                                          ),
                                                                          Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.max,
                                                                            children: [
                                                                              Text(
                                                                                'Время в пути',
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontFamily: 'Inter',
                                                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                                                      fontSize: detailFontSize,
                                                                                      letterSpacing: 0.0,
                                                                                    ),
                                                                              ),
                                                                              Text(
                                                                                valueOrDefault<String>(
                                                                                  containerTripsViewRow?.travelTime,
                                                                                  'Время в пути',
                                                                                ),
                                                                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                      fontFamily: 'Inter',
                                                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                                                      fontSize: detailFontSize,
                                                                                      letterSpacing: 0.0,
                                                                                    ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ].divide(SizedBox(width: 8.0)),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Align(
                                                                    alignment:
                                                                        AlignmentDirectional(
                                                                            0.0,
                                                                            0.0),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children:
                                                                          [
                                                                        Container(
                                                                          width:
                                                                              8.0,
                                                                          height:
                                                                              8.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            borderRadius:
                                                                                BorderRadius.circular(9999.0),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Divider(
                                                                            thickness:
                                                                                1.0,
                                                                            color:
                                                                                Color(0xFFCFD3E2),
                                                                          ),
                                                                        ),
                                                                        ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(0.0),
                                                                          child:
                                                                              Image.asset(
                                                                            'assets/images/avtobas.png',
                                                                            width:
                                                                                25.0,
                                                                            height:
                                                                                25.0,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Divider(
                                                                            thickness:
                                                                                1.0,
                                                                            color:
                                                                                Color(0xFFCFD3E2),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              8.0,
                                                                          height:
                                                                              8.0,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primary,
                                                                            borderRadius:
                                                                                BorderRadius.circular(9999.0),
                                                                          ),
                                                                        ),
                                                                      ].divide(SizedBox(
                                                                              width: 8.0)),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .max,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            RichText(
                                                                              textScaler: MediaQuery.of(context).textScaler,
                                                                              text: TextSpan(
                                                                                children: [
                                                                                  TextSpan(
                                                                                    text: valueOrDefault<String>(
                                                                                      dateTimeFormat(
                                                                                        "d MMMM",
                                                                                        containerTripsViewRow?.departureDate,
                                                                                        locale: FFLocalizations.of(context).languageCode,
                                                                                      ),
                                                                                      'Дата выезда',
                                                                                    ),
                                                                                    style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                          fontFamily: 'Inter',
                                                                                          color: FlutterFlowTheme.of(context).primaryText,
                                                                                          fontSize: detailFontSize,
                                                                                          letterSpacing: 0.0,
                                                                                        ),
                                                                                  ),
                                                                                  TextSpan(
                                                                                    text: ', ',
                                                                                    style: TextStyle(
                                                                                      fontSize: detailFontSize,
                                                                                    ),
                                                                                  ),
                                                                                  TextSpan(
                                                                                    text: valueOrDefault<String>(
                                                                                      dateTimeFormat(
                                                                                        "HH:mm",
                                                                                        containerTripsViewRow?.departureTimeOnly?.time,
                                                                                        locale: FFLocalizations.of(context).languageCode,
                                                                                      ),
                                                                                      'Время выезда',
                                                                                    ),
                                                                                    style: TextStyle(
                                                                                      fontSize: detailFontSize,
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                                style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                      fontFamily: 'Inter',
                                                                                      color: FlutterFlowTheme.of(context).primaryText,
                                                                                      fontSize: metaFontSize,
                                                                                      letterSpacing: 0.0,
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              valueOrDefault<String>(
                                                                                containerTripsViewRow?.originCityName,
                                                                                'Город выезда',
                                                                              ),
                                                                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                    fontFamily: 'Inter',
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    fontSize: titleFontSize,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                            ),
                                                                          ].divide(SizedBox(height: 2.0)),
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children:
                                                                              [
                                                                            Text(
                                                                              valueOrDefault<String>(
                                                                                dateTimeFormat(
                                                                                  "d MMMM, HH:mm",
                                                                                  containerTripsViewRow?.calculatedArrivalTime,
                                                                                  locale: FFLocalizations.of(context).languageCode,
                                                                                ),
                                                                                'Время прибытия',
                                                                              ),
                                                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                                                    font: GoogleFonts.inter(
                                                                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                    ),
                                                                                    fontSize: detailFontSize,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                                                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                                                                  ),
                                                                            ),
                                                                            Text(
                                                                              valueOrDefault<String>(
                                                                                containerTripsViewRow?.destinationCityName,
                                                                                'Город прибытия',
                                                                              ),
                                                                              style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                    fontFamily: 'Inter',
                                                                                    color: FlutterFlowTheme.of(context).primaryText,
                                                                                    fontSize: titleFontSize,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w600,
                                                                                  ),
                                                                            ),
                                                                          ].divide(SizedBox(height: 2.0)),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    height:
                                                                        12.0)),
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(14.0),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.all(fieldPadding),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Text(
                                                                              'Пассажиры',
                                                                              style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                    fontFamily: 'Inter',
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    fontSize: metaFontSize,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w500,
                                                                                  ),
                                                                            ),
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(0.0),
                                                                                  child: Image.asset(
                                                                                    'assets/images/people.png',
                                                                                    width: isCompactWidth ? 15.0 : 17.0,
                                                                                    height: isCompactWidth ? 15.0 : 17.0,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  valueOrDefault<String>(
                                                                                    listViewBookingsRow.passengerCount?.toString(),
                                                                                    'Кол-во пассажиров',
                                                                                  ),
                                                                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                        fontFamily: 'Inter',
                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                        fontSize: metaFontSize,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.normal,
                                                                                      ),
                                                                                ),
                                                                              ].divide(SizedBox(width: 8.0)),
                                                                            ),
                                                                          ].divide(SizedBox(height: 4.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(14.0),
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              FlutterFlowTheme.of(context).primaryBackground,
                                                                          width:
                                                                              1.0,
                                                                        ),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.all(fieldPadding),
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children:
                                                                              [
                                                                            Text(
                                                                              'Багаж',
                                                                              style: FlutterFlowTheme.of(context).labelSmall.override(
                                                                                    fontFamily: 'Inter',
                                                                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                                                                    letterSpacing: 0.0,
                                                                                    fontWeight: FontWeight.w500,
                                                                                  ),
                                                                            ),
                                                                            Row(
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(0.0),
                                                                                  child: Image.asset(
                                                                                    'assets/images/bagash.png',
                                                                                    width: isCompactWidth ? 15.0 : 17.0,
                                                                                    height: isCompactWidth ? 15.0 : 17.0,
                                                                                    fit: BoxFit.cover,
                                                                                  ),
                                                                                ),
                                                                                Text(
                                                                                  valueOrDefault<String>(
                                                                                    listViewBookingsRow.hasLuggage == true ? 'Да' : 'Нет',
                                                                                    'Наличие Багажа',
                                                                                  ),
                                                                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                                                                        fontFamily: 'Inter',
                                                                                        color: FlutterFlowTheme.of(context).primaryText,
                                                                                        fontSize: detailFontSize,
                                                                                        letterSpacing: 0.0,
                                                                                        fontWeight: FontWeight.normal,
                                                                                      ),
                                                                                ),
                                                                              ].divide(SizedBox(width: 8.0)),
                                                                            ),
                                                                          ].divide(SizedBox(height: 4.0)),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    width:
                                                                        12.0)),
                                                              ),
                                                              Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'Примечания для диспетчера',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .labelSmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          fontSize:
                                                                              metaFontSize,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                  ),
                                                                  Container(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              14.0),
                                                                      border:
                                                                          Border
                                                                              .all(
                                                                        color: FlutterFlowTheme.of(context)
                                                                            .primaryBackground,
                                                                        width:
                                                                            1.0,
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              fieldPadding),
                                                                      child:
                                                                          Text(
                                                                        listViewBookingsRow.userComment?.trim().isNotEmpty ==
                                                                                true
                                                                            ? listViewBookingsRow.userComment!.trim()
                                                                            : 'Без комментария',
                                                                        style: FlutterFlowTheme.of(context)
                                                                            .bodyMedium
                                                                            .override(
                                                                              fontFamily: 'Inter',
                                                                              color: FlutterFlowTheme.of(context).primaryText,
                                                                              fontSize: detailFontSize,
                                                                              letterSpacing: 0.0,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ].divide(SizedBox(
                                                                    height:
                                                                        8.0)),
                                                              ),
                                                              Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .max,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Text(
                                                                    'Стоимость:',
                                                                    style: FlutterFlowTheme.of(
                                                                            context)
                                                                        .bodySmall
                                                                        .override(
                                                                          fontFamily:
                                                                              'Inter',
                                                                          color:
                                                                              FlutterFlowTheme.of(context).secondaryBackground,
                                                                          fontSize:
                                                                              metaFontSize,
                                                                          letterSpacing:
                                                                              0.0,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                        ),
                                                                  ),
                                                                  RichText(
                                                                    textScaler:
                                                                        MediaQuery.of(context)
                                                                            .textScaler,
                                                                    text:
                                                                        TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              formatPriceValue(
                                                                            listViewBookingsRow.totalPrice,
                                                                            fallback:
                                                                                'Цена поездки',
                                                                          ),
                                                                          style: FlutterFlowTheme.of(context)
                                                                              .titleLarge
                                                                              .override(
                                                                                fontFamily: 'Inter',
                                                                                color: FlutterFlowTheme.of(context).primaryText,
                                                                                fontSize: titleFontSize + 2.0,
                                                                                letterSpacing: 0.0,
                                                                                fontWeight: FontWeight.w500,
                                                                              ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              ' €',
                                                                          style:
                                                                              TextStyle(),
                                                                        )
                                                                      ],
                                                                      style: FlutterFlowTheme.of(
                                                                              context)
                                                                          .titleLarge
                                                                          .override(
                                                                            fontFamily:
                                                                                'Inter',
                                                                            color:
                                                                                FlutterFlowTheme.of(context).primaryText,
                                                                            fontSize:
                                                                                titleFontSize + 2.0,
                                                                            letterSpacing:
                                                                                0.0,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ].divide(SizedBox(
                                                                height:
                                                                    cardGap)),
                                                          ),
                                                        )
                                                      : SizedBox.shrink(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ].divide(SizedBox(height: 15.0)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: Padding(
                    padding:
                        EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
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
                                label: 'Поездки',
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
      ),
    );
  }
}
