import '/flutter_flow/flutter_flow_util.dart';
import 'reviews_widget.dart' show ReviewsWidget;
import 'package:flutter/material.dart';

class ReviewsModel extends FlutterFlowModel<ReviewsWidget> {
  final formKey = GlobalKey<FormState>();
  FocusNode? titleFocusNode;
  FocusNode? commentFocusNode;
  TextEditingController? titleTextController;
  TextEditingController? commentTextController;

  @override
  void initState(BuildContext context) {
    titleTextController ??= TextEditingController();
    commentTextController ??= TextEditingController();
    titleFocusNode ??= FocusNode();
    commentFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    titleFocusNode?.dispose();
    commentFocusNode?.dispose();
    titleTextController?.dispose();
    commentTextController?.dispose();
  }
}
