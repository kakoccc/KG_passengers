import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'new_tab_item_model.dart';
export 'new_tab_item_model.dart';

class NewTabItemWidget extends StatefulWidget {
  const NewTabItemWidget({
    super.key,
    required this.index,
    required this.label,
    required this.icon,
    required this.onClickAction,
  });

  final int? index;
  final String? label;
  final Widget? icon;
  final Future Function()? onClickAction;

  @override
  State<NewTabItemWidget> createState() => _NewTabItemWidgetState();
}

class _NewTabItemWidgetState extends State<NewTabItemWidget> {
  late NewTabItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NewTabItemModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 5.0, 0.0, 5.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          if (FFAppState().currentTab == widget.index) {
            return;
          }
          FFAppState().currentTab = widget.index!;
          _model.updatePage(() {});
          await widget.onClickAction?.call();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: FFAppState().currentTab == widget.index
                ? Color(0x261976D2)
                : Colors.transparent,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100.0),
              topRight: Radius.circular(100.0),
              bottomLeft: Radius.circular(100.0),
              bottomRight: Radius.circular(100.0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(5.0),
                child: Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: FFAppState().currentTab == widget.index
                        ? Color(0xFF1976D2)
                        : Color(0xFFF0F1F5),
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional(0.0, 0.0),
                    child: widget.icon!,
                  ),
                ),
              ),
              if (FFAppState().currentTab == widget.index)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 16.0, 0.0),
                  child: Text(
                    valueOrDefault<String>(
                      widget.label,
                      'Text',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Inter',
                          color: Color(0xFF1C1C1C),
                          fontSize: 17.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
