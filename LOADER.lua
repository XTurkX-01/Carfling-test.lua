-- ============================================================================
-- X MENU V52 — GitHub raw loader
-- ============================================================================
-- Kullanım:
--   1) Bu dosyayı GitHub deposunda şu isimle koy:
--         XMENU_V52_CLIENT_UI.raw.lua
--   2) Aşağıdaki URL'i kendi raw adresinle değiştir.
--   3) Executor'ın execute alanına BU dosyayı yapıştır ve çalıştır.
--
-- Raw URL biçimi:
--   https://raw.githubusercontent.com/<kullanici>/<depo>/<dal>/<dosya>.lua
--   (dal yerine commit SHA'sı yazarsan içerik sabitlenir; "main" dalı
--    değişirse eski kod çalışır — üretim için SHA önerilir)
--
-- Not: Studio'da denemek istersen HTTP isteklerinin açık olması gerekir
--       (Game Settings → Security → "Allow HTTP Requests").
-- ============================================================================

local URL = "https://raw.githubusercontent.com/KULLANICI/DEPO/main/XMENU_V52_CLIENT_UI.raw.lua"

-- 1) Kaynağı indir
local fetched, source = pcall(function()
	return game:HttpGet(URL)
end)

if not fetched or type(source) ~= "string" or #source == 0 then
	error("[X MENU UI] Kaynak indirilemedi: " .. tostring(source))
end

-- 2) Derle
--    Executor'lar loadstring'ı global tabloya yazar; _G üzerinden bakıyoruz.
local env: any = _G

local ok, chunk, compileError = pcall(function()
	local compile: any = env.loadstring or env.load
	if type(compile) ~= "function" then
		error("[X MENU UI] Bu ortamda loadstring/load yok.")
	end
	local runner: any = compile
	return runner(source, "XMENU_V52_CLIENT_UI")
end)

if not ok then
	error("[X MENU UI] Derleme hatası: " .. tostring(chunk))
end

if chunk == nil then
	error("[X MENU UI] Derleme hatası: " .. tostring(compileError))
end

-- 3) Çalıştır
--    Not: chunk "any" tipinde; nil kontrolü sonrası Luau daraltması çağrıyı
--    "non-callable" gösterdiği için ayrı bir any değişkene alınıp çağrılır.
local run: any = chunk
run()

print("[X MENU UI] Yüklendi. Ayarlar: sol üstteki düğme. Yönetici: sağ üstteki düğme (yetkili hesap).")
