# CHANGELOG — Xtray Script

Semua perubahan yang pernah dilakukan di project ini, dari awal hingga sekarang.
Format: `[Tanggal] versi — deskripsi`

---

## [2026-05-27] v2.2.0 — Full QuestData Overhaul (90 Entry, Fix NpcName→NameQuest)

### Games/BloxFruits.luau — QuestData & Quest Logic

#### Bug Kritis Diperbaiki
- **`StartQuest` salah parameter**: Ganti `quest.NpcName` ("Jungle Quest Giver") → `quest.NameQuest` ("JungleQuest") di `TryAcceptQuest` — sebelumnya SEMUA accept quest pasti gagal karena server BF butuh internal quest ID, bukan display name NPC
- **`TurnInQuest` salah parameter**: Sama — ganti `quest.NpcName` → `quest.NameQuest` di `TryCompleteQuest`
- **`QuestSlot` kini eksplisit di semua entry** — sebelumnya semua default slot 1, quest slot 2 tidak pernah di-accept dengan benar

#### QuestData — Rewrite Total (26 entry lama → 90 entry baru)

**Struktur field baru:**
- `NameQuest` — internal quest ID (untuk StartQuest/TurnInQuest)
- `QuestSlot` — nomor slot di NPC (1 atau 2)
- `MonPos` — posisi spawn musuh (untuk TweenFly ke area farm)

**Sea 1 — 26 entry (dari 16):**
- ✅ **Tambah**: Bandit (Lv1, BanditQuest1 slot1)
- ✅ **Tambah**: Chief Petty Officer (Lv120, MarineQuest2 slot1)
- ✅ **Fix**: Prison quest — Warden/Chief Warden (enemy tidak ada) → Prisoner (Lv190) + Dangerous Prisoner (Lv210), keduanya PrisonerQuest
- ✅ **Tambah**: Toga Warrior (Lv250, ColosseumQuest slot1)
- ✅ **Tambah**: Gladiator (Lv275, ColosseumQuest slot2)
- ✅ **Fix**: Magma Quest — dari Magma Ninja (salah level/enemy) → Military Soldier (Lv300) + Military Spy (Lv325), keduanya MagmaQuest
- ✅ **Tambah**: Fishman Warrior (Lv375, FishmanQuest slot1)
- ✅ **Tambah**: Fishman Commando (Lv400, FishmanQuest slot2)
- ✅ **Fix**: SkyExp — God's Guard pakai SkyExp1Quest (bukan SkyExpQuest), Shanda slot2 NpcPos benar
- ✅ **Tambah**: Royal Squad (Lv525, SkyExp2Quest slot1)
- ✅ **Tambah**: Royal Soldier (Lv550, SkyExp2Quest slot2)
- ✅ **Fix**: SkyQuest NpcPos akurat dari Gay Hub (bukan approx)

**Sea 2 — 22 entry (dari 12):**
- ✅ **Tambah**: Marine Lieutenant (Lv875, MarineQuest3 slot1)
- ✅ **Tambah**: Marine Captain (Lv900, MarineQuest3 slot2)
- ✅ **Fix**: IceSideQuest posisi benar — Lab Subordinate (Lv1100 slot1) + Horned Warrior (Lv1125 slot2)
- ✅ **Fix**: Magma Ninja posisi/quest benar — FireSideQuest slot1 (Lv1175, bukan 1150)
- ✅ **Tambah**: Lava Pirate (Lv1200, FireSideQuest slot2)
- ✅ **Fix**: Ship Quest — ShipQuest1 (Deckhand/Engineer) + ShipQuest2 (Steward/Officer, sebelumnya missing)
- ✅ **Tambah**: Ship Steward (Lv1300, ShipQuest2 slot1)
- ✅ **Tambah**: Ship Officer (Lv1325, ShipQuest2 slot2)
- ✅ **Fix**: ZombieQuest NpcPos akurat, ForgottenQuest NpcPos akurat

**Sea 3 — 42 entry (dari 10):**
- ✅ **Tambah**: Pistol Billionaire (Lv1525, PiratePortQuest slot2)
- ✅ **Tambah**: Dragon Crew Warrior + Archer (Lv1575/1600, DragonCrewQuest)
- ✅ **Tambah**: Hydra Enforcer + Venomous Assailant (Lv1625/1650, VenomCrewQuest)
- ✅ **Fix**: DeepForestIsland3 → Fishman Raider/Captain (Lv1775/1800)
- ✅ **Tambah**: Forest Pirate + Mythological Pirate (Lv1825/1850, DeepForestIsland)
- ✅ **Tambah**: Demonic Soul + Possessed Mummy (Lv2025/2050, HauntedQuest2)
- ✅ **Tambah**: Peanut Scout + President (Lv2075/2100, NutsIslandQuest)
- ✅ **Tambah**: Ice Cream Chef + Commander (Lv2125/2150, IceCreamIslandQuest)
- ✅ **Tambah**: Cookie Crafter + Cake Guard (Lv2200/2225, CakeQuest1)
- ✅ **Tambah**: Baking Staff + Head Baker (Lv2250/2275, CakeQuest2)
- ✅ **Tambah**: Cocoa Warrior + Chocolate Bar Battler (Lv2300/2325, ChocQuest1)
- ✅ **Tambah**: Sweet Thief + Candy Rebel (Lv2350/2375, ChocQuest2)
- ✅ **Fix**: Candy Quest — CandyQuest1 (bukan CandyQuest) + Snow Demon (Lv2425 slot2)
- ✅ **Tambah**: Isle Outlaw + Island Boy (Lv2450/2475, TikiQuest1)
- ✅ **Tambah**: Isle Champion (Lv2525, TikiQuest2)
- ✅ **Tambah**: Serpent Hunter + Skull Slayer (Lv2550/2575, TikiQuest3)

**Sea 4 (Submerged) — 5 entry baru:**
- ✅ **Tambah**: Reef Bandit + Coral Pirate (Lv2600/2625, SubmergedQuest1)
- ✅ **Tambah**: Sea Chanter (Lv2650, SubmergedQuest2)
- ✅ **Tambah**: High Disciple + Grand Devotee (Lv2675/2700, SubmergedQuest3)

#### UI Messages
- Ganti `quest.NpcName` → `quest.Name` di 2 status message (FarmLv + QuestStatus)

**Sumber data**: Gay Hub CheckQuest (sumber utama) + Hoho_Check_Quest.lua (validasi CFrame) + Eclipse Hub (cross-check)

---

## [2026-05-27] v2.1.0 — Upgrade TweenFly + BringEnemy (Multi-Source)

### Games/BloxFruits.luau — Logika saja (UI tidak diubah)

#### TweenFlyTo — Ganti Engine (redzplock technique)
- **Hapus** ketergantungan `TweenModule` dari URL eksternal (newredzv3) — tidak lagi bisa gagal karena URL down
- **Ganti** dengan native `TweenService:Create(hrp, ...)` langsung pada HumanoidRootPart
- **Tambah** `CurrentFlyTween` tracker — bisa di-cancel kapanpun via `StopFlyTween()`
- **Blocking** kini pakai `PlaybackState == Playing` — lebih akurat dari polling `IsTweening()` tiap 0.05s
- Rumus waktu: `dist / speed` (proporsional jarak) — semakin jauh semakin lama, bukan fixed

#### BringEnemiesToPlayer — Upgrade Total (6 perbaikan)
- **Tambah IsRaidMob()** — filter 4 kondisi (LongHiHi, paling lengkap):
  - Cek nama mob: "raid", "microchip", "island"
  - Cek attribute: `IsRaid`, `RaidMob`, `IsBoss`
  - Cek `WalkSpeed == 0` (mob beku/boss)
  - Cek parent `_worldorigin` (eksklusif LongHiHi)
- **Tambah PosMon system** — mob yang sedang ditarget dikunci CFrame-nya, bring selalu ke titik yang sama bukan ikut player bergerak
- **Ganti teleport → TweenService 0.45s smooth** (LongHiHi / Thauan Hub) — mob tidak "lompat" tiba-tiba
- **Tambah MaxBringMobs = 3** — maksimal 3 mob dibring sekaligus, anti-lag
- **Tambah Tweening attribute** — anti double-bring, mob yang sedang di-tween tidak ditween lagi
- **Tambah Animator:Destroy + WalkSpeed=0 + JumpPower=0** (Gay Hub) — mob tidak bisa kabur setelah tiba
- **Perbesar hitbox (60x60x60)** setelah tween selesai, bukan sebelumnya

#### Farm Loop (AutoFarm / AutoQuest / AutoFarmLevel)
- **Tambah** `PosMon = hrp.CFrame` saat mob target ditemukan — sistem bring selalu tahu posisi mob dikunci
- **Tambah** `PosMon = nil` saat tidak ada musuh — bring kembali ke posisi player

#### Cleanup
- Hapus `TweenModule` safeLoad dari URL eksternal
- Hapus fallback block `TweenModule` (tidak diperlukan lagi)
- Update semua komentar yang masih menyebut TweenModule → TweenService

---

## [2026-05-27] v2.0.0 — Panda-Hub Logic + Cleanup

### main.luau
- Hapus entri `MemeSea.luau` & `VoxSeas.luau` dari tabel `Scripts` (file sudah dihapus dari repo)
- Perbaiki pesan "Game tidak didukung" — tidak lagi menyebut Meme Sea/Vox Seas
- Buang ~140 baris kode lama (`--[[...]]`) sisa dari PlockScripts/Testes yang tertinggal
- Bersihkan 15+ baris kosong berlebih
- URL sudah benar mengarah ke `ScXtray/BF`

### Games/BloxFruits.luau — Perbaikan Logika (UI tidak diubah sama sekali)
- **`BringEnemiesToPlayer`** — tambah `hrp.Size = Vector3.new(60,60,60)`, `PlatformStand = true`, `Sit = true`, `CanCollide = false`, `SimulationRadius = math.huge` (teknik Panda-Hub)
- **`KillAuraOnce`** — tambah `PlatformStand = true`, `Sit = true`, `hrp.CFrame = root.CFrame` agar musuh benar-benar ke posisi player sebelum di-kill
- **`TryAcceptQuest`** — ganti `"TakeQuest"` → `SetSpawnPoint` dulu lalu `"StartQuest"` + slot number (teknik Panda-Hub yang benar)
- **`TryCompleteQuest`** — tetap `"TurnInQuest"` tapi dibungkus pcall yang lebih aman
- **`IsQuestActive`** — prioritas cek `PlayerGui.Main.Quest.Visible` (akurat), fallback ke `Data.Quest.Value`
- **`IsQuestComplete`** — cek `questFrame.Visible == false`, fallback ke Data
- **Auto Farm loop** — tambah `SimulationRadius = math.huge` di setiap tick, ganti teleport abrupt → `pcall(TweenFlyTo, hrp.Position)` untuk pergerakan smooth, tick dipercepat dari 0.1 → 0.07s
- **Versi notifikasi** — diupdate dari v1.5.0 → v2.0.0
- **Header komentar** — URL diupdate ke `github.com/ScXtray/BF`

---

## [2026-05-xx] v1.5.0 — Migrasi Repo + Rewrite Games

### Migrasi Repo
- Repo lama `XtrayScript/XtrayScript` kena suspend
- Migrasi ke `ScXtray/BF`
- Update semua URL di `main.luau` ke repo baru

### Games/MemeSea.luau
- Ditulis ulang dari awal (~500 baris, redzlib UI)
- Fitur: Auto Farm, ESP, Auto Quest, Movement
- **Kemudian dihapus** dari repo atas permintaan user (2026-05-27)

### Games/VoxSeas.luau
- Ditulis dari awal (newredzv3 style)
- Fitur: Tween movement (BodyVelocity), BringMobs, ESP, Auto Farm
- PlaceId: `104067066727140`
- **Kemudian dihapus** dari repo atas permintaan user (2026-05-27)

---

## [2026-05-xx] v1.0.0 — Initial Setup

### main.luau
- Setup fetcher + URL resolver (`{Repository}`, `{Utils}`, dll.)
- Debounce anti-double-execute (`rz_execute_debounce`)
- Auto queue_on_teleport untuk persistent script setelah teleport server
- Routing berdasarkan `PlaceId` → load file game yang sesuai
- Error handler dengan `Message` instance di workspace

### Games/BloxFruits.luau
- File utama Blox Fruits (Sea 1, Sea 2, Sea 3)
- UI menggunakan redzlib (`{Repository}Library/main.luau`)
- PlaceId didukung: Sea1 (`2753915549`, `85211729168715`), Sea2 (`4442272183`, `79091703265657`), Sea3 (`7449423635`, `100117331123089`)
- Fitur: Auto Farm, Kill Aura, Auto Quest, Auto Boss, Auto Fishing, Mastery Farm, Auto Chest, Sea Event Farm, ESP, NoClip, Speed/Jump Hack, Anti-AFK, Auto Buso, dan banyak Extras

### Utils/
- `Movement.luau` — speed, jump, fly
- `FullBright.luau` — hapus ambient gelap
- `AntiReset.luau` — block karakter reset
- `BloxFruitsESP.luau` — ESP khusus BF
- `FastAttack.luau` — percepat CombatFramework
- `Module/Tween-Module.luau` — tween fly smooth (BodyVelocity)

---

---

## [2026-05-28] v1.0.0 — Xtray Hub (all-In-One) — Initial Build

### Repo: ScXtray/all-In-One

#### main.lua — Loader baru
- Deteksi PlaceId otomatis → routing ke `Games/BloxFruits.lua`
- Mendukung semua 6 PlaceId BF (Sea 1/2/3, versi lama & baru)
- Warning jika game tidak didukung

#### Games/BloxFruits.lua — Script Hub Lengkap (1,100+ baris)
- **Semua nama `redzplock`/`Redz`/`plock` diganti ke `Xtray`** (kecuali `redzlib` UI library)
- UI menggunakan `redzlib`, window title: **"Xtray Hub"**

##### Tab: Auto Farm
- Select Weapon dropdown (17 pilihan)
- Auto Farm (quest-based, per sea, dengan CheckQuest)
- Auto Farm Nearest (musuh terdekat)
- Boss Farm dengan dropdown semua boss (Sea 1/2/3)
- Material Farm (12 material termasuk Angel Wings, Mystic Droplet, dll.)
- Auto Skills Z/X/C
- Auto Equip Haki

##### Tab: Sea Events
- Auto Farm Boat
- Auto Farm Shark
- Auto Farm Terror Shark / Sea Beast
- Auto Tween to Bounty Expert

##### Tab: Fishing
- Auto Fishing
- Auto Sell Fish

##### Tab: Fruits
- Auto Random Fruits (buy from Cousin)
- Auto Store Fruits (full 41 fruits list)
- Teleport To Fruit Spawn
- Auto Grab Fruits
- Check Stock (Advance + Normal, update tiap 60 detik)
- Raid Fruits (Sea 2/3 only): Select Chip, Auto Buy Chip, Auto Start Raid, Auto Farm Raid
- Raid Law (Sea 2 only): Buy Chip Law, Start Raid Law, Auto Farm Law
- Kitsune Island (Sea 3): Tween + ESP
- Mirage Island (Sea 3): Status check, Tween, ESP
- Azure Ember (Sea 3)
- Look Moon + Auto V3 (Sea 3)

##### Tab: Teleport
- Dropdown island per sea (Sea1: 18, Sea2: 15, Sea3: 15)
- Full CFrame table (40+ islands)
- Auto Tween To Island + Teleport Now button
- Portal detection untuk Sea 3

##### Tab: Combat
- Aimbot Gun (external PlockScripts module)
- Aimbot on Players / Mobs / Ignore Mobs toggle

##### Tab: ESP
- ESP Players (BillboardGui, nama + HP + jarak, save state)
- ESP Size slider (save state)
- ESP Chest
- ESP Fruits (save state)
- ESP Berry
- Meteor Rain effect
- Remove Portal Dash Cooldown

##### Tab: Fight Style
- Buy semua fighting style (Black Leg → Sanguine Art) dengan FlyTo NPC per sea
- Shop items: Swordsman Hat, Tomoe Ring
- Buy Ghoul, Buy Cyborg
- Reset Stats, Random Race

##### Tab: Misc
- Fast Attack (net module)
- Bring Mob
- Rejoin / Server Hop / Anti-Reset 30min
- Join Server (Job ID / Clipboard)
- Join Pirates / Marines team
- Auto Race V3 / V4 (save state)
- WalkSpeed / Jump slider (save state)
- Full Bright (save state)
- Remove Sky Fog / FPS Boost / White Screen
- Delete Lava / Dodge No CD / Infinite Geppo / Walk on Water
- Redeem All Codes (60+ kode)
- Open Title Menu
- Admin auto-detect + auto hop (18 admin list)

---

## Catatan Penting

- Dua akun GitHub sebelumnya (`XtrayScript` dan akun lain) kena suspend — selalu backup token
- Push ke GitHub **hanya via GitHub REST API** (git push diblokir di Replit sandbox)
- SHA file harus diambil ulang setiap sebelum push/delete
