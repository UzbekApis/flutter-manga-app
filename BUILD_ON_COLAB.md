# Google Colab'da Flutter APK build qilish

## Usul 1: To'liq setup (tavsiya etiladi)

Google Colab notebook yarating va quyidagi kodni ketma-ket ishga tushiring:

### 1. Flutter o'rnatish
```python
!apt-get update
!apt-get install -y curl git unzip xz-utils zip libglu1-mesa

# Flutter yuklab olish
!git clone https://github.com/flutter/flutter.git -b stable --depth 1
!echo 'export PATH="$PATH:/content/flutter/bin"' >> ~/.bashrc
!source ~/.bashrc

# Flutter doctor
!/content/flutter/bin/flutter doctor
```

### 2. Android SDK o'rnatish
```python
# Java o'rnatish
!apt-get install -y openjdk-11-jdk

# Android command line tools
!wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
!mkdir -p /content/android-sdk/cmdline-tools
!unzip commandlinetools-linux-9477386_latest.zip -d /content/android-sdk/cmdline-tools
!mv /content/android-sdk/cmdline-tools/cmdline-tools /content/android-sdk/cmdline-tools/latest

# Environment variables
import os
os.environ['ANDROID_HOME'] = '/content/android-sdk'
os.environ['PATH'] = f"{os.environ['PATH']}:/content/android-sdk/cmdline-tools/latest/bin:/content/android-sdk/platform-tools"

# SDK packages o'rnatish
!/content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk "platform-tools" "platforms;android-33" "build-tools;33.0.2"
!/content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk --licenses
```

### 3. Loyihani yuklash
```python
# GitHub'dan
!git clone https://github.com/YOUR_USERNAME/manga_reader_app.git /content/app

# yoki ZIP yuklash
from google.colab import files
uploaded = files.upload()
!unzip manga_reader_app.zip -d /content/app
```

### 4. Build qilish
```python
%cd /content/app/flutter_manga_app

# Dependencies
!/content/flutter/bin/flutter pub get

# Build
!/content/flutter/bin/flutter build apk --release

# APK yuklab olish
from google.colab import files
files.download('/content/app/flutter_manga_app/build/app/outputs/flutter-apk/app-release.apk')
```

## Usul 2: Bitta script (tezroq)

```python
# Hammasi bitta cell'da
!apt-get update && apt-get install -y curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk

# Flutter
!git clone https://github.com/flutter/flutter.git -b stable --depth 1
import os
os.environ['PATH'] = f"{os.environ['PATH']}:/content/flutter/bin"

# Android SDK
!wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
!mkdir -p android-sdk/cmdline-tools && unzip -q commandlinetools-linux-9477386_latest.zip -d android-sdk/cmdline-tools
!mv android-sdk/cmdline-tools/cmdline-tools android-sdk/cmdline-tools/latest
os.environ['ANDROID_HOME'] = '/content/android-sdk'

# SDK setup
!/content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk "platform-tools" "platforms;android-33" "build-tools;33.0.2"
!yes | /content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk --licenses

# Loyiha (ZIP yuklang)
from google.colab import files
uploaded = files.upload()
!unzip -q manga_reader_app.zip

# Build
%cd flutter_manga_app
!/content/flutter/bin/flutter pub get
!/content/flutter/bin/flutter build apk --release

# Download
files.download('build/app/outputs/flutter-apk/app-release.apk')
```

## Usul 3: Codemagic (eng oson)

1. https://codemagic.io ga kiring
2. GitHub repo ulang
3. "Start new build" bosing
4. APK tayyor!

## Maslahatlar

- **Colab Pro** ishlatish tavsiya etiladi (tezroq)
- **Build vaqti**: ~10-15 daqiqa
- **APK hajmi**: ~20-30 MB
- **Internet** kerak (dependencies yuklab olish uchun)

## Xatoliklar

### "Flutter not found"
```python
import os
os.environ['PATH'] = f"{os.environ['PATH']}:/content/flutter/bin"
```

### "Android licenses not accepted"
```python
!yes | /content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk --licenses
```

### "Gradle error"
```python
# flutter_manga_app/android/gradle.properties ga qo'shing:
org.gradle.jvmargs=-Xmx2048m
android.useAndroidX=true
android.enableJetifier=true
```

## Tayyor APK

APK yuklab olgandan keyin:
1. Telefonga o'tkazing
2. "Unknown sources" yoqing
3. APK'ni o'rnating
4. Ishlatishni boshlang!
