import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoSwitchFieldCell extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  final PlutoCell cell;

  final PlutoColumn column;

  final PlutoRow row;

  const PlutoSwitchFieldCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  PlutoSwitchFieldCellState createState() => PlutoSwitchFieldCellState();
}

class PlutoSwitchFieldCellState extends State<PlutoSwitchFieldCell> {
  final _textController = TextEditingController();
  String get formattedValue =>
      widget.column.formattedValueForDisplayInEditing(widget.cell.value);


  // void _handleOnTap() {
  //   widget.stateManager.setKeepFocus(true);
  // }

  @override
  void initState() {
    super.initState();
    widget.stateManager.setTextEditingController(_textController);
    _textController.text = formattedValue;
  }

  @override
  void dispose() {
    if (!widget.stateManager.isEditing ||
        widget.stateManager.currentColumn?.enableEditingMode != true) {
      widget.stateManager.setTextEditingController(null);
    }
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = _textController.text == "1" || _textController.text == "true"
        ? true
        : false;
    return Transform.scale(
      scale: widget.column.type.switchField.sizeScale,
      child: Switch(
          value: value,
          activeColor: Colors.green,
          onChanged: (bool newValue) {
            if (newValue == true) {
              _textController.text = "true";
            } else {
              _textController.text = "false";
            }
            widget.stateManager
                .changeCellValue(widget.cell, _textController.text);
            if (widget.column.type.switchField.onChanged != null) {
              widget.column.type.switchField.onChanged!
                  .call(_textController.text);
            }
            setState(() {

            });
          }),
    );
   }
}
