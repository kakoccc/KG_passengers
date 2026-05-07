import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'auth_redirect_widget.dart' show AuthRedirectWidget;
import 'package:flutter/material.dart';

class AuthRedirectModel extends FlutterFlowModel<AuthRedirectWidget> {
  ///  Local state fields for this page.

  double loadProgress = 0.0;

  String userRole = 'loading';

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in AuthRedirect widget.
  List<UsersRow>? currentUserRow;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
