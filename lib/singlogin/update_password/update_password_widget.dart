import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'update_password_model.dart';
export 'update_password_model.dart';

class UpdatePasswordWidget extends StatefulWidget {
  const UpdatePasswordWidget({super.key});

  static String routeName = 'UpdatePassword';
  static String routePath = '/updatePassword';

  @override
  State<UpdatePasswordWidget> createState() => _UpdatePasswordWidgetState();
}

class _UpdatePasswordWidgetState extends State<UpdatePasswordWidget> {
  late UpdatePasswordModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isUpdatingPassword = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UpdatePasswordModel());

    _model.resetpasswordTextController ??= TextEditingController();
    _model.resetpasswordFocusNode ??= FocusNode();

    _model.resetpassword2TextController ??= TextEditingController();
    _model.resetpassword2FocusNode ??= FocusNode();
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
        backgroundColor: Color(0xFFF0F1F5),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.0, 25.0, 16.0, 25.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                  child: Text(
                    'Восстановление пароля',
                    style: FlutterFlowTheme.of(context).displaySmall.override(
                          fontFamily: 'Inter',
                          color: FlutterFlowTheme.of(context).secondary,
                          fontSize: 24.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 370.0),
                    child: TextFormField(
                      controller: _model.resetpasswordTextController,
                      focusNode: _model.resetpasswordFocusNode,
                      autofocus: false,
                      enabled: true,
                      autofillHints: [AutofillHints.newPassword],
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                      obscureText: !_model.resetpasswordVisibility,
                      decoration: InputDecoration(
                        labelText: 'Введите новый пароль',
                        labelStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x00000000),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).tertiary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).tertiary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hoverColor: Colors.transparent,
                        suffixIcon: InkWell(
                          onTap: () async {
                            safeSetState(() => _model.resetpasswordVisibility =
                                !_model.resetpasswordVisibility);
                          },
                          focusNode: FocusNode(skipTraversal: false),
                          child: Icon(
                            _model.resetpasswordVisibility
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 15.0,
                          ),
                        ),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                      keyboardType: TextInputType.visiblePassword,
                      cursorColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      enableInteractiveSelection: false,
                      validator: _model.resetpasswordTextControllerValidator
                          .asValidator(context),
                      inputFormatters: [
                        if (!isAndroid && !isiOS)
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return TextEditingValue(
                              selection: newValue.selection,
                              text: newValue.text
                                  .toCapitalization(TextCapitalization.none),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: 370.0),
                    child: TextFormField(
                      controller: _model.resetpassword2TextController,
                      focusNode: _model.resetpassword2FocusNode,
                      autofocus: false,
                      enabled: true,
                      autofillHints: [AutofillHints.newPassword],
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                      obscureText: !_model.resetpassword2Visibility,
                      decoration: InputDecoration(
                        labelText: 'Повторите новый пароль',
                        labelStyle:
                            FlutterFlowTheme.of(context).labelMedium.override(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                                  fontSize: 16.0,
                                  letterSpacing: 0.0,
                                ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x00000000),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).tertiary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).tertiary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        hoverColor: Colors.transparent,
                        suffixIcon: InkWell(
                          onTap: () async {
                            safeSetState(() => _model.resetpassword2Visibility =
                                !_model.resetpassword2Visibility);
                          },
                          focusNode: FocusNode(skipTraversal: false),
                          child: Icon(
                            _model.resetpassword2Visibility
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            size: 15.0,
                          ),
                        ),
                      ),
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.inter(
                              fontWeight: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontWeight,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .fontStyle,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                      keyboardType: TextInputType.visiblePassword,
                      cursorColor:
                          FlutterFlowTheme.of(context).secondaryBackground,
                      enableInteractiveSelection: false,
                      validator: _model.resetpassword2TextControllerValidator
                          .asValidator(context),
                      inputFormatters: [
                        if (!isAndroid && !isiOS)
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            return TextEditingValue(
                              selection: newValue.selection,
                              text: newValue.text
                                  .toCapitalization(TextCapitalization.none),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
                FFButtonWidget(
                  onPressed: _isUpdatingPassword
                      ? null
                      : () async {
                          final password =
                              _model.resetpasswordTextController.text.trim();
                          final passwordRepeat =
                              _model.resetpassword2TextController.text.trim();

                          if (!loggedIn) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Ссылка для сброса пароля устарела. Запросите новую ссылку.',
                                ),
                                backgroundColor: Color(0xFFFFDADA),
                              ),
                            );
                            context.goNamed(
                              RecoveryWidget.routeName,
                              extra: <String, dynamic>{
                                '__transition_info__': TransitionInfo(
                                  hasTransition: true,
                                  transitionType: PageTransitionType.fade,
                                  duration: Duration(milliseconds: 0),
                                ),
                              },
                            );
                            return;
                          }
                          if (password.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Новый пароль должен быть не короче 6 символов.',
                                ),
                                backgroundColor: Color(0xFFFFDADA),
                              ),
                            );
                            return;
                          }
                          if (password != passwordRepeat) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Пароли не совпадают.'),
                                backgroundColor: Color(0xFFFFDADA),
                              ),
                            );
                            return;
                          }

                          setState(() => _isUpdatingPassword = true);
                          final passwordUpdated =
                              await authManager.updatePassword(
                            newPassword: password,
                            context: context,
                          );
                          if (!context.mounted) {
                            return;
                          }
                          setState(() => _isUpdatingPassword = false);
                          if (!passwordUpdated) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Пароль успешно изменён. Войдите с новым паролем.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18.0,
                                ),
                              ),
                              duration: Duration(milliseconds: 3000),
                              backgroundColor: Color(0xFF106232),
                            ),
                          );

                          GoRouter.of(context).prepareAuthEvent(true);
                          await authManager.signOut();
                          if (!context.mounted) {
                            return;
                          }
                          GoRouter.of(context).clearRedirectLocation();
                          context.goNamedAuth(
                            LoginNewWidget.routeName,
                            context.mounted,
                            ignoreRedirect: true,
                          );
                        },
                  text: _isUpdatingPassword ? 'Сохраняем...' : 'Сбросить',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 50.0,
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: FlutterFlowTheme.of(context).primary,
                    textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          letterSpacing: 0.0,
                        ),
                    elevation: 3.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ].divide(SizedBox(height: 16.0)),
            ),
          ),
        ),
      ),
    );
  }
}
