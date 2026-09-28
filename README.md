# Repository Übersicht

Dieses Repository enthält **zwei separate Projekte**:

---

## 🏠 Haushaltsplaner iOS App

Eine moderne iOS-App für gemeinsame Haushaltsplanung mit iCloud Family Sharing.

**📂 Verzeichnis:** [`HaushaltsPlaner/`](HaushaltsPlaner/)

### Features
- 📋 Aufgabenverwaltung mit Prioritäten
- 🛒 Intelligente Einkaufsliste  
- 👨‍👩‍👧‍👦 iCloud Family Sharing
- 🎙️ Siri & HomePod Integration
- 🤖 Auto-Completion & Smart Suggestions

### Dokumentation
- [README](HaushaltsPlaner/README.md) - Vollständige Übersicht
- [Quickstart](HaushaltsPlaner/QUICKSTART.md) - 5-Minuten Setup
- [CloudKit Setup](HaushaltsPlaner/CLOUDKIT_SETUP.md)
- [Siri Integration](HaushaltsPlaner/SIRI_SHORTCUTS.md)
- [Auto-Completion](HaushaltsPlaner/AUTO_COMPLETION.md)
- [Design Mockups](HaushaltsPlaner/DESIGN_MOCKUPS.md)

### Technologie
- SwiftUI (iOS 17.0+)
- CloudKit
- SiriKit & Intents
- Modern Swift Concurrency

**➡️ [Zur iOS App Dokumentation](HaushaltsPlaner/README.md)**

---

## 🤖 Homebridge MOVA Plugin

Homebridge-Plugin für MOVA Staubsauger-Roboter in Apple Home.

**📂 Verzeichnis:** Root-Level (Node.js Projekt)

### Features
- Native Matter Integration
- Raumauswahl
- Cleaning Presets
- Apple Home kompatibel

### Dokumentation
- [README](README-HOMEBRIDGE.md) - Plugin Dokumentation
- [Installation & Konfiguration](README-HOMEBRIDGE.md#installation)

### Technologie
- Node.js 22+
- Homebridge 2.0+
- Matter Support

**➡️ [Zur Homebridge Dokumentation](README-HOMEBRIDGE.md)**

---

## 🔀 Separate Repositories (Empfohlen)

Diese Projekte sind technologisch völlig unterschiedlich und sollten idealerweise in separate Repositories aufgeteilt werden:

### Option 1: Neue Repositories erstellen

```bash
# iOS App in eigenes Repository
git subtree split -P HaushaltsPlaner -b haushaltsplaner-app
git push <new-ios-repo-url> haushaltsplaner-app:main

# Homebridge Plugin bleibt hier
# HaushaltsPlaner/ Verzeichnis entfernen
```

### Option 2: Aktueller Zustand

Beide Projekte bleiben im gleichen Repository, sind aber klar getrennt:
- **Homebridge:** Root-Level (package.json, src/, etc.)
- **iOS App:** `HaushaltsPlaner/` Verzeichnis

---

## 📜 Lizenz

- **iOS App:** MIT License (siehe [HaushaltsPlaner/](HaushaltsPlaner/))
- **Homebridge Plugin:** MIT License (siehe [LICENSE](LICENSE))

---

## 🤝 Beitragen

Für Beiträge zu den jeweiligen Projekten siehe:
- iOS App: `HaushaltsPlaner/` - CloudKit und SwiftUI
- Homebridge: Root - Node.js und Homebridge APIs

---

**Hinweis:** Diese Projekte haben keine technische Verbindung zueinander und können unabhängig verwendet werden.
