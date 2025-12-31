import 'package:expenxo/utils/constands/colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 10,
              ),
              child: Container(
                height: 40,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Analytics & Reports',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.black),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.tune, color: Colors.black),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 1. Spending by Category (Pie Chart)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  _buildReportCard(
                    title: "Spending by Category",
                    subtitle: "Distribution of your expenses",
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 0,
                              sections: [
                                PieChartSectionData(
                                  color: const Color(0xFFE76F51),
                                  value: 40,
                                  radius: 80,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFF2A9D8F),
                                  value: 25,
                                  radius: 80,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFF264653),
                                  value: 15,
                                  radius: 80,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFE9C46A),
                                  value: 10,
                                  radius: 80,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: const Color(0xFFF4A261),
                                  value: 10,
                                  radius: 80,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildChartLegend(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Monthly Financial Trend (Bar Chart)
                  _buildReportCard(
                    title: "Monthly Financial Trend",
                    subtitle: "Income vs. expenses over the last 6 months",
                    child: Column(
                      children: [
                        const SizedBox(height: 200, child: _BarChartWidget()),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _indicator(const Color(0xFF00C9A7), "Income"),
                            const SizedBox(width: 20),
                            _indicator(const Color(0xFFF25C54), "Expenses"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. June Overview Summary
                  _buildReportCard(
                    title: "Financial Overview - June",
                    subtitle: "",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _statItem(
                          "Income",
                          "₹25000",
                          AppColors.mainColor,
                          Icons.arrow_upward,
                        ),
                        _statItem(
                          "Expenses",
                          "₹24500",
                          const Color(0xFFF25C54),
                          Icons.arrow_downward,
                        ),
                        _statItem(
                          "Net Savings",
                          "₹500",
                          AppColors.mainColor,
                          Icons.trending_up,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. AI Insights Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F9F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFB2EBE0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: AppColors.mainColor,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "AI Insights",
                              style: TextStyle(
                                color: AppColors.mainColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Great job managing your spending on transport this month! However, your shopping expenses have seen a 15% increase compared to last month. Consider setting a specific budget for discretionary spending to stay on track.",
                          style: TextStyle(
                            color: AppColors.mainColor,
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _insightAction("Review Categories"),
                        const SizedBox(height: 10),
                        _insightAction("Adjust Budget"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // UI Helpers
  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _statItem(String label, String amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _indicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _insightAction(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.mainColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.mainColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.mainColor),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,

      children: [
        _indicator(const Color(0xFFE76F51), ""),
        _indicator(const Color(0xFF2A9D8F), ""),
        _indicator(const Color(0xFF264653), ""),
        _indicator(const Color(0xFFE9C46A), ""),
        _indicator(const Color(0xFFF4A261), ""),
      ],
    );
  }
}

class _BarChartWidget extends StatelessWidget {
  const _BarChartWidget();
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 3000,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                return Text(
                  months[value.toInt()],
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          6,
          (i) => _buildGroup(
            i,
            (2000 + (i * 100)).toDouble(),
            (1500 + (i * 120)).toDouble(),
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildGroup(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: AppColors.mainColor,
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: expense,
          color: const Color(0xFFF25C54),
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
