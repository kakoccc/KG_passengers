import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'tripsdetails_widget.dart' show TripsdetailsWidget;
import 'package:flutter/material.dart';

class TripsdetailsModel extends FlutterFlowModel<TripsdetailsWidget> {
  ///  Local state fields for this page.

  int? selectedSeat;

  ///  State fields for stateful widgets in this page.

  // State field(s) for Checkbox widget.
  bool? checkboxValue;
  // State field(s) for user_comment widget.
  FocusNode? userCommentFocusNode;
  TextEditingController? userCommentTextController;
  String? Function(BuildContext, String?)? userCommentTextControllerValidator;
  // Stores action output result for [Backend Call - Query Rows] action in Container widget.
  List<BookingsRow>? checkExistingBooking;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    userCommentFocusNode?.dispose();
    userCommentTextController?.dispose();
  }
}
