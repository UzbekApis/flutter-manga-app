# Manga Reader - To'liq Funksional Ilova

Flutter yordamida yaratilgan professional manga o'qish ilovasi.

## ✨ Asosiy Funksiyalar

### 📚 Manga Boshqaruvi
- **Qidirish**: Minglab manga va manhvalarni qidiring
- **Batafsil Ma'lumot**: Har bir manga haqida to'liq ma'lumot
- **Inglizcha Interfeys**: Ruscha so'zlar o'rniga inglizcha nomlar

### ❤️ Sevimlilar
- Yoqqan mangalarni sevimlilar ro'yxatiga qo'shing
- Tez kirish uchun alohida sahifa
- Chiroyli grid ko'rinish

### 📖 O'qiyotganlar
- Oxirgi o'qilgan joyni avtomatik saqlash
- Qayerda qolganingizni aniq ko'rsatish
- "Davom etish" tugmasi bilan tezkor kirish
- Har bir manga uchun progress tracking

### 💾 Yuklab Olish
- **Bitta Chapter**: Istalgan chapterni yuklab oling
- **Ko'plab Chapterlar**: Bir nechta chapterni tanlang va yuklab oling
- **Hammasini Yuklab Olish**: Barcha chapterlarni bir bosishda yuklab oling
- **Offline O'qish**: Internetisz o'qing
- **Yuklab Olinganlar Sahifasi**: 
  - Manga rasmi va nomi
  - Nechta chapter yuklangani
  - Har bir chapterning sahifa soni
  - Tez o'chirish imkoniyati

### 🔔 Yangi Chapterlar Haqida Xabar
- Siz ko'rgan va saqlab qo'ygan mangalarga yangi chapter qo'shilsa avtomatik xabar
- Ilova ochilganda tekshirish
- Qancha yangi chapter qo'shilganini ko'rsatish

### 📱 Chiroyli Interfeys
- **Dark Mode**: Ko'zni charchatmaydigan qora tema
- **Gradient Ranglar**: Zamonaviy dizayn
- **Animatsiyalar**: Silliq o'tishlar
- **Responsive**: Har qanday ekran o'lchamiga moslashadi

### 📊 O'qish Tajribasi
- Sahifa raqamini ko'rsatish (masalan: 5/34)
- Avtomatik progress saqlash
- Keyingi/oldingi chapterga o'tish
- Offline yuklab olingan chapterlarni ko'rsatish

## 🚀 O'rnatish

```bash
# Dependencies o'rnatish
flutter pub get

# Ilovani ishga tushirish
flutter run
```

## 📦 Ishlatilgan Paketlar

- `provider` - State management
- `sqflite` - Local database
- `cached_network_image` - Rasm cache
- `dio` - Yuklab olish
- `http` - API so'rovlar
- `path_provider` - Fayl yo'llari

## 🎯 Texnik Xususiyatlar

### Database
- SQLite yordamida local ma'lumotlar saqlash
- 4 ta jadval:
  - `favorites` - Sevimlilar
  - `reading` - O'qiyotganlar va progress
  - `downloads` - Yuklab olinganlar
  - `manga_tracking` - Yangi chapterlar kuzatuvi

### API
- Senkuro API integratsiyasi
- GraphQL so'rovlar
- Xatoliklarni boshqarish
- Timeout va retry mexanizmi

### Offline Funksiyalar
- Chapterlarni local saqlash
- Offline o'qish imkoniyati
- Yuklab olingan rasmlarni cache qilish

## 📱 Ekranlar

1. **Home Screen** - Qidirish va asosiy menyu
2. **Manga Detail** - Batafsil ma'lumot va chapterlar
3. **Reader Screen** - Manga o'qish
4. **Favorites** - Sevimlilar ro'yxati
5. **Reading List** - O'qiyotganlar
6. **Downloads** - Yuklab olinganlar

## 🎨 Dizayn Xususiyatlari

- Material Design 3
- Dark theme
- Gradient colors
- Smooth animations
- Responsive layout
- Custom widgets

## 🔧 Kelajakda Qo'shilishi Mumkin

- [ ] Tilni o'zgartirish (O'zbek, Ingliz, Rus)
- [ ] Yorug' tema
- [ ] Izohlar va reytinglar
- [ ] Manga tavsiyalari
- [ ] Qidirish filtrlari
- [ ] Sozlamalar sahifasi

## 📄 Litsenziya

MIT License

## 👨‍💻 Muallif

Flutter Manga Reader - Professional manga o'qish tajribasi uchun yaratilgan.
