# ✅ TO'G'RILANGAN COLAB BUILD SCRIPT

## ⚠️ MUHIM: Har bir cell'da PATH qayta sozlanadi!

---

## 📱 CELL 1: Flutter o'rnatish (5 daqiqa)

```python
# System packages
!apt-get update -qq
!apt-get install -y -qq curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk

# Flutter clone (agar mavjud bo'lmasa)
import os
if not os.path.exists('/content/flutter'):
    !git clone https://github.com/flutter/flutter.git -b stable --depth 1
else:
    print("Flutter allaqachon o'rnatilgan")

# Test
!ls -la /content/flutter/bin/flutter
!/content/flutter/bin/flutter --version

print("✅ Flutter o'rnatildi!")
```

---

## 🤖 CELL 2: Android SDK (3 daqiqa)

```python
import os

# Download (agar mavjud bo'lmasa)
if not os.path.exists('/content/android-sdk'):
    !wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    !mkdir -p /content/android-sdk/cmdline-tools
    !unzip -q commandlinetools-linux-9477386_latest.zip -d /content/android-sdk/cmdline-tools
    !mv /content/android-sdk/cmdline-tools/cmdline-tools /content/android-sdk/cmdline-tools/latest
    
    # Install packages
    !/content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk "platform-tools" "platforms;android-33" "build-tools;33.0.2"
    !yes | /content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk --licenses
else:
    print("Android SDK allaqachon o'rnatilgan")

print("✅ Android SDK tayyor!")
```

---

## 📂 CELL 3: Loyiha yuklash (1 daqiqa)

```python
import os

# Clone (agar mavjud bo'lmasa)
if not os.path.exists('/content/flutter-manga-app'):
    !git clone https://github.com/UzbekApis/flutter-manga-app.git
else:
    print("Loyiha allaqachon yuklangan")

# Check
!ls -la /content/flutter-manga-app

print("✅ Loyiha tayyor!")
```

---

## 📦 CELL 4: Dependencies (2 daqiqa)

```python
import os

# Change directory
os.chdir('/content/flutter-manga-app')

# Get dependencies
!/content/flutter/bin/flutter pub get

print("✅ Dependencies o'rnatildi!")
```

---

## 🔨 CELL 5: Build APK (10 daqiqa)

```python
import os

# Make sure we're in the right directory
os.chdir('/content/flutter-manga-app')

# Build
!/content/flutter/bin/flutter build apk --release

# Check if APK exists
apk_path = '/content/flutter-manga-app/build/app/outputs/flutter-apk/app-release.apk'

if os.path.exists(apk_path):
    size_mb = os.path.getsize(apk_path) / 1024 / 1024
    print(f"\n✅ BUILD MUVAFFAQIYATLI!")
    print(f"📱 APK hajmi: {size_mb:.2f} MB")
    print(f"📍 Joylashuv: {apk_path}")
else:
    print("\n❌ BUILD XATOLIK!")
    print("Yuqoridagi xatolarni tekshiring")
    # Show build directory
    !ls -la /content/flutter-manga-app/build/app/outputs/ 2>/dev/null || echo "Build papkasi topilmadi"
```

---

## ⬇️ CELL 6: APK yuklab olish

```python
from google.colab import files
import os

apk_path = '/content/flutter-manga-app/build/app/outputs/flutter-apk/app-release.apk'

if os.path.exists(apk_path):
    files.download(apk_path)
    print("✅ APK yuklab olindi!")
else:
    print("❌ APK topilmadi!")
    print("Cell 5'ni qayta ishga tushiring")
```

---

## 🚀 YOKI BITTA CELL'DA HAMMASI (20 daqiqa)

```python
import os

# 1. System packages
print("📦 Installing system packages...")
!apt-get update -qq
!apt-get install -y -qq curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk

# 2. Flutter
print("\n📱 Installing Flutter...")
if not os.path.exists('/content/flutter'):
    !git clone https://github.com/flutter/flutter.git -b stable --depth 1

!/content/flutter/bin/flutter --version

# 3. Android SDK
print("\n🤖 Installing Android SDK...")
if not os.path.exists('/content/android-sdk'):
    !wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
    !mkdir -p /content/android-sdk/cmdline-tools
    !unzip -q commandlinetools-linux-9477386_latest.zip -d /content/android-sdk/cmdline-tools
    !mv /content/android-sdk/cmdline-tools/cmdline-tools /content/android-sdk/cmdline-tools/latest
    !/content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk "platform-tools" "platforms;android-33" "build-tools;33.0.2"
    !yes | /content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk --licenses

# 4. Clone project
print("\n📂 Cloning project...")
if not os.path.exists('/content/flutter-manga-app'):
    !git clone https://github.com/UzbekApis/flutter-manga-app.git

# 5. Dependencies
print("\n📦 Installing dependencies...")
os.chdir('/content/flutter-manga-app')
!/content/flutter/bin/flutter pub get

# 6. Build
print("\n🔨 Building APK...")
!/content/flutter/bin/flutter build apk --release

# 7. Check and download
apk_path = '/content/flutter-manga-app/build/app/outputs/flutter-apk/app-release.apk'
if os.path.exists(apk_path):
    size_mb = os.path.getsize(apk_path) / 1024 / 1024
    print(f"\n✅ BUILD MUVAFFAQIYATLI!")
    print(f"📱 APK hajmi: {size_mb:.2f} MB")
    
    from google.colab import files
    files.download(apk_path)
    print("✅ APK yuklab olindi!")
else:
    print("\n❌ BUILD XATOLIK!")
```

---

## 🐛 XATOLIKLARNI HAL QILISH

### ❌ "flutter: No such file"

**Yechim:**
```python
# Flutter mavjudligini tekshirish
!ls -la /content/flutter/bin/flutter

# Agar yo'q bo'lsa, qayta o'rnatish
!rm -rf /content/flutter
!git clone https://github.com/flutter/flutter.git -b stable --depth 1
```

### ❌ "Build failed"

**Yechim:**
```python
# Xatolarni ko'rish
!/content/flutter/bin/flutter doctor -v

# Clean va rebuild
import os
os.chdir('/content/flutter-manga-app')
!/content/flutter/bin/flutter clean
!/content/flutter/bin/flutter pub get
!/content/flutter/bin/flutter build apk --release --verbose
```

### ❌ "Out of memory"

**Yechim:**
- Colab Pro ishlatish
- Yoki Runtime → Restart runtime → Qaytadan boshlash

---

## ⏱️ JAMI VAQT: ~20 daqiqa

---

## 💡 MASLAHATLAR

✅ **Bitta cell** usulini ishlating (eng oson)
✅ Xatolik bo'lsa, o'sha qismni qayta ishga tushiring
✅ Internet tezligiga bog'liq
✅ Sabr qiling, vaqt kerak

---

## 📱 APK O'RNATISH

1. app-release.apk yuklab olindi
2. Telefonga o'tkazing
3. Settings → Security → Unknown sources ✅
4. APK'ni bosing
5. Install
6. Manga Reader'ni oching! 🎉

---

## ✅ MUVAFFAQIYAT!

Repository: https://github.com/UzbekApis/flutter-manga-app

Agar muammo bo'lsa, GitHub'da issue oching!
