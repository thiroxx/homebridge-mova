# Homebridge MOVA Plugin

Homebridge-Plugin für MOVA Staubsauger-Roboter in Apple Home mit nativer Matter-Integration.

[![npm version](https://badge.fury.io/js/homebridge-mova.svg)](https://badge.fury.io/js/homebridge-mova)
[![verified-by-homebridge](https://badgen.net/badge/homebridge/verified/purple)](https://github.com/homebridge/homebridge/wiki/Verified-Plugins)

---

## Features

- 🏠 **Native Matter Integration** - Direkt in Apple Home
- 🗺️ **Raumauswahl** - Gezielt Räume reinigen
- ⚙️ **Cleaning Presets** - Vordefinierte Reinigungsmodi
- 🔄 **Automatische Synchronisation** - Status-Updates in Echtzeit
- 📱 **Apple Home kompatibel** - Volle HomeKit-Integration
- 🎙️ **Siri-Steuerung** - "Hey Siri, starte den Staubsauger"

---

## Installation

### Via Homebridge Config UI X (Empfohlen)

1. Suche nach `homebridge-mova` in der Plugin-Suche
2. Klicke auf "Install"
3. Konfiguriere das Plugin über die UI
4. Starte Homebridge neu

### Via npm

```bash
npm install -g homebridge-mova
```

---

## Konfiguration

Füge in deiner Homebridge `config.json` folgendes hinzu:

```json
{
    "platforms": [
        {
            "platform": "MOVA",
            "name": "MOVA Vacuum",
            "ip": "192.168.1.XXX",
            "port": 8080,
            "updateInterval": 5000
        }
    ]
}
```

### Konfigurationsoptionen

| Option | Typ | Standard | Beschreibung |
|--------|-----|----------|--------------|
| `platform` | string | - | Muss "MOVA" sein (erforderlich) |
| `name` | string | - | Name des Geräts (erforderlich) |
| `ip` | string | - | IP-Adresse des MOVA-Roboters (erforderlich) |
| `port` | number | 8080 | Port des MOVA-Roboters |
| `updateInterval` | number | 5000 | Status-Update Intervall in ms |

---

## Verwendung

Nach der Installation und Konfiguration:

1. **Apple Home App öffnen**
2. **"+" → Gerät hinzufügen**
3. **MOVA Vacuum** sollte automatisch erkannt werden
4. **Hinzufügen** und fertig!

### Siri-Befehle

- "Hey Siri, starte den Staubsauger"
- "Hey Siri, pausiere den Staubsauger"
- "Hey Siri, schicke den Staubsauger zur Ladestation"
- "Hey Siri, reinige das Wohnzimmer"

---

## Entwicklung

### Setup

```bash
# Repository klonen
git clone https://github.com/thiroxx/homebridge-mova.git
cd homebridge-mova

# Dependencies installieren
npm install

# TypeScript kompilieren
npm run build

# Homebridge starten
homebridge -D
```

### Projekt-Struktur

```
homebridge-mova/
├── src/
│   ├── platform.ts         # Haupt-Platform
│   ├── accessory.ts        # Vacuum Accessory
│   └── settings.ts         # Konfiguration
├── test/                   # Tests
├── homebridge-ui/          # Config UI
├── config.schema.json      # Config Schema
└── package.json
```

### Tests

```bash
npm test
```

---

## Fehlerbehebung

### Gerät wird nicht gefunden

- Prüfe IP-Adresse des MOVA-Roboters
- Stelle sicher, dass Homebridge und Roboter im selben Netzwerk sind
- Prüfe Firewall-Einstellungen

### Status wird nicht aktualisiert

- Erhöhe `updateInterval` in der Konfiguration
- Prüfe Logs: `homebridge -D`
- Starte Homebridge neu

### Weitere Hilfe

Für weitere Hilfe:
- 📖 [Wiki](https://github.com/thiroxx/homebridge-mova/wiki)
- 🐛 [Issues](https://github.com/thiroxx/homebridge-mova/issues)

---

## Technologie

- **Node.js** 22+
- **Homebridge** 2.0+
- **TypeScript** 5.x
- **Matter Support**

---

## Changelog

Siehe [CHANGELOG.md](CHANGELOG.md) für Details zu den Releases.

---

## Lizenz

MIT License - siehe [LICENSE](LICENSE)

---

## 🏠 Haushaltsplaner iOS App

Die **Haushaltsplaner iOS App** (die vorher in diesem Repository war) wurde in ein **eigenes Repository** verschoben:

**➡️ [github.com/thiroxx/haushaltsplaner-ios](https://github.com/thiroxx/haushaltsplaner-ios)**

Die iOS-App ist eine separate, eigenständige Anwendung für Haushaltsplanung mit iCloud Family Sharing und hat **keine Verbindung** zum Homebridge MOVA Plugin.

---

## Dokumentation

Vollständige Plugin-Dokumentation: [README-HOMEBRIDGE.md](README-HOMEBRIDGE.md)

---

**Made with ❤️ for smart homes**
