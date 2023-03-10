import 'package:flutter/material.dart';

String getCurrentRouteOption(BuildContext context) {
  var isEmpty = ModalRoute.of(context) != null &&
          ModalRoute.of(context)!.settings.arguments != null &&
          ModalRoute.of(context)!.settings.arguments is String
      ? ModalRoute.of(context)!.settings.arguments as String
      : '';

  return isEmpty;
}

// Route options
const dflt = 'Default';
const noData = 'No data';
const autoRows = 'Auto rows';
const showBordersWithZebraStripes = 'Borders with Zebra';
const custPager = 'Custom pager';
const defaultSorting = 'Default sorting';
const selectAllPage = 'Select all at page';
const rowTaps = 'Row Taps';
const rowHeightOverrides = 'Row height overrides';
const fixedColumnWidth = 'Fixed column width';
const dataTable2 = 'DataTable2';
const paginatedFixedRowsCols = 'PaginatedDataTable2';
const asyncPaginatedFixedRowsCols = 'AsyncPaginatedDataTable2';

const asyncErrors = "Errors/Retries";

const goToLast = "Start at last page";

const Map<String, List<String>> routeOptions = {
  '/datatable2': [
    dflt,
    noData,
    showBordersWithZebraStripes,
    fixedColumnWidth,
    rowTaps,
    rowHeightOverrides
  ],
  '/paginated2': [dflt, noData, autoRows, custPager, defaultSorting],
  '/datatable2fixedmn': [
    dataTable2,
    paginatedFixedRowsCols,
    asyncPaginatedFixedRowsCols
  ],
  '/asyncpaginated2': [
    dflt,
    noData,
    selectAllPage,
    autoRows,
    asyncErrors,
    goToLast,
    custPager
  ],
};

List<String>? getOptionsForRoute(String route) {
  if (!routeOptions.containsKey(route)) {
    return null;
  }

  return routeOptions[route];
}
