import 'package:flutter/material.dart';
import 'package:mobile_service_manager/models/daily_revenue.dart';
import 'package:mobile_service_manager/utils/extension.dart';
import '../constants/app_colors.dart';

class RevenueCard extends StatelessWidget {
  const RevenueCard({super.key, required this.revenue});

  final DailyRevenue revenue;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                    revenue.formattedDate,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryButton,
                        ),
                  ),
                  Text(
                    'Total: ${revenue.totalServiceItemCount}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryButton,
                        ),
                  ),
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
            const SizedBox(height: 16),

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
            const SizedBox(height: 16),

            // Financial Summary
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                'Financial Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                    'Profit',
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
            count.toString(),
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
