# Haushaltsplaner iOS App

**Getrennt vom Homebridge-Plugin** - Eigenständiges iOS-Projekt

> ⚠️ **Hinweis:** Diese iOS-App ist ein separates Projekt und hat keine Verbindung zum Homebridge MOVA Plugin im Root-Verzeichnis.

---

Eine moderne iOS-App für gemeinsame Haushaltsplanung mit iCloud Family Sharing, entwickelt mit SwiftUI.

## 🚀 Schnellstart

```bash
cd HaushaltsPlaner
open HaushaltsPlaner.xcodeproj
```

Siehe [QUICKSTART.md](QUICKSTART.md) für detaillierte Setup-Anweisungen.

## ✨ Features

### 📋 Aufgabenverwaltung
- ✅ Aufgaben erstellen, bearbeiten und löschen
- 🎯 Vier Prioritätsstufen (Niedrig, Mittel, Hoch, Dringend)
- 👤 Aufgaben Familienmitgliedern zuweisen
- 📅 Fälligkeitsdaten setzen
- 🔍 Filtern nach Status (Alle, Aktiv, Erledigt, Meine Aufgaben)
- ✅ Aufgaben als erledigt markieren
- 🤖 **Auto-Completion** - Intelligente Vorschläge basierend auf Historie

### 🛒 Einkaufsliste
- 🛍️ Artikel zur Einkaufsliste hinzufügen
- 📦 Kategorien: Lebensmittel, Haushalt, Körperpflege, Sonstiges
- 📝 Mengenangaben für jeden Artikel
- ✓ Artikel als gekauft markieren
- 🗂️ Nach Kategorien gruppiert und filtern
- 🎯 **NEU: Prioritäten** - Normal, Wichtig, Dringend
- 🤖 **Auto-Completion** - Lernt von deinen Einkäufen + 100+ vordefinierte Artikel

### 👨‍👩‍👧‍👦 Family Sharing
- ☁️ iCloud CloudKit Integration
- 👥 Familienmitglieder einladen und verwalten
- 🔄 Echtzeit-Synchronisation über alle Geräte
- 🎨 Farbcodierte Familienmitglieder
- 📤 Einfaches Teilen per iCloud-Link

### 🔔 Smart Notifications (NEU!)
- 📬 Neue Aufgaben zugewiesen
- ⏰ Fälligkeitsdatum-Erinnerungen
- ✅ Aufgabe erledigt Benachrichtigungen
- 🛒 Neue Einkaufsartikel
- 🔴 Dringende Artikel-Warnungen
- 👥 Familienmitglied beigetreten
- 📊 Tägliche Zusammenfassung (8:00 Uhr)
- ⚡ Time-Sensitive für dringende Items
- 🎯 Smart Grouping & Badge Count

Siehe [NOTIFICATIONS.md](NOTIFICATIONS.md) für Details!

### 🔄 Wiederkehrende Aufgaben & KI-Intervalle (NEU!)
- 🤖 **KI analysiert deine Gewohnheiten** und schlägt optimale Intervalle vor
- 📊 **50+ vordefinierte Haushaltsaufgaben** mit Best-Practice Intervallen
- ✨ **Automatische Erstellung** von wiederkehrenden Aufgaben
- 🎯 **Smart Vorschläge**: "Du putzt zu oft/selten" mit Begründungen
- 📈 **Konfidenz-Scores**: Datenbasierte Empfehlungen
- ⏱️ **Flexible Intervalle**: Täglich bis Jährlich
- 🏷️ **Kategorien**: Küche, Bad, Wohnbereich, Schlafzimmer, Außen, Wartung
- ⏸️ **Pausieren & Aktivieren**: Volle Kontrolle über Serien
- 🔗 **CloudKit Integration**: Automatisch mit Familie geteilt

Siehe [RECURRING_TASKS.md](RECURRING_TASKS.md) für Details!

### 🗣️ Siri & HomePod Integration
- 🗣️ Aufgaben per Sprachbefehl hinzufügen
  - "Hey Siri, füge eine Aufgabe hinzu"
  - "Hey Siri, füge 'Müll rausbringen' zur Aufgabenliste hinzu"
- 🛒 Einkaufsartikel per Sprache hinzufügen
  - "Hey Siri, füge Milch zur Einkaufsliste hinzu"
  - "Hey Siri, setze Brot auf die Einkaufsliste"
- 📱 Funktioniert auf iPhone, iPad, Apple Watch und HomePod

## 🎨 Design & UX

- 🎯 Moderne, intuitive Benutzeroberfläche mit SwiftUI
- 🌗 Automatische Dark Mode Unterstützung
- 📱 Optimiert für iPhone und iPad
- 🔄 Pull-to-Refresh für Datensynchronisation
- ⚡ Swipe-Aktionen zum schnellen Löschen
- 🎨 SF Symbols für konsistente Icons
- 💫 Flüssige Animationen und Übergänge

## 🛠️ Technische Details

### Architektur
- **Framework**: SwiftUI (iOS 17.0+)
- **Cloud**: CloudKit für iCloud-Synchronisation
- **Sprachbefehle**: SiriKit & Intents Framework
- **Architektur**: MVVM Pattern
- **Datenmodell**: Codable Structs mit CloudKit-Integration

### Features
- ✅ CloudKit Shared Database für Family Sharing
- ✅ Echtzeit-Synchronisation mit CloudKit Subscriptions
- ✅ Offline-Fähigkeit mit automatischer Synchronisation
- ✅ Siri Shortcuts Integration
- ✅ Push-Benachrichtigungen für Updates
- ✅ Moderne Async/Await API-Nutzung
- ✅ Auto-Completion mit lokaler ML

## 📱 Anforderungen

- iOS 17.0 oder neuer
- Xcode 15.0 oder neuer
- Swift 5.9+
- iCloud-Account für Synchronisation
- Apple Developer Account (für CloudKit und Siri)

## 🚀 Setup & Installation

### 1. Xcode-Projekt öffnen
```bash
cd HaushaltsPlaner
open HaushaltsPlaner.xcodeproj
```

### 2. Bundle Identifier anpassen
- Öffne das Projekt in Xcode
- Wähle das Target "HaushaltsPlaner"
- Ändere den Bundle Identifier unter "Signing & Capabilities"
- Beispiel: `com.yourname.haushaltsplaner`

### 3. iCloud Container konfigurieren
- Gehe zu "Signing & Capabilities"
- Füge "iCloud" Capability hinzu
- Aktiviere CloudKit
- Erstelle einen Container: `iCloud.com.yourname.haushaltsplaner`
- Aktualisiere den Container-Identifier in:
  - `HaushaltsPlaner.entitlements`
  - `Services/CloudKitManager.swift`

### 4. CloudKit Schema einrichten
Erstelle folgende Record Types im CloudKit Dashboard:

#### HouseholdTask
- `id` (String, Queryable, Sortable)
- `title` (String, Queryable, Sortable)
- `taskDescription` (String)
- `priority` (String, Queryable)
- `isCompleted` (Int64, Queryable)
- `assignedTo` (String, Queryable)
- `assignedToName` (String)
- `createdBy` (String, Queryable)
- `createdByName` (String)
- `createdAt` (Date/Time, Queryable, Sortable)
- `dueDate` (Date/Time, Queryable, Sortable)
- `completedAt` (Date/Time)

#### ShoppingItem
- `id` (String, Queryable, Sortable)
- `name` (String, Queryable, Sortable)
- `quantity` (String)
- `category` (String, Queryable)
- `priority` (String, Queryable)
- `isPurchased` (Int64, Queryable)
- `addedBy` (String, Queryable)
- `addedByName` (String)
- `addedAt` (Date/Time, Queryable, Sortable)
- `purchasedAt` (Date/Time)

### 5. Siri Integration aktivieren
- Gehe zu "Signing & Capabilities"
- Füge "Siri" Capability hinzu
- Die Intents sind bereits in `Intents.intentdefinition` definiert

### 6. Team auswählen
- Wähle dein Development Team in Xcode
- Aktiviere "Automatically manage signing"

### 7. App ausführen
- Wähle ein Gerät oder Simulator
- Drücke Cmd+R zum Ausführen

## 📖 Dokumentation

Vollständige Dokumentation verfügbar:

- **[QUICKSTART.md](QUICKSTART.md)** - 5-Minuten-Setup-Guide
- **[CLOUDKIT_SETUP.md](CLOUDKIT_SETUP.md)** - Detaillierte CloudKit-Konfiguration
- **[SIRI_SHORTCUTS.md](SIRI_SHORTCUTS.md)** - HomePod & Siri Integration
- **[AUTO_COMPLETION.md](AUTO_COMPLETION.md)** - Auto-Completion & Smart Suggestions
- **[NOTIFICATIONS.md](NOTIFICATIONS.md)** - Push-Benachrichtigungen & Smart Alerts
- **[ADVANCED_FEATURES.md](ADVANCED_FEATURES.md)** - Geo-Fencing & AI Smart Suggestions
- **[RECURRING_TASKS.md](RECURRING_TASKS.md)** - Wiederkehrende Aufgaben & KI-Intervalle
- **[DESIGN_MOCKUPS.md](DESIGN_MOCKUPS.md)** - Design System & UI-Dokumentation

## 🎯 Roadmap

### ✅ Implementiert
- [x] iCloud Family Sharing
- [x] Siri & HomePod Integration
- [x] Push-Benachrichtigungen
- [x] Auto-Completion
- [x] Geo-Fencing Smart Reminders
- [x] AI Smart Suggestions
- [x] Wiederkehrende Aufgaben mit KI-Intervallen

### Geplante Features
- [ ] Widget für Home Screen
- [ ] Apple Watch App
- [ ] Aufgaben-Kategorien
- [ ] Kalender-Integration
- [ ] Benachrichtigungen für Fälligkeitsdaten
- [ ] Aufgaben-Historie und Statistiken
- [ ] Favoriten-Filter
- [ ] Erweiterte Siri-Befehle
- [ ] iPad Split View Optimierung
- [ ] Export-Funktion (PDF, CSV)

## 🐛 Fehlerbehebung

### iCloud funktioniert nicht
- Stelle sicher, dass du mit einem iCloud-Account angemeldet bist
- Prüfe, ob iCloud Drive in den Einstellungen aktiviert ist
- Überprüfe, ob die App die iCloud-Berechtigung hat

### Siri findet die App nicht
- Stelle sicher, dass Siri in den Einstellungen aktiviert ist
- Verwende die App einmal manuell, bevor du Siri nutzt
- Gehe zu Einstellungen → Siri & Suchen → Haushaltsplaner und aktiviere alle Optionen

### Synchronisation dauert lange
- Überprüfe deine Internetverbindung
- Ziehe die Listen nach unten für manuelles Aktualisieren
- CloudKit kann bei vielen Daten etwas Zeit benötigen

## 📦 Projektstruktur

```
HaushaltsPlaner/
├── HaushaltsPlaner.xcodeproj
├── HaushaltsPlaner/
│   ├── HaushaltsPlaner.swift      # App Entry Point
│   ├── ContentView.swift          # Main Tab View
│   ├── Models/
│   │   ├── Task.swift             # Aufgaben-Modell
│   │   ├── ShoppingItem.swift     # Einkaufsartikel-Modell
│   │   └── FamilyMember.swift     # Familienmitglieder-Modell
│   ├── Views/
│   │   ├── TasksView.swift        # Aufgaben-Übersicht
│   │   ├── TaskRowView.swift      # Aufgaben-Zelle
│   │   ├── AddTaskView.swift      # Aufgabe hinzufügen
│   │   ├── ShoppingView.swift     # Einkaufsliste
│   │   ├── ShoppingItemRowView.swift
│   │   ├── AddShoppingItemView.swift
│   │   └── FamilyView.swift       # Familien-Verwaltung
│   ├── Services/
│   │   ├── CloudKitManager.swift  # CloudKit Service
│   │   └── AutoCompletionManager.swift
│   ├── Intents/
│   │   ├── IntentHandler.swift    # Siri Intent Handler
│   │   └── Intents.intentdefinition
│   └── Resources/
│       └── Assets.xcassets
├── Design/
│   └── Mockups/                   # UI Mockups
├── README.md                       # Diese Datei
├── QUICKSTART.md
├── CLOUDKIT_SETUP.md
├── SIRI_SHORTCUTS.md
├── AUTO_COMPLETION.md
└── DESIGN_MOCKUPS.md
```

## 📄 Lizenz

Dieses Projekt ist eine Demo-App und kann frei verwendet und modifiziert werden.

## 🙏 Credits

Entwickelt mit ❤️ und SwiftUI

### Verwendete Technologien
- SwiftUI für die Benutzeroberfläche
- CloudKit für Cloud-Synchronisation
- SiriKit für Sprachbefehle
- Combine für reaktive Programmierung

## 📞 Support

Bei Fragen oder Problemen:
1. Prüfe die Dokumentation
2. Schaue in die Fehlerbehebung
3. Öffne ein Issue auf GitHub

---

**Viel Spaß mit deinem neuen Haushaltsplaner! 🏠✨**
