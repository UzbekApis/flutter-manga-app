import requests
import json

url = "https://api.senkuro.me/graphql"
headers = {
    'accept': 'application/graphql-response+json',
    'content-type': 'application/json',
    'origin': 'https://senkuro.me',
    'referer': 'https://senkuro.me/',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
}

# Taglarni olish
payload = {
    'extensions': {
        'persistedQuery': {
            'sha256Hash': 'ba3a84e0b5ace4cc30f9c542ac73264d95eefcc67700f9b42214373055e36fb5',
            'version': 1
        }
    },
    'operationName': 'fetchMangaFilters'
}

print("Taglarni yuklash...")
response = requests.post(url, headers=headers, json=payload, timeout=15)
print(f"Status: {response.status_code}")

if response.status_code == 200:
    data = response.json()
    if 'errors' in data:
        print("XATOLIK:", json.dumps(data['errors'], indent=2))
    elif 'data' in data and 'mangaFilters' in data['data']:
        filters = data['data']['mangaFilters']
        labels = filters.get('labels', [])
        print(f"Topildi: {len(labels)} ta tag")
        
        if labels:
            print("\nBirinchi 5 ta:")
            for tag in labels[:5]:
                print(f"  - {tag['slug']}")
    else:
        print("Kutilmagan javob:", json.dumps(data, indent=2))
else:
    print("Xato:", response.text)
