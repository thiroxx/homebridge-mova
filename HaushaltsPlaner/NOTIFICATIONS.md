# 🔔 Push-Benachrichtigungen

Die Haushaltsplaner-App unterstützt intelligente Push-Benachrichtigungen, um dich über wichtige Ereignisse zu informieren.

## 🎯 Wer erhält welche Benachrichtigungen?

### 📋 Aufgaben
**Zugewiesener Benutzer erhält:**
- ✅ "Neue Zuweisung" - wenn dir jemand eine Aufgabe zuweist
- ✅ "Fälligkeitsdatum" - am Tag der Fälligkeit (9:00 Uhr)
- ✅ "1 Tag vorher" - Erinnerung einen Tag vor Fälligkeit

**Alle anderen Familienmitglieder:**
- ❌ Keine Benachrichtigung bei Aufgaben-Zuweisung
- ❌ Keine Fälligkeits-Erinnerungen

**Ersteller der Aufgabe:**
- ✅ "Aufgabe erledigt" - wenn die zugewiesene Person sie erledigt

**Wichtig:** 
- Wenn du dir selbst eine Aufgabe zuweist → **keine** Benachrichtigung
- Nur bei Zuweisung **an andere** Person → diese Person wird benachrichtigt

### 🛒 Einkaufsliste
**Alle Familienmitglieder außer Ersteller:**
- ✅ "Neuer Artikel hinzugefügt"
- ✅ "Dringender Artikel" (Time-Sensitive)

**Alle Familienmitglieder:**
- ✅ "X Artikel gekauft" - bei Einkauf durch jemanden
- ✅ "X dringende Artikel" - Übersicht

### 👨‍👩‍👧‍👦 Familie
**Alle Familienmitglieder:**
- ✅ "X ist beigetreten" - neues Mitglied

### 📊 Tägliche Zusammenfassung
**Alle aktiven Benutzer:**
- ✅ Morgen-Übersicht (8:00 Uhr)

## ✨ Verfügbare Benachrichtigungen

### 📋 Aufgaben-Benachrichtigungen

#### Neue Zuweisung
**Wann:** Wenn dir jemand eine Aufgabe zuweist
```
"Lisa hat dir 'Müll rausbringen' zugewiesen"
```

#### Fälligkeitsdatum
**Wann:** Am Fälligkeitstag um 9:00 Uhr
```
"Aufgabe 'Fenster putzen' ist heute fällig"
```

#### Aufgabe erledigt
**Wann:** Wenn ein Familienmitglied eine Aufgabe erledigt
```
"Max hat 'Küche aufräumen' erledigt ✓"
```

#### Überfällige Aufgaben
**Wann:** Bei überfälligen Aufgaben
```
"3 Aufgaben sind überfällig"
```
- Priority: Time-Sensitive (erscheint sofort)

---

### 🛒 Einkaufs-Benachrichtigungen

#### Neuer Artikel
**Wann:** Wenn jemand einen Artikel hinzufügt
```
"Lisa hat 'Milch' zur Einkaufsliste hinzugefügt"
```

#### Dringender Artikel
**Wann:** Wenn ein dringender Artikel hinzugefügt wird
```
"Lisa hat 'Milch' zur Liste hinzugefügt (Dringend)"
```
- Priority: Time-Sensitive

#### Dringende Artikel-Übersicht
**Wann:** Wenn mehrere dringende Artikel vorhanden sind
```
"5 dringende Artikel auf der Liste"
```

#### Einkauf erledigt
**Wann:** Wenn Artikel als gekauft markiert werden
```
"Max hat 3 Artikel gekauft ✓"
```

---

### 👨‍👩‍👧‍👦 Familien-Benachrichtigungen

#### Neues Mitglied
**Wann:** Wenn jemand der Familie beitritt
```
"Tim ist der Familie beigetreten"
```

---

### 📊 Tägliche Zusammenfassung

#### Morgen-Übersicht
**Wann:** Täglich um 8:00 Uhr
```
"3 offene Aufgaben • 5 Einkaufsartikel"
```
- Nur wenn Items vorhanden sind
- Zusammenfassung des aktuellen Status

---

## ⚙️ Einrichtung

### 1. Berechtigung erteilen

Beim ersten Start fragt die App um Erlaubnis:
- ✅ Banner anzeigen
- ✅ Töne abspielen
- ✅ Badge auf App-Icon

**Empfehlung:** Alle aktivieren

### 2. iOS-Einstellungen

**Einstellungen → Benachrichtigungen → Haushaltsplaner**

#### Benachrichtigungsstil:
- ✅ Banner vorübergehend oder dauerhaft
- ✅ Töne
- ✅ Mitteilungszentrale
- ✅ Sperrbildschirm

#### Optionen:
- ✅ Badge aktivieren
- ✅ Als Timesensitive anzeigen (für dringende Items)
- ✅ Vorschau immer anzeigen

### 3. Fokus-Modi konfigurieren

Du kannst Benachrichtigungen in Fokus-Modi filtern:
- **Arbeit:** Nur dringende Aufgaben
- **Schlafen:** Alle stumm
- **Privat:** Alles erlauben

**Einstellungen → Fokus → [Modus] → Apps**

---

## 🎯 Intelligente Features

### Priority Levels

Die App nutzt iOS Interruption Levels:

**Passive (Normal):**
- Normale Einkaufsartikel
- Normale Aufgaben
- Tägliche Zusammenfassung

**Active (Standard):**
- Neue Zuweisungen
- Aufgaben erledigt
- Familienmitglied beigetreten

**Time-Sensitive (Dringend):**
- Dringende/Hohe Priorität Aufgaben
- Dringende Einkaufsartikel
- Überfällige Aufgaben
- Fälligkeitsdaten

### Smart Grouping

Mehrere Benachrichtigungen des gleichen Typs werden gruppiert:
```
Haushaltsplaner (3 Benachrichtigungen)
├─ "Lisa hat 'Milch' hinzugefügt"
├─ "Max hat 'Brot' hinzugefügt"
└─ "Tim hat 'Butter' hinzugefügt"
```

### Badge Count

Das App-Icon zeigt die Anzahl:
- Offene Aufgaben die dir zugewiesen sind
- Ungelesene Benachrichtigungen
- Automatische Aktualisierung

---

## 📱 Interaktive Benachrichtigungen

### Antippen

**Aufgaben-Benachrichtigung:**
→ Öffnet Aufgaben-Tab

**Einkaufs-Benachrichtigung:**
→ Öffnet Einkaufs-Tab

**Familien-Benachrichtigung:**
→ Öffnet Familien-Tab

### Wischen & Actions (geplant für v1.1)

```
[Benachrichtigung]
├─ Wischen nach links:
│  ├─ "Erledigen" (bei Aufgaben)
│  ├─ "Gekauft" (bei Einkäufen)
│  └─ "Löschen"
└─ Wischen nach rechts:
   └─ "Ansehen"
```

---

## 🔕 Benachrichtigungen anpassen

### In der App (geplant für v1.1)

**Einstellungen-Screen:**
```
Benachrichtigungen
├─ Aufgaben
│  ├─ ☑ Neue Zuweisungen
│  ├─ ☑ Fälligkeitsdaten
│  ├─ ☑ Aufgabe erledigt
│  └─ ☑ Überfällige Aufgaben
├─ Einkäufe
│  ├─ ☑ Neuer Artikel
│  ├─ ☑ Nur dringende Artikel
│  └─ ☑ Einkauf erledigt
├─ Familie
│  └─ ☑ Neues Mitglied
└─ Tägliche Zusammenfassung
   ├─ ☑ Aktiviert
   └─ ⏰ Uhrzeit: 8:00 Uhr
```

### In iOS-Einstellungen

**Einstellungen → Benachrichtigungen → Haushaltsplaner**

**Benachrichtigungszeiten anpassen:**
- Fokus-Modi nutzen
- Geplante Zusammenfassung (iOS Feature)
- Nicht stören Zeiten

---

## 🧪 Benachrichtigungen testen

### Debug-Modus (Development)

Die App zeigt alle Benachrichtigungen auch im Vordergrund.

### Test-Szenarien

1. **Neue Aufgabe zuweisen:**
   - Erstelle Aufgabe
   - Weise anderem Familienmitglied zu
   - ✅ Benachrichtigung sollte erscheinen

2. **Fälligkeitsdatum:**
   - Erstelle Aufgabe mit morgigem Datum
   - Warte bis 9:00 Uhr morgen
   - ✅ Benachrichtigung erscheint

3. **Dringender Einkauf:**
   - Füge Artikel mit "Dringend" hinzu
   - ✅ Time-Sensitive Benachrichtigung

---

## 🔒 Datenschutz

**Was wird gesendet:**
- ✅ Aufgaben-Titel (lokal verschlüsselt)
- ✅ Einkaufsartikel-Name
- ✅ Familienmitglieder-Name

**Was NICHT gesendet wird:**
- ❌ Aufgaben-Beschreibungen
- ❌ Standort-Daten
- ❌ Persönliche Informationen

**Apple Push Notification Service (APNs):**
- Ende-zu-Ende verschlüsselt
- Nur über iCloud
- Keine Drittanbieter-Server
- DSGVO-konform

---

## ⚡ Performance

**Batterie-Optimierung:**
- Push-Benachrichtigungen (kein Polling)
- Intelligentes Grouping
- Nur relevante Notifications

**Datenverbrauch:**
- Minimale Payload (<1KB pro Notification)
- Nur über WiFi/Mobile wenn nötig
- CloudKit-Subscriptions für Echtzeit-Updates

---

## 🐛 Problemlösung

### Benachrichtigungen erscheinen nicht

**1. Berechtigung prüfen:**
```
Einstellungen → Haushaltsplaner → Benachrichtigungen
✅ Benachrichtigungen erlauben
```

**2. Fokus-Modus prüfen:**
```
Kontrollzentrum → Fokus
Stelle sicher, dass Haushaltsplaner erlaubt ist
```

**3. iCloud-Verbindung:**
```
Einstellungen → [Dein Name] → iCloud
✅ iCloud Drive aktiviert
```

**4. App im Hintergrund:**
```
Einstellungen → Allgemein → Hintergrundaktualisierung
✅ Haushaltsplaner aktiviert
```

### Zu viele Benachrichtigungen

**Lösung 1: Fokus-Modi nutzen**
- Erstelle Custom Focus für "Zuhause"
- Erlaube nur dringende Benachrichtigungen

**Lösung 2: Tägliche Zusammenfassung**
- Deaktiviere individuelle Benachrichtigungen
- Nur Morning Summary um 8:00 Uhr

**Lösung 3: In-App Einstellungen (v1.1)**
- Wähle welche Benachrichtigungen du möchtest

### Badge-Zahl falsch

**Lösung:**
- Öffne die App
- Badge wird automatisch aktualisiert
- Oder: Wische App im App-Switcher weg und öffne neu

---

## 💡 Beispiel-Szenarien

### Szenario 1: Aufgabe zuweisen

**Familie:**
- Lisa (Ersteller)
- Max (Zugewiesener)
- Tim (weiteres Mitglied)

**Ablauf:**
1. Lisa erstellt Aufgabe "Müll rausbringen" und weist sie **Max** zu
2. **Max erhält:** 📱 "Lisa hat dir 'Müll rausbringen' zugewiesen"
3. **Tim erhält:** ❌ Keine Benachrichtigung
4. **Lisa erhält:** ❌ Keine Benachrichtigung (sie hat sie erstellt)

**Am Fälligkeitstag (9:00 Uhr):**
- **Max erhält:** 📱 "Aufgabe 'Müll rausbringen' ist heute fällig"
- **Lisa & Tim:** ❌ Keine Benachrichtigung

**Wenn Max die Aufgabe erledigt:**
- **Lisa erhält:** 📱 "Max hat 'Müll rausbringen' erledigt ✓"
- **Tim erhält:** ❌ Keine Benachrichtigung
- **Max erhält:** ❌ Keine Benachrichtigung

### Szenario 2: Einkaufsliste

**Familie:**
- Lisa (fügt Artikel hinzu)
- Max, Tim (weitere Mitglieder)

**Ablauf:**
1. Lisa fügt "Milch" (Dringend) zur Liste hinzu
2. **Max erhält:** 📱 "Lisa hat 'Milch' zur Liste hinzugefügt (Dringend)" (Time-Sensitive)
3. **Tim erhält:** 📱 "Lisa hat 'Milch' zur Liste hinzugefügt (Dringend)" (Time-Sensitive)
4. **Lisa erhält:** ❌ Keine Benachrichtigung (sie hat es hinzugefügt)

**Wenn Max 3 Artikel kauft:**
- **Alle (Lisa, Tim, Max):** 📱 "Max hat 3 Artikel gekauft ✓"

### Szenario 3: Selbst-Zuweisung

**Ablauf:**
1. Lisa erstellt Aufgabe "Fenster putzen" und weist sie **sich selbst** zu
2. **Lisa erhält:** ❌ Keine Benachrichtigung (Selbst-Zuweisung)
3. **Fälligkeits-Erinnerung:** ✅ Lisa erhält trotzdem Erinnerungen am Fälligkeitstag

---

## 🎯 Best Practices

### Für optimale Erfahrung:

1. **Timesensitive erlauben**
   - Für dringende Aufgaben und Einkäufe
   - Durchbricht Fokus-Modi wenn wichtig

2. **Badge aktivieren**
   - Sehe auf einen Blick offene Items
   - Automatische Updates

3. **Tägliche Zusammenfassung**
   - Morgens um 8:00 Uhr
   - Perfekter Start in den Tag

4. **Fokus-Modi konfigurieren**
   - Arbeit: Nur dringende Notifications
   - Zuhause: Alle erlauben
   - Schlafen: Stumm

---

## 🔮 Geplante Features (v1.1)

- [ ] In-App Notification Settings
- [ ] Custom Notification Sounds
- [ ] Interactive Actions (Swipe)
- [ ] Rich Notifications mit Bildern
- [ ] Widget-Integration
- [ ] Apple Watch Notifications
- [ ] Notification History
- [ ] Custom Notification Zeitpläne

---

**Benachrichtigungen machen die App noch nützlicher - du verpasst keine wichtigen Aufgaben oder dringenden Einkäufe mehr! 🔔✨**
