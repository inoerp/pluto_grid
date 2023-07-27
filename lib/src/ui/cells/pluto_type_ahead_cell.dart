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

  void _handleOnChanged(String value) {
  }

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

    return SizedBox(
      height: 60,
      width: 276,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TypeAheadField(
              minCharsForSuggestions: 3,
              textFieldConfiguration: TextFieldConfiguration(
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
              ),
              suggestionsCallback: (pattern) async{

                //await Future.delayed(Duration(seconds: 2));
                List<Map> suggestions = [{"001": "1"},{ "002" : "2"}];
                suggestions = await widget.column.type.typeAhead.suggestionsCallback.call();
                return suggestions;
              },
              itemBuilder: (context, Map suggestion) {
                String value = suggestion.values.first.toString();
                return ListTile(
                  title: Text(value),
                );
              },
              onSuggestionSelected: (Map suggestion) {
                _textController.text = suggestion.values.first.toString();
                widget.column.type.typeAhead.onSuggestionSelected.call(suggestion);
                // isValueSelected = true;
                // widget.updateValuesForDeferredSelect.call(suggestion);
                // // Navigator.of(context).push(MaterialPageRoute(
                // //     builder: (context) => ProductPage(product: suggestion)
                // // ));
              },
            ),
          ),
          SizedBox(
            width: 48,
            child: IconButton(
              onPressed: () async {
                final suggestion = await widget.column.type.typeAhead.iconOnClick.call();
                _textController.text = suggestion.values.first.toString();
                _handleOnComplete();
                widget.column.type.typeAhead.onSuggestionSelected.call(suggestion);
              },
              icon: Icon( widget.column.type.typeAhead.popupIcon),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CellEditingStatus {
  init,
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
