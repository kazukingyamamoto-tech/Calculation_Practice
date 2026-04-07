import 'package:fl_chart/fl_chart.dart';

void main() {
	final lineBarsData = [
		LineChartBarData(spots: [const FlSpot(0, 0)]),
	];

	final chart = LineChartData(
		showingTooltipIndicators: [
			ShowingTooltipIndicators([
				LineBarSpot(lineBarsData[0], 0, lineBarsData[0].spots[0]),
			]),
		],
		lineBarsData: lineBarsData,
	);

	assert(chart.lineBarsData.isNotEmpty);
}
