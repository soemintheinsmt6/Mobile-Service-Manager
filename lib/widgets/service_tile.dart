import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:mobile_service_manager/models/service_item.dart';
import 'package:separated_row/separated_row.dart';

const _rowHeight = 35.0;
final _dividerColor = Colors.grey.shade300;
const _leftPadding = 8.0;

class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.item, required this.index});

  final ServiceItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final error = item.faults.map((e) => e.name).join(', ');
    final date =
        DateFormat('dd MMM yyyy').format(DateTime.parse(item.issueDate));
    final color = index % 2 == 0 ? Colors.grey.shade200 : Colors.white;

    return Container(
      height: _rowHeight,
      decoration: BoxDecoration(
        color: color,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: SeparatedRow(
          separatorBuilder: (BuildContext context, int index) => _vDivider(),
          children: [
            _Box(text: index.toString(), width: 50),
            _Box(
                text: item.invoiceId.toString(),
                width: 60,
                alignment: Alignment.centerLeft),
            _Cell(text: item.customerName, flex: 2),
            _Cell(text: item.phoneNumber.toString()),
            _Cell(
                text: '${item.brand.target?.name ?? ''} ${item.model}',
                flex: 2),
            _Cell(text: error, flex: 2),
            _Cell(text: item.simAndSd),
            _Cell(text: date),
            _Box(text: item.status, color: Colors.greenAccent),
            _Box(text: item.location, color: Colors.yellowAccent),
          ]),
    );
  }
}

Widget serviceHeader() {
  return Container(
    height: _rowHeight,
    decoration: BoxDecoration(
      color: Colors.lightBlue.shade300,
      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
    ),
    child: SeparatedRow(
        separatorBuilder: (BuildContext context, int index) => _vDivider(),
        children: const [
          _Box(text: 'No.', width: 50, isHeader: true),
          _Box(
              text: 'Invoice ID',
              width: 60,
              alignment: Alignment.centerLeft,
              isHeader: true),
          _Cell(text: 'Customer Name', flex: 2, isHeader: true),
          _Cell(text: 'Phone Number', isHeader: true),
          _Cell(text: 'Model', flex: 2, isHeader: true),
          _Cell(text: 'Error', flex: 2, isHeader: true),
          _Cell(text: 'SIM & SD', isHeader: true),
          _Cell(text: 'Date', isHeader: true),
          _Box(text: 'Status', color: Colors.transparent, isHeader: true),
          _Box(text: 'Delivery', color: Colors.transparent, isHeader: true),
        ]),
  );
}

class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isHeader;

  const _Cell({
    required this.text,
    this.flex = 1,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = isHeader ? kTextFieldTextStyle : kDefaultTextStyle;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.only(left: _leftPadding),
        child: Text(text,
            style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.text,
    this.color = Colors.transparent,
    this.width = 100,
    this.isHeader = false,
    this.alignment = Alignment.center,
  });

  final String text;
  final double width;
  final Color color;
  final bool isHeader;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final textStyle = isHeader ? kTextFieldTextStyle : kDefaultTextStyle;
    final padding = alignment == Alignment.center ? 0.0 : _leftPadding;

    return Container(
        padding: EdgeInsets.only(left: padding),
        width: width,
        height: _rowHeight,
        color: color,
        alignment: alignment,
        child: Text(text,
            style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis));
  }
}

Widget _vDivider() => Container(width: 1, color: _dividerColor);
