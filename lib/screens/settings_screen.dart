import 'package:flutter/material.dart';
import '../services/proxy_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isProxyEnabled = false;
  bool _isTesting = false;
  List<String> _workingProxies = [];

  @override
  void initState() {
    super.initState();
    _isProxyEnabled = ProxyService.isEnabled;
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
          Card(
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
                              _isProxyEnabled ? 'Yoqilgan' : 'O\'chirilgan',
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
                                    ? 'Proxy yoqildi - Ruscha proxylar ishlatiladi'
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
                    '• Har bir so\'rovda random proxy tanlanadi\n'
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
                      constraints: const BoxConstraints(maxHeight: 200),
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
          ),
          
          const SizedBox(height: 16),
          
          // Boshqa sozlamalar
          Card(
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
                ],
              ),
            ),
          ),
        ],
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
}
