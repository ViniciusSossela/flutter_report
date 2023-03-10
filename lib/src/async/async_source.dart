
import 'package:data_table_2/data_table_2.dart';

abstract class AsyncDataSource extends AsyncDataTableSource {
  AsyncDataSource();

  Future<int> getTotalRecords();

  void sort(String columnName, bool ascending);
}
