import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'recovery_widget.dart' show RecoveryWidget;
import 'package:flutter/material.dart';

class RecoveryModel extends FlutterFlowModel<RecoveryWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for emailreset widget.
  FocusNode? emailresetFocusNode;
  TextEditingController? emailresetTextController;
  String? Function(BuildContext, String?)? emailresetTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    emailresetFocusNode?.dispose();
    emailresetTextController?.dispose();
  }
}
