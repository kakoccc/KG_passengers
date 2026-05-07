import '/components/new_tab_item/new_tab_item_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'profil_widget.dart' show ProfilWidget;
import 'package:flutter/material.dart';

class ProfilModel extends FlutterFlowModel<ProfilWidget> {
  ///  Local state fields for this page.

  bool isEditing = false;

  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataIvv = false;
  FFUploadedFile uploadedLocalFile_uploadDataIvv =
      FFUploadedFile(bytes: Uint8List.fromList([]), originalFilename: '');
  String uploadedFileUrl_uploadDataIvv = '';

  // State field(s) for Name widget.
  FocusNode? nameFocusNode;
  TextEditingController? nameTextController;
  String? Function(BuildContext, String?)? nameTextControllerValidator;
  // State field(s) for tel widget.
  FocusNode? telFocusNode;
  TextEditingController? telTextController;
  String? Function(BuildContext, String?)? telTextControllerValidator;
  // State field(s) for Email widget.
  FocusNode? emailFocusNode;
  TextEditingController? emailTextController;
  String? Function(BuildContext, String?)? emailTextControllerValidator;
  // State field(s) for TG widget.
  FocusNode? tgFocusNode;
  TextEditingController? tgTextController;
  String? Function(BuildContext, String?)? tgTextControllerValidator;
  // State field(s) for IMO widget.
  FocusNode? imoFocusNode;
  TextEditingController? imoTextController;
  String? Function(BuildContext, String?)? imoTextControllerValidator;
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
    nameFocusNode?.dispose();
    nameTextController?.dispose();

    telFocusNode?.dispose();
    telTextController?.dispose();

    emailFocusNode?.dispose();
    emailTextController?.dispose();

    tgFocusNode?.dispose();
    tgTextController?.dispose();

    imoFocusNode?.dispose();
    imoTextController?.dispose();

    newTabItemModel1.dispose();
    newTabItemModel2.dispose();
    newTabItemModel3.dispose();
  }
}
