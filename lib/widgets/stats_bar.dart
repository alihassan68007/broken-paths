import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatsBar extends StatelessWidget {
  final int iman;
  final int knowledge;
  final int wealth;
  final int respect;
  final int coins;

  const StatsBar({
    Key? key,
    required this.iman,
    required this.knowledge,
    required this.wealth,
    required this.respect,
    required this.coins,
  }) : super(key: key);

  Widget _buildStat(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppColors.creamWhite,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Colors.black.withOpacity(0.6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat('Iman', iman, Colors.blue),
          _buildStat('Knowledge', knowledge, Colors.purple),
          _buildStat('Wealth', wealth, Colors.green),
          _buildStat('Respect', respect, Colors.orange),
          _buildStat('Coins', coins, AppColors.gold),
        ],
      ),
    );
  }
}
