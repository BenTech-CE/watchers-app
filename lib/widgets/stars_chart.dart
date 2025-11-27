import 'package:flutter/material.dart';
import 'package:watchers/core/models/global/star_distribution_model.dart';
import 'package:watchers/core/theme/colors.dart';

class StarsChart extends StatefulWidget {
  final List<StarDistributionModel> data;
  final double maxBarHeight;

  const StarsChart({super.key, required this.data, this.maxBarHeight = 80.0});

  @override
  State<StarsChart> createState() => _StarsChartState();
}

class _StarsChartState extends State<StarsChart> {
  double _calculateBarHeight(int count, int maxCount) {
    if (maxCount == 0) return 3;
    double calc = (count / maxCount) * widget.maxBarHeight;

    return calc < 3 ? 3 : calc;
  }

  double _calcMedia() {
    // 1. Calcular o total de votos (o "peso" total)
    // O método fold é seguro, retornando 0 se a lista estiver vazia.
    final int totalCount = widget.data.fold(
      0, // Valor inicial
      (previousValue, element) => previousValue + element.quantity,
    );

    // 2. Calcular a soma ponderada total
    // (Iteramos nas "entries" para ter acesso à chave e ao valor ao mesmo tempo)
    final double totalWeightedSum = widget.data.fold(
      0.0, // Valor inicial
      (previousValue, element) {
        // entry.key é a String (ex: '4.5'), entry.value é a contagem (ex: 346)
        final double ratingValue = element.starRating;
        final int count = element.quantity;
        return previousValue + (ratingValue * count);
      },
    );

    // 3. Calcular a média final (e evitar divisão por zero)
    final double averageRating = (totalCount == 0)
        ? 0.0 // Evita divisão por zero se o Map estiver vazio
        : totalWeightedSum / totalCount;

    return averageRating;
  }

  /// Helper para construir a lista de ícones de estrela
  List<Widget> _buildStarRating(double rating) {
    List<Widget> stars = [];
    // O rating da imagem é de 4/5 estrelas.
    // Este código converte um double (ex: 4.5) em estrelas cheias,
    // meias-estrelas e vazias.
    for (int i = 1; i <= 5; i++) {
      IconData iconData;
      if (i <= rating) {
        iconData = Icons.star;
      } else if (i - 0.5 <= rating) {
        iconData = Icons.star_half;
      } else {
        iconData = Icons.star_border;
      }
      stars.add(Icon(iconData, color: Colors.amber, size: 16));
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    final int maxCount = widget.data.isNotEmpty
        ? widget.data.reduce((a, b) => a.quantity > b.quantity ? a : b).quantity
        : 1;

    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: Row(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var ratingData in widget.data)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: _calculateBarHeight(
                          ratingData.quantity,
                          maxCount,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xff545454),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              _calcMedia().toStringAsFixed(1),
              style: TextStyle(
                color: tColorSecondary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(children: _buildStarRating(_calcMedia().roundToDouble())),
          ],
        ),
      ],
    );
  }
}
