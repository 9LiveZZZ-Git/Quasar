# Quasar: Genre-Agnostic Architecture

## Design Philosophy

**Quasar is genre-agnostic**: it provides fundamental music theory primitives that can be combined to create any style, from Baroque fugues to EDM drops to free improvisation.

Instead of hard-coding "dubstep" concepts, we provide:
- **Harmonic systems** (scales, chords, progressions, voice leading)
- **Melodic systems** (motives, contours, development)
- **Rhythmic systems** (meters, patterns, syncopation)
- **Textural systems** (monophony → polyphony)
- **Formal archetypes** (binary, rondo, sonata, moment form, EDM forms)
- **Orchestration rules** (ranges, doublings, balance)

**Users combine these** via:
1. **Genre templates** (e.g., "Baroque", "Jazz", "Techno")
2. **Constraint profiles** (style-specific rules)
3. **Custom libraries** (their own units/gestures)

---

## Core Architecture: The 10 Pillars

### 1. QProject - Project Container
The root object containing all composition metadata.

```supercollider
QProject {
  var <tempo, <seed;
  var <keySignature, <timeSignature;
  var <palette;      // Materials (units, gestures, states)
  var <timeline;     // Formal structure
  var <theory;       // Theory settings
  var <mixer;        // Audio routing
  var <metadata;     // Version, author, etc.
}
```

**Genre-agnostic design**:
- `tempo` can be fixed, variable, or rubato
- `keySignature` supports any scale (12-TET, microtonal, modal)
- `timeSignature` supports complex/changing meters

---

### 2. QTheory - Music Theory System
Centralizes all theory-related functionality.

```supercollider
QTheory {
  var <harmony;      // QHarmony
  var <melody;       // QMelody
  var <rhythm;       // QRhythm
  var <counterpoint; // QCounterpoint
  var <form;         // QForm
}
```

#### 2.1 QHarmony - Harmonic System

**Capabilities**:
- Define scales/modes (major, minor, dorian, phrygian, whole-tone, octatonic, etc.)
- Construct chords (triads, 7ths, 9ths, clusters, quartal, quintal)
- Generate progressions (functional, modal, chromatic, random)
- Voice leading (SATB rules, smooth voice leading, common-tone retention)
- Modulation strategies

**Example**:
```supercollider
// Baroque-style functional progression
h = QHarmony(\dMajor, \baroque);
prog = h.progression(\authentic);
// → [Dm, A7, Dm] (i - V7 - i)

// Jazz progression
h = QHarmony(\cMajor, \jazz);
prog = h.progression(\twoFiveOne);
// → [Dm7, G7, Cmaj7]

// Modal progression (no functional harmony)
h = QHarmony(\dDorian, \modal);
prog = h.progression(\cyclic, chords: [\i, \bVII, \IV]);
// → [Dm, C, G, Dm, C, G...]

// EDM bass line (just root notes)
h = QHarmony(\dMinor, \edm);
prog = h.bassline(\drops, rhythm: \quarter);
// → D, D, D, D, Bb, Bb, Bb, Bb...
```

**Voice Leading**:
```supercollider
vl = QVoiceLeading(\satb); // Soprano, Alto, Tenor, Bass
vl.addConstraint(\noParallelFifths);
vl.addConstraint(\smoothMotion, weight: 2);
vl.addConstraint(\preferContraryMotion, weight: 1);

// Given chord progression, generate 4-part voicing
voicing = vl.harmonize([Dm, A7, Dm], style: \baroque);
// → [
//     [d5, f4, a3, d3],  // Dm
//     [cs5, e4, a3, d3], // A7 (smooth voice leading)
//     [d5, f4, a3, d3]   // Dm
//   ]
```

#### 2.2 QMelody - Melodic System

**Capabilities**:
- Motive definition and transformation
- Contour generation (up, down, arch, valley, zigzag)
- Interval patterns
- Ornamentation (neighbor tones, passing tones, appoggiaturas)
- Melodic development (repetition, sequence, inversion, retrograde, augmentation, diminution)

**Example**:
```supercollider
// Define a motive (Beethoven's 5th: "short-short-short-long")
motive = QMotive([0, 0, 0, -2], [1, 1, 1, 4]); // [intervals], [durations]

// Transform it
m.develop(\sequence, direction: \up, steps: 2);
// Sequence up twice

m.develop(\inversion);
// Melodic inversion

m.develop(\retrograde);
// Play backwards

m.develop(\augmentation, factor: 2);
// Double note values

// Generate melody from scale and contour
mel = QMelody(\dMinor);
mel.fromContour(\arch, length: 8, highPoint: 0.7);
// Generates 8-note melody that peaks at 70% through

// Add ornamentation
mel.ornament(\baroque, density: 0.3);
// Adds neighbor tones, trills, etc.
```

#### 2.3 QRhythm - Rhythmic System

**Capabilities**:
- Metric hierarchy (strong/weak beats)
- Rhythmic patterns and cells
- Syncopation algorithms
- Polyrhythm/polymeter
- Swing and groove quantization
- Metric modulation

**Example**:
```supercollider
// Create a clave pattern
r = QRhythm(\fourFour);
r.pattern(\sonClave); // → [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0]

// Syncopate a pattern
r.syncopate(density: 0.5); // Move 50% of notes off-beat

// Polyrhythm (3 against 4)
r.polyrhythm([3, 4], duration: 4);
// → Two simultaneous patterns

// Swing quantization
r.swing(0.66); // Swing 16ths (like triplet feel)

// Generate rhythmic cell
r.cell(\balkan, meter: [7, 8], subdivision: [2, 2, 3]);
// → 7/8 time with 2+2+3 grouping
```

#### 2.4 QCounterpoint - Contrapuntal Rules

**Capabilities**:
- Species counterpoint (1st through 5th species)
- Consonance/dissonance treatment
- Motion types (parallel, contrary, oblique, similar)
- Imitation and canon
- Fugue subject/answer generation

**Example**:
```supercollider
// First species (note against note)
cp = QCounterpoint(\firstSpecies);
cantusFirmus = [60, 62, 64, 65, 64, 62, 60]; // C major scale up and down
counterpoint = cp.generate(cantusFirmus, voice: \above);
// → Generates valid counterpoint above the cantus firmus

// Canon at the fifth
cp = QCounterpoint(\canon);
subject = [60, 62, 64, 65];
answer = cp.answer(subject, interval: 7, delay: 2); // 5th up, 2 beats later

// Fugue subject
cp = QCounterpoint(\fugue);
subject = cp.generateSubject(key: \dMinor, length: 4);
answer = cp.answer(subject, type: \tonal); // Tonal answer (adjusted intervals)
counterSubject = cp.counterSubject(subject);
```

#### 2.5 QForm - Formal Archetypes

**Capabilities**:
- Classical forms (binary, ternary, rondo, sonata)
- Baroque forms (fugue, suite movements)
- Romantic forms (character piece, song form, symphonic poem)
- Jazz forms (AABA, 12-bar blues, rhythm changes)
- EDM forms (intro/build/drop/break)
- Experimental forms (moment form, mobile form, open form)

**Example**:
```supercollider
// Sonata form
f = QForm(\sonata);
f.exposition(
  theme1: \heroicTheme, key: \dMajor,
  transition: \modulatingBridge,
  theme2: \lyricalTheme, key: \aMajor // Dominant key
);
f.development(
  techniques: [\fragmentation, \sequence, \modulation],
  intensity: \curve // Builds intensity
);
f.recapitulation(
  theme1: \heroicTheme, key: \dMajor,
  theme2: \lyricalTheme, key: \dMajor // Both themes in tonic
);
f.coda(material: \theme1Fragment);

// Rondo form (ABACABA)
f = QForm(\rondo);
f.refrain(\mainTheme, repeat: 4);
f.episode(\contrastA, key: \relative);
f.episode(\contrastB, key: \subdominant);

// EDM form
f = QForm(\edm);
f.intro(8, texture: \sparse, energy: 0.2);
f.build(8, energy: [0.2, 0.8], filter: \opening);
f.drop(16, texture: \maximal, energy: 0.9);
f.break(8, texture: \minimal, energy: 0.3);
f.drop(16, variant: \pitched); // Second drop variation
f.outro(8, energy: [0.6, 0.1]);

// Moment form (Stockhausen-style)
f = QForm(\moment);
f.moment(\A, duration: \variable, character: \pointillistic);
f.moment(\B, duration: \variable, character: \sustained);
f.moment(\C, duration: \variable, character: \rhythmic);
f.sequence(\random); // Random order each time
```

---

### 3. QTexture - Texture Management

Manages the number of voices and their relationships.

```supercollider
QTexture {
  var <type; // \monophonic, \homophonic, \polyphonic, \heterophonic
  var <voices; // Array of QVoice objects
  var <density; // How many voices active
}
```

**Texture types**:
- **Monophonic**: Single melodic line (plainchant, solo)
- **Homophonic**: Melody + accompaniment (hymn, most pop music)
- **Polyphonic**: Multiple independent melodies (fugue, counterpoint)
- **Heterophonic**: Simultaneous variations of same melody (some world music)

**Example**:
```supercollider
// Start monophonic, gradually add voices
t = QTexture(\monophonic);
t.addVoice(\soprano, melody: mainTheme);

// Morph to homophonic (add accompaniment)
t.morph(\homophonic, bars: 4);
t.addVoice(\alto, role: \harmony);
t.addVoice(\tenor, role: \harmony);
t.addVoice(\bass, role: \bassline);

// Morph to polyphonic (all voices become independent)
t.morph(\polyphonic, bars: 8);
t.setVoiceRole(\alto, \countermelody);
t.setVoiceRole(\tenor, \countermelody);

// Thin back to monophonic
t.reduce(\monophonic, bars: 4, fadeOut: true);
```

---

### 4. QVoice - Voice/Part Abstraction

Represents a single musical line with constraints.

```supercollider
QVoice {
  var <name;           // \soprano, \bassline, \lead, etc.
  var <range;          // [minPitch, maxPitch]
  var <tessitura;      // Comfortable range subset
  var <role;           // \melody, \harmony, \bassline, \countermelody
  var <articulation;   // \legato, \staccato, \marcato, etc.
  var <dynamics;       // QDynamics object
}
```

**Ranges** (built-in presets):
```supercollider
QVoice.ranges = (
  // Vocal ranges
  soprano: [60, 81],   // C4-A5
  mezzosoprano: [57, 77], // A3-F5
  alto: [55, 74],      // G3-D5
  tenor: [48, 69],     // C3-A4
  baritone: [45, 65],  // A2-F4
  bass: [40, 60],      // E2-C4

  // Instrumental ranges
  violin: [55, 103],   // G3-G7
  viola: [48, 91],     // C3-G6
  cello: [36, 76],     // C2-E5
  flute: [60, 96],     // C4-C7
  clarinet: [50, 91],  // D3-G6

  // Bass instruments
  bassSynth: [28, 60], // E1-C4
  kick: [20, 100],     // Frequency range, not pitch
  sub: [20, 80]
);
```

---

### 5. QOrchestration - Instrument Combinations

Manages how voices/instruments combine.

```supercollider
QOrchestration {
  var <ensemble;     // Array of QVoice
  var <balance;      // Relative volume levels
  var <doubling;     // Which voices double each other
  var <spacing;      // Open/closed position
}
```

**Orchestration rules**:
```supercollider
orch = QOrchestration(\stringQuartet);
orch.ensemble([\violin1, \violin2, \viola, \cello]);

// Standard spacing rules
orch.spacing(\open); // Wider intervals in lower voices

// Doubling
orch.double(\melody, instruments: [\violin1, \violin2], interval: \octave);

// Balance
orch.balance(\pyramid); // Louder on bottom, softer on top
orch.balance(\inverted); // Louder on top (spotlight melody)

// Blend (which instruments sound good together)
orch.blend(\strings); // Homogeneous blend
orch.blend(\mixed);   // Heterogeneous (e.g., winds + brass)
```

---

### 6. QGesture - Musical Behaviors

**Gestures are short musical ideas** (phrase-length or less) with specific intent.

**Categories**:
1. **Harmonic Gestures**: Cadences, modulations, pedal points
2. **Melodic Gestures**: Scales, arpeggios, neighbor tones, sequences
3. **Rhythmic Gestures**: Accelerando, ritardando, hemiola
4. **Textural Gestures**: Density changes, imitative entries
5. **Dynamic Gestures**: Crescendo, diminuendo, sforzando
6. **Articulation Gestures**: Legato→staccato transitions

**Base class**:
```supercollider
QGesture {
  var <duration;     // In beats
  var <intent;       // \cadence, \transition, \development, etc.
  var <parameters;   // Dict of params

  asPattern { }      // Returns a Pattern (for events)
  asEnvelope { }     // Returns an Env (for continuous control)
}
```

**Example gestures**:
```supercollider
// Harmonic gestures
QGesture.cadence(\authentic, key: \dMinor);
// → Generates V7 - i progression

QGesture.modulation(\pivot, from: \cMajor, to: \gMajor);
// → Uses common chord to modulate

QGesture.pedalPoint(\dominant, duration: 8);
// → Holds dominant note in bass while harmony changes above

// Melodic gestures
QGesture.scale(\ascending, scale: \dMinor, octaves: 2);
// → Two-octave ascending scale

QGesture.arpeggio(\dm7, direction: \upDown, pattern: \broken);
// → Broken arpeggio up and down

QGesture.sequence(\melodic, motive: [0, 2, 4], direction: \up, steps: 3);
// → Sequence a motive up 3 times

// Rhythmic gestures
QGesture.accelerando(startTempo: 60, endTempo: 120, duration: 8);
// → Gradual tempo increase

QGesture.hemiola(meter: [3, 4], duration: 2);
// → 3/4 time with 2-against-3 feel

// Textural gestures
QGesture.imitation(\canon, subject: myMelody, voices: 4, delay: 2);
// → 4-voice canon with 2-beat delays

QGesture.densityRamp(start: 0.2, end: 0.9, duration: 16);
// → Gradually increase note density

// Dynamic gestures
QGesture.crescendo(start: \pp, end: \ff, duration: 8);
// → Gradual crescendo over 8 beats

QGesture.terracing(levels: [\p, \mf, \f], duration: 12);
// → Stepwise dynamic changes (Baroque style)
```

---

### 7. QUnit - Musical Material Units

**Units are the atoms of composition** - small chunks of musical material.

**Unit types**:
- **Audio buffers** (recorded samples, field recordings)
- **Synth patterns** (procedurally generated)
- **MIDI sequences** (imported)
- **Score fragments** (notated material)

```supercollider
QUnit {
  var <buffer;       // Audio buffer (if audio)
  var <pattern;      // Pattern (if generative)
  var <metadata;     // Tags, features, pitch content, etc.
  var <hash;         // For reproducibility
}
```

**Metadata fields**:
```supercollider
(
  tags: [\string, \pizzicato, \short, \bright],
  duration: 2.5,
  pitchContent: [d4, f4, a4], // Detected/annotated pitches

  // Audio features (extracted or manual)
  rms: 0.65,
  spectralCentroid: 2400,
  spectralSpread: 0.3,
  zcr: 0.15,

  // Music theory annotations
  harmony: \dm, // D minor chord
  register: \mid,
  articulation: \staccato,
  dynamics: \mf,

  // Context tags
  genre: [\classical, \baroque],
  instrument: \violin,
  technique: \pizzicato,
  character: [\playful, \light]
)
```

**Unit selection** (covered in Phase 7):
```supercollider
selector = QSelector(unitDB, seed: 12345);

// Select by tags
unit = selector.choose(
  tags: [\string, \short, \bright],
  exclude: recentUnits,
  context: (
    harmony: \dm,
    dynamics: \mf,
    register: \mid
  )
);

// Scoring considers:
// - Tag match (how many tags match request)
// - Harmonic fit (does unit's pitch content fit current harmony)
// - Novelty (avoid recent repeats)
// - Continuity (smooth register/dynamics transitions)
// - Voice leading (if melodic, prefer smooth intervals)
```

---

### 8. QScene - Audio Scene Management

**A Scene is a mixer + layer stack + macro controls.**

```supercollider
QScene {
  var <proxySpace;   // Underlying ProxySpace
  var <layers;       // Dict of layer name → NodeProxy
  var <macros;       // Dict of macro name → parameter mappings
  var <fxChain;      // FX routing
  var <state;        // Current QState
}
```

**Standard layers** (genre-agnostic):
- **Bass**: Low-frequency foundation
- **Harmony**: Chordal/harmonic content
- **Melody**: Primary melodic line
- **Countermelody**: Secondary melodic lines
- **Texture**: Pad, atmosphere, sustained tones
- **Percussion**: Rhythmic elements
- **FX**: Effects returns

**Macros** (high-level controls):
```supercollider
scene = QScene(\myScene);

// Define macros (one control → many parameters)
scene.defineMacro(\energy, [
  // [layer, param, min, max, curve]
  [\bass, \amp, 0.3, 1.0, \lin],
  [\harmony, \amp, 0.2, 0.8, \lin],
  [\percussion, \density, 0.2, 0.9, \exp],
  [\fx, \verb, 0.4, 0.1, \lin.neg] // Inverse
]);

scene.defineMacro(\brightness, [
  [\bass, \cutoff, 200, 800, \exp],
  [\harmony, \cutoff, 1000, 8000, \exp],
  [\melody, \cutoff, 2000, 12000, \exp]
]);

scene.defineMacro(\space, [
  [\fx, \verbMix, 0.0, 0.6, \lin],
  [\fx, \verbSize, 0.3, 0.95, \lin],
  [\fx, \delayMix, 0.0, 0.3, \lin]
]);

// Control scenes with one knob
scene.setMacro(\energy, 0.8);
scene.setMacro(\brightness, 0.6);
scene.setMacro(\space, 0.3);
```

**Genre-specific presets**:
```supercollider
// Classical orchestra preset
QScene.preset(\orchestra, macros: (
  dynamics: [ /* maps to instrument volumes */ ],
  articulation: [ /* legato/staccato blend */ ],
  hall: [ /* reverb size */ ]
));

// Jazz combo preset
QScene.preset(\jazzCombo, macros: (
  swing: [ /* swing amount */ ],
  walking: [ /* bass walking pattern density */ ],
  ride: [ /* ride cymbal intensity */ ]
));

// EDM preset
QScene.preset(\edm, macros: (
  energy: [ /* as above */ ],
  filter: [ /* global filter sweep */ ],
  sidechain: [ /* sidechain compression depth */ ]
));
```

---

### 9. QTimeline - Formal Structure Sequencer

**Timeline manages sections + transitions.**

```supercollider
QTimeline {
  var <sections;     // Array of QSection
  var <form;         // QForm archetype (optional)
  var <conductor;    // QConductor for playback
}

QSection {
  var <name;         // \intro, \exposition, \dropA, etc.
  var <duration;     // In beats or bars
  var <scene;        // QScene to play
  var <state;        // QState (parameters for this section)
  var <transition;   // QGesture for transition to next section
}
```

**Example**:
```supercollider
timeline = QTimeline();

// Add sections
timeline.add(\intro,
  duration: 8.bars,
  scene: introScene,
  state: \sparse,
  transition: QGesture.crescendo(duration: 2)
);

timeline.add(\themeA,
  duration: 16.bars,
  scene: mainScene,
  state: \energetic,
  transition: QGesture.cadence(\half) // Half cadence transition
);

timeline.add(\development,
  duration: 24.bars,
  scene: devScene,
  state: \intense,
  transition: QGesture.retransition(duration: 4) // Lead back to tonic
);

timeline.add(\recapitulation,
  duration: 16.bars,
  scene: mainScene,
  state: \triumphant,
  transition: QGesture.cadence(\authentic)
);

timeline.add(\coda,
  duration: 8.bars,
  scene: codaScene,
  state: \resolving
);
```

---

### 10. QConductor - Playback Engine

**Conductor handles timing and section changes.**

```supercollider
QConductor {
  var <timeline;
  var <clock;        // TempoClock
  var <routine;      // Main playback Routine
  var <position;     // Current beat position

  play { }           // Start playback
  stop { }           // Stop playback
  seek { |beat| }    // Jump to position

  asScore { }        // Generate Score for NRT rendering
}
```

**Realtime playback**:
```supercollider
conductor = QConductor(timeline, tempo: 120);
conductor.play; // Uses Routine + TempoClock
```

**Offline rendering**:
```supercollider
score = conductor.asScore;
score.recordNRT(
  outputFilePath: "~/output.wav",
  sampleRate: 48000,
  headerFormat: "wav",
  sampleFormat: "int24"
);
```

---

## Genre Templates

To make Quasar easy to use, we provide **genre templates** that set up appropriate:
- Theory systems (scales, progressions, voice leading rules)
- Texture defaults
- Form archetypes
- Macro presets
- Example unit libraries

### Template: Baroque Fugue

```supercollider
QTemplate.baroque = (
  theory: (
    harmony: QHarmony(\baroque,
      progressions: \functional,
      nonChordTones: \passing, // Passing tones, neighbor tones
      dissonanceTreatment: \resolve
    ),
    counterpoint: QCounterpoint(\species, rules: \strict),
    melody: QMelody(\baroque,
      ornamentation: [\trill, \mordent, \turn],
      contour: \stepwise
    ),
    form: QForm(\fugue,
      exposition: (voices: 4, entries: \staggered),
      episodes: (techniques: [\sequence, \fragmentation]),
      stretti: true
    )
  ),

  texture: QTexture(\polyphonic, voices: 4),

  orchestration: (
    ensemble: \stringQuartet, // or \harpsichord, \organ
    balance: \equal,
    articulation: \detached
  ),

  tempo: (range: [60, 120], style: \steady),

  macros: (
    terracing: \baroqueDynamics, // Stepped dynamics, not gradual
    articulation: [\legato, \detache, \staccato]
  )
);
```

**Usage**:
```supercollider
q = QProject.fromTemplate(\baroque);
q.theory.harmony.scale_(\dMinor);
q.theory.form.generate; // Generates fugue structure automatically
q.timeline.populate;    // Populates timeline with generated material
q.play;
```

### Template: Classical Sonata

```supercollider
QTemplate.classical = (
  theory: (
    harmony: QHarmony(\classical,
      progressions: \functional,
      modulations: [\dominant, \relative, \parallel],
      cadences: [\authentic, \half, \deceptive]
    ),
    melody: QMelody(\classical,
      development: [\fragmentation, \sequence, \inversion],
      phrases: \periodic // 4+4, 8+8 bar phrases
    ),
    form: QForm(\sonata,
      exposition: (
        theme1: (character: \masculine, key: \tonic),
        transition: (modulation: \dominant),
        theme2: (character: \feminine, key: \dominant)
      ),
      development: (
        techniques: [\fragmentation, \sequence, \modulation],
        intensity: \climax
      ),
      recapitulation: (
        theme1: (key: \tonic),
        theme2: (key: \tonic) // Resolves to tonic
      )
    )
  ),

  texture: QTexture(\homophonic, // Melody + accompaniment
    layers: [\melody, \harmony, \bass]
  ),

  orchestration: (
    ensemble: \chamberEnsemble,
    balance: \pyramid,
    dynamics: \gradual // Crescendo/diminuendo
  ),

  tempo: (range: [60, 140], changes: \allowed),

  macros: (
    dynamics: [\pp, \p, \mp, \mf, \f, \ff],
    articulation: [\legato, \staccato, \marcato, \tenuto]
  )
);
```

### Template: Jazz Standard

```supercollider
QTemplate.jazz = (
  theory: (
    harmony: QHarmony(\jazz,
      chords: [\7th, \9th, \11th, \13th, \altered],
      progressions: [\twoFiveOne, \rhythm changes, \blues],
      substitutions: [\tritone, \secondary dominant]
    ),
    melody: QMelody(\jazz,
      scales: [\bebop, \altered, \diminished],
      chromaticism: \high,
      ornamentation: [\grace, \bend, \scoop]
    ),
    rhythm: QRhythm(\swing,
      swing: 0.66, // Triplet feel
      syncopation: \high,
      anticipation: true
    ),
    form: QForm(\AABA, bars: [8, 8, 8, 8])
  ),

  texture: QTexture(\polyphonic, // Independent improvisation
    roles: [\head, \comp, \walking, \drums]
  ),

  orchestration: (
    ensemble: \jazzCombo,
    balance: \interactive, // Musicians respond to each other
    articulation: [\swing, \legato, \staccato]
  ),

  tempo: (range: [80, 200], style: \steady),

  macros: (
    swing: [0.5, 0.66, 0.75], // Swing amount
    energy: [\head, \solos, \trading, \out]
  )
);
```

### Template: Minimalism

```supercollider
QTemplate.minimalist = (
  theory: (
    harmony: QHarmony(\modal,
      progressions: \static, // Stays on one or two chords
      changes: \gradual
    ),
    melody: QMelody(\minimalist,
      patterns: \repetitive,
      development: [\phasing, \additive, \subtractive]
    ),
    rhythm: QRhythm(\steady,
      patterns: \ostinato,
      changes: \gradual,
      polyrhythm: true
    ),
    form: QForm(\processual, // Form emerges from process
      processes: [\phasing, \additive, \canonic]
    )
  ),

  texture: QTexture(\varies, // Starts thin, gradually thickens
    evolution: \additive
  ),

  tempo: (style: \constant, changes: \rare),

  macros: (
    density: \gradual, // Slow changes
    phase: \continuous // Phasing relationships
  )
);
```

### Template: EDM (Electronic Dance Music)

```supercollider
QTemplate.edm = (
  theory: (
    harmony: QHarmony(\simple,
      progressions: \repetitive, // Same 4 chords
      bass: \root // Bass plays roots only
    ),
    melody: QMelody(\hook,
      repetition: \high,
      range: \narrow
    ),
    rhythm: QRhythm(\fourOnFloor,
      kick: \steady, // Steady kick drum
      syncopation: \midHigh,
      buildups: true
    ),
    form: QForm(\edm,
      sections: [\intro, \build, \drop, \break, \build2, \drop2, \outro],
      energy: \climactic // Energy focuses on drops
    )
  ),

  texture: QTexture(\layered,
    layers: [\sub, \bass, \lead, \pad, \drums, \fx]
  ),

  macros: (
    energy: [0.0, 1.0], // Extreme dynamics
    filter: \sweepable, // Filter sweeps common
    sidechain: \pumping // Sidechain compression
  ),

  tempo: (range: [100, 180], style: \constant)
);
```

### Template: Ambient

```supercollider
QTemplate.ambient = (
  theory: (
    harmony: QHarmony(\modal,
      progressions: \drifting,
      dissonance: \allowed,
      resolution: \optional
    ),
    melody: QMelody(\sparse,
      contour: \floating,
      rhythm: \free
    ),
    rhythm: QRhythm(\free,
      meter: \implied, // No strict meter
      pulse: \optional
    ),
    form: QForm(\openForm, // No clear sections
      structure: \gradual,
      changes: \morphing
    )
  ),

  texture: QTexture(\evolving,
    density: \variable,
    layers: \overlapping
  ),

  tempo: (style: \rubato, changes: \subtle),

  macros: (
    space: [0.3, 1.0], // Heavy reverb/delay
    brightness: \evolving,
    density: \breathing // Waxes and wanes
  )
);
```

### Template: Free Improvisation / Experimental

```supercollider
QTemplate.experimental = (
  theory: (
    harmony: QHarmony(\atonal, // No tonal center
      pitch: \flexible, // Microtones, noise
      organization: \gestural
    ),
    melody: QMelody(\nontraditional,
      contour: \free,
      material: \extended // Extended techniques
    ),
    rhythm: QRhythm(\flexible,
      meter: \variable,
      pulse: \emergent
    ),
    form: QForm(\openForm,
      structure: \emergent,
      rules: \minimal
    )
  ),

  texture: QTexture(\variable, // Anything goes
    changes: \sudden
  ),

  constraints: \minimal, // Few rules, more freedom

  macros: (
    chaos: [0.0, 1.0], // Degree of randomness
    density: \variable,
    timbre: \exploratory
  )
);
```

---

## Genre-Agnostic Design Principles

### 1. Separation of Concerns
**Music theory is separate from audio rendering.**

```
QTheory (pure music theory)
   ↓
QMaterialGeneration (creates patterns/units)
   ↓
QScene (audio rendering)
```

This means:
- You can compose in music theory terms (C major scale, V-I progression)
- Then render with ANY timbres (orchestra, synths, found sounds)

### 2. Templates as Starting Points, Not Limits
Templates provide:
- Sensible defaults
- Common practices
- Quick start

But you can always:
- Override any setting
- Mix templates (jazz harmony + EDM rhythm)
- Create custom templates

### 3. Constraints are Configurable
Every rule can be:
- **Enabled/disabled**
- **Weighted** (hard constraint vs. preference)
- **Customized** (define your own rules)

Example:
```supercollider
// Strict classical voice leading
vl = QVoiceLeading(\strict);
vl.constraint(\noParallelFifths, weight: \infinite); // Hard constraint
vl.constraint(\smoothMotion, weight: 2); // Strong preference
vl.constraint(\contraryMotion, weight: 1); // Weak preference

// Relaxed modern voice leading
vl = QVoiceLeading(\modern);
vl.constraint(\noParallelFifths, weight: 0); // Disabled
vl.constraint(\smoothMotion, weight: 0.5); // Weak preference
vl.constraint(\voiceRanges, weight: 1); // Keep in range
```

### 4. Multiple Representation Layers
The same musical idea can be represented at multiple levels:

**High-level** (music theory):
```supercollider
h.progression([\I, \V, \vi, \IV]); // In C: C, G, Am, F
```

**Mid-level** (abstract pitch):
```supercollider
Pseq([60, 67, 69, 65]); // MIDI note numbers
```

**Low-level** (audio):
```supercollider
Pbind(\freq, Pseq([261.63, 392.00, 440.00, 349.23])); // Hz
```

Quasar works at **all levels** and translates between them.

### 5. Extensibility
Users can add:
- Custom scales/modes
- Custom chord types
- Custom voice leading rules
- Custom formal archetypes
- Custom gestures
- Custom constraints

Everything is a plugin.

---

## Data Flow: From Theory to Sound

```
1. QProject.fromTemplate(\baroque)
   ↓
2. QTheory generates harmonic progression
   ↓
3. QCounterpoint generates 4 voices
   ↓
4. QVoiceLeading ensures smooth transitions
   ↓
5. QOrchestration assigns voices to instruments
   ↓
6. QGesture adds ornaments and articulations
   ↓
7. QTimeline arranges sections (expo, dev, recap)
   ↓
8. QScene renders audio (SynthDefs, NodeProxies)
   ↓
9. QConductor plays in realtime or renders NRT
   ↓
10. Audio output
```

---

## Implementation Priority for Genre-Agnostic Design

**Phase 0-1**: Core engine (works for any genre)

**Phase 2**: Music theory foundation (THIS IS CRITICAL)
- QHarmony, QMelody, QRhythm must be genre-agnostic from the start
- Build extensibility from day one

**Phase 3-4**: Gestures + Textures (genre-specific behaviors)
- Implement 3-5 gestures per category
- Prove genre-agnostic by implementing Baroque + EDM gestures side-by-side

**Phase 5**: Form archetypes (genre-defining structures)
- Implement 1-2 forms per major genre
- Show how same material can be arranged in different forms

**Phase 6+**: Polish, GUI, etc.

---

## Success Criteria: Is it Genre-Agnostic?

Quasar is truly genre-agnostic if:

1. ✅ **Same core classes work for Bach and Bassnectar**
2. ✅ **No genre-specific hardcoded values** (e.g., no "drop energy = 0.9" in core code)
3. ✅ **Templates are additive**, not baked into the architecture
4. ✅ **Users can create custom genres** without modifying core classes
5. ✅ **Music theory modules support multiple systems** (tonal, modal, atonal, microtonal)
6. ✅ **Example library spans 5+ diverse genres** (classical, jazz, EDM, ambient, experimental)

---

## Next: Expanded Object Model

See OBJECT_MODEL.md for detailed class diagrams and API specifications.
