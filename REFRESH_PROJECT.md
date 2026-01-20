# 🔄 Loyihani yangilash (Colab'da)

Agar Colab'da eski versiya yuklangan bo'lsa, quyidagi cell'ni ishga tushiring:

```python
import os
import shutil

print("🔄 Loyihani yangilash...")

# Eski loyihani o'chirish
if os.path.exists('/content/flutter-manga-app'):
    print("📁 Eski loyihani o'chirish...")
    shutil.rmtree('/content/flutter-manga-app')
    print("✅ O'chirildi")

# Yangi versiyani yuklash
print("\n📥 Yangi versiyani yuklash...")
!git clone https://github.com/UzbekApis/flutter-manga-app.git

print("\n✅ Loyiha yangilandi!")
print("📌 Endi Cell 5 (Dependencies) dan davom eting")
```

Keyin Cell 5, 6, 7'ni ishga tushiring.
