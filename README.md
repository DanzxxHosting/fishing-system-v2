# Fishing System v2 (Safe — Debug / Test Modes)

This upgraded package adds *debug/testing* features intended for use **only in games you develop and control**.
These are NOT cheats for other people's games. Use responsibly.

**New debug/test features**
- Super-fast speed modes for testing: 8x and 10x (client requests this but server clamps/validates).
- Delay Mode (2x) to simulate latency/delay in bite timing.
- Auto-equip "FishingRadar" tool from the player's Backpack/StarterPack (only equips tools present in the game).
- Toggle Fishing Animation On/Off (client-side visual toggle; server-side game logic unaffected).

**Files**
- `FishingModule.lua` — ModuleScript (ReplicatedStorage).
- `FishingServer.lua` — Server Script (ServerScriptService).
- `FishingClient.lua` — LocalScript (StarterPlayerScripts). Builds UI at runtime with new toggles.
- `README.md`, `LICENSE.txt`

**Installation**
1. Place `FishingModule.lua` as a ModuleScript named `FishingModule` in ReplicatedStorage.
2. Place `FishingServer.lua` as a Script named `FishingServer` in ServerScriptService.
3. Place `FishingClient.lua` as a LocalScript in StarterPlayerScripts.
4. (Optional) Add a Tool named `FishingRadar` to StarterPack so Auto-Equip can find it.

**Safety note**
These modes are for debugging and local testing in your own games. Do not use them to exploit or interfere with other Roblox experiences.
