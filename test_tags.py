import requests
import json

# Tag API'ni test qilish
url = "https://api.senkuro.me/graphql"

headers = {
    'accept': 'application/graphql-response+json',
    'content-type': 'application/json',
    'origin': 'https://senkuro.me',
    'referer': 'https://senkuro.me/',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
}

# 1. Taglarni olish
print("=" * 50)
print("1. TAGLARNI OLISH")
print("=" * 50)

payload_tags = {
    'extensions': {
        'persistedQuery': {
            'sha256Hash': 'ba3a84e0b5ace4cc30f9c542ac73264d95eefcc67700f9b42214373055e36fb5',
            'version': 1
        }
    },
    'operationName': 'fetchMangaFilters'
}

try:
    response = requests.post(url, headers=headers, json=payload_tags, timeout=15)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        
        if 'errors' in data:
            print("XATOLIK:", data['errors'])
        else:
            filters = data['data']['mangaFilters']
            labels = filters['labels']
            
            print(f"\nJami {len(labels)} ta tag topildi")
            print("\nBirinchi 10 ta tag:")
            for i, tag in enumerate(labels[:10]):
                slug = tag['slug']
                titles = tag['titles']
                en_title = next((t['content'] for t in titles if t['lang'] == 'EN'), slug)
                print(f"{i+1}. {en_title} ({slug})")
    else:
        print(f"Server xatosi: {response.status_code}")
        print(response.text)
        
except Exception as e:
    print(f"Xatolik: {e}")

# 2. Tag bo'yicha qidirish
print("\n" + "=" * 50)
print("2. TAG BO'YICHA QIDIRISH (action tag)")
print("=" * 50)

payload_search = {
    'extensions': {
        'persistedQuery': {
            'sha256Hash': '2e239cbedda2c8af91bb0f86149b26889f2f800dc08ba36417cdecb91614799e',
            'version': 1
        }
    },
    'operationName': 'fetchMangas',
    'variables': {
        'after': None,
        'bookmark': {'exclude': [], 'include': []},
        'chapters': {},
        'format': {'exclude': [], 'include': []},
        'label': {
            'exclude': [],
            'include': ['action']  # Action tag bilan test
        },
        'orderDirection': 'DESC',
        'orderField': 'POPULARITY_SCORE',
        'originCountry': {'exclude': [], 'include': []},
        'rating': {'exclude': [], 'include': []},
        'releasedOn': {},
        'search': None,
        'source': {'exclude': [], 'include': []},
        'status': {'exclude': [], 'include': []},
        'translitionStatus': {'exclude': [], 'include': []},
        'type': {'exclude': [], 'include': []}
    }
}

try:
    response = requests.post(url, headers=headers, json=payload_search, timeout=15)
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        data = response.json()
        
        if 'errors' in data:
            print("XATOLIK:", data['errors'])
        else:
            edges = data['data']['mangas']['edges']
            print(f"\n{len(edges)} ta manga topildi")
            
            print("\nBirinchi 5 ta manga:")
            for i, edge in enumerate(edges[:5]):
                node = edge['node']
                name = node.get('name', 'N/A')
                slug = node.get('slug', 'N/A')
                print(f"{i+1}. {name} ({slug})")
    else:
        print(f"Server xatosi: {response.status_code}")
        print(response.text)
        
except Exception as e:
    print(f"Xatolik: {e}")

print("\n" + "=" * 50)
print("TEST TUGADI")
print("=" * 50)
