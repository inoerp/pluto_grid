import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoAdvSelectCell extends StatefulWidget {
  final PlutoGridStateManager stateManager;

  final PlutoCell cell;

  final PlutoColumn column;

  final PlutoRow row;

  const PlutoAdvSelectCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  PlutoAdvSelectCellState createState() => PlutoAdvSelectCellState();
}

class PlutoAdvSelectCellState extends State<PlutoAdvSelectCell> {
  final _textController = TextEditingController();
  String get formattedValue =>
      widget.column.formattedValueForDisplayInEditing(widget.cell.value);

  IconData? get icon => widget.column.type.advSelect.popupIcon;
  late final List<DropdownMenuItem<String>> _selectItems;

  @override
  void initState() {
    super.initState();
    widget.stateManager.setTextEditingController(_textController);
    _textController.text = formattedValue;
    _selectItems = _getSelectItems();
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
    bool valueExists = false;
    for (var element in _selectItems) {
      if (element.value == _textController.text) {
        valueExists = true;
      }
    }
    if (_selectItems.isEmpty || !valueExists) {
      _textController.text = " ";
    }
    return DropdownButtonFormField(
        items: _selectItems,
        isExpanded: true,
        //onTap: _handleOnTap,
        value: _textController.text,
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        icon: Icon(widget.column.type.advSelect.popupIcon),
        onChanged: (newValue) {
          _textController.text = newValue.toString();
          widget.stateManager
              .changeCellValue(widget.cell, _textController.text);
        });
  }

  List<DropdownMenuItem<String>> _getSelectItems() {
    List<DropdownMenuItem<String>> retList = <DropdownMenuItem<String>>[];
    bool addEmptyRow = true;
    widget.column.type.advSelect.items.forEach((key, value) {
      if (value == " ") {
        addEmptyRow = false;
      }
      DropdownMenuItem<String> item = DropdownMenuItem(
        key: Key("$key-${value.toString()}"),
        value: key.toString().trim(),
        child: Text(
          getLabel(key, value.toString()),
          softWrap: true,
          maxLines: 1,
          style: widget.stateManager.configuration.style.cellTextStyle,
        ),
      );
      if (!retList.contains(item)) {
        retList.add(item);
      }
    });

    if (retList.isEmpty) {
      DropdownMenuItem<String> item = DropdownMenuItem(
        key: const Key("no-value-found"),
        value: "no-value-found",
        child: Text(
          "No value found",
          softWrap: true,
          maxLines: 1,
          style: widget.stateManager.configuration.style.cellTextStyle,
        ),
      );
      retList.add(item);
    } else if (addEmptyRow) {
      //add an empty row
      DropdownMenuItem<String> item = DropdownMenuItem(
        key: const Key("no-value-found"),
        value: " ",
        child: Text(
          " ",
          softWrap: true,
          maxLines: 1,
          style: widget.stateManager.configuration.style.cellTextStyle,
        ),
      );
      retList.add(item);
    }

    return retList;
  }

  String getLabel(String key, String value) {
    if (widget.column.type.advSelect.displayKey) {
      return "$key${widget.column.type.advSelect.delimiter}$value";
    } else {
      return value;
    }
  }
}
