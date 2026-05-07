import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'update_password_widget.dart' show UpdatePasswordWidget;
import 'package:flutter/material.dart';

class UpdatePasswordModel extends FlutterFlowModel<UpdatePasswordWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for resetpassword widget.
  FocusNode? resetpasswordFocusNode;
  TextEditingController? resetpasswordTextController;
  late bool resetpasswordVisibility;
  String? Function(BuildContext, String?)? resetpasswordTextControllerValidator;
  // State field(s) for resetpassword2 widget.
  FocusNode? resetpassword2FocusNode;
  TextEditingController? resetpassword2TextController;
  late bool resetpassword2Visibility;
  String? Function(BuildContext, String?)?
      resetpassword2TextControllerValidator;

  @override
  void initState(BuildContext context) {
    resetpasswordVisibility = false;
    resetpassword2Visibility = false;
  }

  @override
  void dispose() {
    resetpasswordFocusNode?.dispose();
    resetpasswordTextController?.dispose();

    resetpassword2FocusNode?.dispose();
    resetpassword2TextController?.dispose();
  }
}
