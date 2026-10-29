# X MENU V52 — Kurulum (TEK DOSYA)

**Kurulacak dosya:** `XMENU_V52_CLIENT_UI.client.lua` — başka hiçbir dosya gerekmez.

---

## 1. Kurulum yolları (A–D: dört seçenek)

### Yol A — Studio (kalıcı, en temiz)
1. Roblox Studio'da `StarterPlayer` → `StarterPlayerScripts` → sağ tık → **Insert Object → LocalScript**.
2. Script'in adını `XMENU_V52_CLIENT_UI` yap (uzantı `.client.lua` olmasın).
3. `XMENU_V52_CLIENT_UI.client.lua` içeriğinin **tamamını** kopyalayıp yapıştır.
4. **Play**'e bas.

### Yol B — Command Bar (hızlı deneme)
1. **Play** modundayken **View → Command Bar**'ı aç.
2. Dosyanın tamamını kopyalayıp Command Bar'a yapıştır, **Enter**.
   - Roblox, uzun yapıştırmaları kesebilir: bu durumda Yol A'yı kullan.
3. Test bitince Stop'a bas (sunucu oyunu kapatır).

### Yol C — Executor (bildiğin gibi, en riskli)
1. Sunucuya girdikten sonra executor'ın **execute/çalıştır** alanına dosyanın
   tamamını yapıştır.
2. **Dikkat:** executor'lar oyunda sürekli kod çalıştırma izni verir; sunucunun
   anti-exploit koruması seni **kickleyebilir**. Sadece kendi test sunucunda
   dene. (Bu arayüz `FireServer` dışında **hiçbir şey** yapmaz — sunucu yetkilerini
   genişletmez, sadece sunucunun zaten kabul ettiği komutları gönderir.)

---

## 1-bis. Yol D — GitHub raw + loadstring (uzaktan güncelleme)

**Ne işe yarar:** Script'i GitHub'a koyup tek bir satırla çalıştırırsın.
Kodda değişiklik yapıp **push** ettiğinde, oyuncular aynı URL'den yeni sürümü
alır — kimseye yeni dosya göndermene gerek kalmaz.

### Adım 1 — Depoya koy

```
xmenu-v52/
└── XMENU_V52_CLIENT_UI.raw.lua   ← bu dosya (strict başlığı olmayan sürüm)
```

> **Neden `.raw.lua`?** `XMENU_V52_CLIENT_UI.client.lua` ilk satırında `--!strict`
> vardır. Bu yönerge yalnızca statik tip kontrolünü açar (runtime davranışını
> değiştirmez — Luau derleyicisiyle doğrulandı) ama Roblox'un `loadstring`
> bağlamında strict modlu chunk'ı reddedebilme ihtimali var. `raw` sürümü bu
> riski sıfırlar; geri kalan her satır birebir aynıdır ve aynı testlerden
> geçmiştir.

### Adım 2 — Raw URL'ni al

```
https://raw.githubusercontent.com/<kullanici>/<depo>/<dal>/XMENU_V52_CLIENT_UI.raw.lua
```

- `<dal>` yerine **commit SHA'sı** yazarsan içerik sabitlenir (`main` dalı
  değişirse eski kod çalışır). Üretim için SHA önerilir.
- GitHub → dosyaya tıkla → **Raw** butonu → adres çubuğundan kopyala.

### Adım 3 — Loader'ı çalıştır

`LOADER.lua` dosyasındaki `URL` satırını kendi raw adresinle değiştir, sonra
dosyanın tamamını executor'ın execute alanına yapıştır:

```lua
local URL = "https://raw.githubusercontent.com/KULLANICI/DEPO/main/XMENU_V52_CLIENT_UI.raw.lua"
-- ... LOADER.lua'nın geri kalanı ...
```

Loader ne yapar: `game:HttpGet(URL)` → kaynağı indirir → `loadstring`/`load`
ile derler → çalıştırır. Hata olursa **hata mesajını ekrana basar** (sessiz
kalmaz).

### Adım 4 — Kontrol

Console'da şunu görmelisin:

```
[X MENU UI] Hazır. Ayarlar: sol üstteki düğme. Yönetici: sağ üstteki düğme (yetkili hesap).
```

Bu mesajı görmüyorsan:
| Belirti | Sebep |
|---|---|
| "Kaynak indirilemedi" | URL yanlış / repo gizli / dosya adı farklı / HTTP kapalı |
| "Derleme hatası: ..." | İndirilen içerik Lua değil (GitHub 404 sayfası HTML dönmüş olabilir) |
| "Bu ortamda loadstring/load yok" | Kullandığın executor `loadstring` sağlamıyor → başka executor dene |

> **Studio'da test edeceksen:** HTTP istekleri kapalı gelir.
> **Game Settings → Security → "Allow HTTP Requests"** açılmalı.
> (Yayınlanan oyunda bu ayrıdır; executor'da genelde sorun olmaz.)

### Dikkat

- `loadstring` **üçüncü taraf kod çalıştırma** demektir: sunucunun anti-exploit
  koruması seni **kickleyebilir**. Kendi test sunucunda dene.
- GitHub raw **önbellek** tutar: push'tan sonra birkaç saniye eski içerik
  gelebilir. Sorun olursa URL'ye `?t=<timestamp>` ekleyebilirsin.

---

## 3. Yönetici panelini açmak

Panel **yalnızca** aşağıdaki tabloya kendi `UserId`’ni yazarsan görünür:

```lua
-- XMENU_V52_CLIENT_UI.client.lua içinde, BÖLÜM 5'in başında
local LOCAL_ADMIN_USER_IDS: { [number]: boolean } = {
	-- [123456789] = true, -- ← KENDİ UserId'ni yaz
}
```

- **UserId’ni nereden bulursun?** Roblox profil adresin:
  `https://www.roblox.com/users/<sayı>/profile` → sondaki sayı = UserId.
  (Roblox Studio → **View → Players** sekmesinde de yazar.)
- Bu liste **görünürlük** ayarıdır, güvenlik değil. Gerçek yetki kontrolü
  sunucudaki `AdminCommands` modülünde UserId ile yapılır; liste boş olsa bile
  sunucu seni yönetici saymaz.
- Tablo boşsa veya UserId’n eşleşmezse **panel hiç oluşturulmaz** (düğme de
  görünmez). Bu normal davranıştır.
- Sunucudaki `ADMIN_USER_IDS` ile **aynı** UserId olmalı.

---

## 4. Ayarlar menüsü — ne işe yarar

Sol üstteki **⚙ Ayarlar** düğmesi:

| Ayar | Aralık | Etki |
|---|---|---|
| Müzik / SFX ses seviyesi | 0 – 1 | `SoundService` group volume |
| Parlaklık | 0 – 4 | `Lighting.Brightness` |
| Kamera mesafesi | 4 – 60 | `CameraMaxZoomDistance` (Min = min(zoom, 6)) |
| FOV | 60 – 100 | `Camera.FieldOfView` |
| Gölgeler (GlobalShadows) | açık/kapalı | `Lighting.GlobalShadows` |
| Arayüz ölçeği | 0.8 – 1.25 | `UIScale` (tüm arayüz) |
| Varsayılana dön | — | script başlangıç değerlerine geri döner |

- Değerler **kaydedilmez**; oyun yeniden başlayınca eski değerlere döner.
- `CharacterAdded` veya kamera değişince ayarlar otomatik yeniden uygulanır.
- Bu ayarlar **yetki vermez**, sadece görünüm/ses değiştirir.

---

## 5. Klavye

| Tuş | Yetenek |
|---|---|
| `Z` | SpeedBoost (hız) |
| `X` | HighJump (yüksek zıplama) |
| `C` | Shield (kalkan) |
| `V` | Heal (iyileşme) |

Tuşlar **sadece** sohbete yazarken çalışmaz (odak sohbet kutusunda değilken
basılır). Cooldown/süre bilgisi sunucudan gelir; butonların üstünde yazar.

---

## 6. Yönetici paneli — komutlar

Komut **yazılmaz**; butonlara basılır (mobilde de çalışır).

| Buton | Sunucuya giden komut |
|---|---|
| Oyuncuya ışınlan | `tp <isim>` |
| Oyuncuyu yanıma getir | `bring <isim>` |
| Hızı uygula | `speed <0-100> <isim>` |
| Hızı sıfırla | `speed reset <isim>` |
| Tanrı modu | `god on/off <isim>` |
| İyileştir | `heal <isim>` |
| Oyuncu at | `kick <isim> <sebep>` |

- Cevap **her zaman `Notify` ile** gelir. 3 saniye cevap yoksa
  *"Yanıt yok (yetkin olmayabilir)"* yazılır.
- Hedef, listedeki **oyuncu adı (`Player.Name`)** ile seçilir — DisplayName
  değil (sunucu benzersiz olanı arar).

---

## 7. Sorun giderme

| Belirti | Sebep / Çözüm |
|---|---|
| Hiçbir arayüz çıkmıyor | Sunucu modülleri yüklü değil. Remote’lar `ReplicatedStorage/Remotes` altında mı kontrol et. Console’da `[X MENU UI]` uyarıları var. |
| Yönetici düğmesi yok | `LOCAL_ADMIN_USER_IDS` boş veya UserId eşleşmiyor (§2). |
| Yetenek butonları çıkmıyor | Sunucu yetenekleri `AbilityService` üzerinden yayınlamıyor olabilir; `AbilityResult` remote’u yoksa uyarı basılır. |
| Ayar değişmiyor | Değer `math.clamp` ile sınırlandı; kaydırıcı sınırların dışına çıkıyorsa değer uygulanmaz. |
| Arayüz iki kez görünüyor | Eski modül dosyaları (`UIKit.lua` vb.) hâlâ `StarterPlayerScripts` içinde → **onları sil**. Sadece `XMENU_V52_CLIENT_UI` kalsın. |
| Script'i ikinci çalıştırdım, üst üste binme | Olmaz: script eski arayüzü otomatik temizler (`_G` kaydı). |
| Konuşurken yetenek tuşu çalışmıyor | Normal — sohbet kutusu odaktayken tuşlar yazı olarak geçer. |

---

## 8. Kaldırma

`StarterPlayerScripts` içinden `XMENU_V52_CLIENT_UI` script’ini sil (veya
executor’da çalıştırdıysan `Cleanup` kaydı sayesinde yeniden çalıştırdığında
temizlenir). Sunucu tarafında hiçbir değişiklik yapılmadı, sunucuyu
etkilemez.

---

## 9. Doğrulama

Kendi makinende tekrar çalıştırmak istersen (opsiyonel):

```bash
cd _verification
python3 check.py         # luau-analyze --!strict → "all clean" (3 dosya)
python3 runtime_test.py  # sahte Roblox ortamı → 35 + 47 kontrol geçer
python3 loader_test.py   # raw URL → HttpGet → loadstring → arayüz oluşuyor (4 kontrol)
python3 make_raw.py      # .client.lua → .raw.lua (strict başlığı olmayan sürüm)
```
