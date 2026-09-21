import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'About Us'),
              Tab(text: 'Contact Us'),
            ],
            indicatorColor: AppColors.white,
            labelColor: AppColors.white,
          ),
        ),
        body: const TabBarView(
          children: [
            _AboutUsTab(),
            _ContactUsTab(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ABOUT US TAB
// ============================================================
class _AboutUsTab extends StatelessWidget {
  const _AboutUsTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.newspaper,
                  size: 60, color: AppColors.white),
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Oromia Communication Bureau',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Biiroo Komunikeeshinii Oromiyaa',
              style: TextStyle(
                  fontSize: 14, color: AppColors.mediumGray),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryRed.withValues(alpha: 0.08),
              border: const Border(
                  left: BorderSide(color: AppColors.primaryRed, width: 4)),
            ),
            child: const Text(
              '"Effective communication for Oromia Prosperity"',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryRed,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'About Us',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 12),
          const Text(
            'The Oromia Communication Bureau is the official government '
            'communication body of the Oromia Regional State. We are '
            'responsible for public communication, media relations, and '
            'information dissemination across the region.\n\n'
            'Our mission is to ensure effective communication for Oromia '
            'Prosperity by providing accurate, timely, and accessible '
            'information to citizens, government institutions, and '
            'stakeholders.\n\n'
            'Through our digital platforms, publications, and media services, '
            'we strive to foster transparency, accountability, and public '
            'engagement throughout the Oromia region.',
            style: TextStyle(fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 24),
          const Text(
            'Our Services',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 12),
          _buildServiceItem(Icons.newspaper, 'News & Information'),
          _buildServiceItem(Icons.gavel, 'Tenders & Procurement'),
          _buildServiceItem(Icons.business, 'Government Information'),
          _buildServiceItem(Icons.video_library, 'Media & Publications'),
          _buildServiceItem(Icons.book, 'Kallacha Oromia'),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryRed, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

// ============================================================
// CONTACT US TAB
// ============================================================
class _ContactUsTab extends StatefulWidget {
  const _ContactUsTab();

  @override
  State<_ContactUsTab> createState() => _ContactUsTabState();
}

class _ContactUsTabState extends State<_ContactUsTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Message Sent'),
        content: const Text('Thank you! We will get back to you soon.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nameCtrl.clear();
              _emailCtrl.clear();
              _msgCtrl.clear();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Office Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Office Address',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 12),
                _buildContactRow(Icons.location_on,
                    'Bole Dembel, Finfinnee (Addis Ababa), Ethiopia'),
                _buildContactRow(Icons.phone, '+251 115 541 816'),
                _buildContactRow(Icons.phone, '+251 115 541 801'),
                _buildContactRow(
                    Icons.email, 'info@oromiacommunication.gov.et'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contact Form
          const Text(
            'Send us a Message',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _msgCtrl,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primaryRed),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
