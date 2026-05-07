import '/auth/supabase_auth/auth_util.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/ux_reliability.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'reviews_model.dart';
export 'reviews_model.dart';

class ReviewsWidget extends StatefulWidget {
  const ReviewsWidget({super.key});

  static String routeName = 'Reviews';
  static String routePath = '/reviews';

  @override
  State<ReviewsWidget> createState() => _ReviewsWidgetState();
}

class _ReviewsWidgetState extends State<ReviewsWidget> {
  static const Duration _reviewsQueryTimeout = Duration(seconds: 12);
  static List<ReviewsViewRow>? _cachedReviews;

  late ReviewsModel _model;
  late Future<List<ReviewsViewRow>> _reviewsFuture;
  double _selectedRating = 5.0;
  bool _submitInProgress = false;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _loadReviews() {
    _reviewsFuture = _queryReviewsWithCacheFallback();
  }

  Future<List<ReviewsViewRow>> _queryReviews() async {
    final rows = await ReviewsViewTable()
        .queryRows(
          queryFn: (q) => q.order('created_at', ascending: false),
        )
        .timeout(_reviewsQueryTimeout);
    _cachedReviews = rows;
    return rows;
  }

  Future<List<ReviewsViewRow>> _queryReviewsWithCacheFallback() async {
    try {
      return await _queryReviews();
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 350));
      try {
        return await _queryReviews();
      } catch (_) {
        final cachedReviews = _cachedReviews;
        if (cachedReviews != null) {
          return cachedReviews;
        }
        rethrow;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ReviewsModel());
    _loadReviews();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_submitInProgress) {
      return;
    }
    if (currentUserUid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Войдите в аккаунт, чтобы оставить отзыв')),
      );
      return;
    }
    if (!(_model.formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _submitInProgress = true);
    final existingReviews = await _reviewsFuture;
    if (!mounted) {
      return;
    }
    if (_currentUserReview(existingReviews) != null) {
      setState(() => _submitInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Вы уже оставили отзыв')),
      );
      return;
    }

    try {
      await ReviewsTable().insert({
        'user_id': currentUserUid,
        'rating': _selectedRating.round(),
        'title': _cleanNullable(_model.titleTextController.text),
        'comment': _model.commentTextController.text.trim(),
      });

      _model.titleTextController?.clear();
      _model.commentTextController?.clear();
      setState(() {
        _selectedRating = 5.0;
        _loadReviews();
      });
      if (!mounted) {
        return;
      }
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Спасибо, отзыв опубликован')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось сохранить отзыв. Проверьте текст и попробуйте еще раз')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitInProgress = false);
      }
    }
  }

  String? _cleanNullable(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  double _averageRating(List<ReviewsViewRow> reviews) {
    if (reviews.isEmpty) {
      return 0.0;
    }
    final total = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return total / reviews.length;
  }

  ReviewsViewRow? _currentUserReview(List<ReviewsViewRow> reviews) {
    if (currentUserUid.isEmpty) {
      return null;
    }

    for (final review in reviews) {
      if (review.userId == currentUserUid) {
        return review;
      }
    }
    return null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    return dateTimeFormat('d MMM y', date, locale: FFLocalizations.of(context).languageCode);
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
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _buildPageTitle(context),
                Flexible(
                  child: FutureBuilder<List<ReviewsViewRow>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return KgErrorState(
                          title: 'Отзывы не загрузились',
                          message: 'Проверьте подключение и попробуйте еще раз.',
                          onRetry: () => setState(_loadReviews),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: FlutterFlowTheme.of(context).primary,
                          ),
                        );
                      }

                      final reviews = snapshot.data!;
                      final averageRating = _averageRating(reviews);
                      final userReview = _currentUserReview(reviews);
                      final showReviewForm = currentUserUid.isNotEmpty && userReview == null;

                      return RefreshIndicator(
                        color: FlutterFlowTheme.of(context).primary,
                        onRefresh: () async {
                          setState(_loadReviews);
                          await _reviewsFuture;
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                          children: [
                            _buildHeader(context, reviews.length, averageRating),
                            if (showReviewForm) ...[
                              SizedBox(height: 16.0),
                              _buildReviewForm(context),
                            ],
                            if (reviews.isNotEmpty || !showReviewForm)
                              SizedBox(height: 18.0),
                            if (reviews.isEmpty && !showReviewForm)
                              KgEmptyState(
                                title: 'Отзывов пока нет',
                                message: 'Будьте первым, кто расскажет о поездке.',
                                icon: Icons.rate_review_outlined,
                              )
                            else
                              ...reviews.map((review) => Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                      0.0,
                                      0.0,
                                      0.0,
                                      12.0,
                                    ),
                                    child: _buildReviewCard(context, review),
                                  )),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageTitle(BuildContext context) {
    return Container(
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
              'Отзывы',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
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
    );
  }

  Widget _buildHeader(BuildContext context, int reviewsCount, double averageRating) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.primaryText,
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            color: Color(0x33000000),
            offset: Offset(0.0, 2.0),
            spreadRadius: 1.0,
          )
        ],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Отзывы',
                        style: theme.bodyMedium.override(
                          fontFamily: 'TTNormsPro',
                          color: Colors.white,
                          fontSize: 28.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6.0),
                      Text(
                        'Реальные впечатления пассажиров KG Pass',
                        style: theme.bodyMedium.override(
                          fontFamily: 'TTNormsPro',
                          color: Colors.white.withOpacity(0.82),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/2ce86a.png',
                  width: 96.0,
                  height: 72.0,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                _buildStatPill(
                  context,
                  value: reviewsCount.toString(),
                  label: 'Отзывы',
                ),
                SizedBox(width: 10.0),
                _buildStatPill(
                  context,
                  value: averageRating == 0 ? '0.0' : averageRating.toStringAsFixed(1),
                  label: 'Средний рейтинг',
                  icon: Icons.star_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(
    BuildContext context, {
    required String value,
    required String label,
    IconData? icon,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(14.0, 12.0, 14.0, 12.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'TTNormsPro',
                    color: Colors.white,
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (icon != null) ...[
                  SizedBox(width: 3.0),
                  Icon(icon, color: Color(0xFFFFC857), size: 22.0),
                ],
              ],
            ),
            SizedBox(height: 4.0),
            Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'TTNormsPro',
                color: Colors.white.withOpacity(0.82),
                fontSize: 11.0,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewForm(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 12.0,
            color: Color(0x14000000),
            offset: Offset(0.0, 6.0),
          )
        ],
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 16.0),
        child: Form(
          key: _model.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Оставьте отзыв',
                style: theme.bodyMedium.override(
                  fontFamily: 'TTNormsPro',
                  color: theme.primaryText,
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10.0),
              _buildRatingSelector(context),
              SizedBox(height: 12.0),
              TextFormField(
                controller: _model.titleTextController,
                focusNode: _model.titleFocusNode,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(context, 'Заголовок (необязательно)'),
                style: _inputTextStyle(context),
                cursorColor: FlutterFlowTheme.of(context).secondaryBackground,
                minLines: 1,
                maxLines: 1,
                maxLength: 80,
              ),
              SizedBox(height: 10.0),
              TextFormField(
                controller: _model.commentTextController,
                focusNode: _model.commentFocusNode,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(context, 'Расскажите о поездке'),
                style: _inputTextStyle(context),
                cursorColor: FlutterFlowTheme.of(context).secondaryBackground,
                minLines: 1,
                maxLines: 6,
                maxLength: 600,
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'Напишите текст отзыва';
                  }
                  if ((value ?? '').trim().length < 8) {
                    return 'Минимум 8 символов';
                  }
                  return null;
                },
              ),
              SizedBox(height: 12.0),
              FFButtonWidget(
                onPressed: _submitInProgress ? null : _submitReview,
                text: _submitInProgress ? 'Сохраняем...' : 'Опубликовать отзыв',
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 52.0,
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: theme.primary,
                  textStyle: theme.titleSmall.override(
                    font: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontStyle: theme.titleSmall.fontStyle,
                    ),
                    color: Colors.white,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                    fontStyle: theme.titleSmall.fontStyle,
                  ),
                  elevation: 0.0,
                  borderSide: BorderSide(color: Colors.transparent, width: 1.0),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String label) {
    final theme = FlutterFlowTheme.of(context);
    return InputDecoration(
      labelText: label,
      labelStyle: theme.labelMedium.override(
        fontFamily: 'Inter',
        color: theme.secondaryBackground,
        fontSize: 14.0,
        letterSpacing: 0.0,
      ),
      floatingLabelStyle: theme.labelMedium.override(
        fontFamily: 'Inter',
        color: theme.secondaryBackground,
        fontSize: 13.0,
        letterSpacing: 0.0,
      ),
      isDense: true,
      contentPadding: EdgeInsetsDirectional.fromSTEB(14.0, 14.0, 14.0, 14.0),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.tertiary, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: theme.tertiary, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      fillColor: theme.primaryBackground,
      hoverColor: Colors.transparent,
      counterText: '',
    );
  }

  TextStyle _inputTextStyle(BuildContext context) {
    return FlutterFlowTheme.of(context).bodyMedium.override(
          font: GoogleFonts.inter(
            fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
          ),
          letterSpacing: 0.0,
          fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
          fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
        );
  }

  Widget _buildRatingSelector(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final rating = index + 1;
        final selected = rating <= _selectedRating.round();
        return InkWell(
          borderRadius: BorderRadius.circular(18.0),
          onTap: () => setState(() => _selectedRating = rating.toDouble()),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
            child: Icon(
              Icons.star_rounded,
              color: selected ? Color(0xFFFFC857) : Color(0xFFE0E3E7),
              size: 34.0,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildReviewCard(BuildContext context, ReviewsViewRow review) {
    final theme = FlutterFlowTheme.of(context);
    final authorName = _cleanNullable(review.firstName) ?? 'Пассажир KG Pass';
    final title = _cleanNullable(review.title);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 12.0,
            color: Color(0x12000000),
            offset: Offset(0.0, 6.0),
          )
        ],
        borderRadius: BorderRadius.circular(22.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 14.0, 16.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(context, review.avatarUrl, authorName),
                SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodyMedium.override(
                          fontFamily: 'TTNormsPro',
                          color: theme.primaryText,
                          fontSize: 17.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3.0),
                      Text(
                        _formatDate(review.createdAt),
                        style: theme.bodyMedium.override(
                          fontFamily: 'Inter',
                          color: theme.secondaryText,
                          fontSize: 12.0,
                          letterSpacing: 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildRatingStars(review.rating, size: 19.0),
              ],
            ),
            if (title != null) ...[
              SizedBox(height: 14.0),
              Text(
                title,
                style: theme.bodyMedium.override(
                  fontFamily: 'TTNormsPro',
                  color: theme.primaryText,
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            SizedBox(height: 8.0),
            Text(
              review.comment,
              style: theme.bodyMedium.override(
                fontFamily: 'Inter',
                color: theme.secondary,
                fontSize: 14.0,
                letterSpacing: 0.0,
                lineHeight: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(int rating, {required double size}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          Icons.star_rounded,
          color: index < rating ? Color(0xFFFFC857) : Color(0xFFE0E3E7),
          size: size,
        );
      }),
    );
  }

  Widget _buildAvatar(BuildContext context, String? avatarUrl, String authorName) {
    final hasAvatar = kgHasUsableUrl(avatarUrl);

    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Color(0x22000000),
            offset: Offset(1.0, 1.0),
          )
        ],
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
      ),
      child: ClipOval(
        child: hasAvatar
            ? Image.network(
                avatarUrl!.trim(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _defaultAvatar(context),
              )
            : _defaultAvatar(context),
      ),
    );
  }

  Widget _defaultAvatar(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: FlutterFlowTheme.of(context).primaryBackground,
        alignment: AlignmentDirectional(0.0, 0.0),
        child: Icon(
          Icons.person_outline,
          color: FlutterFlowTheme.of(context).secondaryBackground,
          size: 22.0,
        ),
      ),
    );
  }

}
