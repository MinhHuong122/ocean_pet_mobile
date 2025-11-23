// lib/widgets/health_score_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/health_score_service.dart';

class HealthScoreCard extends StatelessWidget {
  final int healthScore;
  final List<String> recommendations;
  final VoidCallback? onViewDetails;

  const HealthScoreCard({
    Key? key,
    required this.healthScore,
    required this.recommendations,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scoreInfo = HealthScoreService.getHealthScoreInfo(healthScore);
    final scoreColor = Color(scoreInfo['color'] as int);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scoreColor.withOpacity(0.1),
              scoreColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Điểm Sức Khỏe',
                        style: GoogleFonts.afacad(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '$healthScore',
                            style: GoogleFonts.afacad(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/100',
                            style: GoogleFonts.afacad(
                              fontSize: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Circular progress
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        // Background circle
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 8,
                              ),
                            ),
                          ),
                        ),
                        // Progress circle
                        Center(
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value: healthScore / 100,
                              strokeWidth: 8,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(scoreColor),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        // Center text
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                scoreInfo['level'],
                                style: GoogleFonts.afacad(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                scoreInfo['icon'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scoreInfo['description'],
                  style: GoogleFonts.afacad(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recommendations
              Text(
                'Khuyến nghị',
                style: GoogleFonts.afacad(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: recommendations
                    .take(3)
                    .map(
                      (recommendation) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: scoreColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: GoogleFonts.afacad(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (recommendations.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '+${recommendations.length - 3} khuyến nghị khác',
                    style: GoogleFonts.afacad(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (onViewDetails != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scoreColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Xem Chi Tiết',
                      style: GoogleFonts.afacad(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget hiển thị Health Score chi tiết với biểu đồ
class HealthScoreDetailChart extends StatelessWidget {
  final int healthScore;
  final double weight;
  final double idealWeight;
  final int vaccinationCount;
  final bool teethHealthy;
  final int medicalHistoryCount;
  final int allergyCount;

  const HealthScoreDetailChart({
    Key? key,
    required this.healthScore,
    required this.weight,
    required this.idealWeight,
    required this.vaccinationCount,
    required this.teethHealthy,
    required this.medicalHistoryCount,
    required this.allergyCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tính toán các chỉ số thành phần
    final vaccinationScore = _calculateVaccinationScore();
    final teethScore = teethHealthy ? 100.0 : 50.0;
    final medicalScore =
        _calculateMedicalScore(medicalHistoryCount, allergyCount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bar chart
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          'Tiêm chủng',
                          'Răng',
                          'Y tế',
                        ];
                        if (value.toInt() >= 0 && value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              labels[value.toInt()],
                              style: GoogleFonts.afacad(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: GoogleFonts.afacad(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: [
                  _buildBarGroup(0, vaccinationScore),
                  _buildBarGroup(1, teethScore),
                  _buildBarGroup(2, medicalScore),
                ],
              ),
            ),
          ),
        ),
        // Detailed breakdown
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricRow('Tiêm chủng', vaccinationScore),
              _buildMetricRow('Sức khỏe răng', teethScore),
              _buildMetricRow('Lịch sử y tế', medicalScore),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateVaccinationScore() {
    if (vaccinationCount >= 4) return 100;
    if (vaccinationCount >= 2) return 70;
    if (vaccinationCount > 0) return 40;
    return 0;
  }

  double _calculateMedicalScore(int historyCount, int allergyCount) {
    int score = 100;
    score -= historyCount * 15;
    score -= allergyCount * 10;
    return score.toDouble().clamp(0, 100);
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Color.lerp(
            const Color(0xFFF44336),
            const Color(0xFF4CAF50),
            y / 100,
          )!,
          width: 20,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, double value) {
    final percentage = (value / 100 * 100).toStringAsFixed(0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.afacad(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percentage%',
                style: GoogleFonts.afacad(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color.lerp(
                    const Color(0xFFF44336),
                    const Color(0xFF4CAF50),
                    value / 100,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.lerp(
                  const Color(0xFFF44336),
                  const Color(0xFF4CAF50),
                  value / 100,
                )!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
