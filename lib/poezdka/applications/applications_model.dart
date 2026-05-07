import '/components/new_tab_item/new_tab_item_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'applications_widget.dart' show ApplicationsWidget;
import 'package:flutter/material.dart';

class ApplicationsModel extends FlutterFlowModel<ApplicationsWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for NewTabItem component.
  late NewTabItemModel newTabItemModel1;
  // Model for NewTabItem component.
  late NewTabItemModel newTabItemModel2;
  // Model for NewTabItem component.
  late NewTabItemModel newTabItemModel3;

  @override
  void initState(BuildContext context) {
    newTabItemModel1 = createModel(context, () => NewTabItemModel());
    newTabItemModel2 = createModel(context, () => NewTabItemModel());
    newTabItemModel3 = createModel(context, () => NewTabItemModel());
  }

  @override
  void dispose() {
    newTabItemModel1.dispose();
    newTabItemModel2.dispose();
    newTabItemModel3.dispose();
  }
}
