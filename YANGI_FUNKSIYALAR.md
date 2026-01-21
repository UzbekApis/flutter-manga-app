# 🎉 Yangi Qo'shilgan Funksiyalar

## 📌 Bosh Sahifa Rekomendatsiyalari

### 1. Spotlight Rekomendatsiyalar ⭐
- API dan avtomatik yuklanadi
- Eng yaxshi mangalarni ko'rsatadi
- Gorizontal scroll bilan ko'rish

### 2. Haftalik Mashhurlar 📈
- Oxirgi haftaning eng mashhur mangalari
- Har hafta yangilanadi
- Trend mangalarni topish oson

### 3. Oylik Mashhurlar 🔥
- Oxirgi oyning eng mashhur mangalari
- Har oy yangilanadi
- Eng ko'p o'qilgan mangalar

## 🏷️ Tag Bo'yicha Qidirish

### Asosiy Funksiyalar
- **500+ Tag**: Barcha mavjud taglar
- **Ko'p Taglar**: Bir nechta tagni birga tanlash
- **Filtr**: Kerakli taglarni qo'shish/olib tashlash
- **Natijalar**: Tag bo'yicha manga ro'yxati

### Qanday Ishlaydi?

1. **Tag Tanlash**:
   - Bosh sahifada "Tag bo'yicha qidirish" tugmasini bosing
   - Taglar ro'yxatidan keraklilarini tanlang
   - Tanlangan taglar yuqorida ko'rinadi

2. **Qidirish**:
   - "Qidirish" tugmasini bosing
   - Natijalar yangi sahifada ochiladi
   - Grid ko'rinishda mangalar

3. **Filtr Qo'shish**:
   - Qo'shimcha taglar qo'shing
   - Yana qidiring
   - Natijalar yangilanadi

### Tag Turlari

#### Janrlar
- Action, Fantasy, Romance, Comedy
- Horror, Mystery, Thriller, Drama
- Sci-Fi, Supernatural, Adventure

#### Personajlar
- Male Protagonist, Female Protagonist
- Overpowered MC, Weak to Strong
- Vampire, Wizard, Samurai, Ninja

#### Muhit
- School, Fantasy World, Modern
- Medieval, Post-Apocalyptic, Space
- Urban, Coastal, Underworld

#### Mavzular
- Isekai, Reincarnation, Time Travel
- System, Cultivation, Magic
- Harem, Romance, Friendship

#### Demografiya
- Shounen, Seinen, Shoujo, Josei
- Kids, Xianxia, Murim

## 🔧 Texnik Ma'lumotlar

### API Endpointlar

1. **Bosh Sahifa**:
```
operationName: fetchMainPage
sha256Hash: c1a427930add310e7e68870182c3b17a84b3bac00a46bed07b72d0760f5fd09a
```

2. **Mashhur Mangalar**:
```
operationName: fetchPopularMangaByPeriod
sha256Hash: 896d217de6cea8cedadd67abbfeed5e17589e77708d1e38b4f6a726ae409ca67
period: WEEK yoki MONTH
```

3. **Taglar Ro'yxati**:
```
operationName: fetchMangaFilters
sha256Hash: ba3a84e0b5ace4cc30f9c542ac73264d95eefcc67700f9b42214373055e36fb5
```

4. **Tag Bo'yicha Qidirish**:
```
operationName: fetchMangas
sha256Hash: 2e239cbedda2c8af91bb0f86149b26889f2f800dc08ba36417cdecb91614799e
```

### Yangi Fayllar

- `test_api.py` - API testlari (Python)
- Yangilangan `lib/services/api_service.dart`
- Yangilangan `lib/providers/manga_provider.dart`
- Yangilangan `lib/screens/home_screen.dart`

### Yangi Metodlar

**ApiService**:
- `getMainPage()` - Bosh sahifa ma'lumotlari
- `getPopularManga()` - Mashhur mangalar
- `getMangaFilters()` - Taglar ro'yxati
- `fetchMangasByTags()` - Tag bo'yicha qidirish

**MangaProvider**:
- `loadRecommendations()` - Rekomendatsiyalarni yuklash
- `loadPopularWeekly()` - Haftalik mashhurlarni yuklash
- `loadPopularMonthly()` - Oylik mashhurlarni yuklash
- `loadAllTags()` - Barcha taglarni yuklash
- `addTag()` - Tag qo'shish
- `removeTag()` - Tag olib tashlash
- `fetchByTags()` - Tag bo'yicha qidirish

## 📱 Yangi Ekranlar

### 1. TagFilterScreen
- Barcha taglarni ko'rsatadi
- Taglarni tanlash/olib tashlash
- Tanlangan taglarni ko'rsatish
- Qidirish tugmasi

### 2. TagResultsScreen
- Qidirish natijalari
- Grid ko'rinish
- Manga kartochkalari
- Batafsil sahifaga o'tish

## 🎨 Interfeys Yangiliklari

### Bosh Sahifa
- Rekomendatsiyalar bo'limi
- Haftalik mashhurlar bo'limi
- Oylik mashhurlar bo'limi
- Tag qidirish tugmasi
- Gorizontal scroll
- Chiroyli kartochkalar

### Ranglar
- ⭐ Sariq - Rekomendatsiyalar
- 📈 Yashil - Haftalik
- 🔥 To'q sariq - Oylik
- 🏷️ Binafsha - Taglar

## 💡 Foydalanish Misollari

### Misol 1: Action Manga Topish
1. "Tag bo'yicha qidirish" ni bosing
2. "action" tagini tanlang
3. "Qidirish" ni bosing
4. Natijalarni ko'ring

### Misol 2: Isekai + Fantasy
1. "Tag bo'yicha qidirish" ni bosing
2. "isekai" va "fantasy" taglarini tanlang
3. "Qidirish" ni bosing
4. Ikkala tagga mos mangalar ko'rinadi

### Misol 3: Mashhurlarni Ko'rish
1. Bosh sahifaga o'ting
2. Pastga scroll qiling
3. "Haftalik Mashhurlar" yoki "Oylik Mashhurlar" ni ko'ring
4. Istalgan mangani bosing

## 🚀 Kelajakda Qo'shilishi Mumkin

- [ ] Tag exclude funksiyasi (istalmagan taglarni chiqarish)
- [ ] Saqlangan filtrlar
- [ ] Filtr presetlari (masalan: "Action Isekai", "Romance School")
- [ ] Tag bo'yicha statistika
- [ ] Eng ko'p ishlatiladigan taglar
- [ ] Tag tavsiyalari

## 🧪 Test Qilish

Python test faylini ishga tushiring:
```bash
python test_api.py
```

Natijalar:
- ✅ Bosh sahifa rekomendatsiyalari
- ✅ Oylik mashhur mangalar
- ✅ Haftalik mashhur mangalar
- ✅ Taglar ro'yxati (500+ ta)
- ✅ Tag bo'yicha qidirish
- ✅ Ko'p taglar bilan qidirish

## 📊 Statistika

- **Taglar soni**: 500+
- **Rekomendatsiyalar**: ~20 ta
- **Mashhurlar**: ~20 ta (haftalik/oylik)
- **Qidirish natijalari**: ~20 ta (har bir so'rov)

## ✨ Xususiyatlar

- **Tez yuklash**: Cache mexanizmi
- **Offline qo'llab-quvvatlash**: Yuklab olingan mangalar
- **Inglizcha nomlar**: Ruscha o'rniga
- **Chiroyli interfeys**: Material Design 3
- **Responsive**: Har qanday ekran o'lchami

Yaxshi foydalanish! 🎉
