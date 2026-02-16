import 'package:flutter/material.dart';
import 'package:mobile_service_manager/data/models/revenue.dart';
import 'package:mobile_service_manager/core/utils/extension.dart';
import '../../core/constants/app_colors.dart';

class RevenueCard extends StatelessWidget {
  const RevenueCard({
    super.key,
    required this.title,
    required this.revenue,
  });

  final String title;
  final Revenue revenue;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with date and total count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryButton,
                        ),
                  ),
                  _totalItems(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Counts
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Service Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child:
                      _buildStatusCard('Done', revenue.doneCount, Colors.green),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusCard(
                      'In Progress', revenue.inProgressCount, Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusCard(
                      'Return', revenue.returnCount, Colors.red),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusCard(
                      'Free', revenue.freeCount, Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Location Counts
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Delivery Status',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                      'In Store', revenue.inStoreCount, Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusCard(
                      'Delivered', revenue.deliveredCount, Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Financial Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Financial Summary',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  if (revenue.priceTotal > 0) _profitMargin(),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  _buildFinancialRow(
                      'Total Income', revenue.priceTotal, Colors.green[700]!),
                  const Divider(),
                  _buildFinancialRow(
                      'Total Expense', revenue.expenseTotal, Colors.red[700]!),
                  const Divider(),
                  _buildFinancialRow(
                    'Net Profit',
                    revenue.profit,
                    revenue.profit >= 0 ? Colors.green[700]! : Colors.red[700]!,
                    isProfit: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalItems() {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[300]!, Colors.blue[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          'Total Items: ${revenue.totalServiceItemCount}',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ));
  }

  Widget _profitMargin() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: revenue.profit >= 0 ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: revenue.profit >= 0 ? Colors.green[300]! : Colors.red[300]!,
        ),
      ),
      child: Text(
        'Profit Margin: ${((revenue.profit / revenue.priceTotal) * 100).toStringAsFixed(2)}%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: revenue.profit >= 0 ? Colors.green[700] : Colors.red[700],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.formatted(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String title, int amount, Color color,
      {bool isProfit = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isProfit ? FontWeight.bold : FontWeight.w500,
            fontSize: isProfit ? 16 : 14,
          ),
        ),
        Text(
          '${amount >= 0 ? '+' : ''}${amount.toMMks()}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: isProfit ? 16 : 14,
          ),
        ),
      ],
    );
  }
}
