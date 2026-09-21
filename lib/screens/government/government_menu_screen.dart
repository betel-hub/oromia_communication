import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class GovernmentMenuScreen extends StatelessWidget {
  const GovernmentMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Government')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTile(
            context,
            icon: Icons.account_balance,
            title: 'Regional Sectors',
            subtitle: 'Government bureaus and offices',
            color: Colors.blue,
            onTap: () => context.push('/government/regional-sectors'),
          ),
          _buildTile(
            context,
            icon: Icons.location_city,
            title: 'Zone → Woreda → Kebele',
            subtitle: 'Administrative hierarchy',
            color: Colors.green,
            onTap: () => context.push('/government/zone'),
          ),
          _buildTile(
            context,
            icon: Icons.apartment,
            title: 'City → Sub-City → Kebele',
            subtitle: 'Urban hierarchy',
            color: Colors.purple,
            onTap: () => context.push('/government/city'),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}