import 'package:flutter/material.dart';
import 'package:mobile_service_manager/constants/constants.dart';
import 'package:mobile_service_manager/models/service_item.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import 'package:mobile_service_manager/utils/utils.dart';
import 'package:separated_row/separated_row.dart';

const _rowHeight = 35.0;
final _dividerColor = Colors.grey.shade300;
const _leftPadding = 8.0;

class ServiceTile extends StatelessWidget {
  const ServiceTile({
    super.key,
    required this.item,
    required this.index,
    this.onTap,
  });

  final ServiceItem item;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = index % 2 == 0 ? Colors.white : Colors.grey.shade200;
    final phoneNumber =
        item.phoneNumber == 0 ? '' : item.phoneNumber.toString();
    final error = item.faults.map((e) => e.name).join(', ');
    final issueDate = item.issueDate.formattedDate;
    final deliveryDate =
        item.deliveryDate == null ? '' : item.deliveryDate!.formattedDate;

    return InkWell(
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        height: _rowHeight,
        decoration: BoxDecoration(
          color: color,
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: SeparatedRow(
            separatorBuilder: (BuildContext context, int index) => _vDivider(),
            children: [
              _Box(text: (index + 1).toString(), width: 40),
              _Box(
                  text: item.invoiceId.toString(),
                  width: 88,
                  alignment: Alignment.centerLeft),
              _Cell(text: item.customerName, flex: 2),
              _Cell(text: phoneNumber),
              _Cell(
                  text: '${item.brand.target?.name ?? ''} ${item.model}',
                  flex: 2),
              _Cell(text: error, flex: 2),
              _Cell(text: item.simAndSd),
              _Cell(text: issueDate, isCenter: true),
              _Box(text: translate(item.status), color: setColor(item.status)),
              _Box(
                  text: translate(item.location),
                  color: setColor(item.location)),
              _Box(text: deliveryDate, color: Colors.grey.shade200),
            ]),
      ),
    );
  }
}

Widget serviceHeader() {
  return Container(
    height: _rowHeight,
    decoration: BoxDecoration(
      color: const Color(0xFF4372C4),
      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
    ),
    child: SeparatedRow(
        separatorBuilder: (BuildContext context, int index) => _vDivider(),
        children: const [
          _Box(text: 'No.', width: 40, isHeader: true),
          _Box(
              text: 'Invoice ID',
              width: 88,
              alignment: Alignment.centerLeft,
              isHeader: true),
          _Cell(text: 'Name', flex: 2, isHeader: true),
          _Cell(text: 'Phone No.', isHeader: true),
          _Cell(text: 'Model', flex: 2, isHeader: true),
          _Cell(text: 'Error', flex: 2, isHeader: true),
          _Cell(text: 'SIM & SD', isHeader: true),
          _Cell(text: 'Date', isCenter: true, isHeader: true),
          _Box(text: 'Status', isHeader: true),
          _Box(text: 'Delivery', isHeader: true),
          _Box(text: 'Delivery Date', isHeader: true),
        ]),
  );
}

class _Cell extends StatelessWidget {
  final String text;
  final int flex;
  final bool isCenter;
  final bool isHeader;

  const _Cell({
    required this.text,
    this.flex = 1,
    this.isCenter = false,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = isHeader
        ? kBodyTextStyle.copyWith(
            color: Colors.white, fontWeight: FontWeight.w600)
        : kDefaultTextStyle;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.only(left: isCenter ? 0.0 : _leftPadding),
        child: Text(text,
            style: textStyle,
            textAlign: isCenter ? TextAlign.center : TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
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
    final textStyle = isHeader
        ? kBodyTextStyle.copyWith(
            color: Colors.white, fontWeight: FontWeight.w600)
        : kDefaultTextStyle;
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
