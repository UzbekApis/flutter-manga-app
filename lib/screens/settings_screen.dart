import 'package:flutter/material.dart';
import '../services/proxy_service.dart';
import '../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isProxyEnabled = false;
  bool _isTesting = false;
  List<String> _workingProxies = [];
  List<String> _excludedTags = [];
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isProxyEnabled = ProxyService.isEnabled;
    _loadExcludedTags();
  }

  Future<void> _loadExcludedTags() async {
    // TODO: Load from database or shared preferences
    setState(() {
      _excludedTags = ['female_protagonist', 'yaoi', 'yuri']; // Default
    });
  }

  Future<void> _saveExcludedTags() async {
    // TODO: Save to database or shared preferences
  }

  void _addExcludedTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_excludedTags.contains(tag)) {
      setState(() {
        _excludedTags.add(tag);
      });
      _tagController.clear();
      _saveExcludedTags();
    }
  }

  void _removeExcludedTag(String tag) {
    setState(() {
      _excludedTags.remove(tag);
    });
    _saveExcludedTags();
  }

  Future<void> _testProxies() async {
    setState(() {
      _isTesting = true;
    });

    final workingProxies = await ProxyService.getWorkingProxies();

    setState(() {
      _workingProxies = workingProxies;
      _isTesting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${workingProxies.length} ta ishlaydigan proxy topildi'),
          backgroundColor: workingProxies.isEmpty ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sozlamalar'),
        backgroundColor: Colors.indigo.shade900,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Proxy bo'limi
          _buildProxySection(),
          
          const SizedBox(height: 16),
          
          // Tag Exclude bo'limi
          _buildTagExcludeSection(),
          
          const SizedBox(height: 16),
          
          // Ilova haqida
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildProxySection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vpn_lock,
                  color: _isProxyEnabled ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ruscha Proxy',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isProxyEnabled ? 'Yoqilgan (2-3s rotation)' : 'O\'chirilgan',
                        style: TextStyle(
                          fontSize: 14,
                          color: _isProxyEnabled ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isProxyEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isProxyEnabled = value;
                      if (value) {
                        ProxyService.enable();
                      } else {
                        ProxyService.disable();
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? 'Proxy yoqildi - Har 2-3 sekundda almashtiradi'
                              : 'Proxy o\'chirildi',
                        ),
                        backgroundColor: value ? Colors.green : Colors.orange,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Proxy haqida:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Ruscha bepul proxylar ishlatiladi\n'
              '• Har 2-3 sekundda avtomatik almashtiradi\n'
              '• API rate limit muammosini hal qiladi\n'
              '• Agar kerak bo\'lsa yoqing',
              style: TextStyle(fontSize: 13, height: 1.5),
            ),
            if (_isProxyEnabled && ProxyService.currentProxy != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade900.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade700),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hozirgi proxy: ${ProxyService.currentProxy}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isTesting ? null : _testProxies,
              icon: _isTesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.speed),
              label: Text(_isTesting ? 'Tekshirilmoqda...' : 'Proxylarni Test Qilish'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade700,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
            if (_workingProxies.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Ishlaydigan proxylar: ${_workingProxies.length} ta',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _workingProxies.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.check, color: Colors.green, size: 16),
                      title: Text(
                        _workingProxies[index],
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagExcludeSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.block, size: 32, color: Colors.red),
                SizedBox(width: 16),
                Text(
                  'Istalmagan Taglar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Rekomendatsiyalarda ko\'rinmasin:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _excludedTags.map((tag) {
                return Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeExcludedTag(tag),
                  backgroundColor: Colors.red.shade900.withOpacity(0.3),
                  deleteIconColor: Colors.red,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Tag nomini kiriting',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: (_) => _addExcludedTag(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addExcludedTag,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                  ),
                  child: const Text('Qo\'shish'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Masalan: yaoi, yuri, harem, ecchi',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, size: 32),
                SizedBox(width: 16),
                Text(
                  'Ilova haqida',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Versiya', '1.0.0'),
            _buildInfoRow('Til', 'O\'zbek'),
            _buildInfoRow('API', 'Senkuro'),
            _buildInfoRow('Yuklab olish', 'Parallel (5x tezroq)'),
            _buildInfoRow('Pagination', 'Avtomatik'),
            _buildInfoRow('Proxy Rotation', '2-3 sekund'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }
}
