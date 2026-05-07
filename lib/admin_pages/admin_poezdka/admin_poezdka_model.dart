import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'admin_poezdka_widget.dart' show AdminPoezdkaWidget;
import 'package:flutter/material.dart';

class AdminPoezdkaModel extends FlutterFlowModel<AdminPoezdkaWidget> {
  ///  Local state fields for this page.

  DateTime? selectedDate;

  DateTime? selectedTime;

  ///  State fields for stateful widgets in this page.

  // State field(s) for city_from widget.
  String? cityFromValue;
  FormFieldController<String>? cityFromValueController;
  // State field(s) for city_to widget.
  String? cityToValue;
  FormFieldController<String>? cityToValueController;
  DateTime? datePicked1;
  DateTime? datePicked2;
  // State field(s) for Cars widget.
  String? carsValue;
  FormFieldController<String>? carsValueController;
  // State field(s) for seats_input widget.
  FocusNode? seatsInputFocusNode;
  TextEditingController? seatsInputTextController;
  String? Function(BuildContext, String?)? seatsInputTextControllerValidator;
  // State field(s) for price_input widget.
  FocusNode? priceInputFocusNode;
  TextEditingController? priceInputTextController;
  String? Function(BuildContext, String?)? priceInputTextControllerValidator;
  // State field(s) for note_input widget.
  FocusNode? noteInputFocusNode;
  TextEditingController? noteInputTextController;
  String? Function(BuildContext, String?)? noteInputTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    seatsInputFocusNode?.dispose();
    seatsInputTextController?.dispose();

    priceInputFocusNode?.dispose();
    priceInputTextController?.dispose();

    noteInputFocusNode?.dispose();
    noteInputTextController?.dispose();
  }
}
