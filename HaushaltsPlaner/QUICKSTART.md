# 🚀 Quick Start Guide

## Schnellstart in 5 Minuten

### 1. Xcode öffnen
```bash
cd HaushaltsPlaner
open HaushaltsPlaner.xcodeproj
```

### 2. Wichtige Dateien anpassen

**a) Bundle Identifier ändern** (in Xcode)
- Target "HaushaltsPlaner" auswählen
- Unter "Signing & Capabilities"
- Ändere: `com.haushaltsplaner.app` → `com.deinname.haushaltsplaner`

**b) CloudKit Container ändern**

In `Services/CloudKitManager.swift` Zeile 21:
```swift
container = CKContainer(identifier: "iCloud.com.deinname.haushaltsplaner")
```

In `HaushaltsPlaner.entitlements`:
```xml
<string>iCloud.com.deinname.haushaltsplaner</string>
```

### 3. Team & Signing
- In Xcode: Signing & Capabilities
- Wähle dein Development Team
- ✅ "Automatically manage signing"

### 4. Capabilities hinzufügen
In Xcode unter "Signing & Capabilities":
- ➕ iCloud (CloudKit aktivieren)
- ➕ Siri
- ➕ Push Notifications
- ➕ App Groups

### 5. CloudKit Schema erstellen

Öffne [CloudKit Dashboard](https://icloud.developer.apple.com/):

**HouseholdTask Record Type:**
```
id: String (Queryable)
title: String (Queryable)
taskDescription: String
priority: String (Queryable)
isCompleted: Int64 (Queryable)
assignedTo: String (Queryable)
assignedToName: String
createdBy: String (Queryable)
createdByName: String
createdAt: Date/Time (Queryable, Sortable)
dueDate: Date/Time (Queryable, Sortable)
completedAt: Date/Time
```

**ShoppingItem Record Type:**
```
id: String (Queryable)
name: String (Queryable)
quantity: String
category: String (Queryable)
isPurchased: Int64 (Queryable)
addedBy: String (Queryable)
addedByName: String
addedAt: Date/Time (Queryable, Sortable)
purchasedAt: Date/Time
```

### 6. App starten
- Wähle ein iOS 17.0+ Gerät/Simulator
- Drücke Cmd+R
- Melde dich mit iCloud an (wenn gefragt)

## ✅ Fertig!

Du kannst nun:
- ✅ Aufgaben erstellen und verwalten
- ✅ Einkaufsliste nutzen
- ✅ Familie einladen (iCloud-Link teilen)
- ✅ Siri verwenden: "Hey Siri, füge Milch zur Einkaufsliste hinzu"

## 📚 Weitere Dokumentation

- `README.md` - Vollständige Übersicht
- `CLOUDKIT_SETUP.md` - Detailliertes CloudKit Setup
- `SIRI_SHORTCUTS.md` - Siri & HomePod Integration

## 🆘 Probleme?

**App startet nicht:**
- Prüfe iOS-Version (min. 17.0)
- Prüfe Signing-Konfiguration

**iCloud funktioniert nicht:**
- Bei iCloud anmelden (Einstellungen → iCloud)
- CloudKit Schema im Dashboard erstellt?
- Container-Identifier korrekt?

**Siri findet App nicht:**
- App einmal manuell öffnen
- Einstellungen → Siri & Suchen → Haushaltsplaner
- Alle Vorschläge aktivieren

---

**Viel Erfolg! Bei Fragen siehe die ausführliche Dokumentation. 🎉**
