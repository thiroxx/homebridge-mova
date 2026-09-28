# 🔄 Wiederkehrende Aufgaben & KI-Intervall-Vorschläge

## Übersicht

Das Recurring Tasks System ermöglicht es dir, wiederkehrende Haushaltsaufgaben automatisch zu verwalten. Die **KI analysiert deine Gewohnheiten** und schlägt optimale Intervalle basierend auf Best Practices vor.

## Hauptfunktionen

### 1. KI-Intervall-Analyse 🧠

Die KI analysiert:
- **Deine Gewohnheiten**: Wie oft machst du bestimmte Aufgaben?
- **Best Practice**: Vergleich mit empfohlenen Intervallen für Haushaltsaufgaben
- **Konsistenz**: Wie regelmäßig erledigst du Aufgaben?
- **Optimierung**: Vorschläge zur Verbesserung deines Rhythmus

#### Arten von KI-Vorschlägen

**Perfekt** ✓
```
Dein Intervall ist optimal! 14 Tage entspricht Best Practice.
```

**Zu häufig** ⬇️
```
Du machst es alle 3 Tage - das ist öfter als nötig. 
Empfohlen: 7 Tage.
```

**Zu selten** ⬆️
```
Du machst es alle 60 Tage - das könnte zu selten sein. 
Empfohlen: 30 Tage.
```

**Neue Aufgabe** ✨
```
Noch nie gemacht. Hygiene und Frische - alle 2 Wochen empfohlen.
```

### 2. 50+ vordefinierte Haushaltsaufgaben

Das System kennt bereits viele gängige Haushaltsaufgaben mit optimalen Intervallen:

#### Küche
- **Kühlschrank reinigen**: alle 14 Tage
- **Backofen reinigen**: alle 30 Tage
- **Spülmaschine reinigen**: alle 30 Tage

#### Badezimmer
- **Bad putzen**: alle 7 Tage
- **Duschkopf entkalken**: alle 60 Tage
- **Waschmaschine reinigen**: alle 30 Tage

#### Wohnraum
- **Fenster putzen**: alle 21 Tage
- **Staubsaugen**: alle 3 Tage
- **Wischen**: alle 7 Tage
- **Staub wischen**: alle 7 Tage

#### Schlafzimmer
- **Bettwäsche wechseln**: alle 14 Tage
- **Matratze wenden**: alle 90 Tage

#### Außenbereich
- **Balkon/Terrasse reinigen**: alle 30 Tage
- **Garten gießen**: alle 2 Tage (Sommer)
- **Rasen mähen**: alle 7 Tage

#### Wartung
- **Heizung warten**: jährlich
- **Rauchmelder testen**: alle 180 Tage
- **Filter Dunstabzug wechseln**: alle 90 Tage
- **Luftfilter wechseln**: alle 180 Tage

### 3. Automatische Aufgabenerstellung

Wiederkehrende Aufgaben werden **automatisch erstellt**:

```swift
// Beispiel: Fenster putzen alle 21 Tage
RecurringTask(
    title: "Fenster putzen",
    intervalDays: 21,
    category: .livingArea,
    priority: .medium
)
```

**Was passiert:**
1. Aufgabe wird am Fälligkeitstag automatisch in CloudKit erstellt
2. Benachrichtigung wird verschickt
3. Nächster Termin wird berechnet (heute + 21 Tage)
4. Wenn erledigt → Nächste Aufgabe wird geplant

## Verwendung

### KI-Vorschläge nutzen

1. **Tab "Serien"** öffnen
2. **Nach unten ziehen** zum Aktualisieren
3. KI analysiert deine Aufgaben-Historie
4. **Vorschläge ansehen**:
   - Grüne Badge = hohe Konfidenz (>80%)
   - Orange Badge = mittlere Konfidenz (>50%)
   - Datenbasiert = basiert auf deinen tatsächlichen Gewohnheiten
5. **"Serie erstellen"** tippen zum Akzeptieren

### Manuell Serie erstellen

1. **"+"** Button → **"Manuell erstellen"**
2. Titel eingeben oder **Vorlage wählen**
3. **Intervall** einstellen (1-365 Tage)
4. **Kategorie** wählen
5. **Priorität** festlegen
6. Optional: **Familienmitglied** zuweisen
7. **"Erstellen"** tippen

### Serien verwalten

#### Pausieren
Wische nach links → **"Pausieren"**
- Serie wird deaktiviert
- Keine neuen Aufgaben werden erstellt

#### Aktivieren
Pausierte Serie → Wische nach links → **"Aktivieren"**
- Serie wird wieder aktiv

#### Löschen
Wische nach links → **"Löschen"**
- Serie wird permanent gelöscht

#### Details ansehen
Tippe auf eine Serie:
- Nächste Fälligkeit
- Letzte Erledigung
- Vollständige Einstellungen

## Technische Details

### Architektur

```
RecurringTasksManager
├── AI Interval Analysis
│   ├── Pattern Recognition (Mustererkennung)
│   ├── Best Practice Comparison
│   └── Confidence Scoring
├── Task Templates (50+ Vorlagen)
├── Automatic Scheduling
└── CloudKit Integration
```

### Datenmodelle

#### `RecurringTask`
```swift
struct RecurringTask {
    let title: String
    var intervalDays: Int
    var category: TaskCategory
    var priority: TaskPriority
    var assignedTo: String?
    var isActive: Bool
    var nextDueDate: Date
    var lastCompletedDate: Date?
}
```

#### `TaskIntervalSuggestion`
```swift
struct TaskIntervalSuggestion {
    let taskTitle: String
    let currentInterval: Int?
    let suggestedInterval: Int
    let reasoning: String
    let confidence: Double
    let adjustment: IntervalAdjustment
}
```

### Algorithmus

#### 1. Mustererkennung
```swift
// Berechne durchschnittliches Intervall
let avgInterval = sum(intervals) / count(intervals)

// Berechne Standardabweichung
let stdDev = sqrt(variance(intervals))

// Konsistenz-Score (0-1)
let consistency = 1.0 - min(stdDev / avgInterval, 1.0)
```

#### 2. Best Practice Vergleich
```swift
let difference = abs(userInterval - recommendedInterval)
let percentDiff = difference / recommendedInterval

if percentDiff < 0.1 {
    // Perfekt!
} else if userInterval < minInterval {
    // Zu häufig
} else if userInterval > maxInterval {
    // Zu selten
}
```

#### 3. Konfidenz-Berechnung
```swift
confidence = consistency * (dataPoints / 10)
// Je mehr Datenpunkte + je konsistenter = höhere Konfidenz
```

### Integration mit CloudKit

Wenn eine Aufgabe als **erledigt** markiert wird:

```swift
// 1. CloudKitManager.updateTask()
task.isCompleted = true

// 2. AIInsightsManager speichert Completion
AIInsightsManager.recordTaskCompletion(task)

// 3. Prüfe auf Recurring Task
if let recurringTask = RecurringTasksManager.find(task.title) {
    // 4. Plane nächste Occurrence
    let nextDate = today + recurringTask.intervalDays
    recurringTask.nextDueDate = nextDate
    
    // 5. Beim nächsten Check: Neue Aufgabe erstellen
    RecurringTasksManager.checkAndCreateDueTasks()
}
```

### Timer & Background Updates

**Stündliche Prüfung**:
```swift
Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
    Task {
        await RecurringTasksManager.checkAndCreateDueTasks()
    }
}
```

- Läuft im Hintergrund
- Erstellt fällige Aufgaben automatisch
- Verschickt Benachrichtigungen

## Best Practices

### Für Benutzer

1. **Nutze die KI-Vorschläge**: Sie basieren auf wissenschaftlichen Empfehlungen
2. **Starte mit Vorlagen**: 50+ bewährte Haushaltsaufgaben
3. **Passe Intervalle an**: Jeder Haushalt ist anders
4. **Regelmäßigkeit ist wichtig**: Die KI lernt von deinen Gewohnheiten
5. **Pausiere statt Löschen**: Bei Urlaub oder Änderungen

### Für Entwickler

1. **Datenschutz**: Alle Daten lokal in `UserDefaults`
2. **Performance**: Lazy Loading der Templates
3. **Offline-First**: Funktioniert ohne Internet
4. **CloudKit Sync**: Automatische Synchronisation der erstellten Aufgaben
5. **Error Handling**: Robuste Fehlerbehandlung

## Erweiterte Features

### Kategorien mit Icons

Jede Kategorie hat ein passendes SF Symbol:
- 🍴 Küche: `fork.knife`
- 🚿 Bad: `shower`
- 🛋️ Wohnbereich: `sofa`
- 🛏️ Schlafzimmer: `bed.double`
- 🍃 Außen: `leaf`
- 🔧 Wartung: `wrench.and.screwdriver`

### Intelligente Benennungen

Das System erkennt verschiedene Schreibweisen:
```swift
"Fenster putzen" = "fenster putzen" = "Fenster Putzen"
"Kühlschrank reinigen" = "kühlschrank reinigen"
```

### Anpassungsstufen

**5 Anpassungsstufen**:
1. `perfect` ✓ - Optimal
2. `nearOptimal` ✓ - Fast optimal
3. `tooFrequent` ⬇️ - Zu oft
4. `tooRare` ⬆️ - Zu selten
5. `needsAdjustment` ↔️ - Anpassung nötig

## Troubleshooting

### KI zeigt keine Vorschläge

**Lösung**:
- Mindestens 2 Erledigungen derselben Aufgabe nötig
- Warte einige Tage und sammle mehr Daten
- Nutze "KI-Vorschläge laden" im Menü

### Aufgaben werden nicht erstellt

**Prüfe**:
1. Serie ist **aktiv** (nicht pausiert)
2. `nextDueDate` ist in der Vergangenheit
3. App wurde geöffnet (Timer läuft nur im Vordergrund)
4. CloudKit-Verbindung funktioniert

### Konfidenz ist niedrig

**Bedeutung**:
- Wenige Datenpunkte (<5 Erledigungen)
- Inkonsistente Intervalle
- Große Standardabweichung

**Verbesserung**:
- Erledige Aufgaben regelmäßiger
- Sammle mehr Daten
- Nutze manuelle Intervalle

## Beispiel-Workflows

### Workflow 1: Neuer Haushalt

1. Öffne "Serien" Tab
2. Tippe "KI-Vorschläge laden"
3. Siehst ~50 neue Vorschläge
4. Wähle 5-10 wichtigste aus
5. Serien werden automatisch gestartet

### Workflow 2: Optimierung

1. Nutze App 2-4 Wochen normal
2. Öffne "Serien" Tab
3. KI zeigt Optimierungen:
   - "Du putzt zu oft" → Intervall erhöhen
   - "Du putzt zu selten" → Intervall verringern
4. Akzeptiere Vorschläge
5. Neue optimale Intervalle

### Workflow 3: Saisonale Anpassung

Winter:
- **Garten gießen** → Pausieren
- **Heizung warten** → Aktivieren

Sommer:
- **Garten gießen** → Aktivieren (2 Tage)
- **Balkon reinigen** → Aktivieren (14 Tage)

## Zukünftige Erweiterungen

### Geplant
- [ ] Wetterbasierte Auto-Anpassung (z.B. Garten gießen bei Regen pausieren)
- [ ] Familien-Gewohnheiten lernen (verschiedene Intervalle pro Person)
- [ ] Saisonale Templates (Frühling, Sommer, Herbst, Winter)
- [ ] Smart Home Integration (z.B. Roboter-Staubsauger)
- [ ] Sprach-Setup via Siri ("Hey Siri, richte Fenster putzen alle 3 Wochen ein")

### Community-Ideen willkommen!

Hast du Ideen für weitere Vorlagen oder Features? 
Eröffne ein GitHub Issue!

---

**Made with ❤️ for organized households**
