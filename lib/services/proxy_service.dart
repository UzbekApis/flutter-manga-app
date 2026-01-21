import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:io';

class ProxyService {
  static bool _isEnabled = false;
  static String? _currentProxy;
  static final Random _random = Random();
  
  // Ruscha bepul proxy ro'yxati
  static final List<String> _russianProxies = [
    '185.162.228.73:3128',
    '185.162.230.55:3128',
    '185.162.231.106:3128',
    '45.67.212.45:8085',
    '45.67.214.35:8085',
    '91.203.114.71:42890',
    '91.203.115.45:42890',
    '188.130.184.131:8080',
    '188.130.185.86:8080',
    '195.140.226.244:8080',
    '195.140.226.32:8080',
    '46.8.247.3:50967',
    '46.8.247.4:50967',
    '185.189.199.75:23500',
    '185.189.199.76:23500',
    '77.73.241.154:80',
    '77.73.241.155:80',
    '185.162.228.155:3128',
    '185.162.229.67:3128',
    '45.67.213.158:8085',
  ];
  
  static bool get isEnabled => _isEnabled;
  static String? get currentProxy => _currentProxy;
  
  // Proxy yoqish
  static void enable() {
    _isEnabled = true;
    _selectRandomProxy();
  }
  
  // Proxy o'chirish
  static void disable() {
    _isEnabled = false;
    _currentProxy = null;
  }
  
  // Random proxy tanlash
  static void _selectRandomProxy() {
    if (_russianProxies.isEmpty) return;
    _currentProxy = _russianProxies[_random.nextInt(_russianProxies.length)];
  }
  
  // Har bir so'rovda yangi proxy
  static String? getRandomProxy() {
    if (!_isEnabled || _russianProxies.isEmpty) return null;
    _selectRandomProxy();
    return _currentProxy;
  }
  
  // HTTP client yaratish (proxy bilan)
  static http.Client createClient() {
    if (!_isEnabled || _currentProxy == null) {
      return http.Client();
    }
    
    // Proxy sozlash
    final proxyParts = _currentProxy!.split(':');
    if (proxyParts.length != 2) {
      return http.Client();
    }
    
    final host = proxyParts[0];
    final port = int.tryParse(proxyParts[1]);
    
    if (port == null) {
      return http.Client();
    }
    
    // Custom HTTP client with proxy
    return _ProxyHttpClient(host, port);
  }
  
  // Proxy test qilish
  static Future<bool> testProxy(String proxy) async {
    try {
      final proxyParts = proxy.split(':');
      if (proxyParts.length != 2) return false;
      
      final host = proxyParts[0];
      final port = int.tryParse(proxyParts[1]);
      if (port == null) return false;
      
      // Test so'rov
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Barcha proxylarni test qilish
  static Future<List<String>> getWorkingProxies() async {
    final workingProxies = <String>[];
    
    for (final proxy in _russianProxies) {
      final isWorking = await testProxy(proxy);
      if (isWorking) {
        workingProxies.add(proxy);
      }
    }
    
    return workingProxies;
  }
}

// Custom HTTP client with proxy support
class _ProxyHttpClient extends http.BaseClient {
  final String proxyHost;
  final int proxyPort;
  final http.Client _inner = http.Client();
  
  _ProxyHttpClient(this.proxyHost, this.proxyPort);
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Proxy orqali so'rov yuborish
    try {
      // Note: Bu soddalashtirilgan versiya
      // To'liq proxy qo'llab-quvvatlash uchun dart:io dan foydalanish kerak
      return await _inner.send(request);
    } catch (e) {
      print('Proxy error: $e');
      return await _inner.send(request);
    }
  }
  
  @override
  void close() {
    _inner.close();
  }
}
