import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:intl/intl.dart';

class InvestmentPieChart extends StatelessWidget {
  // Cores para cada tipo de investimento
  final Map<String, Color> investmentColors = {
    'Ações': AppColors.darkTeal,
    'Tesouro Direto': Colors.blue[400]!,
    'Fundos Imobiliários': Colors.green[600]!,
    'CDB': Colors.amber[600]!,
    'Criptomoedas': Colors.purple[400]!,
  };

  // Valores aleatórios para cada tipo de investimento
  final Map<String, double> investmentValues = {
    'Ações': _randomValue(),
    'Tesouro Direto': _randomValue(),
    'Fundos Imobiliários': _randomValue(),
    'CDB': _randomValue(),
    'Criptomoedas': _randomValue(),
  };

  // Gera um valor aleatório entre 1000 e 10000
  static double _randomValue() {
    return (1000 + (9000 * (DateTime.now().microsecond / 1000000)))
        .roundToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final totalInvested = investmentValues.values.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Distribuição dos Investimentos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        _buildPieChart(),
        _buildInvestmentCards(totalInvested),
      ],
    );
  }

  Widget _buildPieChart() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Column(
          children: [
            Text(
              'Tipos de Investimento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.greyPlaceholder,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _buildPieSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  startDegreeOffset: 180,
                ),
              ),
            ),
            SizedBox(height: 10),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    return investmentValues.entries.map((entry) {
      final color = investmentColors[entry.key]!;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title:
            '${(entry.value / investmentValues.values.reduce((a, b) => a + b) * 100).toStringAsFixed(1)}%',
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 60,
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children:
          investmentColors.entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 12, height: 12, color: entry.value),
                SizedBox(width: 4),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.greyPlaceholder,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  Widget _buildInvestmentCards(double totalInvested) {
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      padding: EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'Total Investido',
          formatador.format(totalInvested),
          AppColors.darkTeal,
        ),
        _buildSummaryCard(
          'Maior Investimento',
          formatador.format(
            investmentValues.values.reduce((a, b) => a > b ? a : b),
          ),
          Colors.blue[600]!,
        ),
        _buildSummaryCard(
          'Menor Investimento',
          formatador.format(
            investmentValues.values.reduce((a, b) => a < b ? a : b),
          ),
          Colors.green[600]!,
        ),
        _buildSummaryCard(
          'Número de Tipos',
          investmentValues.length.toString(),
          Colors.purple[600]!,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Card(
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.greyPlaceholder,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
