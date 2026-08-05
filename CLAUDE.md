# Idle Farm Template — CLAUDE.md

## Proje
Godot 4.x ile yapılan hybrid casual idle mobil oyun şablonu.
iOS + Android. GDScript. Şablon yapı — tema değiştirilerek çoğaltılacak.
GitHub: https://github.com/borayldrmm/idle-farm-template

## Roller
- Bora: karar verir, test eder, deploy eder
- Claude: kod yazar, mimari kurar, hata giderir

## Teknik Kurallar
- Godot 4.x, GDScript
- Her sistem kendi scene dosyasında
- Autoload ile global state yönetimi
- Hardcode yasak — tüm değerler config dosyasından
- Her commit çalışan kod içerir
- Kırık kod commit edilmez

## Dil Kuralları
- Tüm kodlar, değişken isimleri, yorumlar İngilizce
- Tüm Git commit mesajları İngilizce
- Oyun içi tüm metinler İngilizce
- CLAUDE.md güncellemeleri Türkçe olabilir (Bora ile iletişim dili)

## Oyun Mekanikleri
- Idle kaynak üretimi (offline max 8 saat)
- Upgrade sistemi
- Manager/worker sistemi
- Sandık sistemi (standart, gold, platinum)
- Elmas ekonomisi
- Günlük/haftalık görevler
- Rewarded reklam (2x boost, süre hızlandır)
- Reklamsız paket (IAP)
- Lisanslı bölge sistemi

## Şablon Kuralları
- Tüm tema değerleri config dosyasından okunur
- Yeni oyun = fork + config + asset değişikliği
- Mekanikler dokunulmaz, sadece tema değişir

## Aşamalar
- [x] Godot kurulum + proje yapısı
- [x] GitHub repo + CLAUDE.md
- [x] Core loop (üret → harca → upgrade)
- [x] Manager sistemi + offline progress
- [x] UI sistemi
- [x] Sandık + IAP sistemi
- [ ] Reklam entegrasyonu
- [ ] Görev sistemi
- [ ] iOS + Android build
- [ ] Store yayını

## Mevcut Durum
Sandık sistemi tamamlandı ve test edildi. 3 tier çalışıyor,
rarity sistemi doğru, gem harcama doğru.
Sıradaki adım: Reklam entegrasyonu (rewarded + interstitial).

## Bir Sonraki Adım
Reklam sistemi: AdManager autoload, rewarded ad (2x boost),
interstitial ad, reklamsız IAP paketi altyapısı.
