# 🚀 Flutter Manga App - Colab Build Guide (FINAL)

Bu qo'llanma orqali siz **Flutter Manga App** loyihasini Google Colab yordamida **APK** formatida qurishingiz mumkin. Bu eng ishonchli va tekshirilgan usul.

## 📋 Talablar

- Google Account
- Google Colab (Free versiyasi yetarli)
- Sabr (taxminan 20 daqiqa)

## 🛠️ Bosqichma-bosqich Yo'riqnoma

### 1. Google Colab'ni oching

[Yangi Colab Notebook ochish](https://colab.research.google.com/#create=true)

### 2. Quyidagi kodni nusxalang va Colab'dagi birinchi cell'ga tashlang

```python
import os
import sys
from google.colab import files

def run_step(step_name, command, check_path=None):
    print(f"\n🚀 {step_name}...")
    result = os.system(command)
    if result != 0:
        print(f"❌ {step_name} xatolik bilan tugadi!")
        sys.exit(1)
    if check_path and not os.path.exists(check_path):
        print(f"❌ {step_name}: {check_path} topilmadi!")
        sys.exit(1)
    print(f"✅ {step_name} muvaffaqiyatli!")

# 1. Tizim kutubxonalarini o'rnatish
run_step(
    "Tizim kutubxonalarini o'rnatish",
    "apt-get update -qq && apt-get install -y -qq curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk cmake ninja-build"
)

# 2. Flutter o'rnatish
if not os.path.exists('/content/flutter'):
    run_step(
        "Flutter yuklash",
        "git clone https://github.com/flutter/flutter.git -b stable --depth 1",
        "/content/flutter/bin/flutter"
    )

# PATH sozlash
os.environ['PATH'] = f"{os.environ['PATH']}:/content/flutter/bin"

# 3. Android SDK o'rnatish
if not os.path.exists('/content/android-sdk'):
    run_step(
        "Android SDK yuklash",
        "wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip"
    )
    run_step(
        "Android SDK arxivdan chiqarish",
        "mkdir -p /content/android-sdk/cmdline-tools && unzip -q commandlinetools-linux-9477386_latest.zip -d /content/android-sdk/cmdline-tools && mv /content/android-sdk/cmdline-tools/cmdline-tools /content/android-sdk/cmdline-tools/latest",
        "/content/android-sdk/cmdline-tools/latest/bin/sdkmanager"
    )
    
    # Environment variables
    os.environ['ANDROID_HOME'] = '/content/android-sdk'
    os.environ['ANDROID_SDK_ROOT'] = '/content/android-sdk'
    
    run_step(
        "Android SDK paketlarini o'rnatish",
        "yes | /content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk 'platform-tools' 'platforms;android-33' 'build-tools;33.0.2'",
        "/content/android-sdk/platform-tools/adb"
    )
    
    run_step(
        "Litsenziyalarni qabul qilish",
        "yes | /content/android-sdk/cmdline-tools/latest/bin/sdkmanager --sdk_root=/content/android-sdk --licenses"
    )

# 4. Loyihani yuklash
if not os.path.exists('/content/flutter-manga-app'):
    run_step(
        "Loyihani klonlash",
        "git clone https://github.com/UzbekApis/flutter-manga-app.git",
        "/content/flutter-manga-app"
    )

# 5. Build qilish
os.chdir('/content/flutter-manga-app')
run_step(
    "Dependencies o'rnatish",
    "/content/flutter/bin/flutter pub get"
)

run_step(
    "APK Build qilish",
    "/content/flutter/bin/flutter build apk --release",
    "/content/flutter-manga-app/build/app/outputs/flutter-apk/app-release.apk"
)

# 6. Yuklab olish
print("\n🎉 Build muvaffaqiyatli yakunlandi!")
print("⬇️ APK yuklab olinmoqda...")
files.download('/content/flutter-manga-app/build/app/outputs/flutter-apk/app-release.apk')
```

### 3. Ishga tushirish

1. Cell chap tomonidagi **Play** (▶️) tugmasini bosing.
2. Jarayonni kuzating. Hammasi avtomatik bajariladi.
3. Yakunida `app-release.apk` fayli avtomatik yuklab olinadi.

## ❓ Muammolar yuzaga kelsa

- **"Out of memory"**: Runtime -> Restart runtime qilib qayta urinib ko'ring.
- **"Network error"**: Internet aloqasini tekshiring va qayta urinib ko'ring.
- **Build uzoq vaqt qotib qolsa**: Sahifani yangilang va qaytadan boshlang.

---
**Eslatma**: Bu skript har doim eng so'nggi barqaror Flutter versiyasini va kerakli Android SDK vositalarini o'rnatadi.
