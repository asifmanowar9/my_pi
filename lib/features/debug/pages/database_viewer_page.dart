import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/database/database_inspector.dart';

class DatabaseViewerPage extends StatefulWidget {
  const DatabaseViewerPage({super.key});

  @override
  State<DatabaseViewerPage> createState() => _DatabaseViewerPageState();
}

class _DatabaseViewerPageState extends State<DatabaseViewerPage> {
  final DatabaseInspector _inspector = DatabaseInspector();
  List<String> _tables = [];
  String? _selectedTable;
  List<Map<String, dynamic>> _tableData = [];
  List<Map<String, dynamic>> _tableSchema = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    setState(() => _isLoading = true);
    try {
      final tables = await _inspector.getTableNames();
      setState(() {
        _tables = tables;
        if (tables.isNotEmpty && _selectedTable == null) {
          _selectedTable = tables.first;
          _loadTableData();
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tables: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTableData() async {
    if (_selectedTable == null) return;

    setState(() => _isLoading = true);
    try {
      final data = await _inspector.getTableData(_selectedTable!);
      final schema = await _inspector.getTableSchema(_selectedTable!);
      setState(() {
        _tableData = data;
        _tableSchema = schema;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load table data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _insertSampleData() async {
    setState(() => _isLoading = true);
    try {
      await _inspector.insertSampleData();
      await _loadTableData();
      Get.snackbar('Success', 'Sample data inserted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to insert sample data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllData() async {
    final confirmed =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'Are you sure you want to clear all data from the database? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Clear'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      setState(() => _isLoading = true);
      try {
        await _inspector.clearAllData();
        await _loadTableData();
        Get.snackbar('Success', 'All data cleared successfully');
      } catch (e) {
        Get.snackbar('Error', 'Failed to clear data: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Viewer'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadTables),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Insert Sample Data'),
                onTap: _insertSampleData,
              ),
              PopupMenuItem(
                child: const Text('Clear All Data'),
                onTap: _clearAllData,
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Table selector
                Container(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: _selectedTable,
                    decoration: const InputDecoration(
                      labelText: 'Select Table',
                      border: OutlineInputBorder(),
                    ),
                    items: _tables.map((table) {
                      return DropdownMenuItem(value: table, child: Text(table));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedTable = value);
                      _loadTableData();
                    },
                  ),
                ),

                // Table info
                if (_selectedTable != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'Table: $_selectedTable',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Rows: ${_tableData.length}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Schema section
                if (_tableSchema.isNotEmpty) ...[
                  ExpansionTile(
                    title: const Text('Table Schema'),
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Column')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Not Null')),
                            DataColumn(label: Text('Primary Key')),
                          ],
                          rows: _tableSchema.map((column) {
                            return DataRow(
                              cells: [
                                DataCell(Text(column['name'] ?? '')),
                                DataCell(Text(column['type'] ?? '')),
                                DataCell(
                                  Text(column['notnull'] == 1 ? 'Yes' : 'No'),
                                ),
                                DataCell(
                                  Text(column['pk'] == 1 ? 'Yes' : 'No'),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],

                // Data section
                Expanded(
                  child: _tableData.isEmpty
                      ? const Center(
                          child: Text(
                            'No data found in this table',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: _tableData.isNotEmpty
                                  ? _tableData.first.keys.map((key) {
                                      return DataColumn(
                                        label: Text(
                                          key,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList()
                                  : [],
                              rows: _tableData.map((row) {
                                return DataRow(
                                  cells: row.values.map((value) {
                                    return DataCell(
                                      Container(
                                        constraints: const BoxConstraints(
                                          maxWidth: 150,
                                        ),
                                        child: Text(
                                          value?.toString() ?? 'null',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
