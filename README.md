# 📱 Flutter Manga Reader

Senkuro.me saytidan manga o'qish uchun Flutter ilovasi.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-brightgreen.svg)](https://www.android.com/)
[![Open in Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/UzbekApis/flutter-manga-app/blob/main/Flutter_Manga_App_Builder.ipynb)

## ✨ Xususiyatlar

- 🔍 **Qidirish** - Manga qidirish (ruscha/inglizcha)
- 📖 **Online o'qish** - To'g'ridan-to'g'ri Senkuro API orqali
- 💾 **Offline o'qish** - Chapterlarni yuklab olish
- 📜 **Vertikal scroll** - Pastdan yuqoriga o'qish
- 🖼️ **Auto-fit** - Rasmlar ekranga moslashadi
- ⚡ **Cache** - Tez yuklash uchun (CachedNetworkImage)
- 🌙 **Dark mode** - Qorong'i tema
- 🛡️ **Xatoliklar** - Yaxshilangan xatoliklar bilan ishlash

## 📸 Screenshots

<p align="center">
  <img src="screenshots/home.png" width="200" />
  <img src="screenshots/search.png" width="200" />
  <img src="screenshots/reader.png" width="200" />
</p>

## 🚀 Google Colab'da Build qilish (TAVSIYA ETILADI)

Eng ishonchli va oson usul bu **Google Colab** yordamida build qilishdir.

👉 **[COLAB_FINAL.md](COLAB_FINAL.md)** faylida to'liq va yangilangan yo'riqnoma mavjud.

### Qisqacha:
1. [Google Colab](https://colab.research.google.com/) oching
2. [COLAB_FINAL.md](COLAB_FINAL.md) dagi kodni nusxalang
3. Ishga tushiring va 20 daqiqa kuting
4. APK tayyor!

## 💻 Lokal Build

```bash
# Clone
git clone https://github.com/UzbekApis/flutter-manga-app.git
cd flutter-manga-app

# Dependencies
flutter pub get

# Run
flutter run

# Build APK
flutter build apk --release
```

## 📦 Dependencies

```yaml
dependencies:
  http: ^1.1.0              # API so'rovlar
  provider: ^6.1.1          # State management
  sqflite: ^2.3.0           # Local database
  path_provider: ^2.1.1     # File paths
  cached_network_image: ^3.3.0  # Image cache
  photo_view: ^0.14.0       # Image viewer
  dio: ^5.4.0               # Downloads
  permission_handler: ^11.1.0   # Permissions
  flutter_spinkit: ^5.2.0   # Loading indicators
```

## 🏗️ Arxitektura

```
lib/
├── main.dart                 # Entry point
├── models/                   # Data models
│   ├── manga.dart
│   └── chapter.dart
├── providers/                # State management
│   └── manga_provider.dart
├── services/                 # Business logic
│   ├── api_service.dart      # Senkuro API
│   └── download_service.dart # Offline storage
└── screens/                  # UI screens
    ├── home_screen.dart
    ├── manga_detail_screen.dart
    ├── reader_screen.dart
    └── downloads_screen.dart
```

## 🔌 API

Ilova to'g'ridan-to'g'ri Senkuro GraphQL API bilan ishlaydi:

- **Base URL**: `https://api.senkuro.me/graphql`
- **Operations**: 
  - `search` - Manga qidirish
  - `fetchManga` - Manga ma'lumotlari
  - `fetchMangaChapters` - Chapterlar ro'yxati
  - `fetchMangaChapter` - Chapter rasmlar

## 📱 Foydalanish

1. **Qidirish**: Qidiruv maydoniga manga nomini kiriting
2. **Tanlash**: Manga tanlang va chapterlar ro'yxatini ko'ring
3. **O'qish**: Chapterni bosing va o'qishni boshlang
4. **Yuklab olish**: Reader ekranida download tugmasini bosing
5. **Offline**: Downloads bo'limidan yuklab olingan chapterlarni oching

## 🐛 Muammolar

### 503 Service Unavailable
- Senkuro serveri vaqtincha band
- Bir necha daqiqa kutib qayta urinib ko'ring

### Yuklab olish ishlamayapti
- Storage permission tekshiring
- Settings → Apps → Manga Reader → Permissions

### Rasmlar yuklanmayapti
- Internet ulanishini tekshiring
- Cache'ni tozalang

## 🤝 Hissa qo'shish

Pull request'lar xush kelibsiz! Katta o'zgarishlar uchun avval issue oching.

1. Fork qiling
2. Feature branch yarating (`git checkout -b feature/AmazingFeature`)
3. Commit qiling (`git commit -m 'Add some AmazingFeature'`)
4. Push qiling (`git push origin feature/AmazingFeature`)
5. Pull Request oching

## 📄 Litsenziya

[MIT License](LICENSE)

## 👨‍💻 Muallif

**UzbekApis**
- GitHub: [@UzbekApis](https://github.com/UzbekApis)

## 🙏 Minnatdorchilik

- [Senkuro.me](https://senkuro.me) - Manga ma'lumotlari uchun
- [Flutter](https://flutter.dev) - Framework
- Barcha contributors'larga

---

<p align="center">Made with ❤️ by UzbekApis</p>
