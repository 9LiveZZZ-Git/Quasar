# Quasar: Complete Object Model

## Overview

This document details all classes, their relationships, and APIs.

---

## Class Hierarchy

```
QProject (root container)
├── QTheory (music theory engine)
│   ├── QHarmony (scales, chords, progressions, voice leading)
│   ├── QMelody (motives, contours, development)
│   ├── QRhythm (meters, patterns, syncopation)
│   ├── QCounterpoint (species counterpoint, fugue)
│   └── QForm (formal archetypes)
│
├── QPalette (material library)
│   ├── QUnitDB (unit database)
│   ├── QUnit (individual units)
│   ├── QGestureLibrary (gesture presets)
│   └── QStateLibrary (parameter snapshots)
│
├── QTimeline (formal structure)
│   ├── QSection (timeline section)
│   └── QTransition (section transitions)
│
├── QTexture (voice management)
│   ├── QVoice (individual voice/part)
│   └── QOrchestration (instrument combinations)
│
├── QScene (audio rendering)
│   ├── QMixer (bus routing)
│   ├── QMacro (macro controls)
│   └── QFXESP (FX chain)
│
├── QSelector (material selection engine)
│   ├── QConstraint (selection constraints)
│   ├── QScoring (scoring functions)
│   └── QGrammar (compositional grammar)
│
├── QConductor (playback engine)
│   ├── QRenderer (NRT rendering)
│   └── QStemExporter (stem export)
│
└── QGUI (user interface)
    ├── QGUITimeline
    ├── QGUIScene
    ├── QGUITheory
    └── QMIDIMapper
```

---

## Core Classes

### QProject

**Purpose**: Root container for all composition data.

```supercollider
QProject {
  classvar <version = "1.0.0";

  var <name;
  var <tempo, <tempoMap;     // Can be constant or variable
  var <seed;                  // RNG seed for reproducibility
  var <keySignature;          // Current key (can modulate)
  var <timeSignature;         // Current meter (can change)

  var <theory;                // QTheory
  var <palette;               // QPalette
  var <timeline;              // QTimeline
  var <texture;               // QTexture
  var <scene;                 // QScene (current)
  var <selector;              // QSelector
  var <conductor;             // QConductor

  var <metadata;              // Dict (author, date, version info)

  *new { |name, tempo=120, seed|
    ^super.newCopyArgs(
      name,
      tempo,
      nil, // tempoMap
      seed ?? { Date.seed },
      \cMajor, // default key
      [4, 4]   // default time signature
    ).init;
  }

  init {
    theory = QTheory(this);
    palette = QPalette(this);
    timeline = QTimeline(this);
    texture = QTexture(this);
    selector = QSelector(this);
    conductor = QConductor(this);
    metadata = ();
  }

  // Template loading
  *fromTemplate { |name, params|
    var template = QTemplate.get(name);
    var project = QProject(
      name: template[\name] ?? name,
      tempo: template[\tempo],
      seed: params[\seed]
    );
    template[\theory].keysValuesDo { |k, v|
      project.theory.perform(k.asSetter, v);
    };
    ^project;
  }

  // Playback
  play { conductor.play }
  stop { conductor.stop }
  pause { conductor.pause }
  seek { |beat| conductor.seek(beat) }

  // Rendering
  render { |path, stems=false|
    if (stems) {
      conductor.renderStems(path);
    } {
      conductor.render(path);
    };
  }

  // Saving/loading
  save { |path|
    var data = this.asData;
    data.writeJSON(path);
  }

  *load { |path|
    var data = path.parseJSONFile;
    ^this.fromData(data);
  }

  asData {
    ^(
      version: version,
      name: name,
      tempo: tempo,
      seed: seed,
      keySignature: keySignature,
      timeSignature: timeSignature,
      metadata: metadata,
      theory: theory.asData,
      palette: palette.asData,
      timeline: timeline.asData,
      texture: texture.asData
    )
  }
}
```

---

## Music Theory Classes

### QTheory

**Purpose**: Container for all music theory modules.

```supercollider
QTheory {
  var <project;
  var <harmony, <melody, <rhythm, <counterpoint, <form;

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    harmony = QHarmony(project);
    melody = QMelody(project);
    rhythm = QRhythm(project);
    counterpoint = QCounterpoint(project);
    form = QForm(project);
  }

  asData {
    ^(
      harmony: harmony.asData,
      melody: melody.asData,
      rhythm: rhythm.asData,
      counterpoint: counterpoint.asData,
      form: form.asData
    )
  }
}
```

### QHarmony

**Purpose**: Harmonic system (scales, chords, progressions, voice leading).

```supercollider
QHarmony {
  var <project;
  var <scale, <mode;
  var <style; // \baroque, \classical, \jazz, \modal, \atonal, etc.
  var <progressionRules;
  var <voiceLeadingRules;

  // Scales (extensible)
  classvar <scales;

  *initClass {
    scales = (
      // Diatonic modes
      major: [0, 2, 4, 5, 7, 9, 11],
      minor: [0, 2, 3, 5, 7, 8, 10],
      harmonicMinor: [0, 2, 3, 5, 7, 8, 11],
      melodicMinor: [0, 2, 3, 5, 7, 9, 11],
      dorian: [0, 2, 3, 5, 7, 9, 10],
      phrygian: [0, 1, 3, 5, 7, 8, 10],
      lydian: [0, 2, 4, 6, 7, 9, 11],
      mixolydian: [0, 2, 4, 5, 7, 9, 10],
      locrian: [0, 1, 3, 5, 6, 8, 10],

      // Symmetric scales
      wholeTone: [0, 2, 4, 6, 8, 10],
      octatonic: [0, 2, 3, 5, 6, 8, 9, 11], // Half-whole
      chromatic: (0..11),

      // Pentatonic
      majorPentatonic: [0, 2, 4, 7, 9],
      minorPentatonic: [0, 3, 5, 7, 10],

      // Blues
      blues: [0, 3, 5, 6, 7, 10],

      // Jazz scales
      bebop: [0, 2, 4, 5, 7, 9, 10, 11],
      altered: [0, 1, 3, 4, 6, 8, 10],
      lydianDominant: [0, 2, 4, 6, 7, 9, 10],

      // Exotic
      hungarianMinor: [0, 2, 3, 6, 7, 8, 11],
      enigmatic: [0, 1, 4, 6, 8, 10, 11],
      hirajoshi: [0, 2, 3, 7, 8]
    );
  }

  *new { |project, scale=\major, style=\functional|
    ^super.newCopyArgs(project, scale, nil, style).init;
  }

  init {
    progressionRules = ();
    voiceLeadingRules = ();
    this.setStyle(style);
  }

  // Set harmonic style (loads default rules)
  setStyle { |newStyle|
    style = newStyle;
    case
    { style == \baroque } {
      progressionRules = (
        // Common Baroque progressions
        cadences: [\authentic, \plagal, \half, \deceptive],
        sequences: true,
        chromaticism: \moderate
      );
      voiceLeadingRules = (
        parallelFifths: false,
        parallelOctaves: false,
        hiddenFifths: \avoid,
        voiceCrossing: \rare,
        doubling: \root // Double root in triads
      );
    }
    { style == \classical } {
      progressionRules = (
        cadences: [\authentic, \half, \deceptive],
        modulations: [\dominant, \subdominant, \relative],
        secondaryDominants: true
      );
      voiceLeadingRules = (
        parallelFifths: false,
        parallelOctaves: false,
        smoothMotion: true,
        leapResolution: true
      );
    }
    { style == \jazz } {
      progressionRules = (
        cadences: [\twoFiveOne],
        substitutions: [\tritone, \secondary],
        extensions: [\7th, \9th, \11th, \13th, \altered]
      );
      voiceLeadingRules = (
        parallelFifths: \allowed, // Jazz allows parallels
        chromaticism: \high,
        alterations: true
      );
    }
    { style == \modal } {
      progressionRules = (
        functional: false, // No V-I
        movement: \stepwise, // Chords move by step
        pedal: true
      );
      voiceLeadingRules = (
        parallelFifths: \allowed,
        staticBass: \common
      );
    }
    { style == \atonal } {
      progressionRules = (
        functional: false,
        organization: \intervallic
      );
      voiceLeadingRules = (
        traditional: false,
        avoidTriads: true
      );
    };
  }

  // Get scale degrees
  degree { |degree, octave=4|
    var pc = scales[scale][degree % 7];
    var oct = octave + (degree div: 7);
    ^(oct * 12) + pc + this.rootPitch;
  }

  rootPitch {
    // Parse key signature (e.g., \cMajor, \dMinor)
    var key = project.keySignature.asString;
    ^"cdefgab".indexOf(key[0].toLower) !? { |i|
      [0, 2, 4, 5, 7, 9, 11][i]
    } ? 0;
  }

  // Generate chord from scale degree
  chord { |degree, type=\triad|
    var root = this.degree(degree);
    case
    { type == \triad } {
      ^[root, this.degree(degree+2), this.degree(degree+4)]
    }
    { type == \seventh } {
      ^[root, this.degree(degree+2), this.degree(degree+4), this.degree(degree+6)]
    }
    { type == \ninth } {
      ^[root, this.degree(degree+2), this.degree(degree+4),
        this.degree(degree+6), this.degree(degree+8)]
    }
  }

  // Generate progression
  progression { |type, length=4|
    case
    { type == \authentic } {
      ^[this.chord(4), this.chord(0)] // V-I
    }
    { type == \half } {
      ^[this.chord(0), this.chord(4)] // I-V
    }
    { type == \plagal } {
      ^[this.chord(3), this.chord(0)] // IV-I
    }
    { type == \twoFiveOne } {
      ^[
        this.chord(1, \seventh), // ii7
        this.chord(4, \seventh), // V7
        this.chord(0, \seventh)  // Imaj7
      ]
    }
    { type == \cyclic } {
      // Modal cyclic progression
      ^(length).collect { |i|
        this.chord(i % 7)
      }
    }
    { type == \functional } {
      // Generate functional progression using common rules
      var degrees = [0]; // Start with tonic
      (length-1).do {
        var last = degrees.last;
        var next = case
        { last == 0 } { [1, 2, 3, 4, 5, 6].choose } // From I, anywhere
        { last == 4 } { 0 } // V resolves to I
        { last == 6 } { 0 } // viio resolves to I
        { [1, 3, 5].choose }; // Others move freely
        degrees = degrees.add(next);
      };
      ^degrees.collect { |d| this.chord(d) }
    };
  }

  // Voice leading
  voiceLead { |chordProgression, voices=4|
    var voicer = QVoiceLeading(this, voices);
    ^voicer.harmonize(chordProgression)
  }

  asData {
    ^(
      scale: scale,
      style: style,
      progressionRules: progressionRules,
      voiceLeadingRules: voiceLeadingRules
    )
  }
}
```

### QVoiceLeading

**Purpose**: Voice leading calculator and enforcer.

```supercollider
QVoiceLeading {
  var <harmony;
  var <numVoices;
  var <constraints;
  var <ranges; // Per-voice ranges

  *new { |harmony, numVoices=4|
    ^super.newCopyArgs(harmony, numVoices).init;
  }

  init {
    constraints = ();
    // Default SATB ranges
    ranges = [
      [60, 81],  // Soprano C4-A5
      [55, 74],  // Alto G3-D5
      [48, 69],  // Tenor C3-A4
      [40, 60]   // Bass E2-C4
    ];
  }

  addConstraint { |name, func, weight=1|
    constraints[name] = (func: func, weight: weight);
  }

  // Harmonize a chord progression
  harmonize { |chordProgression|
    var voicings = [];
    var previousVoicing;

    chordProgression.do { |chord, i|
      var voicing;
      if (i == 0) {
        // First chord: just distribute notes
        voicing = this.initialVoicing(chord);
      } {
        // Subsequent chords: voice lead from previous
        voicing = this.voiceLeadFrom(previousVoicing, chord);
      };
      voicings = voicings.add(voicing);
      previousVoicing = voicing;
    };

    ^voicings;
  }

  initialVoicing { |chord|
    // Distribute chord tones across voices
    var voicing = Array.fill(numVoices);
    chord.do { |pc, i|
      var voice = i % numVoices;
      var octave = (ranges[voice][0] / 12).floor;
      voicing[voice] = (octave * 12) + (pc % 12);
    };
    ^voicing;
  }

  voiceLeadFrom { |previousVoicing, chord|
    // Find voicing of chord that minimizes motion from previous
    var candidates = this.generateCandidates(chord);
    var scored = candidates.collect { |voicing|
      var score = this.scoreVoicing(voicing, previousVoicing);
      [voicing, score]
    };
    ^scored.maxItem { |item| item[1] }[0]; // Best scoring voicing
  }

  generateCandidates { |chord|
    // Generate all valid voicings of chord within ranges
    // (Simplified - real implementation would be more thorough)
    var voicings = [];
    10.do { // Generate 10 random voicings
      var voicing = Array.fill(numVoices, { |i|
        var pc = chord.choose % 12;
        var range = ranges[i];
        var octave = rrand(range[0] / 12, range[1] / 12).floor;
        (octave * 12) + pc;
      });
      if (this.isValidVoicing(voicing)) {
        voicings = voicings.add(voicing);
      };
    };
    ^voicings;
  }

  isValidVoicing { |voicing|
    // Check if voicing satisfies all constraints
    numVoices.do { |i|
      var pitch = voicing[i];
      if (pitch < ranges[i][0] or: { pitch > ranges[i][1] }) {
        ^false; // Out of range
      };
    };
    ^true;
  }

  scoreVoicing { |voicing, previousVoicing|
    var score = 0;

    // Smooth motion (prefer small intervals)
    var totalMotion = voicing.sum { |pitch, i|
      (pitch - previousVoicing[i]).abs;
    };
    score = score - (totalMotion * 0.1); // Penalty for motion

    // Check for parallel fifths/octaves
    if (constraints[\noParallelFifths] !? _.weight > 0) {
      if (this.hasParallelFifths(previousVoicing, voicing)) {
        score = score - 100; // Heavy penalty
      };
    };

    // Prefer contrary motion
    if (constraints[\contraryMotion] !? _.weight > 0) {
      var contraryCount = this.countContraryMotion(previousVoicing, voicing);
      score = score + (contraryCount * constraints[\contraryMotion].weight);
    };

    ^score;
  }

  hasParallelFifths { |v1, v2|
    // Check all voice pairs for parallel perfect fifths
    numVoices.do { |i|
      (i+1..numVoices-1).do { |j|
        var interval1 = (v1[j] - v1[i]) % 12;
        var interval2 = (v2[j] - v2[i]) % 12;
        if (interval1 == 7 and: { interval2 == 7 }) {
          // Both are perfect fifths
          var motion1 = v2[i] - v1[i];
          var motion2 = v2[j] - v1[j];
          if (motion1.sign == motion2.sign) {
            ^true; // Parallel motion
          };
        };
      };
    };
    ^false;
  }

  countContraryMotion { |v1, v2|
    var count = 0;
    numVoices.do { |i|
      (i+1..numVoices-1).do { |j|
        var motion1 = (v2[i] - v1[i]).sign;
        var motion2 = (v2[j] - v1[j]).sign;
        if (motion1 == motion2.neg and: { motion1 != 0 }) {
          count = count + 1; // Contrary motion
        };
      };
    };
    ^count;
  }
}
```

### QMelody

**Purpose**: Melodic generation and development.

```supercollider
QMelody {
  var <project;
  var <harmony; // Reference to QHarmony
  var <style;
  var <contourLibrary;
  var <ornamentationRules;

  *new { |project, style=\lyrical|
    ^super.newCopyArgs(project, project.theory.harmony, style).init;
  }

  init {
    contourLibrary = (
      arch: { |length, peak=0.5|
        Array.fill(length, { |i|
          var pos = i / (length - 1);
          sin((pos - 0.5 + peak) * pi).max(0);
        });
      },
      ascending: { |length|
        Array.fill(length, { |i| i / (length - 1) });
      },
      descending: { |length|
        Array.fill(length, { |i| 1 - (i / (length - 1)) });
      },
      wave: { |length, cycles=2|
        Array.fill(length, { |i|
          sin(i / (length - 1) * cycles * 2pi) * 0.5 + 0.5;
        });
      }
    );
  }

  // Generate melody from contour
  fromContour { |contourType, length=8, range=12|
    var contour = contourLibrary[contourType].value(length);
    var melody = contour.collect { |val|
      var degree = (val * range).round.asInteger;
      harmony.degree(degree);
    };
    ^melody;
  }

  // Develop a motive
  develop { |motive, technique|
    case
    { technique == \repetition } {
      ^motive; // Exact repeat
    }
    { technique == \sequence } { |direction=\up, steps=1|
      var intervals = motive.differentiate.drop(1);
      var start = motive[0] + (steps * 2); // Transpose up by scale steps
      ^[start] ++ intervals.integrate(start);
    }
    { technique == \inversion } {
      var intervals = motive.differentiate.drop(1);
      ^[motive[0]] ++ intervals.neg.integrate(motive[0]);
    }
    { technique == \retrograde } {
      ^motive.reverse;
    }
    { technique == \augmentation } { |factor=2|
      // Double note durations (rhythmic, not pitch)
      ^motive; // Would need rhythm info
    };
  }

  // Add ornamentation
  ornament { |melody, density=0.3, types=[\neighbor, \passing]|
    var ornamented = [];
    melody.do { |pitch, i|
      ornamented = ornamented.add(pitch);
      if (density.coin and: { i < (melody.size - 1) }) {
        var nextPitch = melody[i + 1];
        var ornament = types.choose;
        case
        { ornament == \neighbor } {
          // Add upper or lower neighbor
          var neighbor = pitch + [1, -1].choose;
          ornamented = ornamented.add(neighbor);
        }
        { ornament == \passing } {
          // Add passing tone between pitches
          var interval = nextPitch - pitch;
          if (interval.abs > 2) {
            var passing = pitch + interval.sign;
            ornamented = ornamented.add(passing);
          };
        };
      };
    };
    ^ornamented;
  }

  asData {
    ^(
      style: style
    )
  }
}
```

### QRhythm

**Purpose**: Rhythmic pattern generation and manipulation.

```supercollider
QRhythm {
  var <project;
  var <meter;
  var <patternLibrary;

  *new { |project, meter=[4, 4]|
    ^super.newCopyArgs(project, meter).init;
  }

  init {
    patternLibrary = (
      // Common rhythm patterns (in beats)
      quarter: [1, 1, 1, 1],
      eighth: [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5],
      swingEighth: [0.66, 0.33, 0.66, 0.33, 0.66, 0.33, 0.66, 0.33],
      dotted: [0.75, 0.25, 0.75, 0.25, 0.75, 0.25, 0.75, 0.25],

      // Clave patterns (as binary)
      sonClave: [1,0,0,1,0,0,1,0, 0,0,1,0,1,0,0,0],
      rumbaClave: [1,0,0,1,0,0,1,0, 0,1,0,0,1,0,0,0],

      // Tresillo
      tresillo: [1,0,0,1,0,0,1,0]
    );
  }

  pattern { |name|
    ^patternLibrary[name];
  }

  // Syncopate a rhythm
  syncopate { |pattern, density=0.5|
    var syncopated = pattern.copy;
    pattern.do { |val, i|
      if (val == 1 and: { density.coin }) {
        // Move note off-beat
        if (i > 0 and: { pattern[i-1] == 0 }) {
          syncopated[i-1] = 1;
          syncopated[i] = 0;
        };
      };
    };
    ^syncopated;
  }

  // Create polyrhythm
  polyrhythm { |ratios, duration|
    var patterns = ratios.collect { |ratio|
      var beats = duration * ratio;
      var pattern = Array.fill(beats, { |i|
        i % ratio == 0; // Hit every ratio beats
      });
      pattern;
    };
    ^patterns;
  }

  // Apply swing
  swing { |pattern, amount=0.66|
    // Swing affects pairs of eighth notes
    var swung = [];
    var i = 0;
    while { i < pattern.size } {
      if (i < (pattern.size - 1)) {
        // Pair of notes
        swung = swung.add(pattern[i] * amount);
        swung = swung.add(pattern[i+1] * (1 - amount));
        i = i + 2;
      } {
        swung = swung.add(pattern[i]);
        i = i + 1;
      };
    };
    ^swung;
  }

  asData {
    ^(
      meter: meter
    )
  }
}
```

### QCounterpoint

**Purpose**: Contrapuntal composition and fugue generation.

```supercollider
QCounterpoint {
  var <project;
  var <harmony;
  var <species; // \first, \second, \third, \fourth, \fifth

  *new { |project, species=\first|
    ^super.newCopyArgs(project, project.theory.harmony, species).init;
  }

  init {
    // Initialize counterpoint rules based on species
  }

  // Generate counterpoint above/below a cantus firmus
  generate { |cantusFirmus, voice=\above|
    case
    { species == \first } {
      ^this.firstSpecies(cantusFirmus, voice);
    }
    { species == \second } {
      ^this.secondSpecies(cantusFirmus, voice);
    };
  }

  firstSpecies { |cf, voice|
    // Note against note
    var counterpoint = [];
    cf.do { |note, i|
      var consonances = [0, 3, 4, 5, 7, 8, 9, 12]; // Consonant intervals
      var interval, cpNote;

      if (i == 0 or: { i == (cf.size - 1) }) {
        interval = [0, 7, 12].choose; // Start/end on perfect consonance
      } {
        interval = consonances.choose;
      };

      cpNote = if (voice == \above) {
        note + interval;
      } {
        note - interval;
      };

      counterpoint = counterpoint.add(cpNote);
    };
    ^counterpoint;
  }

  // Fugue subject generation
  generateSubject { |key, length=4|
    // Generate a fugue subject (simplified)
    var subject = [];
    var currentPitch = harmony.degree(0); // Start on tonic

    length.do { |i|
      subject = subject.add(currentPitch);
      // Move by step or small leap
      var motion = [-2, -1, 1, 2, 3, 4].choose;
      currentPitch = currentPitch + motion;
    };

    ^subject;
  }

  // Generate tonal answer to fugue subject
  answer { |subject, type=\tonal|
    case
    { type == \real } {
      // Real answer: exact transposition to dominant
      ^subject + 7; // Up a fifth
    }
    { type == \tonal } {
      // Tonal answer: adjusted to stay in key
      var answer = [];
      subject.do { |pitch, i|
        var degree = this.pitchToDegree(pitch);
        var answerDegree = case
        { degree == 0 } { 4 } // Tonic → Dominant
        { degree == 4 } { 0 } // Dominant → Tonic
        { degree }; // Others stay same
        answer = answer.add(harmony.degree(answerDegree));
      };
      ^answer;
    };
  }

  pitchToDegree { |pitch|
    var pc = pitch % 12;
    var root = harmony.rootPitch;
    var scalePCs = harmony.scales[harmony.scale].collect { |i| (i + root) % 12 };
    ^scalePCs.indexOf(pc) ? 0;
  }

  asData {
    ^(
      species: species
    )
  }
}
```

### QForm

**Purpose**: Large-scale formal archetypes.

```supercollider
QForm {
  var <project;
  var <archetype; // \binary, \ternary, \rondo, \sonata, etc.
  var <sections; // Array of section definitions

  *new { |project, archetype=\ternary|
    ^super.newCopyArgs(project, archetype, []).init;
  }

  init {
    this.setArchetype(archetype);
  }

  setArchetype { |type|
    archetype = type;
    case
    { type == \binary } {
      sections = [
        (name: \A, repeat: true),
        (name: \B, repeat: true)
      ];
    }
    { type == \ternary } {
      sections = [
        (name: \A, duration: 8),
        (name: \B, duration: 8),
        (name: \A, duration: 8) // Repeat of A
      ];
    }
    { type == \rondo } {
      sections = [
        (name: \A, duration: 8),
        (name: \B, duration: 8),
        (name: \A, duration: 8),
        (name: \C, duration: 8),
        (name: \A, duration: 8)
      ];
    }
    { type == \sonata } {
      sections = [
        (name: \exposition, subsections: [\theme1, \transition, \theme2]),
        (name: \development, techniques: [\fragmentation, \sequence]),
        (name: \recapitulation, subsections: [\theme1, \theme2]) // Both in tonic
      ];
    }
    { type == \edm } {
      sections = [
        (name: \intro, duration: 8, energy: 0.2),
        (name: \build, duration: 8, energy: [0.2, 0.8]),
        (name: \drop, duration: 16, energy: 0.9),
        (name: \break, duration: 8, energy: 0.3),
        (name: \drop2, duration: 16, energy: 0.9),
        (name: \outro, duration: 8, energy: [0.6, 0.1])
      ];
    };
  }

  generate {
    // Generate timeline from form definition
    sections.do { |sectionDef|
      var section = QSection(
        name: sectionDef[\name],
        duration: sectionDef[\duration] ?? 8,
        scene: nil, // To be filled
        state: nil
      );
      project.timeline.addSection(section);
    };
  }

  asData {
    ^(
      archetype: archetype,
      sections: sections
    )
  }
}
```

---

## Material Classes (Continued in next file for length)

I'll create a second part with the remaining classes...
