# ☁️ CloudKit Setup Guide

Diese Anleitung erklärt, wie du CloudKit für die Haushaltsplaner-App konfigurierst.

## Übersicht

Die App nutzt CloudKit für:
- ☁️ iCloud-Synchronisation zwischen Geräten
- 👨‍👩‍👧‍👦 Family Sharing / Geteilte Datenbanken
- 🔄 Echtzeit-Updates mit Subscriptions
- 📱 Offline-Support mit automatischer Synchronisation

## Voraussetzungen

- ✅ Apple Developer Account (kostenlos oder bezahlt)
- ✅ Xcode 15.0 oder neuer
- ✅ iOS 17.0+ Deployment Target
- ✅ iCloud-Account für Tests

## Setup-Schritte

### 1. Bundle Identifier konfigurieren

1. Öffne `HaushaltsPlaner.xcodeproj` in Xcode
2. Wähle das Target "HaushaltsPlaner"
3. Gehe zu "Signing & Capabilities"
4. Ändere den Bundle Identifier:
   ```
   Beispiel: com.deinname.haushaltsplaner
   ```

### 2. Team auswählen

1. Unter "Signing & Capabilities"
2. Wähle dein Team im Dropdown
3. Aktiviere "Automatically manage signing"

### 3. iCloud Capability hinzufügen

1. Klicke auf "+ Capability"
2. Suche nach "iCloud"
3. Füge "iCloud" hinzu
4. Aktiviere "CloudKit"
5. Klicke auf "+" bei Containers
6. Erstelle einen neuen Container:
   ```
   iCloud.com.deinname.haushaltsplaner
   ```

### 4. Siri Capability hinzufügen

1. Klicke auf "+ Capability"
2. Suche nach "Siri"
3. Füge "Siri" hinzu

### 5. Push Notifications hinzufügen

1. Klicke auf "+ Capability"
2. Suche nach "Push Notifications"
3. Füge "Push Notifications" hinzu

### 6. App Groups hinzufügen

1. Klicke auf "+ Capability"
2. Suche nach "App Groups"
3. Füge "App Groups" hinzu
4. Erstelle eine neue Gruppe:
   ```
   group.com.deinname.haushaltsplaner
   ```

### 7. Entitlements aktualisieren

Öffne `HaushaltsPlaner.entitlements` und stelle sicher, dass folgendes enthalten ist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.deinname.haushaltsplaner</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>com.apple.developer.ubiquity-container-identifiers</key>
    <array>
        <string>iCloud.com.deinname.haushaltsplaner</string>
    </array>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.deinname.haushaltsplaner</string>
    </array>
    <key>com.apple.developer.siri</key>
    <true/>
    <key>aps-environment</key>
    <string>development</string>
</dict>
</plist>
```

### 8. CloudKitManager aktualisieren

Öffne `Services/CloudKitManager.swift` und aktualisiere den Container-Identifier:

```swift
init() {
    container = CKContainer(identifier: "iCloud.com.deinname.haushaltsplaner")
    privateDatabase = container.privateCloudDatabase
    sharedDatabase = container.sharedCloudDatabase
}
```

## CloudKit Dashboard Setup

### Zugriff auf das Dashboard

1. Öffne [https://icloud.developer.apple.com/](https://icloud.developer.apple.com/)
2. Melde dich mit deiner Apple ID an
3. Wähle deine App bzw. deinen Container

### Schema einrichten

#### Record Type: HouseholdTask

1. Klicke auf "Schema" → "Record Types"
2. Klicke auf "+" für neuen Record Type
3. Name: `HouseholdTask`
4. Füge folgende Felder hinzu:

| Feldname | Typ | Index | Sortierbar |
|----------|-----|-------|------------|
| id | String | Queryable | Yes |
| title | String | Queryable | Yes |
| taskDescription | String | - | No |
| priority | String | Queryable | No |
| isCompleted | Int(64) | Queryable | No |
| assignedTo | String | Queryable | No |
| assignedToName | String | - | No |
| createdBy | String | Queryable | No |
| createdByName | String | - | No |
| createdAt | Date/Time | Queryable | Yes |
| dueDate | Date/Time | Queryable | Yes |
| completedAt | Date/Time | - | No |

5. Klicke auf "Save"

#### Record Type: ShoppingItem

1. Klicke auf "+" für neuen Record Type
2. Name: `ShoppingItem`
3. Füge folgende Felder hinzu:

| Feldname | Typ | Index | Sortierbar |
|----------|-----|-------|------------|
| id | String | Queryable | Yes |
| name | String | Queryable | Yes |
| quantity | String | - | No |
| category | String | Queryable | No |
| isPurchased | Int(64) | Queryable | No |
| addedBy | String | Queryable | No |
| addedByName | String | - | No |
| addedAt | Date/Time | Queryable | Yes |
| purchasedAt | Date/Time | - | No |

4. Klicke auf "Save"

### Security Settings

#### Default Roles konfigurieren

1. Gehe zu "Security Roles"
2. Für "World" (Öffentlich):
   - Read: ❌ Deaktiviert
   - Write: ❌ Deaktiviert
   - Create: ❌ Deaktiviert
   
3. Für "Authenticated" (Angemeldet):
   - Read: ✅ Aktiviert
   - Write: ✅ Aktiviert
   - Create: ✅ Aktiviert

#### Shared Database Settings

1. Gehe zu "Database" → "Shared"
2. Aktiviere "Share Management"
3. Erlaube "Read" und "Write" für geteilte Records

### Indexes konfigurieren

Wichtige Indexes für Performance:

1. **HouseholdTask:**
   - Index 1: `createdAt` (sortierbar)
   - Index 2: `isCompleted` + `priority` (zusammengesetzt)
   - Index 3: `assignedTo` + `isCompleted`

2. **ShoppingItem:**
   - Index 1: `addedAt` (sortierbar)
   - Index 2: `isPurchased` + `category` (zusammengesetzt)

### Subscriptions einrichten

Die App erstellt automatisch Subscriptions beim ersten Start, aber du kannst sie auch manuell im Dashboard konfigurieren:

1. Gehe zu "Subscriptions"
2. Klicke auf "+"
3. Name: `TaskSubscription`
4. Record Type: `HouseholdTask`
5. Fires: On Create, Update, Delete
6. Klicke auf "Save"

Wiederhole für `ShoppingItem`.

## Development vs. Production

### Development Environment

- Nutze während der Entwicklung automatisch
- Separate Daten von Production
- Unbegrenzte kostenlose Nutzung während Entwicklung

### Production Environment

1. Im CloudKit Dashboard
2. Wähle "Deploy Schema Changes"
3. Bestätige die Änderungen
4. Production ist nun live

⚠️ **Wichtig:** Schema-Änderungen in Production sind permanent und können nicht rückgängig gemacht werden!

### Build Settings anpassen

Für Production Build:
1. Öffne `HaushaltsPlaner.entitlements`
2. Ändere `aps-environment`:
   ```xml
   <key>aps-environment</key>
   <string>production</string>
   ```

## Testing

### Lokales Testing

1. Baue und starte die App
2. Melde dich mit iCloud an
3. Erstelle Test-Aufgaben und Einkaufsartikel
4. Prüfe im CloudKit Dashboard unter "Data" → "Records"

### Multi-Device Testing

1. Installiere die App auf mehreren Geräten mit demselben iCloud-Account
2. Erstelle eine Aufgabe auf Gerät 1
3. Pull-to-Refresh auf Gerät 2
4. Die Aufgabe sollte erscheinen

### Family Sharing Testing

1. Lade ein Testgerät/Account ein
2. Akzeptiere die Einladung
3. Beide sollten die gleichen Daten sehen
4. Änderungen sollten synchronisiert werden

## Monitoring & Debugging

### CloudKit Console Logs

1. Öffne CloudKit Dashboard
2. Gehe zu "Logs"
3. Filtere nach Fehlertypen
4. Analysiere API-Aufrufe

### Xcode Console

Aktiviere CloudKit-Logging:
```swift
// In AppDelegate oder App.swift
UserDefaults.standard.set(true, forKey: "CKLogToOSActivity")
```

### Häufige Fehler

#### "Account Not Available"
- ✅ Lösung: In iOS-Einstellungen bei iCloud anmelden

#### "Network Unavailable"
- ✅ Lösung: Internetverbindung prüfen
- ✅ Lösung: iCloud-Status prüfen (status.apple.com)

#### "Zone Not Found"
- ✅ Lösung: App einmal starten um Zone zu erstellen
- ✅ Lösung: CloudKit-Container im Dashboard prüfen

#### "Permission Failure"
- ✅ Lösung: Security Roles im Dashboard prüfen
- ✅ Lösung: Entitlements korrekt konfiguriert?

## Limits & Quotas

### Kostenlose Limits

CloudKit ist für die meisten Apps kostenlos:
- Bis zu 1 PB Storage
- Bis zu 40 GB Assets pro Nutzer
- Unbegrenzte Requests für aktive Nutzer

### Best Practices

1. **Batch Operations**: Nutze `modifyRecords` für mehrere Records
2. **Caching**: Cache Daten lokal, sync im Hintergrund
3. **Efficient Queries**: Nutze Indexes für schnelle Suchen
4. **Error Handling**: Implementiere Retry-Logik für Netzwerkfehler

## Weitere Resourcen

### Apple Dokumentation
- [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [Sharing CloudKit Data](https://developer.apple.com/documentation/cloudkit/shared_records)
- [CloudKit Best Practices](https://developer.apple.com/videos/cloudkit)

### Troubleshooting
- [CloudKit Support](https://developer.apple.com/support/cloudkit/)
- [System Status](https://www.apple.com/support/systemstatus/)

---

**Hinweis:** Diese Anleitung basiert auf dem aktuellen Stand von CloudKit. Details können sich mit iOS-Updates ändern.

Bei Fragen oder Problemen: Prüfe die Apple Developer Forums oder die offizielle Dokumentation.
