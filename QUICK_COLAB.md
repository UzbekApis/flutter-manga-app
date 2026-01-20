# ✅ ISHLAYOTGAN COLAB BUILD SCRIPT

## Har bir cell'ni alohida ishga tushiring!

---

## 📱 CELL 1: Flutter o'rnatish (5 daqiqa)

```python
# System packages
!apt-get update -qq
!apt-get install -y -qq curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk

# Flutter clone
!git clone https://github.com/flutter/flutter.git -b stable --depth 1

# PATH
import os
os.environ['PATH'] = f"{os.environ['PATH']}:/content/flutter/bin"

# Test
!ls -la /content/flutter/bin/flutter
!/content/flutter/bin/flutter --version

print("✅ Flutter o'rnatildi!")
```

**Kutish:** ~5 daqiqa. "Flutter o'rnatildi!" ko'rinishi kerak.

---

## 🤖 CELL 2: Android SDK (3 daqiqa)

```python
# Download
!wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip

# Extract
!mkdir -p /content/android-sdk/cmdline-tools
!unzip -q commandlinetools-linux-9477386_latest.zip -d /content/android-sdk/cmdline-tools
!mv /content/android-sdk/cmdline-tools/cmdline-tools /content/android-sdk/cmdline-tools/latest

# Environment
import os
os.environ['ANDROID_HOME'] = '/content/android-sdk'
os.environ['ANDROID_SDK_ROOT'] = '/content/android-sdk'

# Install packages
!/content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Accept licenses
!yes | /content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk --licenses

print("✅ Android SDK o'rnatildi!")
```

**Kutish:** ~3 daqiqa. "Android SDK o'rnatildi!" ko'rinishi kerak.

---

## 📂 CELL 3: Loyiha yuklash (1 daqiqa)

```python
# Clone from GitHub
!git clone https://github.com/UzbekApis/flutter-manga-app.git

# Check
!ls -la /content/flutter-manga-app

print("✅ Loyiha yuklandi!")
```

**Kutish:** ~1 daqiqa. Papka ro'yxati ko'rinishi kerak.

---

## 📦 CELL 4: Dependencies (2 daqiqa)

```python
# Change directory
%cd /content/flutter-manga-app

# Get dependencies
!/content/flutter/bin/flutter pub get

print("✅ Dependencies o'rnatildi!")
```

**Kutish:** ~2 daqiqa. "Got dependencies!" ko'rinishi kerak.

---

## 🔨 CELL 5: Build APK (10 daqiqa)

```python
# Build
!/content/flutter/bin/flutter build apk --release

# Check if APK exists
import os
apk_path = '/content/flutter-manga-app/build/app/outputs/flutter-apk/app-release.apk'

if os.path.exists(apk_path):
    size_mb = os.path.getsize(apk_path) / 1024 / 1024
    print(f"✅ Build muvaffaqiyatli!")
    print(f"📱 APK hajmi: {size_mb:.2f} MB")
else:
    print("❌ Build xatolik!")
    print("Yuqoridagi xatolarni tekshiring")
```

**Kutish:** ~10 daqiqa. "Build muvaffaqiyatli!" ko'rinishi kerak.

---

## ⬇️ CELL 6: APK yuklab olish

```python
from google.colab import files

apk_path = '/content/flutter-manga-app/build/app/outputs/flutter-apk/app-release.apk'

# Download
files.download(apk_path)

print("✅ APK yuklab olindi!")
```

**Natija:** APK yuklab olish boshlandi!

---

## 🐛 XATOLIKLARNI HAL QILISH

### ❌ "flutter: No such file"
**Sabab:** Cell 1 to'liq ishlamagan
**Yechim:** Cell 1'ni qayta ishga tushiring

### ❌ "flutter-manga-app: No such directory"
**Sabab:** Cell 3 ishlamagan
**Yechim:** Cell 3'ni qayta ishga tushiring

### ❌ "Build failed"
**Sabab:** Dependencies yoki SDK muammosi
**Yechim:** 
1. Runtime → Restart runtime
2. Barcha cell'larni qaytadan ishga tushiring

### ❌ "Gradle error"
**Sabab:** Memory yetishmayapti
**Yechim:** Colab Pro ishlatish yoki qayta urinish

---

## ⏱️ JAMI VAQT

- Cell 1: ~5 daqiqa
- Cell 2: ~3 daqiqa
- Cell 3: ~1 daqiqa
- Cell 4: ~2 daqiqa
- Cell 5: ~10 daqiqa
- Cell 6: ~10 soniya

**JAMI: ~20 daqiqa**

---

## 💡 MASLAHATLAR

✅ Har bir cell tugashini kuting
✅ Xatolik bo'lsa, o'sha cell'ni qayta ishga tushiring
✅ Internet tezligiga bog'liq
✅ Colab Pro tezroq ishlaydi

---

## 📱 APK O'RNATISH

1. APK yuklab olindi (app-release.apk)
2. Telefonga o'tkazing
3. Settings → Security → Unknown sources ✅
4. APK'ni bosing va o'rnating
5. Manga Reader ilovasini oching
6. Manga qidiring va o'qing! 🎉

---

## ✅ MUVAFFAQIYAT!

Endi sizda ishlaydigan manga reader ilovasi bor!

Repository: https://github.com/UzbekApis/flutter-manga-app
