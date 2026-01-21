import requests
import json

BASE_URL = 'https://api.senkuro.me/graphql'
HEADERS = {
    'accept': 'application/graphql-response+json',
    'content-type': 'application/json',
    'origin': 'https://senkuro.me',
    'referer': 'https://senkuro.me/',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
}

def test_main_page():
    """Bosh sahifa rekomendatsiyalarini test qilish"""
    print("\n🧪 BOSH SAHIFA REKOMENDATSIYALARI TEST")
    print("=" * 60)
    
    payload = {
        "extensions": {
            "persistedQuery": {
                "sha256Hash": "c1a427930add310e7e68870182c3b17a84b3bac00a46bed07b72d0760f5fd09a",
                "version": 1
            }
        },
        "operationName": "fetchMainPage",
        "variables": {
            "label": {"exclude": ["female_protagonist"]},
            "skipAnime": True,
            "skipLabelsSpotlight": False,
            "skipManga": False,
            "skipPosts": True
        }
    }
    
    response = requests.post(BASE_URL, headers=HEADERS, json=payload)
    data = response.json()
    
    # JSON strukturasini tekshirish
    print("\n📊 JSON Struktura:")
    if 'data' in data:
        print("✅ 'data' mavjud")
        if 'mainPage' in data['data']:
            print("✅ 'mainPage' mavjud")
            main_page = data['data']['mainPage']
            
            # Spotlight
            if 'mangaSpotlight' in main_page:
                spotlight = main_page['mangaSpotlight']
                print(f"✅ 'mangaSpotlight' mavjud: {len(spotlight)} ta manga")
                
                if spotlight:
                    first = spotlight[0]
                    print(f"\n📌 Birinchi manga:")
                    print(f"   ID: {first.get('id')}")
                    print(f"   Slug: {first.get('slug')}")
                    
                    # Titles tekshirish
                    if 'titles' in first:
                        titles = first['titles']
                        print(f"   Titles: {len(titles)} ta")
                        for title in titles:
                            print(f"      - {title.get('lang')}: {title.get('content')}")
                    
                    # Cover tekshirish
                    if 'cover' in first:
                        cover = first['cover']
                        if 'preview' in cover:
                            print(f"   Cover preview: {cover['preview'].get('url')[:50]}...")
            else:
                print("❌ 'mangaSpotlight' yo'q")
        else:
            print("❌ 'mainPage' yo'q")
    else:
        print("❌ 'data' yo'q")
        print(f"Response: {data}")
    
    # JSON faylga saqlash
    with open('main_page_response.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"\n💾 JSON saqlandi: main_page_response.json")
    
    return data

def test_popular_manga():
    """Mashhur mangalarni test qilish"""
    print("\n🧪 MASHHUR MANGALAR TEST")
    print("=" * 60)
    
    payload = {
        "extensions": {
            "persistedQuery": {
                "sha256Hash": "896d217de6cea8cedadd67abbfeed5e17589e77708d1e38b4f6a726ae409ca67",
                "version": 1
            }
        },
        "operationName": "fetchPopularMangaByPeriod",
        "variables": {"period": "MONTH"}
    }
    
    response = requests.post(BASE_URL, headers=HEADERS, json=payload)
    data = response.json()
    
    print("\n📊 JSON Struktura:")
    if 'data' in data and 'popularMangaByPeriod' in data['data']:
        mangas = data['data']['popularMangaByPeriod']
        print(f"✅ {len(mangas)} ta manga topildi")
        
        if mangas:
            first = mangas[0]
            print(f"\n📌 Birinchi manga:")
            print(f"   ID: {first.get('id')}")
            print(f"   Slug: {first.get('slug')}")
            
            if 'titles' in first:
                titles = first['titles']
                for title in titles:
                    print(f"   - {title.get('lang')}: {title.get('content')}")
    else:
        print("❌ Xatolik")
        print(f"Response: {data}")
    
    with open('popular_manga_response.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"\n💾 JSON saqlandi: popular_manga_response.json")
    
    return data

def test_manga_detail():
    """Manga detailni test qilish"""
    print("\n🧪 MANGA DETAIL TEST")
    print("=" * 60)
    
    # Eleceed manga
    payload = {
        "extensions": {
            "persistedQuery": {
                "sha256Hash": "6d8b28abb9a9ee3199f6553d8f0a61c005da8f5c56a88ebcf3778eff28d45bd5",
                "version": 1
            }
        },
        "operationName": "fetchManga",
        "variables": {"slug": "eleceed"}
    }
    
    response = requests.post(BASE_URL, headers=HEADERS, json=payload)
    data = response.json()
    
    print("\n📊 JSON Struktura:")
    if 'data' in data and 'manga' in data['data']:
        manga = data['data']['manga']
        print(f"✅ Manga topildi")
        print(f"   ID: {manga.get('id')}")
        print(f"   Slug: {manga.get('slug')}")
        
        # Titles
        if 'titles' in manga:
            print(f"\n   Titles:")
            for title in manga['titles']:
                print(f"      - {title.get('lang')}: {title.get('content')}")
        
        # Labels (Tags)
        if 'labels' in manga:
            labels = manga['labels']
            print(f"\n   Labels: {len(labels)} ta")
            for label in labels[:5]:
                if 'titles' in label:
                    for title in label['titles']:
                        if title.get('lang') == 'EN':
                            print(f"      - {title.get('content')}")
                            break
        
        # Description
        if 'localizations' in manga:
            locs = manga['localizations']
            for loc in locs:
                if loc.get('lang') == 'EN' and loc.get('description'):
                    print(f"\n   Description: {loc['description'][:100]}...")
                    break
    else:
        print("❌ Xatolik")
        print(f"Response: {data}")
    
    with open('manga_detail_response.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"\n💾 JSON saqlandi: manga_detail_response.json")
    
    return data

def test_tag_search():
    """Tag qidirish test"""
    print("\n🧪 TAG QIDIRISH TEST")
    print("=" * 60)
    
    payload = {
        "extensions": {
            "persistedQuery": {
                "sha256Hash": "2e239cbedda2c8af91bb0f86149b26889f2f800dc08ba36417cdecb91614799e",
                "version": 1
            }
        },
        "operationName": "fetchMangas",
        "variables": {
            "after": None,
            "bookmark": {"exclude": [], "include": []},
            "chapters": {},
            "format": {"exclude": [], "include": []},
            "label": {
                "exclude": [],
                "include": ["action"]
            },
            "orderDirection": "DESC",
            "orderField": "POPULARITY_SCORE",
            "originCountry": {"exclude": [], "include": []},
            "rating": {"exclude": [], "include": []},
            "releasedOn": {},
            "search": None,
            "source": {"exclude": [], "include": []},
            "status": {"exclude": [], "include": []},
            "translitionStatus": {"exclude": [], "include": []},
            "type": {"exclude": [], "include": []}
        }
    }
    
    response = requests.post(BASE_URL, headers=HEADERS, json=payload)
    data = response.json()
    
    print("\n📊 JSON Struktura:")
    if 'data' in data and 'mangas' in data['data']:
        edges = data['data']['mangas']['edges']
        print(f"✅ {len(edges)} ta manga topildi")
        
        if edges:
            first = edges[0]['node']
            print(f"\n📌 Birinchi manga:")
            print(f"   ID: {first.get('id')}")
            print(f"   Slug: {first.get('slug')}")
            
            if 'titles' in first:
                for title in first['titles']:
                    print(f"   - {title.get('lang')}: {title.get('content')}")
    else:
        print("❌ Xatolik")
        print(f"Response: {data}")
    
    with open('tag_search_response.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"\n💾 JSON saqlandi: tag_search_response.json")
    
    return data

if __name__ == "__main__":
    print("🚀 JSON PARSING TESTLARI BOSHLANDI\n")
    
    # Barcha testlar
    test_main_page()
    test_popular_manga()
    test_manga_detail()
    test_tag_search()
    
    print("\n" + "=" * 60)
    print("✅ BARCHA TESTLAR TUGADI!")
    print("=" * 60)
    print("\nJSON fayllar yaratildi:")
    print("  - main_page_response.json")
    print("  - popular_manga_response.json")
    print("  - manga_detail_response.json")
    print("  - tag_search_response.json")
