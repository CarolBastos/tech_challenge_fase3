import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tech_challenge_fase3/app_colors.dart';
import 'package:tech_challenge_fase3/provider/transaction_provider.dart';
import 'package:tech_challenge_fase3/models/transaction_model.dart';

class TransactionChartSummary extends StatelessWidget {
  final Map<String, Color> tipoCores = {
    'Depósito': AppColors.darkTeal,
    'Saque': Colors.red[400]!,
    'Transferência': Colors.amber[600]!,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.darkTeal),
          );
        }

        if (provider.transactions.isEmpty) {
          return Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Nenhuma transação encontrada',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.greyPlaceholder,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final resumo = _calcularResumo(provider.transactions);
        final dadosGrafico = _processarDadosGrafico(provider.transactions);

        return ListView(
          // Substituído SingleChildScrollView por ListView
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Visão Geral das Transações',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            _buildChart(dadosGrafico),
            _buildSummaryCards(
              resumo,
            ), // GridView agora está dentro de um ListView
          ],
        );
      },
    );
  }

  Widget _buildChart(DadosGrafico dados) {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Transações por Tipo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.greyPlaceholder,
              ),
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = dados.dates[value.toInt()];
                          return SideTitleWidget(
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: TextStyle(
                                color: AppColors.greyPlaceholder,
                                fontSize: 10,
                              ),
                            ),
                            space: 4,
                            meta: meta,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    _buildLineData(
                      'Depósito',
                      dados.depositos,
                      tipoCores['Depósito']!,
                    ),
                    _buildLineData('Saque', dados.saques, tipoCores['Saque']!),
                    _buildLineData(
                      'Transferência',
                      dados.transferencias,
                      tipoCores['Transferência']!,
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final tipo =
                              spot.barIndex == 0
                                  ? 'Depósito'
                                  : spot.barIndex == 1
                                  ? 'Saque'
                                  : 'Transferência';
                          return LineTooltipItem(
                            '$tipo: R\$ ${spot.y.toStringAsFixed(2)}',
                            TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                  ),
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

  LineChartBarData _buildLineData(
    String tipo,
    List<double> valores,
    Color cor,
  ) {
    return LineChartBarData(
      spots:
          valores.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value);
          }).toList(),
      isCurved: true,
      color: cor,
      barWidth: 2,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(show: false),
      dotData: FlDotData(show: false),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          tipoCores.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
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
              ),
            );
          }).toList(),
    );
  }

  Widget _buildSummaryCards(Map<String, double> resumo) {
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return GridView.count(
      shrinkWrap: true, // Permite que o GridView se ajuste ao conteúdo
      physics:
          NeverScrollableScrollPhysics(), // Desativa a rolagem interna do GridView
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      padding: EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildSummaryCard(
          'Total de Transações',
          resumo['count']?.toInt().toString() ?? '0',
          AppColors.darkTeal,
        ),
        _buildSummaryCard(
          'Total Depositado',
          formatador.format(resumo['deposito'] ?? 0),
          Colors.green[600]!,
        ),
        _buildSummaryCard(
          'Total Sacado',
          formatador.format(resumo['saque'] ?? 0),
          Colors.red[400]!,
        ),
        _buildSummaryCard(
          'Maior Transação',
          formatador.format(resumo['maior'] ?? 0),
          Colors.amber[700]!,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return SizedBox(
      // Define um tamanho fixo para o card
      width: 150, // Largura fixa
      height: 120, // Altura fixa
      child: Card(
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
      ),
    );
  }

  Map<String, double> _calcularResumo(List<TransactionModel> transactions) {
    double deposito = 0;
    double saque = 0;
    double maior = 0;

    for (final t in transactions) {
      final valor = t.valor;
      if (t.tipo == 'Depósito') {
        deposito += valor;
      } else {
        saque += valor;
      }
      if (valor > maior) maior = valor;
    }

    return {
      'count': transactions.length.toDouble(),
      'deposito': deposito,
      'saque': saque,
      'maior': maior,
    };
  }

  DadosGrafico _processarDadosGrafico(List<TransactionModel> transactions) {
    final Map<DateTime, Map<String, double>> dados = {};

    // Agrupa as transações por data e tipo
    for (final t in transactions) {
      final date = DateTime(t.data.year, t.data.month, t.data.day);
      if (!dados.containsKey(date)) {
        dados[date] = {'Depósito': 0, 'Saque': 0, 'Transferência': 0};
      }
      dados[date]![t.tipo] = dados[date]![t.tipo]! + t.valor.abs();
    }

    // Ordena as datas
    final dates = dados.keys.toList()..sort();

    // Extrai os valores para cada tipo
    final depositos = dates.map((date) => dados[date]!['Depósito']!).toList();
    final saques = dates.map((date) => dados[date]!['Saque']!).toList();
    final transferencias =
        dates.map((date) => dados[date]!['Transferência']!).toList();

    return DadosGrafico(
      dates: dates,
      depositos: depositos,
      saques: saques,
      transferencias: transferencias,
    );
  }
}

class DadosGrafico {
  final List<DateTime> dates;
  final List<double> depositos;
  final List<double> saques;
  final List<double> transferencias;

  DadosGrafico({
    required this.dates,
    required this.depositos,
    required this.saques,
    required this.transferencias,
  });
}
