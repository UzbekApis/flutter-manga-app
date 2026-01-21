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

def get_all_chapters(branch_id):
    """Barcha chapterlarni pagination bilan olish"""
    all_chapters = []
    after_cursor = None
    page = 1
    
    while True:
        print(f"\n📄 Sahifa {page} yuklanmoqda...")
        
        payload = {
            'extensions': {
                'persistedQuery': {
                    'sha256Hash': '8c854e121f05aa93b0c37889e732410df9ea207b4186c965c845a8d970bdcc12',
                    'version': 1
                }
            },
            'operationName': 'fetchMangaChapters',
            'variables': {
                'after': after_cursor,
                'branchId': branch_id,
                'number': None,
                'orderBy': {'direction': 'DESC', 'field': 'NUMBER'}
            }
        }
        
        response = requests.post(BASE_URL, headers=HEADERS, json=payload)
        data = response.json()
        
        if 'data' not in data or 'mangaChapters' not in data['data']:
            print(f"❌ Xatolik: {data}")
            break
        
        manga_chapters = data['data']['mangaChapters']
        edges = manga_chapters.get('edges', [])
        page_info = manga_chapters.get('pageInfo', {})
        
        print(f"✅ {len(edges)} ta chapter topildi")
        
        # Chapterlarni qo'shish
        for edge in edges:
            chapter = edge['node']
            all_chapters.append({
                'number': chapter.get('number'),
                'slug': chapter.get('slug'),
                'name': chapter.get('name'),
            })
        
        # Keyingi sahifa bormi?
        has_next_page = page_info.get('hasNextPage', False)
        after_cursor = page_info.get('endCursor')
        
        print(f"   Keyingi sahifa: {has_next_page}")
        print(f"   Cursor: {after_cursor}")
        
        if not has_next_page or not after_cursor:
            break
        
        page += 1
    
    return all_chapters

def test_eleceed():
    """Eleceed mangasini test qilish"""
    print("🧪 ELECEED MANGA TEST")
    print("=" * 50)
    
    # Eleceed branch ID
    branch_id = "TUFOR0FfQlJBTkNIOjQ2MzU3MTA4NjY4NTg4NDQ2"
    
    chapters = get_all_chapters(branch_id)
    
    print(f"\n📊 NATIJALAR:")
    print(f"   Jami chapterlar: {len(chapters)}")
    
    if chapters:
        print(f"\n   Birinchi chapter: {chapters[0]['number']} - {chapters[0]['name']}")
        print(f"   Oxirgi chapter: {chapters[-1]['number']} - {chapters[-1]['name']}")
        
        # Birinchi 5 ta va oxirgi 5 ta
        print(f"\n   📌 Birinchi 5 ta:")
        for ch in chapters[:5]:
            print(f"      Chapter {ch['number']}: {ch['name'] or 'No name'}")
        
        print(f"\n   📌 Oxirgi 5 ta:")
        for ch in chapters[-5:]:
            print(f"      Chapter {ch['number']}: {ch['name'] or 'No name'}")
    
    return chapters

def test_different_cursors():
    """Turli cursorlarni test qilish"""
    print("\n\n🧪 CURSOR TEST")
    print("=" * 50)
    
    branch_id = "TUFOR0FfQlJBTkNIOjQ2MzU3MTA4NjY4NTg4NDQ2"
    cursors = [None, "gflVcA", "gflZ2A", "gflcfA"]
    
    for cursor in cursors:
        print(f"\n📍 Cursor: {cursor or 'None (birinchi sahifa)'}")
        
        payload = {
            'extensions': {
                'persistedQuery': {
                    'sha256Hash': '8c854e121f05aa93b0c37889e732410df9ea207b4186c965c845a8d970bdcc12',
                    'version': 1
                }
            },
            'operationName': 'fetchMangaChapters',
            'variables': {
                'after': cursor,
                'branchId': branch_id,
                'number': None,
                'orderBy': {'direction': 'DESC', 'field': 'NUMBER'}
            }
        }
        
        response = requests.post(BASE_URL, headers=HEADERS, json=payload)
        data = response.json()
        
        if 'data' in data and 'mangaChapters' in data['data']:
            edges = data['data']['mangaChapters']['edges']
            page_info = data['data']['mangaChapters']['pageInfo']
            
            print(f"   ✅ {len(edges)} ta chapter")
            if edges:
                first_ch = edges[0]['node']['number']
                last_ch = edges[-1]['node']['number']
                print(f"   Chapter range: {first_ch} - {last_ch}")
            print(f"   Has next: {page_info.get('hasNextPage')}")
            print(f"   End cursor: {page_info.get('endCursor')}")

if __name__ == "__main__":
    # Test 1: Barcha chapterlarni olish
    chapters = test_eleceed()
    
    # Test 2: Cursorlarni test qilish
    test_different_cursors()
    
    # JSON ga saqlash
    if chapters:
        with open('eleceed_chapters.json', 'w', encoding='utf-8') as f:
            json.dump(chapters, f, ensure_ascii=False, indent=2)
        print(f"\n💾 {len(chapters)} ta chapter 'eleceed_chapters.json' ga saqlandi")
    
    print("\n✅ BARCHA TESTLAR TUGADI!")
