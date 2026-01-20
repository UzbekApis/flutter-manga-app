# Google Colab'da Flutter APK Build - Qadam-baqadam

## ✅ ISHLAYOTGAN USUL

### 1️⃣ Colab ochish
https://colab.research.google.com → New Notebook

---

### 2️⃣ CELL 1: Setup (5-7 daqiqa)

```python
# System packages
!apt-get update -qq
!apt-get install -y -qq curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk

# Flutter o'rnatish
!git clone https://github.com/flutter/flutter.git -b stable --depth 1

# PATH sozlash
import os
os.environ['PATH'] = f"{os.environ['PATH']}:/content/flutter/bin"

# Flutter tekshirish
!/content/flutter/bin/flutter --version
!/content/flutter/bin/flutter doctor

print("\n✅ Flutter o'rnatildi!")
```

**Kutish:** ~5 daqiqa

---

### 3️⃣ CELL 2: Android SDK (3-5 daqiqa)

```python
# Android SDK yuklab olish
!wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip

# Unzip
!mkdir -p /content/android-sdk/cmdline-tools
!unzip -q commandlinetools-linux-9477386_latest.zip -d /content/android-sdk/cmdline-tools
!mv /content/android-sdk/cmdline-tools/cmdline-tools /content/android-sdk/cmdline-tools/latest

# Environment
import os
os.environ['ANDROID_HOME'] = '/content/android-sdk'
os.environ['ANDROID_SDK_ROOT'] = '/content/android-sdk'

# SDK packages o'rnatish
!/content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk "platform-tools" "platforms;android-33" "build-tools;33.0.2"

# Licenses
!yes | /content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk --licenses

print("\n✅ Android SDK o'rnatildi!")
```

**Kutish:** ~3 daqiqa

---

### 4️⃣ CELL 3: Loyihani yuklash

```python
# ZIP faylni yuklash
from google.colab import files
print("📁 ZIP faylni tanlang...")
uploaded = files.upload()

# Unzip
import os
zip_name = list(uploaded.keys())[0]
!unzip -q {zip_name}

# Papkalarni ko'rish
!ls -la

print("\n✅ Loyiha yuklandi!")
print("📂 Papka nomini eslab qoling (flutter_manga_app)")
```

**Kutish:** ZIP yuklash vaqti

---

### 5️⃣ CELL 4: Dependencies (2-3 daqiqa)

```python
# Loyiha papkasiga o'tish
%cd /content/flutter_manga_app

# Dependencies o'rnatish
!/content/flutter/bin/flutter pub get

print("\n✅ Dependencies o'rnatildi!")
```

**Kutish:** ~2 daqiqa

---

### 6️⃣ CELL 5: Build (5-10 daqiqa)

```python
# APK build qilish
!/content/flutter/bin/flutter build apk --release

print("\n✅ Build tugadi!")
```

**Kutish:** ~5-10 daqiqa

---

### 7️⃣ CELL 6: APK yuklab olish

```python
# APK yuklab olish
from google.colab import files

apk_path = '/content/flutter_manga_app/build/app/outputs/flutter-apk/app-release.apk'

# Hajmini ko'rish
import os
size_mb = os.path.getsize(apk_path) / 1024 / 1024
print(f"📱 APK hajmi: {size_mb:.2f} MB")

# Yuklab olish
files.download(apk_path)

print("\n✅ APK yuklab olindi!")
```

---

## 🐛 XATOLIKLARNI HAL QILISH

### ❌ "flutter: command not found"
**Yechim:** To'liq yo'lni ishlating
```python
!/content/flutter/bin/flutter --version
```

### ❌ "No such file or directory: flutter_manga_app"
**Yechim:** Papka nomini tekshiring
```python
!ls -la /content/
%cd /content/flutter_manga_app  # to'g'ri nom
```

### ❌ "Gradle error"
**Yechim:** Colab'ni restart qiling
- Runtime → Restart runtime
- Qaytadan boshlang

### ❌ "Android licenses"
**Yechim:** Bu normal, davom eting

---

## ⏱️ JAMI VAQT

- Setup: ~5 daqiqa
- Android SDK: ~3 daqiqa
- Upload: ~1 daqiqa
- Dependencies: ~2 daqiqa
- Build: ~5-10 daqiqa

**JAMI: ~15-20 daqiqa**

---

## 📱 APK O'RNATISH

1. APK yuklab olindi
2. Telefonga o'tkazing
3. Settings → Security → Unknown sources ✅
4. APK'ni bosing va o'rnating
5. Ishlatishni boshlang! 🎉

---

## 💡 MASLAHATLAR

✅ Colab Pro ishlatish (tezroq)
✅ Barcha cell'larni ketma-ket ishga tushiring
✅ Har bir cell tugashini kuting
✅ Internet tezligiga bog'liq

---

## 🔄 QAYTA BUILD QILISH

Agar o'zgarish kiritgan bo'lsangiz:

1. ZIP yangilang
2. Cell 3'dan boshlang (Setup qayta kerak emas!)
3. Cell 4, 5, 6'ni ishga tushiring

---

## ✅ TAYYOR!

Endi sizda ishlaydigan manga reader ilovasi bor! 🎉
