import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/helper/platform_helper.dart';
import 'text_cell.dart';

class PlutoTypeAheadCell extends StatefulWidget implements TextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoTypeAheadCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    Key? key,
  }) : super(key: key);

  @override
  PlutoTypeAheadCellState createState() => PlutoTypeAheadCellState();
}

class PlutoTypeAheadCellState extends State<PlutoTypeAheadCell>
    with TextCellState<PlutoTypeAheadCell> {
  final _textController = TextEditingController();

  @override
  TextInputType get keyboardType => TextInputType.text;

  @override
  List<TextInputFormatter>? get inputFormatters => [];

  @override
  String get formattedValue =>
      widget.column.formattedValueForDisplayInEditing(widget.cell.value);

  @override
  void initState() {
    super.initState();

    widget.stateManager.setTextEditingController(_textController);

    _textController.text = formattedValue;

    _textController.addListener(() {
      _handleOnChanged(_textController.text.toString());
    });
  }

  void _changeValue() {
    if (formattedValue == _textController.text) {
      return;
    }

    widget.stateManager.changeCellValue(widget.cell, _textController.text);

    _textController.text = formattedValue;

    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: _textController.text.length),
    );
  }

  void _handleOnChanged(String value) {}

  void _handleOnComplete() {
    final old = _textController.text;

    _changeValue();

    _handleOnChanged(old);

    PlatformHelper.onMobile(() {
      widget.stateManager.setKeepFocus(false);
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _handleOnTap() {
    widget.stateManager.setKeepFocus(true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager.keepFocus) {
      cellFocus.requestFocus();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TypeAheadField(
            builder: (context, controller, focusNode) {
              return TextField(
                focusNode: cellFocus,
                controller: _textController,
                //readOnly: widget.column.checkReadOnly(widget.row, widget.cell),
                onChanged: _handleOnChanged,
                onEditingComplete: _handleOnComplete,
                onSubmitted: (_) => _handleOnComplete(),
                onTap: _handleOnTap,
                style: widget.stateManager.configuration.style.cellTextStyle,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 1,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                textAlignVertical: TextAlignVertical.center,
                textAlign: widget.column.textAlign.value,
              );
            },

            suggestionsCallback: (pattern) async {
              List<Map> suggestions = await widget
                  .column.type.typeAhead.suggestionsCallback
                  .call(pattern, widget.cell.row.sortIdx);
              return suggestions;
            },
            itemBuilder: (context, Map suggestion) {
              String value = suggestion.values.first.toString();
              return ListTile(
                title: Text(value),
              );
            },
            onSelected: (Map selectedValue) {
              if (selectedValue.keys.isEmpty) {
                return;
              }
              _updateSelectedValue(selectedValue);

              widget.stateManager
                  .changeCellValue(widget.cell, _textController.text);
              widget.column.type.typeAhead.onSuggestionSelected
                  .call(selectedValue, widget.cell.row.sortIdx);
            },
          ),
        ),
        SizedBox(
          width: 48 * widget.column.type.typeAhead.sizeScale,
          child: Transform.scale(
            scale: widget.column.type.typeAhead.sizeScale,
            child: IconButton(
              onPressed: () async {
                final selectedValue =
                    await widget.column.type.typeAhead.iconOnClick.call(widget.cell.row.sortIdx);

                if (selectedValue is Map && selectedValue.keys.isEmpty) {
                  return;
                }
                _updateSelectedValue(selectedValue);
                widget.stateManager
                    .changeCellValue(widget.cell, _textController.text);
                widget.column.type.typeAhead.onSuggestionSelected
                    .call(selectedValue, widget.cell.row.sortIdx);
              },
              icon: Icon(widget.column.type.typeAhead.popupIcon),
            ),
          ),
        ),
      ],
    );
  }

  void _updateSelectedValue(Map<dynamic, dynamic> selectedValue) {
    bool setDefaultValue = true;
    if (selectedValue.keys.first is Map) {
      if ((selectedValue.keys.first as Map)
          .containsKey("plutoFieldName")) {
        final keyName =
            selectedValue.keys.first["plutoFieldName"].toString();
        _textController.text =
            selectedValue.keys.first[keyName].toString();
        setDefaultValue = false;
      } else if ((selectedValue.keys.first as Map)
          .containsKey(widget.column.field)) {
        _textController.text =
            selectedValue.keys.first[widget.column.field].toString();
        setDefaultValue = false;
      }
    }
    if (setDefaultValue) {
      _textController.text = selectedValue.keys.first.toString();
    }
  }
}

enum _CellEditingStatus {
  changed,
  updated;

  bool get isNotChanged {
    return _CellEditingStatus.changed != this;
  }

  bool get isChanged {
    return _CellEditingStatus.changed == this;
  }

  bool get isUpdated {
    return _CellEditingStatus.updated == this;
  }
}
