# 🔐 Proxy Funksiyasi Qo'llanmasi

## 🎯 Nima Uchun Proxy?

Proxy funksiyasi quyidagi muammolarni hal qiladi:
- ✅ API rate limiting (so'rovlar cheklovi)
- ✅ IP bloklash
- ✅ Geografik cheklovlar
- ✅ Tezlikni oshirish

## 🚀 Qanday Ishlatish?

### 1. Sozlamalar Sahifasiga O'tish
```
Bosh sahifa → Sozlamalar (⚙️ tugma)
```

### 2. Proxy Yoqish
```
Ruscha Proxy → Switch tugmasini yoqing
```

### 3. Proxylarni Test Qilish (Optional)
```
"Proxylarni Test Qilish" tugmasini bosing
Natija: Ishlaydigan proxylar ro'yxati
```

## 📊 Proxy Xususiyatlari

### Avtomatik Almashtirish
- Har bir so'rovda yangi proxy tanlanadi
- 20 ta ruscha proxy mavjud
- Random tanlash algoritmi

### Ruscha Proxylar
```
185.162.228.73:3128
185.162.230.55:3128
185.162.231.106:3128
45.67.212.45:8085
45.67.214.35:8085
91.203.114.71:42890
91.203.115.45:42890
188.130.184.131:8080
188.130.185.86:8080
195.140.226.244:8080
195.140.226.32:8080
46.8.247.3:50967
46.8.247.4:50967
185.189.199.75:23500
185.189.199.76:23500
77.73.241.154:80
77.73.241.155:80
185.162.228.155:3128
185.162.229.67:3128
45.67.213.158:8085
```

## 🔧 Texnik Detalllar

### Qanday Ishlaydi?

1. **Proxy Yoqilganda**:
```dart
ProxyService.enable();
// Random proxy tanlanadi
```

2. **Har Bir So'rovda**:
```dart
ProxyService.getRandomProxy();
// Yangi proxy tanlanadi
```

3. **HTTP Client**:
```dart
final client = ProxyService.createClient();
// Proxy bilan client yaratiladi
```

### Kod Misoli

```dart
// API Service
if (ProxyService.isEnabled) {
  ProxyService.getRandomProxy();
  print('Using proxy: ${ProxyService.currentProxy}');
}

final client = ProxyService.createClient();
final response = await client.post(url, ...);
client.close();
```

## 📱 Foydalanuvchi Interfeysi

### Sozlamalar Sahifasi
```
┌─────────────────────────────┐
│  🔐 Ruscha Proxy            │
│  ○ Yoqilgan / O'chirilgan   │
│  [Switch]                   │
├─────────────────────────────┤
│  Proxy haqida:              │
│  • Ruscha bepul proxylar    │
│  • Random almashtirish      │
│  • Rate limit hal qilish    │
├─────────────────────────────┤
│  Hozirgi proxy:             │
│  ✓ 185.162.228.73:3128     │
├─────────────────────────────┤
│  [Proxylarni Test Qilish]   │
└─────────────────────────────┘
```

## 🧪 Test Qilish

### Proxy Test Funksiyasi
```dart
Future<bool> testProxy(String proxy) async {
  try {
    final socket = await Socket.connect(
      host, port,
      timeout: const Duration(seconds: 5),
    );
    socket.destroy();
    return true;
  } catch (e) {
    return false;
  }
}
```

### Barcha Proxylarni Test
```dart
final workingProxies = await ProxyService.getWorkingProxies();
print('${workingProxies.length} ta ishlaydigan proxy');
```

## ⚠️ Ogohlantirish

### Bepul Proxylar
- ✅ Bepul
- ⚠️ Sekinroq bo'lishi mumkin
- ⚠️ Ba'zan ishlamasligi mumkin
- ⚠️ Xavfsizlik kamroq

### Tavsiyalar
1. Faqat kerak bo'lganda yoqing
2. Agar sekin bo'lsa, o'chiring
3. Test qilib ko'ring
4. Ishlamasa, o'chiring

## 🎯 Qachon Ishlatish?

### Yoqish Kerak:
- ✅ API rate limit xatosi
- ✅ "Too many requests" xatosi
- ✅ IP bloklangan
- ✅ Tez-tez yuklab olishda

### O'chirish Kerak:
- ✅ Oddiy foydalanishda
- ✅ Tez ishlayotganda
- ✅ Proxy sekin bo'lsa
- ✅ Xato bersa

## 📊 Statistika

### Proxy Bilan
- Tezlik: Sekinroq (proxy overhead)
- Xavfsizlik: O'rtacha
- Rate limit: Yo'q
- IP block: Yo'q

### Proxy Siz
- Tezlik: Tezroq
- Xavfsizlik: Yuqori
- Rate limit: Mumkin
- IP block: Mumkin

## 🔄 Muammolarni Hal Qilish

### Proxy Ishlamayapti?
1. Boshqa proxy sinab ko'ring (avtomatik)
2. Proxylarni test qiling
3. Proxy o'chiring va qayta yoqing
4. Internetni tekshiring

### Juda Sekin?
1. Proxy o'chiring
2. Boshqa vaqtda sinab ko'ring
3. Internetni tekshiring

### Xato Beradi?
1. Proxy o'chiring
2. Oddiy rejimda ishlating
3. Keyin qayta yoqib ko'ring

## 💡 Maslahatlar

1. **Test Qiling**: Avval test qilib ko'ring
2. **Ehtiyotkorlik**: Faqat kerak bo'lganda yoqing
3. **Monitoring**: Hozirgi proxy ko'rsatiladi
4. **Flexibility**: Istalgan vaqt o'chirish mumkin

## 🎉 Xulosa

Proxy funksiyasi:
- ✅ Oson ishlatish
- ✅ Avtomatik almashtirish
- ✅ 20 ta ruscha proxy
- ✅ Test funksiyasi
- ✅ On/Off switch
- ✅ Real-time monitoring

Agar API muammolari bo'lsa - yoqing!
Agar hammasi yaxshi bo'lsa - o'chiring!
