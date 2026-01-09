# QOrch & QHuman: Orchestration and Humanization Frameworks

**Status**: Design Complete ✅
**Phase**: 10 (Weeks 55-58)
**LOC Estimate**: ~2,500 lines
**Classes**: ~15 classes

---

## Philosophy

**Problem**: Computer-generated music often sounds mechanical and unrealistic, especially for orchestral/acoustic instruments. Compositions may write unplayable parts or ignore instrument limitations.

**Solution**:
- **QOrch**: Deep orchestration knowledge (ranges, techniques, idiomatic writing, timbral blending)
- **QHuman**: Physical modeling of human performance (breathing, bowing, vibrato, fatigue)

**Together**: Create realistic, playable, expressive orchestral music.

---

## QOrch: Deep Orchestration System

### Core Capabilities

1. **Instrument Knowledge Database**
   - Professional ranges (written vs sounding)
   - Playing techniques and articulations
   - Timbre characteristics (spectral profiles)
   - Technical difficulty assessment
   - Idiomatic vs non-idiomatic writing

2. **Range Validation & Correction**
   - Prevent impossible notes
   - Suggest octave transpositions
   - Warn about extreme ranges
   - Respect comfortable vs extended ranges

3. **Timbral Blending & Balance**
   - Recommend doublings (which instruments blend well)
   - Calculate spectral overlap/masking
   - Suggest octave doublings for thickness
   - Balance recommendations (dynamics per section)

4. **Playing Technique Validation**
   - Check if fast passages are playable
   - Validate interval leaps
   - Assess string crossings
   - Check for breath requirements (winds)
   - Flag extended techniques

5. **Orchestral Spacing & Voicing**
   - Optimal chord spacing for different ensembles
   - Voice leading for orchestral sections
   - Unison vs octave spacing
   - Register-appropriate writing

6. **Idiomatic Writing Checker**
   - Flag non-idiomatic patterns
   - Suggest alternatives
   - Style checking (Romantic vs Contemporary)

---

## QOrch Architecture

```supercollider
// ===== MAIN ENGINE =====
QOrch {
  var <instrumentDB;     // QInstrumentDatabase
  var <validator;        // QOrchValidator
  var <blender;          // QTimbralBlender
  var <balancer;         // QOrchestralBalance
  var <arranger;         // QAutoArranger

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    instrumentDB = QInstrumentDatabase.load;
    validator = QOrchValidator(instrumentDB);
    blender = QTimbralBlender(instrumentDB);
    balancer = QOrchestralBalance(instrumentDB);
    arranger = QAutoArranger(this);
  }

  // Validate a part for an instrument
  validate { |part, instrument|
    var issues = [];

    // Range check
    issues = issues ++ validator.checkRange(part, instrument);

    // Playability check
    issues = issues ++ validator.checkPlayability(part, instrument);

    // Technique check
    issues = issues ++ validator.checkTechniques(part, instrument);

    // Idiomatic check
    issues = issues ++ validator.checkIdiomatic(part, instrument);

    ^issues;
  }

  // Auto-correct issues
  fix { |part, instrument, issues|
    issues.do { |issue|
      part = this.applyFix(part, instrument, issue);
    };
    ^part;
  }

  // Suggest doublings for a melody
  suggestDoublings { |melody, ensemble|
    ^blender.findBestDoublings(melody, ensemble);
  }

  // Balance an orchestral score
  balance { |score, style=\classical|
    ^balancer.autoBalance(score, style);
  }
}

// ===== INSTRUMENT DATABASE =====
QInstrumentDatabase {
  classvar <instruments;

  *initClass {
    instruments = IdentityDictionary[
      \violin -> (
        family: \strings,
        range: [55, 103].midicps,        // G3 to G7
        comfortableRange: [55, 93].midicps, // G3 to A6
        transposition: 0,
        techniques: [
          \arco, \pizzicato, \tremolo, \harmonics,
          \sul_ponticello, \sul_tasto, \col_legno
        ],
        maxLeap: 12,                      // Semitones
        maxSpeed: 16,                     // 16th notes at quarter=120
        spectralCentroid: 2000,           // Hz (approximate)
        blendsWellWith: [\viola, \cello, \flute, \oboe],
        difficulty: (
          fast_scales: \hard,
          large_leaps: \medium,
          high_register: \medium
        )
      ),

      \flute -> (
        family: \woodwinds,
        range: [60, 96].midicps,          // C4 to C7
        comfortableRange: [62, 91].midicps,
        transposition: 0,
        techniques: [
          \flutter_tongue, \harmonics, \whistle_tones,
          \breath_sounds, \multiphonics
        ],
        maxLeap: 24,                      // Very agile
        maxSpeed: 32,                     // Very fast
        breathCapacity: 4.0,              // Seconds at mezzo-forte
        spectralCentroid: 1500,
        blendsWellWith: [\violin, \oboe, \clarinet],
        difficulty: (
          fast_scales: \medium,
          large_leaps: \easy,
          high_register: \hard
        )
      ),

      \horn -> (
        family: \brass,
        range: [41, 77].midicps,          // F2 to F5 (written)
        comfortableRange: [46, 72].midicps,
        transposition: -7,                // Sounds P5 lower (F horn)
        techniques: [
          \stopped, \muted, \bells_up, \brassy
        ],
        maxLeap: 12,
        maxSpeed: 8,                      // Slower than woodwinds
        breathCapacity: 6.0,
        spectralCentroid: 500,
        blendsWellWith: [\trombone, \bassoon, \cello, \viola],
        difficulty: (
          fast_scales: \hard,
          large_leaps: \medium,
          high_register: \very_hard
        )
      ),

      \cello -> (
        family: \strings,
        range: [36, 84].midicps,          // C2 to C6
        comfortableRange: [36, 76].midicps,
        transposition: 0,
        techniques: [
          \arco, \pizzicato, \tremolo, \harmonics,
          \sul_ponticello, \sul_tasto
        ],
        maxLeap: 12,
        maxSpeed: 12,
        spectralCentroid: 400,
        blendsWellWith: [\bass, \bassoon, \horn, \viola],
        difficulty: (
          fast_scales: \medium,
          large_leaps: \medium,
          high_register: \hard
        )
      )

      // ... Add all orchestral instruments ...
    ];
  }

  *get { |instrument| ^instruments[instrument] }

  *allInstruments { ^instruments.keys.asArray }

  *byFamily { |family|
    ^instruments.select { |inst| inst.family == family }.keys;
  }
}

// ===== VALIDATOR =====
QOrchValidator {
  var <db;

  *new { |database| ^super.newCopyArgs(database) }

  checkRange { |part, instrumentName|
    var inst = db.get(instrumentName);
    var issues = [];

    part.notes.do { |note|
      var freq = note.freq;

      // Out of possible range
      if (freq < inst.range[0] or: { freq > inst.range[1] }) {
        issues = issues.add((
          type: \range_error,
          severity: \error,
          note: note,
          message: "% Hz is outside % range (% - % Hz)".format(
            freq.round(0.1),
            instrumentName,
            inst.range[0].round(0.1),
            inst.range[1].round(0.1)
          ),
          fix: \transpose_octave
        ));
      };

      // Outside comfortable range
      if (freq < inst.comfortableRange[0] or: {
        freq > inst.comfortableRange[1]
      }) {
        issues = issues.add((
          type: \range_warning,
          severity: \warning,
          note: note,
          message: "% Hz is in extreme range for %".format(
            freq.round(0.1), instrumentName
          ),
          fix: \suggest_alternative
        ));
      };
    };

    ^issues;
  }

  checkPlayability { |part, instrumentName|
    var inst = db.get(instrumentName);
    var issues = [];

    // Check intervals/leaps
    part.notes.doAdjacentPairs { |note1, note2|
      var interval = (note2.midinote - note1.midinote).abs;

      if (interval > inst.maxLeap) {
        issues = issues.add((
          type: \leap_too_large,
          severity: \warning,
          notes: [note1, note2],
          message: "Leap of % semitones is difficult for %".format(
            interval, instrumentName
          ),
          fix: \add_passing_notes
        ));
      };
    };

    // Check speed
    var notesPerSecond = part.notes.size / part.duration;
    var maxNotesPerSecond = inst.maxSpeed / 4.0; // Assuming quarter=120

    if (notesPerSecond > maxNotesPerSecond) {
      issues = issues.add((
        type: \too_fast,
        severity: \warning,
        message: "Passage may be too fast for % (% notes/sec)".format(
          instrumentName, notesPerSecond.round(0.1)
        ),
        fix: \slow_down
      ));
    };

    ^issues;
  }

  checkTechniques { |part, instrumentName|
    var inst = db.get(instrumentName);
    var issues = [];

    part.techniques.do { |tech|
      if (inst.techniques.includes(tech).not) {
        issues = issues.add((
          type: \invalid_technique,
          severity: \error,
          technique: tech,
          message: "% is not a valid technique for %".format(
            tech, instrumentName
          ),
          fix: \remove_technique
        ));
      };
    };

    ^issues;
  }

  checkIdiomatic { |part, instrumentName|
    var inst = db.get(instrumentName);
    var issues = [];

    // String-specific: avoid awkward string crossings
    if (inst.family == \strings) {
      issues = issues ++ this.checkStringCrossings(part, inst);
    };

    // Wind-specific: check breath requirements
    if ([\woodwinds, \brass].includes(inst.family)) {
      issues = issues ++ this.checkBreathing(part, inst);
    };

    ^issues;
  }

  checkBreathing { |part, inst|
    var issues = [];
    var phraseDuration = 0;

    part.notes.do { |note|
      phraseDuration = phraseDuration + note.dur;

      if (note.isRest) {
        phraseDuration = 0; // Reset on rest
      } {
        if (phraseDuration > inst.breathCapacity) {
          issues = issues.add((
            type: \no_breath,
            severity: \error,
            note: note,
            message: "Phrase too long (% sec) without breath for %".format(
              phraseDuration.round(0.1), inst.name
            ),
            fix: \add_breath_mark
          ));
        };
      };
    };

    ^issues;
  }
}

// ===== TIMBRAL BLENDER =====
QTimbralBlender {
  var <db;

  *new { |database| ^super.newCopyArgs(database) }

  findBestDoublings { |melody, ensemble|
    var primary = melody.instrument;
    var candidates = ensemble.instruments;
    var recommendations = [];

    candidates.do { |candidate|
      if (candidate != primary) {
        var score = this.blendScore(primary, candidate);

        if (score > 0.6) { // Good blend threshold
          recommendations = recommendations.add((
            instrument: candidate,
            score: score,
            octave: this.suggestOctave(primary, candidate),
            reason: this.explainBlend(primary, candidate)
          ));
        };
      };
    };

    ^recommendations.sort { |a, b| a.score > b.score };
  }

  blendScore { |inst1Name, inst2Name|
    var inst1 = db.get(inst1Name);
    var inst2 = db.get(inst2Name);
    var score = 0.0;

    // Check if they blend well (from database)
    if (inst1.blendsWellWith.includes(inst2Name)) {
      score = score + 0.5;
    };

    // Spectral similarity
    var spectralDiff = (inst1.spectralCentroid - inst2.spectralCentroid).abs;
    score = score + (1.0 - (spectralDiff / 3000.0).clip(0, 1)) * 0.3;

    // Same family bonus
    if (inst1.family == inst2.family) {
      score = score + 0.2;
    };

    ^score.clip(0, 1);
  }

  suggestOctave { |inst1Name, inst2Name|
    var inst1 = db.get(inst1Name);
    var inst2 = db.get(inst2Name);
    var centroid1 = inst1.spectralCentroid;
    var centroid2 = inst2.spectralCentroid;

    // If similar range, same octave
    if ((centroid1 - centroid2).abs < 500) {
      ^0; // Unison
    };

    // If inst2 is lower, double below
    if (centroid2 < centroid1) {
      ^-1; // Octave below
    };

    // If inst2 is higher, double above
    ^1; // Octave above
  }

  explainBlend { |inst1Name, inst2Name|
    var inst1 = db.get(inst1Name);
    var inst2 = db.get(inst2Name);

    if (inst1.family == inst2.family) {
      ^"Same family (%) - natural blend".format(inst1.family);
    };

    if (inst1.blendsWellWith.includes(inst2Name)) {
      ^"Traditional orchestral doubling";
    };

    ^"Complementary timbres";
  }
}

// ===== ORCHESTRAL BALANCE =====
QOrchestralBalance {
  var <db;

  *new { |database| ^super.newCopyArgs(database) }

  autoBalance { |score, style=\classical|
    var balanced = score.deepCopy;

    // Get all parts
    var parts = balanced.parts;

    // Calculate base dynamics
    parts.do { |part|
      var inst = db.get(part.instrument);
      var baseDynamic = this.calculateBaseDynamic(inst, part, style);
      part.dynamic = baseDynamic;
    };

    // Balance sections against each other
    this.balanceSections(parts, style);

    ^balanced;
  }

  calculateBaseDynamic { |inst, part, style|
    var base = 0.5; // mf

    // Brass louder by default
    if (inst.family == \brass) { base = base + 0.1 };

    // Strings slightly softer in large sections
    if (inst.family == \strings) { base = base - 0.05 };

    // Adjust based on register
    if (part.averagePitch > 80.midicps) { base = base + 0.1 }; // High = more audible
    if (part.averagePitch < 50.midicps) { base = base - 0.1 }; // Low = less audible

    // Style adjustments
    if (style == \romantic) { base = base + 0.1 };      // Louder overall
    if (style == \baroque) { base = base - 0.1 };       // More restrained
    if (style == \contemporary) { base = base + 0.15 }; // Extreme dynamics

    ^base.clip(0, 1);
  }

  balanceSections { |parts, style|
    // Group by family
    var byFamily = parts.groupBy { |p| db.get(p.instrument).family };

    // Calculate section loudness
    byFamily.keysValuesDo { |family, familyParts|
      var avgDynamic = familyParts.collect(_.dynamic).mean;

      "% section: avg dynamic = %".format(
        family, avgDynamic.round(0.01)
      ).postln;
    };

    // TODO: More sophisticated balancing based on style
  }
}
```

---

## QHuman: Advanced Humanization Framework

### Core Capabilities

1. **Breath Modeling**
   - Inhale sounds before phrases
   - Breath capacity limits
   - Phrase-based breathing
   - Breath noise intensity

2. **Vibrato Simulation**
   - Natural vibrato onset (delay after note start)
   - Speed and depth variation
   - Context-aware (vibrato on long notes, not short)
   - Style-specific (Romantic vs Baroque)

3. **Bowing Simulation (Strings)**
   - Bow changes (automatic detection)
   - Bow pressure variation
   - Sul ponticello/tasto transitions
   - String crossing noise

4. **Finger/Hand Mechanics**
   - Portamento on position shifts
   - Finger slides
   - Fret noise (guitar)
   - Key clicks (winds)

5. **Performance Dynamics**
   - Micro-dynamics within phrases
   - Natural crescendos/diminuendos
   - Attack variation
   - Note-to-note dynamic contour

6. **Performance Fatigue**
   - Gradual timing degradation
   - Intonation drift
   - Dynamic inconsistency over time

---

## QHuman Architecture

```supercollider
QHuman {
  var <breath;      // QBreathModel
  var <vibrato;     // QVibratoModel
  var <bowing;      // QBowingModel
  var <finger;      // QFingerModel
  var <dynamics;    // QMicroDynamics
  var <fatigue;     // QFatigueModel

  var <intensity = 0.5;  // How much humanization?

  *new { |intensity=0.5|
    ^super.newCopyArgs(intensity).init;
  }

  init {
    breath = QBreathModel(intensity);
    vibrato = QVibratoModel(intensity);
    bowing = QBowingModel(intensity);
    finger = QFingerModel(intensity);
    dynamics = QMicroDynamics(intensity);
    fatigue = QFatigueModel(intensity);
  }

  humanize { |part, instrument|
    var humanized = part.deepCopy;
    var inst = QInstrumentDatabase.get(instrument);

    // Breath (winds/brass)
    if ([\woodwinds, \brass].includes(inst.family)) {
      humanized = breath.apply(humanized, inst);
    };

    // Vibrato (strings/winds)
    if ([\strings, \woodwinds].includes(inst.family)) {
      humanized = vibrato.apply(humanized, inst);
    };

    // Bowing (strings)
    if (inst.family == \strings) {
      humanized = bowing.apply(humanized, inst);
    };

    // Finger mechanics (all)
    humanized = finger.apply(humanized, inst);

    // Micro-dynamics (all)
    humanized = dynamics.apply(humanized, inst);

    // Fatigue (optional, for long pieces)
    if (part.duration > 60) { // Only on pieces > 1 minute
      humanized = fatigue.apply(humanized, inst);
    };

    ^humanized;
  }
}

// ===== BREATH MODEL =====
QBreathModel {
  var <intensity;

  *new { |intensity=0.5| ^super.newCopyArgs(intensity) }

  apply { |part, inst|
    var breathCapacity = inst.breathCapacity ? 4.0;
    var phraseDuration = 0;
    var newNotes = [];

    part.notes.do { |note, i|
      // Track phrase duration
      if (note.isRest) {
        phraseDuration = 0;
      } {
        phraseDuration = phraseDuration + note.dur;

        // Need breath?
        if (phraseDuration > (breathCapacity * (1.0 - (intensity * 0.3)))) {
          // Insert breath rest
          var breathRest = (
            type: \rest,
            dur: rrand(0.05, 0.15) * intensity,
            breathSound: intensity > 0.3 // Add audible inhale?
          );
          newNotes = newNotes.add(breathRest);
          phraseDuration = 0;

          "Added breath before note %".format(i).postln;
        };
      };

      newNotes = newNotes.add(note);
    };

    part.notes = newNotes;
    ^part;
  }
}

// ===== VIBRATO MODEL =====
QVibratoModel {
  var <intensity;

  *new { |intensity=0.5| ^super.newCopyArgs(intensity) }

  apply { |part, inst|
    part.notes.do { |note|
      // Only apply to notes longer than 0.5 seconds
      if (note.dur > 0.5 and: { note.isRest.not }) {
        note.vibrato = (
          rate: rrand(4.5, 6.5),              // Hz (typical 5-6 Hz)
          depth: rrand(0.01, 0.03) * intensity, // Semitones
          onset: rrand(0.1, 0.3),             // Delay before vibrato starts
          shape: \sine                         // Vibrato waveform
        );
      };
    };

    ^part;
  }
}

// ===== BOWING MODEL =====
QBowingModel {
  var <intensity;

  *new { |intensity=0.5| ^super.newCopyArgs(intensity) }

  apply { |part, inst|
    var bowDirection = 1; // 1 = down, -1 = up
    var notesSinceBowChange = 0;

    part.notes.do { |note, i|
      if (note.isRest.not) {
        notesSinceBowChange = notesSinceBowChange + 1;

        // Bow change every ~4-8 notes (or when phrase ends)
        if (notesSinceBowChange > rrand(4, 8) or: {
          note.dur > 2.0 // Long note forces bow change
        }) {
          bowDirection = bowDirection.neg;
          notesSinceBowChange = 0;

          // Add bow change noise
          note.bowChange = (
            intensity: intensity * 0.3,
            direction: bowDirection
          );
        };

        note.bowDirection = bowDirection;

        // Vary bow pressure slightly
        note.bowPressure = rrand(0.5, 0.8) * (1.0 + (intensity * 0.3));
      };
    };

    ^part;
  }
}

// ===== FINGER MODEL =====
QFingerModel {
  var <intensity;

  *new { |intensity=0.5| ^super.newCopyArgs(intensity) }

  apply { |part, inst|
    part.notes.doAdjacentPairs { |note1, note2|
      var interval = (note2.midinote - note1.midinote).abs;

      // Large leap = position shift = portamento
      if (interval > 4 and: { intensity > 0.3 }) {
        note2.portamento = (
          time: rrand(0.02, 0.08) * intensity,
          curve: \exp
        );

        // Maybe add slide noise
        if (inst.family == \strings and: { intensity > 0.5 }) {
          note2.slideNoise = intensity * 0.4;
        };
      };

      // Add finger noise on key press (winds)
      if ([\woodwinds, \brass].includes(inst.family)) {
        note2.keyClick = rrand(0.0, 0.1) * intensity;
      };
    };

    ^part;
  }
}

// ===== MICRO-DYNAMICS =====
QMicroDynamics {
  var <intensity;

  *new { |intensity=0.5| ^super.newCopyArgs(intensity) }

  apply { |part, inst|
    // Create natural dynamic contours within phrases
    var phrases = this.detectPhrases(part);

    phrases.do { |phrase|
      var phraseNotes = part.notes[phrase.start..phrase.end];
      var contour = this.generateContour(phraseNotes.size);

      phraseNotes.do { |note, i|
        var dynamicMod = contour[i] * intensity * 0.2;
        note.velocity = (note.velocity ? 0.7) + dynamicMod;
        note.velocity = note.velocity.clip(0.1, 1.0);
      };
    };

    ^part;
  }

  generateContour { |size|
    // Natural phrase shape: crescendo to middle, decrescendo at end
    ^Array.fill(size, { |i|
      var pos = i / size;

      if (pos < 0.5) {
        pos * 2;              // Crescendo
      } {
        2 - (pos * 2);        // Diminuendo
      };
    });
  }

  detectPhrases { |part|
    // Simple: split on rests
    var phrases = [];
    var currentStart = 0;

    part.notes.do { |note, i|
      if (note.isRest) {
        if (i > currentStart) {
          phrases = phrases.add((start: currentStart, end: i-1));
        };
        currentStart = i + 1;
      };
    };

    // Add final phrase
    if (currentStart < part.notes.size) {
      phrases = phrases.add((start: currentStart, end: part.notes.size-1));
    };

    ^phrases;
  }
}

// ===== FATIGUE MODEL =====
QFatigueModel {
  var <intensity;

  *new { |intensity=0.5| ^super.newCopyArgs(intensity) }

  apply { |part, inst|
    var fatigueFactor = 0;

    part.notes.do { |note, i|
      // Fatigue increases over time
      fatigueFactor = (i / part.notes.size) * intensity * 0.1;

      // Timing gets slightly worse
      note.dur = note.dur * rrand(1.0 - fatigueFactor, 1.0 + fatigueFactor);

      // Intonation drifts slightly (pitch wobble)
      if (note.isRest.not) {
        note.midinote = note.midinote + rrand(
          -fatigueFactor * 0.1,
          fatigueFactor * 0.1
        );
      };

      // Dynamics less consistent
      note.velocity = (note.velocity ? 0.7) * rrand(
        1.0 - fatigueFactor,
        1.0 + fatigueFactor
      );
    };

    ^part;
  }
}
```

---

## Integration Example

```supercollider
(
// ===== COMPOSITION =====
q = QProject(\orchestral);
q.tempo = 80;

// Write a string quartet
var melody = q.theory.melody.generate(\lyrical, key: \Dmajor);

// Add to violin 1
var vln1 = q.scene.addLayer(\violin1, \violin, melody);

// ===== ORCHESTRATION =====
var orch = QOrch(q);

// 1. Validate the violin part
var issues = orch.validate(vln1, \violin);
issues.do { |issue|
  "ISSUE: % (severity: %)".format(issue.message, issue.severity).postln;
};

// 2. Auto-fix issues
if (issues.notEmpty) {
  vln1 = orch.fix(vln1, \violin, issues);
  "Fixed % issues".format(issues.size).postln;
};

// 3. Find good doublings
var doublings = orch.suggestDoublings(melody, q.scene.ensemble);
"Suggested doublings:".postln;
doublings.do { |d|
  "  % (score: %, octave: %, reason: %)".format(
    d.instrument, d.score.round(0.01), d.octave, d.reason
  ).postln;
};

// Add best doubling (viola at unison)
var vla = q.scene.addLayer(\viola, \viola, melody);

// ===== HUMANIZATION =====
var human = QHuman(intensity: 0.7);

// Humanize both parts
vln1 = human.humanize(vln1, \violin);
vla = human.humanize(vla, \viola);

"Humanization complete:".postln;
"  - Added breath marks".postln;
"  - Applied vibrato to long notes".postln;
"  - Simulated bow changes".postln;
"  - Added micro-dynamics".postln;

// ===== BALANCE =====
var balanced = orch.balance(q.scene, style: \romantic);
"Balanced orchestral score for Romantic style".postln;

// ===== RENDER =====
q.render("~/string_quartet_realistic.wav");
)
```

---

## Use Cases

### Classical Composition
- Write playable orchestral scores
- Learn orchestration rules
- Validate existing scores

### Film Scoring
- Realistic orchestral mockups
- Quick orchestration decisions
- Professional-sounding demos

### Music Education
- Teach orchestration principles
- Demonstrate good vs bad writing
- Provide immediate feedback

### Sample Library Programming
- Realistic articulation switching
- Natural performance simulation
- Humanized MIDI programming

---

## Summary

| Feature | QOrch | QHuman |
|---------|-------|--------|
| **Range Validation** | ✅ | — |
| **Playability Check** | ✅ | — |
| **Timbral Blending** | ✅ | — |
| **Breathing** | — | ✅ |
| **Vibrato** | — | ✅ |
| **Bowing** | — | ✅ |
| **Micro-Dynamics** | — | ✅ |
| **Fatigue** | — | ✅ |
| **LOC Estimate** | ~1,500 | ~1,000 |
| **Classes** | 8 | 7 |

**Total**: ~2,500 LOC, ~15 classes, 4 weeks implementation

---

**QOrch + QHuman = Professional orchestral realism**
