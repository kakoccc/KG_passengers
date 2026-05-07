import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/ux_reliability.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'passager_detal_admin_model.dart';
export 'passager_detal_admin_model.dart';

class PassagerDetalAdminWidget extends StatefulWidget {
  const PassagerDetalAdminWidget({
    super.key,
    required this.passengerId,
    required this.bookingId,
    this.bookingStatus,
    this.userComment,
    this.adminComment,
    this.seatNumber,
  });

  final String passengerId;
  final String bookingId;
  final String? bookingStatus;
  final String? userComment;
  final String? adminComment;
  final int? seatNumber;

  @override
  State<PassagerDetalAdminWidget> createState() =>
      _PassagerDetalAdminWidgetState();
}

class _PassagerDetalAdminWidgetState extends State<PassagerDetalAdminWidget> {
  late PassagerDetalAdminModel _model;
  late Future<List<UsersRow>> _passengerFuture;
  bool _isConfirmingBooking = false;
  bool _isRemovingBooking = false;
  late String _bookingStatus;
  String? _bookingActionError;
  static const Duration _bookingActionTimeout = Duration(seconds: 8);

  void _loadPassenger() {
    _passengerFuture = UsersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull(
        'id',
        widget.passengerId,
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Подтверждена';
      case 'cancel_requested':
        return 'Запрошена отмена';
      case 'pending':
      default:
        return 'Ожидает подтверждения';
    }
  }

  Color _statusColor(String status) {
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

  void _showInfoSnack(
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

  Future<void> _copyContactValue(BuildContext context, String? value) async {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      _showInfoSnack(
        context,
        'Контакт не указан.',
        backgroundColor: Color(0xFFFFF4CC),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: normalized));
    if (!context.mounted) {
      return;
    }
    _showInfoSnack(context, 'Контакт скопирован.');
  }

  Future<void> _openContactUrl(
    BuildContext context,
    String? value,
    String Function(String value) uriBuilder,
  ) async {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      _showInfoSnack(
        context,
        'Контакт не указан.',
        backgroundColor: Color(0xFFFFF4CC),
      );
      return;
    }
    try {
      await launchURL(uriBuilder(normalized));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      await _copyContactValue(context, normalized);
    }
  }

  String _telegramUrl(String value) {
    final username = value.replaceFirst('@', '').trim();
    if (username.startsWith('http://') || username.startsWith('https://')) {
      return username;
    }
    return 'https://t.me/$username';
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String label,
    required String? value,
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      onLongPress: () async => _copyContactValue(context, value),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 0.0, 0.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  assetPath,
                  width: 40.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 16.0, 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      valueOrDefault<String>(value, 'Не указано'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            color: FlutterFlowTheme.of(context).secondary,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ].divide(SizedBox(height: 4.0)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
              child: Icon(
                Icons.content_copy,
                color: FlutterFlowTheme.of(context).secondaryBackground,
                size: 20.0,
              ),
            ),
          ].divide(SizedBox(width: 16.0)),
        ),
      ),
    );
  }

  Future<void> _confirmBooking(BuildContext context) async {
    if (_isConfirmingBooking || _isRemovingBooking) {
      return;
    }
    if (_bookingStatus == 'confirmed') {
      _showInfoSnack(
        context,
        'Бронь уже подтверждена.',
      );
      return;
    }
    if (_bookingStatus != 'pending') {
      _showInfoSnack(
        context,
        'Подтвердить можно только заявку в ожидании.',
        backgroundColor: Color(0xFFFFF4CC),
      );
      return;
    }
    setState(() {
      _isConfirmingBooking = true;
      _bookingActionError = null;
    });
    try {
      await BookingsTable().update(
        data: {
          'status': 'confirmed',
        },
        matchingRows: (rows) => rows.eqOrNull(
          'id',
          widget.bookingId,
        ),
      ).timeout(_bookingActionTimeout);
      if (!context.mounted) {
        return;
      }
      setState(() => _bookingStatus = 'confirmed');
      _showInfoSnack(
        context,
        'Бронь подтверждена.',
      );
      Navigator.pop(context, true);
    } on PostgrestException catch (error) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        _bookingActionError = 'Не удалось подтвердить бронь: ${error.message}';
      });
      _showInfoSnack(
        context,
        'Не удалось подтвердить бронь: ${error.message}',
        backgroundColor: Color(0xFFFFDADA),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        _bookingActionError =
            'Не удалось подтвердить бронь. Проверьте подключение и попробуйте ещё раз.';
      });
      _showInfoSnack(
        context,
        'Не удалось подтвердить бронь.',
        backgroundColor: Color(0xFFFFDADA),
      );
    } finally {
      if (mounted) {
        setState(() => _isConfirmingBooking = false);
      }
    }
  }

  Future<void> _removeBooking(BuildContext context) async {
    if (_isConfirmingBooking || _isRemovingBooking) {
      return;
    }
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text('Снять бронь?'),
              content: Text(
                'Заявка будет удалена из базы и место снова станет доступным.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text('Снять'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (!shouldDelete) {
      return;
    }

    setState(() {
      _isRemovingBooking = true;
      _bookingActionError = null;
    });
    try {
      await BookingsTable()
          .delete(
            matchingRows: (rows) => rows.eqOrNull(
              'id',
              widget.bookingId,
            ),
          )
          .timeout(_bookingActionTimeout);
      if (!context.mounted) {
        return;
      }
      _showInfoSnack(
        context,
        'Бронь удалена.',
      );
      Navigator.pop(context, true);
    } on PostgrestException catch (error) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        _bookingActionError = 'Не удалось снять бронь: ${error.message}';
      });
      _showInfoSnack(
        context,
        'Не удалось снять бронь: ${error.message}',
        backgroundColor: Color(0xFFFFDADA),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      setState(() {
        _bookingActionError =
            'Не удалось снять бронь. Проверьте подключение и попробуйте ещё раз.';
      });
      _showInfoSnack(
        context,
        'Не удалось снять бронь.',
        backgroundColor: Color(0xFFFFDADA),
      );
    } finally {
      if (mounted) {
        setState(() => _isRemovingBooking = false);
      }
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PassagerDetalAdminModel());
    _bookingStatus = widget.bookingStatus ?? 'pending';
    _loadPassenger();
  }

  @override
  void didUpdateWidget(covariant PassagerDetalAdminWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.passengerId != widget.passengerId) {
      _loadPassenger();
    }
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: AlignmentDirectional(0.0, 0.0),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: FutureBuilder<List<UsersRow>>(
            future: _passengerFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return KgErrorState(
                  title: 'Не удалось загрузить пассажира',
                  message:
                      'Проверьте подключение и попробуйте открыть заявку ещё раз.',
                  icon: Icons.person_outline,
                  onRetry: () {
                    safeSetState(() {
                      _loadPassenger();
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
              List<UsersRow> containerUsersRowList = snapshot.data!;

              final containerUsersRow = containerUsersRowList.isNotEmpty
                  ? containerUsersRowList.first
                  : null;
              final mediaQuery = MediaQuery.of(context);
              final viewportSize = mediaQuery.size;
              final availableHeight = max(
                0.0,
                viewportSize.height -
                    mediaQuery.viewInsets.bottom -
                    mediaQuery.padding.vertical -
                    24.0,
              );
              final dialogWidth = max(
                280.0,
                min(450.0, viewportSize.width - 32.0),
              );
              final dialogHeight = min(700.0, availableHeight);
              final dialogRadius = viewportSize.height < 520.0 ? 28.0 : 50.0;

              return Container(
                width: dialogWidth,
                constraints: BoxConstraints(maxHeight: dialogHeight),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondaryText,
                  borderRadius: BorderRadius.circular(dialogRadius),
                ),
                child: SingleChildScrollView(
                  primary: false,
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      16.0,
                      viewportSize.height < 520.0 ? 24.0 : 40.0,
                      16.0,
                      24.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Stack(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            children: [
                              Align(
                                alignment: AlignmentDirectional(1.0, 0.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.close,
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    size: 34.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 96.0,
                          height: 96.0,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: ClipOval(
                            child: kgNetworkImageOrPlaceholder(
                              context,
                              imageUrl: containerUsersRow?.avatarUrl,
                              width: 96.0,
                              height: 96.0,
                              fit: BoxFit.cover,
                              placeholderIcon: Icons.person_outline,
                              placeholderIconSize: 30.0,
                            ),
                          ),
                        ),
                        Text(
                          valueOrDefault<String>(
                            containerUsersRow?.firstName,
                            'Имя',
                          ),
                          style: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .override(
                                fontFamily: 'Inter',
                                color: FlutterFlowTheme.of(context).secondary,
                                fontSize: 20.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            _buildContactCard(
                              context,
                              label: 'Телефон',
                              value: containerUsersRow?.phone,
                              assetPath: 'assets/images/154Icon.png',
                              onTap: () async => _openContactUrl(
                                context,
                                containerUsersRow?.phone,
                                (value) => 'tel:$value',
                              ),
                            ),
                            _buildContactCard(
                              context,
                              label: 'Почта',
                              value: containerUsersRow?.email,
                              assetPath: 'assets/images/Ico56789899n.png',
                              onTap: () async => _openContactUrl(
                                context,
                                containerUsersRow?.email,
                                (value) => 'mailto:$value',
                              ),
                            ),
                            _buildContactCard(
                              context,
                              label: 'Telegram',
                              value: containerUsersRow?.telegram,
                              assetPath: 'assets/images/teleg.png',
                              onTap: () async => _openContactUrl(
                                context,
                                containerUsersRow?.telegram,
                                _telegramUrl,
                              ),
                            ),
                            _buildContactCard(
                              context,
                              label: 'Imo',
                              value: containerUsersRow?.imo,
                              assetPath: 'assets/images/Imo.png',
                              onTap: () async => _copyContactValue(
                                context,
                                containerUsersRow?.imo,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Заявка',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondaryBackground,
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          Text(
                                            widget.seatNumber != null
                                                ? 'Место №${widget.seatNumber}'
                                                : 'Номер места не указан',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Inter',
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .secondary,
                                                  fontSize: 16.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ].divide(SizedBox(height: 4.0)),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: _statusColor(_bookingStatus)
                                            .withValues(alpha: 0.12),
                                        borderRadius:
                                            BorderRadius.circular(999.0),
                                      ),
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          12.0, 6.0, 12.0, 6.0),
                                      child: Text(
                                        _statusLabel(_bookingStatus),
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily: 'Inter',
                                              color:
                                                  _statusColor(_bookingStatus),
                                              fontSize: 12.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Комментарий пассажира',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context)
                                                .secondaryBackground,
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    Text(
                                      valueOrDefault<String>(
                                        widget.userComment,
                                        'Комментария нет',
                                      ),
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            fontFamily: 'Inter',
                                            color: FlutterFlowTheme.of(context)
                                                .secondary,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                          ),
                                    ),
                                  ].divide(SizedBox(height: 8.0)),
                                ),
                              ),
                            ),
                            if (_bookingActionError != null)
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFDADA),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(
                                    _bookingActionError!,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Inter',
                                          color: Color(0xFFB3261E),
                                          fontSize: 13.0,
                                          letterSpacing: 0.0,
                                        ),
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: FFButtonWidget(
                                    onPressed: _isConfirmingBooking ||
                                            _isRemovingBooking ||
                                            _bookingStatus != 'pending'
                                        ? null
                                        : () async {
                                            await _confirmBooking(context);
                                          },
                                    text: _isConfirmingBooking
                                        ? 'Подтверждаем...'
                                        : _bookingStatus == 'pending'
                                            ? 'Подтвердить бронь'
                                            : _bookingStatus == 'confirmed'
                                                ? 'Уже подтверждена'
                                                : 'Подтверждение недоступно',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 48.0,
                                      color: _bookingStatus == 'confirmed'
                                          ? Color(0xFFB7BDC9)
                                          : Color(0xFF4CAF50),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                          ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FFButtonWidget(
                                    onPressed: _isConfirmingBooking ||
                                            _isRemovingBooking
                                        ? null
                                        : () async {
                                            await _removeBooking(context);
                                          },
                                    text: _isRemovingBooking
                                        ? 'Снимаем...'
                                        : 'Снять бронь',
                                    options: FFButtonOptions(
                                      width: double.infinity,
                                      height: 48.0,
                                      color: Color(0xFFE53935),
                                      textStyle: FlutterFlowTheme.of(context)
                                          .titleSmall
                                          .override(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            letterSpacing: 0.0,
                                          ),
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ].divide(SizedBox(width: 8.0)),
                            ),
                          ].divide(SizedBox(height: 8.0)),
                        ),
                      ].divide(SizedBox(height: 24.0)),
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
