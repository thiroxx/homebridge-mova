# 🎙️ Siri Shortcuts & HomePod Setup

## Siri Shortcuts einrichten

Die Haushaltsplaner-App unterstützt zwei Haupt-Shortcuts:

### 1. Aufgabe hinzufügen

**Verfügbare Sprachbefehle:**
- "Hey Siri, füge eine Aufgabe hinzu"
- "Hey Siri, füge 'Müll rausbringen' zur Aufgabenliste hinzu"
- "Hey Siri, erstelle eine neue Aufgabe"
- "Hey Siri, neue Aufgabe: Wäsche waschen"

**Parameter:**
- **Aufgabe** (erforderlich): Der Titel der Aufgabe
- **Beschreibung** (optional): Zusätzliche Details zur Aufgabe
- **Priorität** (optional): Niedrig, Mittel, Hoch, Dringend

**Beispiele:**
```
"Hey Siri, füge eine Aufgabe 'Fenster putzen' mit hoher Priorität hinzu"
"Hey Siri, neue Aufgabe: Garten gießen"
"Hey Siri, füge 'Staubsaugen' zur Aufgabenliste hinzu"
```

### 2. Einkaufsartikel hinzufügen

**Verfügbare Sprachbefehle:**
- "Hey Siri, füge Milch zur Einkaufsliste hinzu"
- "Hey Siri, setze Brot auf die Einkaufsliste"
- "Hey Siri, ich brauche Eier"
- "Hey Siri, füge 2 Liter Milch zum Einkaufen hinzu"

**Parameter:**
- **Artikel** (erforderlich): Name des Artikels
- **Menge** (optional): Anzahl oder Menge (Standard: "1")
- **Kategorie** (optional): Lebensmittel, Haushalt, Körperpflege, Sonstiges

**Beispiele:**
```
"Hey Siri, füge 2 Liter Milch zur Einkaufsliste hinzu"
"Hey Siri, setze 500g Butter auf die Liste"
"Hey Siri, ich brauche Toilettenpapier"
"Hey Siri, füge Äpfel zum Einkaufen hinzu"
```

## HomePod Integration

### Voraussetzungen
1. HomePod mit iOS 17.0 oder neuer
2. Gleicher iCloud-Account auf HomePod und iPhone
3. Home-App konfiguriert
4. Haushaltsplaner-App mindestens einmal auf dem iPhone verwendet

### Setup-Schritte

#### 1. HomePod verbinden
- Stelle sicher, dass dein HomePod mit demselben WLAN verbunden ist
- Öffne die Home-App auf deinem iPhone
- Füge den HomePod hinzu (falls noch nicht geschehen)

#### 2. Siri-Zugriff erlauben
- Öffne "Einstellungen" auf dem iPhone
- Gehe zu "Siri & Suchen"
- Suche "Haushaltsplaner"
- Aktiviere:
  - ✅ Vorschläge von App anzeigen
  - ✅ Vorschläge für Siri anzeigen
  - ✅ Im Sperrbildschirm vorschlagen
  - ✅ Vorschläge für HomePod teilen

#### 3. Shortcuts freigeben
- Öffne die Shortcuts-App
- Gehe zu "Meine Shortcuts"
- Tippe auf die drei Punkte bei einem Shortcut
- Aktiviere "Für HomePod verwenden"

#### 4. Persönliche Anfragen aktivieren
- Öffne die Home-App
- Drücke lange auf den HomePod
- Gehe zu Einstellungen
- Aktiviere "Persönliche Anfragen"

### Verwendung mit HomePod

Nach dem Setup kannst du folgende Befehle direkt zu deinem HomePod sagen:

```
"Hey Siri, füge Milch zur Einkaufsliste hinzu"
"Hey Siri, neue Aufgabe: Müll rausbringen"
"Hey Siri, setze Toilettenpapier auf die Einkaufsliste"
"Hey Siri, füge 'Auto waschen' zur Aufgabenliste hinzu"
```

## Erweiterte Shortcuts erstellen

### Benutzerdefinierte Shortcuts

Du kannst in der Shortcuts-App eigene Automationen erstellen:

#### Beispiel 1: Morgenroutine
```
Wenn: 7:00 Uhr
Dann: Füge Aufgabe "Frühstück vorbereiten" hinzu
```

#### Beispiel 2: Wochenend-Einkauf
```
Wenn: Samstag 9:00 Uhr
Dann: Öffne Haushaltsplaner → Einkaufsliste
```

#### Beispiel 3: Geofencing
```
Wenn: Verlasse "Zuhause"
Dann: Zeige offene Einkaufsartikel
```

### Schritt-für-Schritt: Eigenen Shortcut erstellen

1. **Shortcuts-App öffnen**
   - Tippe auf das "+" Symbol

2. **Aktion hinzufügen**
   - Suche nach "Haushaltsplaner"
   - Wähle "Aufgabe hinzufügen" oder "Einkaufsartikel hinzufügen"

3. **Parameter konfigurieren**
   - Setze Standardwerte oder frage nach Eingaben
   - Beispiel: "Text abfragen" vor der Aktion

4. **Sprachbefehl festlegen**
   - Tippe auf den Shortcut-Namen
   - Wähle "Zu Siri hinzufügen"
   - Spreche deinen gewünschten Befehl

5. **Testen**
   - Sage den Befehl zu Siri
   - Überprüfe in der App, ob es funktioniert

## Tipps & Tricks

### Beste Praktiken
- ✅ Verwende kurze, eindeutige Befehle
- ✅ Sprich deutlich und in normaler Geschwindigkeit
- ✅ Nutze natürliche Sprache
- ✅ Teste Befehle zuerst auf dem iPhone

### Häufige Fehler vermeiden
- ❌ Zu komplexe Sätze
- ❌ Ungewöhnliche Begriffe
- ❌ Zu schnelles Sprechen
- ❌ Hintergrundgeräusche bei HomePod

### Optimierung für Familien
- Jedes Familienmitglied kann eigene Shortcuts erstellen
- Verwendet einheitliche Begriffe für Artikel
- Legt gemeinsame Kategorien fest
- Nutzt die Prioritäten konsistent

## Problemlösung

### Siri versteht den Befehl nicht
**Lösung:**
1. Überprüfe die Siri-Einstellungen
2. Verwende einfachere Formulierungen
3. Öffne die App einmal manuell
4. Erstelle den Shortcut neu

### HomePod reagiert nicht
**Lösung:**
1. Stelle sicher, dass persönliche Anfragen aktiviert sind
2. Überprüfe die WLAN-Verbindung
3. Starte HomePod neu
4. Prüfe iCloud-Synchronisation

### Artikel/Aufgabe wird nicht hinzugefügt
**Lösung:**
1. Öffne die App manuell
2. Prüfe iCloud-Verbindung
3. Schaue in die App nach (könnte verzögert sein)
4. Versuche es erneut mit klarerem Befehl

### Shortcuts fehlen
**Lösung:**
1. Verwende jede Funktion einmal in der App
2. Gehe zu iOS Einstellungen → Siri & Suchen
3. Aktiviere alle Vorschläge für Haushaltsplaner
4. Warte einige Minuten nach erstmaliger Nutzung

## Automation-Ideen

### Für den Alltag
```
🌅 Morgens (7:00):
- "Frühstück vorbereiten" zur Aufgabenliste

☕ Nach dem Kaffee (8:00):
- Öffne Aufgaben des Tages

🌆 Abends (18:00):
- "Abendessen kochen" zur Aufgabenliste

🌙 Vor dem Schlafen (22:00):
- Zeige erledigte Aufgaben des Tages
```

### Für Einkäufe
```
📍 Verlasse Supermarkt:
- Markiere alle Einkäufe als gekauft

📍 Komme zu Hause an:
- Zeige offene Haushaltsaufgaben

📅 Sonntag-Abend:
- Erinnerung: Einkaufsliste für die Woche erstellen
```

### Für die Familie
```
👨‍👩‍👧‍👦 Familien-Checkliste:
- Montag: Müll rausbringen
- Mittwoch: Wäsche waschen
- Samstag: Wohnung putzen
- Sonntag: Einkaufsliste planen
```

## Erweiterte Integration

### Mit anderen Apps
Die Shortcuts können mit anderen Apps kombiniert werden:
- **Kalender**: Aufgaben mit Terminen verknüpfen
- **Erinnerungen**: Migration von Erinnerungen
- **Notizen**: Aufgaben aus Notizen erstellen
- **Karten**: Einkaufsliste öffnen bei Supermarkt-Nähe

### Mit Smart Home
- **HomeKit**: Licht einschalten wenn Aufgabe erstellt
- **Bewegungssensor**: Aufgaben bei Betreten eines Raums
- **Türsensor**: Einkaufsliste beim Verlassen des Hauses

## Weitere Ressourcen

### Offizielle Apple Dokumentation
- [Siri Shortcuts User Guide](https://support.apple.com/guide/shortcuts/)
- [HomePod Support](https://support.apple.com/homepod)
- [Personal Requests](https://support.apple.com/guide/homepod/)

### Community
- Teile deine besten Shortcuts mit der Familie
- Experimentiere mit verschiedenen Befehlen
- Passe die Automationen an deinen Alltag an

---

**Tipp:** Die HomePod-Integration macht die App besonders nützlich in der Küche - einfach rufen, was auf die Einkaufsliste soll, während du kochst! 🍳🎙️
