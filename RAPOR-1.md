# X MENU V52 — Client Arayüz Raporu (TEK DOSYA)

**Tarih:** 29 Ekim 2026
**Teslim:** `XMENU_V52_CLIENT_UI.client.lua` — tek dosya, executor/Command Bar
tarzı **yapıştır-çalıştır**.
**Kapsam:** Sunucu tarafı **hazır** (`roblox_yetenek_antiexploit_rehberi.md`
modülleri). Bu çalışmada **sadece client arayüzü** yazıldı: yetenek çubuğu +
klavye + ayarlar menüsü + yönetici paneli. Sunucu tarafına **hiç dokunulmadı**.

---

## 1. Ne yapıldı (özet)

| Ekran | Durum | Dayanak |
|---|---|---|
| Yetenek çubuğu (ability bar) | **YAZILDI** (tek dosyanın Bölüm 2'si) | `roblox_ai_destek_paketi.md` §1.4–1.5 |
| Klavye ile yetenek (Z/X/C/V) | **YAZILDI** (Bölüm 3) | antiexploit rehberi §4.7 |
| **Ayarlar menüsü** | **YAZILDI** (Bölüm 4) — dokümanda kod yoktu, sözleşme vardı | `ui_baglanti_belgesi.md` §4 |
| **Yönetici paneli** | **YAZILDI** (Bölüm 5) — dokümanda kod yoktu, sözleşme vardı | `ui_baglanti_belgesi.md` §3 |
| Çift bildirim (toast) düzeltmesi | **YAPILDI** — tek bildirim kaynağı | `roblox_ai_destek_paketi.md` §1.6 |
| Mağaza ekranı | **YAZILMADI** — sunucusu yok, sadece §1.8 sözleşmesi var | `ui_baglanti_belgesi.md` §1.8 |

PDF **Adım 1 (UI/UX Modernizasyonu)** maddeleri arayüze uyarlandı:

- **Glassmorphism:** yarı saydam arka plan + neon `UIStroke` kenarlığı.
- **Hover efekti:** butonlarda `MouseEnter/MouseLeave` renk geçişi.
- **Tween geçişi:** pencere açılış/kapanışı `TweenService` ile yumuşak.
- **Etkileşimli kaydırıcı:** metin kutusu değil, sürüklenebilir slider.
- **Arayüz ölçeği:** `UIScale` ile tüm arayüz 0.8–1.25.

---

## 2. Tek dosyanın mimarisi

```
XMENU_V52_CLIENT_UI.client.lua   (1.557 satır, --!strict)
│
├─ ORTAK / PRELUDE   servisler, temizlik kaydı, remote bekleme
│                   (remote'lar hiçbir zaman OLUŞTURULMAZ, sadece bulunur)
├─ BÖLÜM 1  UIKit            pencere, buton, cooldown butonu, etiket, slider, toast
├─ BÖLÜM 2  Yetenek çubuğu  sunucudaki yetenekleri butonla gösterir
├─ BÖLÜM 3  Klavye           Z hız · X zıplama · C kalkan · V iyileşme
├─ BÖLÜM 4  Ayarlar menüsü  ses, parlaklık, kamera mesafesi, FOV, efekt, ölçek
└─ BÖLÜM 5  Yönetici paneli speed/god/heal/tp/bring/kick (yalnızca yetkili görünümü)
```

**Tekrar çalıştırma koruması:** script ikinci kez çalıştırılırsa `_G` kaydındaki
`Cleanup` çağrılır → eski `UIKitGui` yok edilir, tüm `RBXScriptConnection`
bağlantıları kesilir → arayüz üst üste binmez.

---

## 3. Çakışma analizi ("aynı işi yapan ikinci şey yok")

| Mevcut dosya | Durumu | Çakışma? |
|---|---|---|
| `XMENU_V52.lua` (8.929 satır) | Sunucu remote'larına **hiç bağlanmıyor** (`UseAbility`/`AbilityResult`/`AdminCommand`/`RequestRejoin` → 0 eşleşme) | **Yok.** Yeni ekranlar tamamlayıcısı. |
| `XMenuClient.client.lua` (1.618 satır) | Kendi `toast`/paneli var; yetenek barı, ayarlar, admin paneli **yok**. Farklı remote (`XMenuCommandBridge`) | **Yok.** Farklı remote, farklı iş. |
| `ChatBridge.server.lua` | Sadece sohbet komut köprüsü | **Yok.** |

`ScreenGui` adları: `UIKitGui` (ortak), `SettingsWindow`, `AdminWindow` —
eski menünün `ScreenGui`'siyle isim çakışması yok.

**Bildirim kaynağı tek yerinde:**

| Kanal | Dinleyen | Nerede |
|---|---|---|
| `AbilityResult` | Yetenek çubuğu (buton rengi + cooldown metni) | Bölüm 2 |
| `Notify` | Yönetici paneli (sonuç satırı) | Bölüm 5 |

Klavye bölümü `Notify`/`AbilityResult` **dinlemez** → çift toast yok.

---

## 4. Sunucu sözleşmesi uyumu (client sadece İSTEK yollar)

| Remote | Client ne yapar | Nerede |
|---|---|---|
| `UseAbility` | `FireServer(abilityId)` — yeteneğin **kimliği** | Bölüm 2, 3 |
| `AbilityResult` | `(abilityId, ok, reason, cooldownRemaining)` → buton durumu | Bölüm 2 |
| `Notify` | `(message)` → yönetici paneli sonucu | Bölüm 5 |
| `AdminCommand` | `FireServer(command, argument)` | Bölüm 5 |
| `RequestRejoin` | `FireServer()` | Bölüm 4 |

- Süre / cooldown / yetki / parametre **client'ta belirlenmez**; `reason`
  (`OK|Cooldown|Dead|Unknown|NotReady`) ve `cooldownRemaining` sunucudan gelir.
- Komut uzunluğu ≤ 20 karakter, argüman ≤ 100 karakter (istemci tarafı sınır).
- Hedeflemede `Player.Name` kullanılır (DisplayName benzersiz değildir).
- Yetkili olmayan hesapta yönetici paneli **hiç oluşturulmaz** (liste boşsa
  `isLocalAdmin == false` → panel kurulumu atlanır). Bu **görünürlük** ayarıdır,
  güvenlik değil; yetki yine sunucuda denetlenir.

---

## 5. Doğrulama

| Kontrol | Araç | Sonuç |
|---|---|---|
| Tip kontrolü | `luau-analyze --!strict` (Roblox API stub'ları ile) | **temiz** (3 dosya, 0 hata, 0 uyarı) |
| Runtime — normal oyuncu | sahte Roblox ortamı | **35 kontrol → TÜM TESTLER GEÇTİ** |
| Runtime — yönetici | sahte Roblox ortamı | **47 kontrol → TÜM TESTLER GEÇTİ** |
| Runtime — raw sürüm | aynı test, `.raw.lua` hedefi | **35 + 47 kontrol → GEÇTİ** |
| Loader uçtan uca | `HttpGet → loadstring → arayüz` | **4 kontrol → GEÇTİ** |

Runtime testi **teslim edilen tek dosyanın kendisini** çalıştırır (mock
ortam: Instance ağacı, `FireServer/FireClient`, sanal saat, `task.delay`,
`PlayerGui`, `TweenService/TweenInfo/UIScale/UIStroke` stub'ları). Kapsanan
başlıca davranışlar: yetenek butonu oluşma, cooldown metni, klavye ile
`FireServer`, ayar sliderlarının `math.clamp` sınırları, "varsayılana dön",
rejoin butonu, admin panelinin yetkisizde **oluşmaması**, komut biçimi
(`speed 50 Ali`), 3 saniye cevap yoksa uyarı, `Notify` cevabının sonuç
satırına düşmesi, **temizlik kaydının arayüzü kaldırması**.

Test dosyaları: `_verification/check.py` (tip), `_verification/runtime_test.py`
(runtime), `_verification/.check/` (üretilen geçici dosyalar).

---

## 6. Yazarken bulunan ve düzeltilen gerçek hatalar

| # | Hata | Düzeltme |
|---|---|---|
| 1 | `local x = f(function() x ... end)` — global sayımı (Luau) | Kapsam dışı isimle yeniden adlandırıldı |
| 2 | Admin paneli açılışta patlıyordu (slider'ın `OnChange` etiketten önce bağlanıyordu) | Bağlama sırası düzeltildi |
| 3 | `Instance.new()` strict cast eksikleri | Tüm çağrılara `:: ClassName` cast'i |
| 4 | `Activated:Disconnect()` — bağlantı saklanmıyordu | Bağlantılar `track()` ile toplanıyor |
| 5 | `useAbility == nil` daraltması eksikti | `if useAbility ~= nil then ... end` guard'ı |
| 6 | Birleşim sırasında `window`/`body`/`openButton` isim çakışması | `settingsWindow`/`adminWindow`, `settingsBody`/`adminBody`, `settingsOpenButton`/`adminOpenButton` |
| 7 | `(_G :: any)[REGISTRY_KEY] = {` belirsiz sözdizimi | `local sharedGlobals: any = _G` üzerinden atama |
| 8 | İç içe fonksiyonlarda upvalue nil daraltması çalışmıyordu | `commandRemote`/`notifyRemote` non-nil kopyaları |

---

## 7. Bilinen sınırlar ( dürüst not )

1. **Gerçek Roblox'ta çalıştırılmadı.** Tip kontrolü ve sahte ortam testi
   geçti; ama Roblox Studio'da elle denenmedi. Özellikle **mobil dokunma
   hissi**, kaydırıcının sürükleme konforu ve panel açılış animasyonu gözle
   kontrol edilmeli.
2. **Mağaza ekranı yazılmadı** — sunucu tarafı yok, sadece sözleşme var
   (§1.8). İstendiğinde ayrı ekran olarak eklenebilir.
3. **Ayarlar kalıcı değil** — kaydedilmez; sunucu başlama değerlerine döner.
4. **Sunucu tarafına dokunulmadı** — hiçbir remote oluşturulmadı/değiştirilmedi.
5. Yönetici paneli için `LOCAL_ADMIN_USER_IDS` tablosu **elle doldurulmalı**
   (sunucudaki `ADMIN_USER_IDS` ile aynı olmalı).

---

## 8. GitHub raw + loadstring dağıtımı

Kullanıcı sorusu: *"Hepsini GitHub'a koysam, raw yapıp loadstring ile çalışır mı?"*
→ **Evet, çalışır.** Bunun için ek bir sürüm üretildi:

| Dosya | Ne |
|---|---|
| `XMENU_V52_CLIENT_UI.raw.lua` | Host edilecek sürüm. `client.lua` ile **birebir aynı**, tek farkı ilk satırdaki `--!strict` yönergesinin olmaması. |
| `LOADER.lua` | `game:HttpGet(URL)` → `loadstring`/`load` → çalıştırma. Hata olursa mesajı basar (sessiz kalmaz). |
| `_verification/make_raw.py` | `client.lua` → `raw.lua` üreticisi (tek satır farkı, elle kopya yok). |

### `--!strict` neden kaldırıldı?

Luau derleyicisiyle **doğrudan ölçüldü**:

```
loadstring("--!strict\nlocal x: number = 5\nreturn x")  →  function (derlendi, çalıştı)
```

→ `--!strict` yalnızca **statik analiz** bayrağı; runtime davranışını değiştirmez
( Luau dokümanı: "mode'lar tip kontrolünü açar, çalışma zamanı etkisi yok").
Ama **Roblox'un `loadstring` bağlamında** motor seviyesinde ek bir kısıt
bulunabilir; kaynaklarda doğrulanamadı. Bedeli sıfır olduğu için (strict'i
kaldırmak hiçbir şeyi değiştirmiyor) **risk alınmadı** → `.raw.lua` sürümü
üretildi ve o da aynı testlerden geçirildi.

### Loader'ın gerçekten çalıştığı test edildi

Sahte ortamda `game:HttpGet` mock'landı, `loadstring` gerçek Luau derleyicisi
üzerinden çalıştı ve **arayüz gerçekten oluştu**:

```
✓ HttpGet mock URL'i çağrıldı
✓ fetch edilen kaynak boş değil
✓ loadstring sonrası arayüz oluştu
✓ temizlik kaydı oluştu
```

> Chunk **global ortamda** çalışır (Roblox'taki gibi) → mock'un servisleri
> global'e açılarak test edildi.

### Dikkat notları

- GitHub raw **önbellek** tutar → push'tan sonra birkaç saniye eski içerik
  gelebilir. Üretimde **commit SHA** ile sabitle.
- `loadstring` üçüncü taraf kod çalıştırmadır → sunucunun anti-exploit'i
  **kickleyebilir**. Kendi test sunucunda dene.
- Studio'da HTTP isteklerinin açık olması gerekir
  (Game Settings → Security → "Allow HTTP Requests").

---

## 9. Teslim içeriği

| Dosya | Ne |
|---|---|
| `XMENU_V52_CLIENT_UI.client.lua` | **TEK teslim dosyası** — Studio/Command Bar için (strict'li) |
| `XMENU_V52_CLIENT_UI.raw.lua` | GitHub raw + loadstring sürümü (strict başlığı yok) |
| `LOADER.lua` | GitHub raw yükleme parçası (URL yer tutuculu) |
| `KURULUM.md` | 4 kurulum yolu + ayarlar + sorun giderme |
| `RAPOR.md` | bu rapor |
| `_verification/` | tip kontrolü, runtime testi, loader testi, raw üreticisi |

> **Önemli:** Tek dosya yaklaşımına geçildiği için eski 5 modül dosyası
> (`UIKit.lua`, `UIClient.lua`, `AbilityClient.lua`, `SettingsClient.lua`,
> `AdminClient.lua`) **tek dosyanın içine katlandı ve ayrı dosya olarak
> kaldırıldı**. Bunları Studio'ya koyma; yalnızca `XMENU_V52_CLIENT_UI.client.lua`
> dosyasını koy (aksi halde arayüz iki kez oluşur).
