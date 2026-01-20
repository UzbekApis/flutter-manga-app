"""
Google Colab'da Flutter APK build qilish scripti
Bu faylni Colab'ga yuklang va ishga tushiring
"""

import os
import subprocess
from pathlib import Path

def run_command(cmd, check=True):
    """Komandani ishga tushirish"""
    print(f"\n🔧 Running: {cmd}")
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.stdout:
        print(result.stdout)
    if result.stderr:
        print(result.stderr)
    if check and result.returncode != 0:
        raise Exception(f"Command failed: {cmd}")
    return result

def main():
    print("=" * 60)
    print("🚀 Flutter APK Builder for Google Colab")
    print("=" * 60)
    
    # 1. System packages
    print("\n📦 Installing system packages...")
    run_command("apt-get update -qq")
    run_command("apt-get install -y -qq curl git unzip xz-utils zip libglu1-mesa openjdk-11-jdk")
    
    # 2. Flutter o'rnatish
    print("\n📱 Installing Flutter...")
    if not Path("/content/flutter").exists():
        run_command("git clone https://github.com/flutter/flutter.git -b stable --depth 1 /content/flutter")
    
    flutter_bin = "/content/flutter/bin/flutter"
    os.environ['PATH'] = f"{os.environ['PATH']}:/content/flutter/bin"
    
    run_command(f"{flutter_bin} --version")
    
    # 3. Android SDK
    print("\n🤖 Installing Android SDK...")
    android_home = "/content/android-sdk"
    
    if not Path(android_home).exists():
        run_command("wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip")
        run_command(f"mkdir -p {android_home}/cmdline-tools")
        run_command(f"unzip -q commandlinetools-linux-9477386_latest.zip -d {android_home}/cmdline-tools")
        run_command(f"mv {android_home}/cmdline-tools/cmdline-tools {android_home}/cmdline-tools/latest")
    
    os.environ['ANDROID_HOME'] = android_home
    os.environ['ANDROID_SDK_ROOT'] = android_home
    
    sdkmanager = f"{android_home}/cmdline-tools/latest/bin/sdkmanager"
    
    # SDK packages
    print("\n📦 Installing Android SDK packages...")
    run_command(f'{sdkmanager} --sdk_root={android_home} "platform-tools" "platforms;android-33" "build-tools;33.0.2"')
    run_command(f"yes | {sdkmanager} --sdk_root={android_home} --licenses", check=False)
    
    # 4. Loyiha
    print("\n📂 Setting up project...")
    
    # Agar ZIP yuklangan bo'lsa
    zip_files = list(Path("/content").glob("*.zip"))
    if zip_files:
        print(f"Found ZIP: {zip_files[0]}")
        run_command(f"unzip -q {zip_files[0]} -d /content/")
    
    # Loyiha papkasini topish
    project_dir = None
    for possible_dir in ["/content/flutter_manga_app", "/content/manga_reader_app", "/content/app"]:
        if Path(possible_dir).exists():
            project_dir = possible_dir
            break
    
    if not project_dir:
        print("❌ Project directory not found!")
        print("Please upload flutter_manga_app.zip to Colab")
        return
    
    print(f"✅ Project found: {project_dir}")
    os.chdir(project_dir)
    
    # 5. Dependencies
    print("\n📦 Installing dependencies...")
    run_command(f"{flutter_bin} pub get")
    
    # 6. Build
    print("\n🔨 Building APK...")
    run_command(f"{flutter_bin} build apk --release")
    
    # 7. APK topish
    apk_path = f"{project_dir}/build/app/outputs/flutter-apk/app-release.apk"
    
    if Path(apk_path).exists():
        print("\n✅ BUILD SUCCESSFUL!")
        print(f"📱 APK location: {apk_path}")
        print(f"📊 APK size: {Path(apk_path).stat().st_size / 1024 / 1024:.2f} MB")
        
        # Download
        print("\n⬇️ Downloading APK...")
        try:
            from google.colab import files
            files.download(apk_path)
            print("✅ Download started!")
        except:
            print("⚠️ Manual download required")
            print(f"Download from: {apk_path}")
    else:
        print("\n❌ BUILD FAILED!")
        print("Check errors above")

if __name__ == "__main__":
    main()
