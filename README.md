# Baro-ModKit

🚀 A modular and extensible equipment & scripting toolkit for **Barotrauma**, focused on Lua/XML-based wearable devices, remote controls, and AI-interaction systems.

---

## 🎯 Project Goal

**Baro-ModKit** aims to provide reusable, configurable, and multiplayer-safe equipment modules (such as injection collars, remote triggers, wireless systems) built in pure XML + Lua.

Designed to be:
- Multiplayer-safe ✅
- Fully customizable ✅
- Easy to integrate ✅
- Extensible for new devices ✅

---

## 🧩 Included Modules

| Module Identifier | Description | Status |
|-------------------|-------------|--------|
| `injectioncollar` | A wearable collar that injects drugs remotely via wireless signal | ✅ Completed |
| `remotetrigger`   | Handheld controller for frequency-based triggering | ✅ Completed |
| `npccontrolhook`  | Lua hook to intercept remote commands and trigger AI actions | 🛠️ In development |
| `cooldownmanager` | Shared cooldown timer script for device balancing | ✅ Completed |

---

## 🧠 Tech Stack

- ✅ XML for item & component definitions
- ✅ Lua for logic, triggers, and NPC reactions
- ✅ Supports `WifiComponent`, `CustomInterface`, `LuaComponent`, `ItemContainer`
- ✅ Designed for **Barotrauma's LocalMods system**

---

## 📦 Installation

1. Clone or download this repository.
2. Copy the folder to your Barotrauma mods directory:

