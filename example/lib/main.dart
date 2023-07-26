import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlutoGrid Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlutoGridExamplePage(),
    );
  }
}

/// PlutoGrid Example
//
/// For more examples, go to the demo web link on the github below.
class PlutoGridExamplePage extends StatefulWidget {
  const PlutoGridExamplePage({Key? key}) : super(key: key);

  @override
  State<PlutoGridExamplePage> createState() => _PlutoGridExamplePageState();
}

class _PlutoGridExamplePageState extends State<PlutoGridExamplePage> {
  TextEditingController getController(int i) {
    return controllers[i];
  }

  final List<TextEditingController> controllers = [
    TextEditingController(text: ''),
    TextEditingController(text: ''),
    TextEditingController(text: ''),
  ];

  final List<PlutoRow> rows = [
    PlutoRow(
      cells: {
        'id': PlutoCell(value: 'user1'),
        'name': PlutoCell(value: 'Mike'),
        'age': PlutoCell(value: 20),
        'grade': PlutoCell(value: '1A'),
        'role': PlutoCell(value: 'Programmer'),
        'job': PlutoCell(value: '001'),
        'position': PlutoCell(value: '444444444'),
        'joined': PlutoCell(value: '2021-01-01'),
        'working_time': PlutoCell(value: '09:00'),
        'salary': PlutoCell(value: 300),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: 'user2'),
        'name': PlutoCell(value: 'Jack'),
        'age': PlutoCell(value: 25),
        'grade': PlutoCell(value: '1B'),
        'role': PlutoCell(value: 'Designer'),
        'job': PlutoCell(value: '002'),
        'position': PlutoCell(value: '1111111111111'),
        'joined': PlutoCell(value: '2021-02-01'),
        'working_time': PlutoCell(value: '10:00'),
        'salary': PlutoCell(value: 400),
      },
    ),
    PlutoRow(
      cells: {
        'id': PlutoCell(value: 'user3'),
        'name': PlutoCell(value: 'Suzi'),
        'age': PlutoCell(value: 40),
        'grade': PlutoCell(value: '1B'),
        'role': PlutoCell(value: 'Owner'),
        'job': PlutoCell(value: '001'),
        'position': PlutoCell(value: '22222222'),
        'joined': PlutoCell(value: '2021-03-01'),
        'working_time': PlutoCell(value: '11:00'),
        'salary': PlutoCell(value: 700),
      },
    ),
  ];

  /// columnGroups that can group columns can be omitted.
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'Id', fields: ['id'], expandedColumn: true),
    PlutoColumnGroup(title: 'User information', fields: ['name', 'age']),
    PlutoColumnGroup(title: 'Status', children: [
      PlutoColumnGroup(title: 'A', fields: ['role'], expandedColumn: true),
      PlutoColumnGroup(title: 'Etc.', fields: ['joined', 'working_time']),
    ]),
  ];

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late final PlutoGridStateManager stateManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(15),
        child: PlutoGrid(
          columns: getColumns(),
          rows: rows,
          columnGroups: columnGroups,
          onLoaded: (PlutoGridOnLoadedEvent event) {
            stateManager = event.stateManager;
            stateManager.setShowColumnFilter(true);
          },
          onChanged: (PlutoGridOnChangedEvent event) {
            print(event);
          },
          configuration: const PlutoGridConfiguration(),
        ),
      ),
    );
  }

  Map<String, dynamic> items = {
    '001': 'Accountant',
    '002': 'Buyer',
    '003': 'Planner',
  };

  List<DropdownMenuItem<String>> _getSelectItems() {
    List<DropdownMenuItem<String>> retList = <DropdownMenuItem<String>>[];
    items.forEach((key, value) {
      DropdownMenuItem<String> item = DropdownMenuItem(
        value: key.toString().trim(),
        child: Text(
          key,
          softWrap: true,
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      );
      if (!retList.contains(item)) {
        retList.add(item);
      }
    });

    return retList;
  }

  getColumns() {
    final List<PlutoColumn> columns = <PlutoColumn>[
      PlutoColumn(
        title: 'Id',
        field: 'id',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Name',
        field: 'name',
        type: PlutoColumnType.text(),
      ),
      PlutoColumn(
        title: 'Grade',
        field: 'grade',
        type: PlutoColumnType.typeAhead(),
      ),
      PlutoColumn(
        title: 'Job',
        field: 'job',
        type: PlutoColumnType.advSelect(
          <String, String>{
            '001': 'Intern',
            '002': 'Trainee',
            '003': 'Engineer',
            '004': 'Sr. Engineer',
          },
          displayKey: false,
          delimiter: " | ",
        ),
      ),
      PlutoColumn(
          title: 'Position',
          field: 'position',
          type: PlutoColumnType.text(),
          renderer: (context) {
            return getRenderedWidget(context);
          }),
      PlutoColumn(
        title: 'Role',
        field: 'role',
        type: PlutoColumnType.select(<String>[
          'Programmer',
          'Designer',
          'Owner',
        ], enableColumnFilter: true),
      ),
      PlutoColumn(
        title: 'Joined',
        field: 'joined',
        type: PlutoColumnType.date(),
      ),
      PlutoColumn(
        title: 'Age',
        field: 'age',
        type: PlutoColumnType.number(),
      ),
      PlutoColumn(
        title: 'Working time',
        field: 'working_time',
        type: PlutoColumnType.time(),
      ),
      PlutoColumn(
        title: 'salary',
        field: 'salary',
        type: PlutoColumnType.currency(),
        footerRenderer: (rendererContext) {
          return PlutoAggregateColumnFooter(
            rendererContext: rendererContext,
            formatAsCurrency: true,
            type: PlutoAggregateColumnType.sum,
            format: '#,###',
            alignment: Alignment.center,
            titleSpanBuilder: (text) {
              return [
                const TextSpan(
                  text: 'Sum',
                  style: TextStyle(color: Colors.red),
                ),
                const TextSpan(text: ' : '),
                TextSpan(text: text),
              ];
            },
          );
        },
      ),
    ];

    return columns;
  }

  Widget getRenderedWidget(PlutoColumnRendererContext context) {
    int rowNum = context.rowIdx;
    final textController = getController(rowNum);
    return RepaintBoundary(
        child: Container(
          width: double.infinity,
      color: Colors.red,
      child: Focus(
        child: TextFormField(
          keyboardType: TextInputType.text,
          controller: textController,
        ),
      ),
    ));

    return DropdownButtonFormField(
        items: _getSelectItems(),
        isExpanded: true,
        value: textController.text,
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        icon: Icon(Icons.arrow_drop_down),
        onChanged: (newValue) {
          textController.text = newValue.toString();
        });
  }
}
