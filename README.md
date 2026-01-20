# Manga Reader - Flutter ilovasi

Senkuro.me saytidan manga o'qish uchun Flutter ilovasi.

## Xususiyatlar

✅ **Qidirish** - Manga qidirish (ruscha/inglizcha)
✅ **Online o'qish** - To'g'ridan-to'g'ri Senkuro API orqali
✅ **Offline o'qish** - Chapterlarni yuklab olish
✅ **Vertikal scroll** - Pastdan yuqoriga o'qish
✅ **Auto-fit** - Rasmlar ekranga moslashadi
✅ **Cache** - Tez yuklash uchun

## Google Colab'da build qilish

### 1. Colab notebook yarating va quyidagi kodni kiriting:

```python
# Flutter o'rnatish
!wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
!tar xf flutter_linux_3.16.0-stable.tar.xz
!export PATH="$PATH:`pwd`/flutter/bin"

# Android SDK o'rnatish
!wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
!unzip commandlinetools-linux-9477386_latest.zip -d android-sdk
!yes | android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=$PWD/android-sdk --licenses
!android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=$PWD/android-sdk "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Loyihani yuklash (GitHub'dan yoki zip)
!git clone <your-repo-url> manga_app
# yoki
from google.colab import files
uploaded = files.upload()  # ZIP faylni yuklang
!unzip manga_reader_app.zip

# Dependencies o'rnatish
%cd manga_app
!flutter/bin/flutter pub get

# APK build qilish
!flutter/bin/flutter build apk --release

# APK yuklab olish
from google.colab import files
files.download('build/app/outputs/flutter-apk/app-release.apk')
```

### 2. Yoki qisqa yo'l:

```bash
# Colab'da
!pip install flutter-build
!flutter-build build --platform android
```

## Lokal build (agar Android Studio ishlasa)

```bash
cd flutter_manga_app
flutter pub get
flutter run
# yoki
flutter build apk --release
```

## Foydalanish

1. Ilovani oching
2. Qidiruv maydoniga manga nomini kiriting (masalan: "Элисед")
3. Manga tanlang
4. Chapterni tanlang
5. O'qing!

### Yuklab olish:
- Reader ekranida yuqori o'ng burchakdagi download tugmasini bosing
- Yuklab olingan chapterlar "Downloads" bo'limida

### Offline o'qish:
- Downloads bo'limidan yuklab olingan chapterni oching
- Internet kerak emas!

## Texnologiyalar

- **Flutter 3.0+**
- **Provider** - State management
- **HTTP** - API so'rovlar
- **Dio** - Yuklab olish
- **SQLite** - Local storage
- **Cached Network Image** - Rasm cache

## API

Ilova to'g'ridan-to'g'ri Senkuro GraphQL API bilan ishlaydi:
- `https://api.senkuro.me/graphql`

## Muammolar

Agar 503 xatolik chiqsa:
- Bir necha daqiqa kuting
- Qayta urinib ko'ring
- Senkuro serveri vaqtincha band bo'lishi mumkin

## Litsenziya

MIT License
