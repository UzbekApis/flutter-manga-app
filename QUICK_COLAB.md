═══════════════════════════════════════════════════════════
  TEZKOR COLAB BUILD (COPY-PASTE QILING)
═══════════════════════════════════════════════════════════

🔥 BITTA CELL'DA HAMMASI (20 daqiqa):

```python
# 1. Setup
!apt-get update -qq
!apt-get install -y -qq curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk

# 2. Flutter
!git clone https://github.com/flutter/flutter.git -b stable --depth 1

import os
os.environ['PATH'] = f"{os.environ['PATH']}:/content/flutter/bin"

# 3. Android SDK
!wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
!mkdir -p /content/android-sdk/cmdline-tools
!unzip -q commandlinetools-linux-9477386_latest.zip -d /content/android-sdk/cmdline-tools
!mv /content/android-sdk/cmdline-tools/cmdline-tools /content/android-sdk/cmdline-tools/latest

os.environ['ANDROID_HOME'] = '/content/android-sdk'
os.environ['ANDROID_SDK_ROOT'] = '/content/android-sdk'

!/content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk "platform-tools" "platforms;android-33" "build-tools;33.0.2"
!yes | /content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk --licenses

# 4. Loyiha yuklash (GitHub'dan)
!git clone https://github.com/UzbekApis/flutter-manga-app.git

# 5. Build
%cd /content/flutter-manga-app
!/content/flutter/bin/flutter pub get
!/content/flutter/bin/flutter build apk --release

# 6. Download
from google.colab import files
files.download('/content/flutter-manga-app/build/app/outputs/flutter-apk/app-release.apk')

print("\n✅ TAYYOR! APK yuklab olindi!")
```

═══════════════════════════════════════════════════════════

📝 QANDAY ISHLASH:

1. Colab ochish: https://colab.research.google.com
2. Yuqoridagi kodni copy qiling
3. Yangi cell'ga paste qiling
4. Run tugmasini bosing ▶️
5. ZIP faylni yuklang (flutter_manga_app.zip)
6. 15 daqiqa kuting ☕
7. APK yuklab olindi! 🎉

═══════════════════════════════════════════════════════════

⚠️ MUHIM:

• ZIP fayl nomi: flutter_manga_app.zip
• Ichida: flutter_manga_app/ papkasi
• Barcha fayllar to'g'ri joylashgan

═══════════════════════════════════════════════════════════

🎯 AGAR XATOLIK BO'LSA:

1. Runtime → Restart runtime
2. Qaytadan ishga tushiring
3. Sabr qiling, vaqt kerak

═══════════════════════════════════════════════════════════
