# 🤖 Auto-Completion & Smart Suggestions

Die Haushaltsplaner-App lernt von deinen Eingaben und bietet intelligente Vorschläge.

## ✨ Features

### 📋 Aufgaben Auto-Completion

**Intelligente Vorschläge:**
- Zeigt die letzten 50 verwendeten Aufgaben-Titel
- Filtert in Echtzeit während der Eingabe
- Häufig verwendete Aufgaben werden priorisiert
- Vorgegebene häufige Haushaltsaufgaben

**Verwendung:**
1. Öffne "Neue Aufgabe"
2. Beginne mit der Eingabe im Titel-Feld
3. Vorschläge erscheinen automatisch darunter
4. Tippe auf einen Vorschlag zum Übernehmen
5. Oder scrolle durch "Häufig verwendet" Chips

**Vordefinierte Aufgaben:**
- Müll rausbringen
- Wäsche waschen
- Staubsaugen
- Fenster putzen
- Bad putzen
- Küche aufräumen
- Spülmaschine ausräumen
- Betten beziehen
- Pflanzen gießen
- Post abholen
- Auto waschen
- Einkaufen gehen
- Essen vorbereiten
- Garage aufräumen

---

### 🛒 Einkaufsliste Auto-Completion

**Intelligente Vorschläge:**
- Lernt von deinen bisherigen Einkäufen
- Kategorie-spezifische Vorschläge
- 100+ vordefinierte häufige Artikel
- Filtert während der Eingabe

**Verwendung:**
1. Öffne "Artikel hinzufügen"
2. Beginne mit der Eingabe
3. Vorschläge erscheinen automatisch
4. "Häufig gekauft" zeigt passende Artikel zur Kategorie
5. Wähle einen Artikel aus oder tippe weiter

**Vordefinierte Artikel nach Kategorie:**

#### 🛒 Lebensmittel
- Milch, Brot, Butter, Eier, Käse
- Joghurt, Äpfel, Bananen, Tomaten, Gurken
- Kartoffeln, Reis, Nudeln, Mehl, Zucker
- Salz, Pfeffer, Öl, Kaffee, Tee
- ... und viele mehr

#### 🏠 Haushalt
- Toilettenpapier, Küchenpapier, Müllbeutel
- Spülmittel, Waschmittel, Weichspüler
- Allzweckreiniger, Schwämme
- Glühbirnen, Batterien, Alufolie, Frischhaltefolie

#### 💄 Körperpflege
- Zahnpasta, Zahnbürste, Shampoo, Duschgel
- Seife, Deo, Rasierer, Rasierschaum
- Creme, Taschentücher

#### 📦 Sonstiges
- Blumen, Kerzen, Geschenkpapier, Tierfutter

---

## 🎯 Prioritäten für Einkäufe (NEU!)

Jetzt kannst du auch Einkaufsartikel priorisieren!

### Prioritätsstufen

**🔴 Dringend**
- Für Artikel, die sofort gebraucht werden
- Werden ganz oben angezeigt
- Rote Badge-Farbe

**🟠 Wichtig**
- Für wichtige aber nicht dringende Artikel
- Werden vor normalen Artikeln angezeigt
- Orange Badge-Farbe

**⚪ Normal**
- Standard-Priorität
- Keine Badge-Anzeige
- Graue Farbe

### Vorteile

**Bessere Organisation:**
- Dringende Artikel fallen sofort auf
- Keine wichtigen Artikel vergessen
- Effizienteres Einkaufen

**Sortierung:**
- Artikel werden automatisch nach Priorität sortiert
- Dringende zuerst, dann wichtige, dann normale
- Gekaufte Artikel werden ans Ende sortiert

---

## 🧠 Wie das System lernt

### Lernmechanismus

1. **Bei jeder Eingabe:**
   - Titel/Name wird gespeichert
   - Häufigkeit wird gezählt
   - Reihenfolge wird aktualisiert

2. **Intelligente Filterung:**
   - Zuletzt verwendete Einträge zuerst
   - Passende Treffer bei Teilstring-Suche
   - Maximal 5 Vorschläge gleichzeitig

3. **Kategorien-Kontext:**
   - Bei Einkäufen: Kategorie-spezifische Vorschläge
   - Häufige Artikel pro Kategorie
   - Kombiniert eigene + vordefinierte Artikel

### Datenspeicherung

**Lokal auf dem Gerät:**
- Gespeichert in UserDefaults
- Maximal 50 Einträge pro Typ
- Automatische Bereinigung bei Limit
- Privat und sicher

**Nicht in iCloud:**
- Auto-Completion-Historie ist geräte-lokal
- Jedes Familienmitglied hat eigene Vorschläge
- Keine Synchronisation zwischen Geräten

---

## 💡 Tipps zur Nutzung

### Für Aufgaben

1. **Konsistente Namen verwenden:**
   - Verwende immer gleiche Formulierungen
   - z.B. "Müll rausbringen" statt "Müll entsorgen"
   - System lernt deine bevorzugten Formulierungen

2. **Häufig verwendet nutzen:**
   - Scrolle durch die Chips am Ende des Formulars
   - Schneller Zugriff auf deine Top-Aufgaben
   - Aktualisiert sich automatisch

3. **Bei Tippfehlern:**
   - System filtert auch bei Teilübereinstimmung
   - "Fenst" findet "Fenster putzen"
   - Funktioniert auch in der Wortmitte

### Für Einkäufe

1. **Kategorie zuerst wählen:**
   - Wähle die Kategorie bevor du tippst
   - "Häufig gekauft" passt sich an
   - Bessere Vorschläge

2. **Standardisierte Mengen:**
   - z.B. "2L" für Milch, "500g" für Butter
   - Konsistenz hilft beim Lernen
   - Einfaches Wiederverwenden

3. **Prioritäten setzen:**
   - Dringend: Wenn heute noch benötigt
   - Wichtig: Wenn bald benötigt
   - Normal: Standard für reguläre Einkäufe

---

## ⚙️ Einstellungen

### Historie zurücksetzen

Falls du die Vorschläge zurücksetzen möchtest:

```swift
// In der App (für zukünftige Version):
// Einstellungen → Auto-Completion → Historie löschen
```

Aktuell kannst du die Historie über:
- App deinstallieren und neu installieren
- Oder entwickle ein Settings-Screen (siehe Roadmap)

---

## 🔮 Zukünftige Features

### Geplante Erweiterungen

1. **Cloud-Synchronisation (Optional):**
   - Vorschläge über Geräte hinweg
   - Opt-in für Familien
   - Gemeinsame Lern-Historie

2. **Häufigkeits-Analyse:**
   - "Top 10" meistverwendete Aufgaben
   - Häufigste Einkaufsartikel
   - Statistiken anzeigen

3. **Zeitbasierte Vorschläge:**
   - "Montags oft: Müll rausbringen"
   - Saisonale Artikel vorschlagen
   - Kalender-Integration

4. **Smart Completion:**
   - Automatische Kategorie-Erkennung
   - Vorgeschlagene Mengen
   - Automatische Priorität basierend auf Historie

5. **Sprachverarbeitung:**
   - "Ich brauche dringend Milch" → Artikel mit Priorität "Dringend"
   - Automatisches Parsing von Siri-Befehlen
   - NLP für bessere Vorschläge

---

## 🎯 Best Practices

### Do's ✅

- Verwende klare, eindeutige Namen
- Setze Prioritäten konsistent
- Wähle passende Kategorien
- Nutze die Vorschläge aktiv
- Lösche erledigte Artikel regelmäßig

### Don'ts ❌

- Keine zu langen Titel (max. 50 Zeichen)
- Keine inkonsistenten Formulierungen
- Nicht zu viele verschiedene Namen für dasselbe
- Keine Abkürzungen, die du später nicht verstehst

---

## 📊 Technische Details

### AutoCompletionManager

**Klasse:** `AutoCompletionManager`
**Speicherort:** `Services/AutoCompletionManager.swift`

**Hauptfunktionen:**
- `addTaskToHistory(_ title: String)` - Speichert Aufgaben-Titel
- `addShoppingItemToHistory(_ name: String)` - Speichert Artikel-Namen
- `getTaskSuggestions(for query: String) -> [String]` - Gefilterte Vorschläge
- `getShoppingItemSuggestions(for query: String) -> [String]` - Gefilterte Vorschläge
- `getSmartTaskSuggestions() -> [String]` - Kombinierte Vorschläge
- `getSmartShoppingItemSuggestions(for category:) -> [String]` - Kategorie-spezifisch

**Speicher-Keys:**
- `taskHistory` - Aufgaben-Historie
- `shoppingHistory` - Einkaufs-Historie

**Limits:**
- Maximal 50 Einträge pro Historie
- Maximal 5 Vorschläge gleichzeitig
- Automatisches Bereinigen bei Überschreitung

---

## 🔐 Datenschutz

**Was wird gespeichert:**
- ✅ Titel von Aufgaben
- ✅ Namen von Einkaufsartikeln
- ✅ Häufigkeit der Verwendung

**Was NICHT gespeichert wird:**
- ❌ Beschreibungen
- ❌ Zuweisungen
- ❌ Zeitstempel (nur für Sortierung)
- ❌ Persönliche Daten

**Speicherort:**
- Lokal auf dem Gerät (UserDefaults)
- Nicht in iCloud
- Nicht auf Servern
- Nicht mit Familie geteilt

---

**Das Auto-Completion-System macht die App noch intelligenter und spart dir Zeit beim Erstellen von Aufgaben und Einkaufslisten! 🚀**
