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
    """Bosh sahifa rekomendatsiyalari"""
    print("\n=== BOSH SAHIFA REKOMENDATSIYALARI ===")
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
    
    if 'data' in data and 'mainPage' in data['data']:
        main_page = data['data']['mainPage']
        print(f"✅ Muvaffaqiyatli! Quyidagi bo'limlar mavjud:")
        for key in main_page.keys():
            print(f"  - {key}")
        
        # Manga spotlight
        if 'mangaSpotlight' in main_page and main_page['mangaSpotlight']:
            spotlight = main_page['mangaSpotlight']
            print(f"\n📌 Spotlight Manga: {len(spotlight)} ta")
            for manga in spotlight[:3]:
                titles = manga.get('titles', [])
                name = next((t['content'] for t in titles if t['lang'] == 'EN'), 'Unknown')
                print(f"  - {name}")
    else:
        print(f"❌ Xatolik: {data}")
    
    return data

def test_popular_monthly():
    """Oylik mashhur mangalar"""
    print("\n=== OYLIK MASHHUR MANGALAR ===")
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
    
    if 'data' in data and 'popularMangaByPeriod' in data['data']:
        mangas = data['data']['popularMangaByPeriod']
        print(f"✅ {len(mangas)} ta manga topildi")
        for manga in mangas[:5]:
            titles = manga.get('titles', [])
            name = next((t['content'] for t in titles if t['lang'] == 'EN'), 'Unknown')
            print(f"  - {name}")
    else:
        print(f"❌ Xatolik: {data}")
    
    return data

def test_popular_weekly():
    """Haftalik mashhur mangalar"""
    print("\n=== HAFTALIK MASHHUR MANGALAR ===")
    payload = {
        "extensions": {
            "persistedQuery": {
                "sha256Hash": "896d217de6cea8cedadd67abbfeed5e17589e77708d1e38b4f6a726ae409ca67",
                "version": 1
            }
        },
        "operationName": "fetchPopularMangaByPeriod",
        "variables": {"period": "WEEK"}
    }
    
    response = requests.post(BASE_URL, headers=HEADERS, json=payload)
    data = response.json()
    
    if 'data' in data and 'popularMangaByPeriod' in data['data']:
        mangas = data['data']['popularMangaByPeriod']
        print(f"✅ {len(mangas)} ta manga topildi")
        for manga in mangas[:5]:
            titles = manga.get('titles', [])
            name = next((t['content'] for t in titles if t['lang'] == 'EN'), 'Unknown')
            print(f"  - {name}")
    else:
        print(f"❌ Xatolik: {data}")
    
    return data

def test_manga_filters():
    """Taglar ro'yxati"""
    print("\n=== TAGLAR RO'YXATI ===")
    payload = {
        "extensions": {
            "persistedQuery": {
                "sha256Hash": "ba3a84e0b5ace4cc30f9c542ac73264d95eefcc67700f9b42214373055e36fb5",
                "version": 1
            }
        },
        "operationName": "fetchMangaFilters"
    }
    
    response = requests.post(BASE_URL, headers=HEADERS, json=payload)
    data = response.json()
    
    if 'data' in data and 'mangaFilters' in data['data']:
        filters = data['data']['mangaFilters']
        print(f"✅ Filtrlar topildi:")
        
        if 'labels' in filters:
            labels = filters['labels']
            print(f"\n📌 Taglar: {len(labels)} ta")
            for label in labels[:10]:
                print(f"  - {label['slug']}: {label.get('name', 'No name')}")
        
        if 'types' in filters:
            types = filters['types']
            print(f"\n📌 Turlar: {len(types)} ta")
            for t in types:
                print(f"  - {t}")
    else:
        print(f"❌ Xatolik: {data}")
    
    return data

def test_fetch_by_tags():
    """Tag bo'yicha qidirish"""
    print("\n=== TAG BO'YICHA QIDIRISH (male_protagonist) ===")
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
                "exclude": ["female_protagonist"],
                "include": ["male_protagonist"]
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
    
    if 'data' in data and 'mangas' in data['data']:
        edges = data['data']['mangas']['edges']
        print(f"✅ {len(edges)} ta manga topildi")
        for edge in edges[:5]:
            manga = edge['node']
            titles = manga.get('titles', [])
            name = next((t['content'] for t in titles if t['lang'] == 'EN'), 'Unknown')
            print(f"  - {name}")
    else:
        print(f"❌ Xatolik: {data}")
    
    return data

def test_multiple_tags():
    """Ko'p taglar bilan qidirish"""
    print("\n=== KO'P TAGLAR BILAN QIDIRISH (action + fantasy) ===")
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
                "include": ["action", "fantasy"]
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
    
    if 'data' in data and 'mangas' in data['data']:
        edges = data['data']['mangas']['edges']
        print(f"✅ {len(edges)} ta manga topildi")
        for edge in edges[:5]:
            manga = edge['node']
            titles = manga.get('titles', [])
            name = next((t['content'] for t in titles if t['lang'] == 'EN'), 'Unknown')
            print(f"  - {name}")
    else:
        print(f"❌ Xatolik: {data}")
    
    return data

if __name__ == "__main__":
    print("🚀 API TESTLARI BOSHLANDI\n")
    
    # Barcha testlarni ishga tushirish
    test_main_page()
    test_popular_monthly()
    test_popular_weekly()
    test_manga_filters()
    test_fetch_by_tags()
    test_multiple_tags()
    
    print("\n✅ BARCHA TESTLAR TUGADI!")
