# Quasar Object Model (Part 2)

## Material & Selection Classes

### QPalette

**Purpose**: Container for all musical materials (units, gestures, states).

```supercollider
QPalette {
  var <project;
  var <unitDB;         // QUnitDB
  var <gestureLibrary; // QGestureLibrary
  var <stateLibrary;   // QStateLibrary

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    unitDB = QUnitDB(project);
    gestureLibrary = QGestureLibrary(project);
    stateLibrary = QStateLibrary(project);
  }

  loadUnits { |path|
    unitDB.scan(path);
  }

  asData {
    ^(
      units: unitDB.asData,
      gestures: gestureLibrary.asData,
      states: stateLibrary.asData
    )
  }
}
```

### QUnitDB

**Purpose**: Audio/pattern unit database with tagging and indexing.

```supercollider
QUnitDB {
  var <project;
  var <units;      // Dict of name → QUnit
  var <manifest;   // Manifest data (hashes, tags, features)
  var <tagIndex;   // Dict of tag → [unit names]

  *new { |project|
    ^super.newCopyArgs(project, (), (), ()).init;
  }

  scan { |path|
    var soundFiles = PathName(path).filesDo { |file|
      if (#[\wav, \aif, \aiff, \flac].includes(file.extension.asSymbol)) {
        this.addUnit(file.fullPath);
      };
    };
    this.buildIndex;
  }

  addUnit { |path|
    var unit = QUnit(path);
    units[unit.name] = unit;
  }

  buildIndex {
    tagIndex = ();
    units.do { |unit|
      unit.tags.do { |tag|
        if (tagIndex[tag].isNil) {
          tagIndex[tag] = [];
        };
        tagIndex[tag] = tagIndex[tag].add(unit.name);
      };
    };
  }

  // Query units by tags
  query { |tags, options|
    var matchingNames = tagIndex[tags[0]] ? [];
    tags[1..].do { |tag|
      matchingNames = matchingNames.sect(tagIndex[tag] ? []);
    };
    ^matchingNames.collect { |name| units[name] };
  }

  saveManifest { |path|
    var data = units.collect { |unit| unit.asData };
    data.writeJSON(path);
  }

  loadManifest { |path|
    var data = path.parseJSONFile;
    data.keysValuesDo { |name, unitData|
      var unit = QUnit.fromData(unitData);
      units[name] = unit;
    };
    this.buildIndex;
  }

  asData {
    ^units.collect { |unit| unit.asData };
  }
}
```

### QUnit

**Purpose**: Individual musical unit (audio or pattern).

```supercollider
QUnit {
  var <name;
  var <path;
  var <buffer;      // Buffer (if audio)
  var <pattern;     // Pattern (if generative)
  var <tags;        // Array of symbols
  var <features;    // Dict of audio features
  var <metadata;    // Dict of music theory annotations
  var <hash;        // SHA256 hash of audio file

  *new { |path|
    ^super.newCopyArgs().initFromPath(path);
  }

  initFromPath { |filePath|
    path = filePath;
    name = PathName(path).fileNameWithoutExtension.asSymbol;
    buffer = Buffer.read(Server.default, path);
    tags = this.parseTagsFromFilename;
    hash = this.computeHash;
    features = this.extractFeatures;
    metadata = ();
  }

  parseTagsFromFilename {
    // e.g., "violin_pizzicato_short_bright_01.wav"
    // → [\violin, \pizzicato, \short, \bright]
    var parts = name.asString.split($_);
    ^parts.select { |p| p.size > 0 and: { p.every(_.isAlpha) } }.collect(_.asSymbol);
  }

  extractFeatures {
    // Extract audio features (simplified)
    // Real implementation would use FFT, onset detection, etc.
    ^(
      duration: buffer.duration,
      rms: this.computeRMS,
      spectralCentroid: this.computeSpectralCentroid,
      zcr: this.computeZCR
    )
  }

  computeRMS {
    // Placeholder - would analyze buffer
    ^0.5;
  }

  computeSpectralCentroid {
    // Placeholder - would analyze spectrum
    ^2000;
  }

  computeZCR {
    // Placeholder - zero crossing rate
    ^0.1;
  }

  computeHash {
    // Hash file contents for reproducibility
    var file = File(path, "r");
    var bytes = file.readAllBytes;
    file.close;
    ^bytes.hash.asHexString; // Simplified (use SHA256 in real impl)
  }

  play {
    buffer.play;
  }

  asData {
    ^(
      name: name,
      path: path,
      tags: tags,
      features: features,
      metadata: metadata,
      hash: hash
    )
  }

  *fromData { |data|
    var unit = QUnit(data[\path]);
    unit.tags = data[\tags];
    unit.metadata = data[\metadata];
    ^unit;
  }
}
```

### QSelector

**Purpose**: Intelligent material selection with constraints and scoring.

```supercollider
QSelector {
  var <project;
  var <rng;          // Seeded RNG
  var <constraints;  // Array of QConstraint
  var <scoring;      // QScoring
  var <history;      // Recently selected units (for novelty)

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    rng = Pseed(project.seed, Pwhite(0, 1000000)).asStream;
    constraints = [];
    scoring = QScoring(this);
    history = [];
  }

  addConstraint { |constraint|
    constraints = constraints.add(constraint);
  }

  choose { |tags, context|
    var candidates = project.palette.unitDB.query(tags);
    var valid = candidates.select { |unit|
      this.satisfiesConstraints(unit, context);
    };
    var scored = valid.collect { |unit|
      [unit, scoring.score(unit, tags, context)]
    };
    var best = scored.maxItem { |item| item[1] }[0];
    history = history.add(best);
    ^best;
  }

  satisfiesConstraints { |unit, context|
    constraints.do { |constraint|
      if (constraint.check(unit, context).not) {
        ^false;
      };
    };
    ^true;
  }
}
```

### QConstraint

**Purpose**: Selection constraint (hard or soft).

```supercollider
QConstraint {
  var <name;
  var <checkFunc; // Function that returns true/false
  var <type;      // \hard or \soft
  var <weight;    // Weight (for soft constraints)

  *new { |name, checkFunc, type=\hard, weight=1|
    ^super.newCopyArgs(name, checkFunc, type, weight);
  }

  check { |unit, context|
    ^checkFunc.value(unit, context);
  }

  // Common constraints
  *avoidRepeat { |n=4|
    ^QConstraint(\avoidRepeat, { |unit, context|
      var history = context[\history] ? [];
      history.keep(-1 * n).includes(unit).not;
    });
  }

  *pitchRange { |min, max|
    ^QConstraint(\pitchRange, { |unit, context|
      var pitches = unit.metadata[\pitchContent] ? [];
      pitches.every { |p| p >= min and: { p <= max } };
    });
  }

  *harmonicFit { |chord|
    ^QConstraint(\harmonicFit, { |unit, context|
      var pitches = unit.metadata[\pitchContent] ? [];
      var chordPCs = chord.collect { |p| p % 12 };
      pitches.every { |p|
        chordPCs.includes(p % 12);
      };
    }, \soft, 2);
  }
}
```

### QScoring

**Purpose**: Score units based on multiple factors.

```supercollider
QScoring {
  var <selector;
  var <factors; // Dict of factor name → weight

  *new { |selector|
    ^super.newCopyArgs(selector).init;
  }

  init {
    factors = (
      tagMatch: 2.0,
      novelty: 1.0,
      harmonicFit: 1.5,
      dynamicContinuity: 0.5,
      registerContinuity: 0.5
    );
  }

  score { |unit, requestedTags, context|
    var s = 0;
    s = s + (this.tagMatchScore(unit, requestedTags) * factors[\tagMatch]);
    s = s + (this.noveltyScore(unit, context) * factors[\novelty]);
    s = s + (this.harmonicFitScore(unit, context) * factors[\harmonicFit]);
    s = s + (this.dynamicContinuityScore(unit, context) * factors[\dynamicContinuity]);
    s = s + (this.registerContinuityScore(unit, context) * factors[\registerContinuity]);
    ^s;
  }

  tagMatchScore { |unit, requestedTags|
    var matches = unit.tags.sect(requestedTags).size;
    var total = requestedTags.size;
    ^matches / total.max(1);
  }

  noveltyScore { |unit, context|
    var history = context[\history] ? [];
    var lastN = history.keep(-4);
    var timesUsed = lastN.occurrencesOf(unit);
    ^(1.0 - (timesUsed * 0.3)).max(0);
  }

  harmonicFitScore { |unit, context|
    var currentHarmony = context[\harmony];
    if (currentHarmony.isNil) { ^0.5 }; // Neutral if no harmony specified

    var unitPitches = unit.metadata[\pitchContent] ? [];
    var harmonyPCs = currentHarmony.collect { |p| p % 12 };
    var fits = unitPitches.count { |p|
      harmonyPCs.includes(p % 12);
    };
    ^fits / unitPitches.size.max(1);
  }

  dynamicContinuityScore { |unit, context|
    var lastDynamic = context[\lastDynamic];
    if (lastDynamic.isNil) { ^0.5 };

    var unitDynamic = unit.metadata[\dynamics] ? \mf;
    var dynamicLevels = [\pppp, \ppp, \pp, \p, \mp, \mf, \f, \ff, \fff, \ffff];
    var lastIdx = dynamicLevels.indexOf(lastDynamic) ? 5;
    var unitIdx = dynamicLevels.indexOf(unitDynamic) ? 5;
    var diff = (unitIdx - lastIdx).abs;
    ^(1.0 - (diff * 0.2)).max(0);
  }

  registerContinuityScore { |unit, context|
    var lastRegister = context[\lastRegister];
    if (lastRegister.isNil) { ^0.5 };

    var unitRegister = unit.metadata[\register] ? \mid;
    var registers = [\low, \midlow, \mid, \midhigh, \high];
    var lastIdx = registers.indexOf(lastRegister) ? 2;
    var unitIdx = registers.indexOf(unitRegister) ? 2;
    var diff = (unitIdx - lastIdx).abs;
    ^(1.0 - (diff * 0.25)).max(0);
  }
}
```

---

## Gesture Classes

### QGestureLibrary

**Purpose**: Container for gesture presets.

```supercollider
QGestureLibrary {
  var <project;
  var <gestures; // Dict of name → QGesture

  *new { |project|
    ^super.newCopyArgs(project, ()).init;
  }

  init {
    this.loadDefaultGestures;
  }

  loadDefaultGestures {
    // Harmonic gestures
    gestures[\cadence_authentic] = QGestureCadence(\authentic);
    gestures[\cadence_half] = QGestureCadence(\half);
    gestures[\cadence_plagal] = QGestureCadence(\plagal);
    gestures[\modulation] = QGestureModulation();

    // Melodic gestures
    gestures[\scale_ascending] = QGestureScale(\ascending);
    gestures[\scale_descending] = QGestureScale(\descending);
    gestures[\arpeggio] = QGestureArpeggio();

    // Rhythmic gestures
    gestures[\accelerando] = QGestureAccelerando();
    gestures[\ritardando] = QGestureRitardando();

    // Dynamic gestures
    gestures[\crescendo] = QGestureCrescendo();
    gestures[\diminuendo] = QGestureDiminuendo();

    // Textural gestures
    gestures[\densityRamp] = QGestureDensityRamp();
    gestures[\imitation] = QGestureImitation();
  }

  get { |name| ^gestures[name] }

  asData {
    ^gestures.collect { |gest| gest.asData };
  }
}
```

### QGesture (Base Class)

```supercollider
QGesture {
  var <duration;    // In beats
  var <intent;      // \transition, \cadence, \ornament, etc.
  var <parameters;  // Dict

  *new { |duration=4, intent=\generic|
    ^super.newCopyArgs(duration, intent, ()).init;
  }

  init { }

  // Subclasses implement one or both:
  asPattern { ^nil }    // Returns Pattern (for discrete events)
  asEnvelope { ^nil }   // Returns Env (for continuous control)

  asData {
    ^(
      type: this.class.name,
      duration: duration,
      intent: intent,
      parameters: parameters
    )
  }
}
```

### QGestureCadence

```supercollider
QGestureCadence : QGesture {
  var <cadenceType; // \authentic, \half, \plagal, \deceptive

  *new { |type=\authentic, duration=4|
    ^super.new(duration, \cadence).initCadence(type);
  }

  initCadence { |type|
    cadenceType = type;
    parameters[\cadenceType] = type;
  }

  asPattern {
    var harmony = currentEnvironment[\harmony];
    var progression = case
    { cadenceType == \authentic } {
      [harmony.chord(4), harmony.chord(0)] // V - I
    }
    { cadenceType == \half } {
      [harmony.chord(0), harmony.chord(4)] // I - V
    }
    { cadenceType == \plagal } {
      [harmony.chord(3), harmony.chord(0)] // IV - I
    }
    { cadenceType == \deceptive } {
      [harmony.chord(4), harmony.chord(5)] // V - vi
    };

    ^Pbind(
      \degree, Pseq(progression),
      \dur, duration / progression.size
    );
  }
}
```

### QGestureCrescendo

```supercollider
QGestureCrescendo : QGesture {
  var <startAmp, <endAmp;

  *new { |start=0.2, end=0.9, duration=8|
    ^super.new(duration, \dynamic).initCresc(start, end);
  }

  initCresc { |start, end|
    startAmp = start;
    endAmp = end;
    parameters[\startAmp] = start;
    parameters[\endAmp] = end;
  }

  asEnvelope {
    ^Env([startAmp, endAmp], [duration], \lin);
  }

  asPattern {
    // For discrete events, quantize to steps
    var steps = 8;
    var amps = Array.interpolation(steps, startAmp, endAmp);
    ^Pbind(
      \amp, Pseq(amps),
      \dur, duration / steps
    );
  }
}
```

### QGestureDensityRamp

```supercollider
QGestureDensityRamp : QGesture {
  var <startDensity, <endDensity;

  *new { |start=0.2, end=0.9, duration=16|
    ^super.new(duration, \textural).initRamp(start, end);
  }

  initRamp { |start, end|
    startDensity = start;
    endDensity = end;
    parameters[\startDensity] = start;
    parameters[\endDensity] = end;
  }

  asPattern {
    // Density = probability of event firing
    var steps = (duration * 4).asInteger; // 16th note grid
    var densities = Array.interpolation(steps, startDensity, endDensity);

    ^Pbind(
      \degree, Pwhite(0, 7),
      \dur, 0.25, // 16th notes
      \amp, Pfunc { |event|
        var idx = (thisThread.beats / 0.25 % steps).asInteger;
        if (densities[idx].coin) { 0.5 } { 0 }; // Event fires based on density
      }
    ).select { |event| event[\amp] > 0 }; // Filter out silent events
  }

  asEnvelope {
    ^Env([startDensity, endDensity], [duration], \exp);
  }
}
```

---

## Texture & Voice Classes

### QTexture

**Purpose**: Manage texture types and voice count.

```supercollider
QTexture {
  var <project;
  var <type;    // \monophonic, \homophonic, \polyphonic, \heterophonic
  var <voices;  // Array of QVoice

  *new { |project, type=\monophonic|
    ^super.newCopyArgs(project, type, []).init;
  }

  init {
    // Start with one voice
    this.addVoice(\voice1);
  }

  addVoice { |name, params|
    var voice = QVoice(name, params);
    voices = voices.add(voice);
  }

  removeVoice { |name|
    voices = voices.reject { |v| v.name == name };
  }

  morph { |newType, duration|
    // Morph texture over duration
    // Implementation would gradually add/remove voices
    type = newType;
  }

  numActiveVoices {
    ^voices.count { |v| v.active };
  }

  asData {
    ^(
      type: type,
      voices: voices.collect { |v| v.asData }
    )
  }
}
```

### QVoice

**Purpose**: Individual voice/part with range and role.

```supercollider
QVoice {
  var <name;
  var <range;         // [minPitch, maxPitch]
  var <tessitura;     // Comfortable range
  var <role;          // \melody, \harmony, \bass, \countermelody
  var <instrument;    // \violin, \flute, \synth, etc.
  var <active;        // Boolean

  // Voice parameters
  var <articulation;  // \legato, \staccato, etc.
  var <dynamics;      // Current dynamic level
  var <timbre;        // Timbral settings

  *new { |name, params|
    ^super.newCopyArgs(
      name,
      params[\range] ?? [48, 72],     // Default 2-octave range
      params[\tessitura] ?? [52, 67], // Comfortable subset
      params[\role] ?? \melody,
      params[\instrument],
      true // Active by default
    ).init;
  }

  init {
    articulation = \normal;
    dynamics = \mf;
    timbre = ();
  }

  inRange { |pitch|
    ^pitch >= range[0] and: { pitch <= range[1] };
  }

  inTessitura { |pitch|
    ^pitch >= tessitura[0] and: { pitch <= tessitura[1] };
  }

  setRole { |newRole|
    role = newRole;
  }

  asData {
    ^(
      name: name,
      range: range,
      tessitura: tessitura,
      role: role,
      instrument: instrument,
      active: active,
      articulation: articulation,
      dynamics: dynamics
    )
  }
}
```

### QOrchestration

**Purpose**: Manage instrument combinations and balance.

```supercollider
QOrchestration {
  var <project;
  var <ensemble;      // Preset or custom array of voices
  var <balance;       // Balance strategy
  var <doubling;      // Doubling rules
  var <spacing;       // \open or \closed

  *new { |project, ensemble=\quartet|
    ^super.newCopyArgs(project, ensemble).init;
  }

  init {
    this.setEnsemble(ensemble);
    balance = \balanced;
    spacing = \open;
  }

  setEnsemble { |name|
    case
    { name == \quartet } {
      project.texture.addVoice(\violin1, (range: [55, 103], role: \melody));
      project.texture.addVoice(\violin2, (range: [55, 98], role: \harmony));
      project.texture.addVoice(\viola, (range: [48, 91], role: \harmony));
      project.texture.addVoice(\cello, (range: [36, 76], role: \bass));
    }
    { name == \orchestra } {
      // Full orchestra setup...
    }
    { name == \jazzCombo } {
      project.texture.addVoice(\trumpet, (range: [55, 82]));
      project.texture.addVoice(\sax, (range: [49, 85]));
      project.texture.addVoice(\piano, (range: [21, 108]));
      project.texture.addVoice(\bass, (range: [28, 67]));
      project.texture.addVoice(\drums, (range: [20, 100])); // Frequency range
    };
  }

  double { |voice, interval=12|
    // Double a voice at octave or other interval
    ^(
      voice: voice,
      interval: interval
    );
  }

  balance { |strategy|
    case
    { strategy == \pyramid } {
      // More weight on lower voices
      ^[\fff, \ff, \f, \mf].reverse;
    }
    { strategy == \inverted } {
      // Melody on top louder
      ^[\fff, \f, \mf, \mp];
    }
    { strategy == \balanced } {
      // Equal balance
      ^[\mf, \mf, \mf, \mf];
    };
  }

  asData {
    ^(
      ensemble: ensemble,
      balance: balance,
      spacing: spacing
    )
  }
}
```

---

## Timeline & Rendering Classes

### QTimeline

**Purpose**: Sequence of sections defining form.

```supercollider
QTimeline {
  var <project;
  var <sections;      // Array of QSection

  *new { |project|
    ^super.newCopyArgs(project, []).init;
  }

  addSection { |section|
    sections = sections.add(section);
  }

  add { |name, duration, scene, state, transition|
    var section = QSection(name, duration, scene, state, transition);
    this.addSection(section);
  }

  totalDuration {
    ^sections.sum { |sec| sec.duration };
  }

  sectionAt { |beat|
    var currentBeat = 0;
    sections.do { |sec|
      if (beat >= currentBeat and: { beat < (currentBeat + sec.duration) }) {
        ^sec;
      };
      currentBeat = currentBeat + sec.duration;
    };
    ^nil;
  }

  asData {
    ^(
      sections: sections.collect { |sec| sec.asData }
    )
  }
}
```

### QSection

**Purpose**: One section of the timeline.

```supercollider
QSection {
  var <name;
  var <duration;     // In beats or bars
  var <scene;        // QScene or scene name
  var <state;        // QState or state name
  var <transition;   // QGesture for transition to next section
  var <startBeat;    // Calculated start time

  *new { |name, duration=8, scene, state, transition|
    ^super.newCopyArgs(name, duration, scene, state, transition);
  }

  asData {
    ^(
      name: name,
      duration: duration,
      scene: scene,
      state: state,
      transition: transition !? { transition.asData }
    )
  }
}
```

### QConductor

**Purpose**: Playback engine (realtime and NRT).

```supercollider
QConductor {
  var <project;
  var <clock;
  var <routine;
  var <isPlaying;
  var <currentBeat;
  var <currentSection;

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    clock = TempoClock(project.tempo / 60);
    isPlaying = false;
    currentBeat = 0;
  }

  play {
    if (isPlaying) { ^this };
    isPlaying = true;
    routine = this.makeRoutine;
    routine.play(clock);
  }

  stop {
    isPlaying = false;
    routine.stop;
  }

  seek { |beat|
    currentBeat = beat;
    // Would need to rebuild state at this beat
  }

  makeRoutine {
    ^Routine {
      project.timeline.sections.do { |section|
        currentSection = section;
        this.playSection(section);
        section.duration.wait;

        // Play transition if exists
        if (section.transition.notNil) {
          this.playGesture(section.transition);
          section.transition.duration.wait;
        };
      };
      isPlaying = false;
    };
  }

  playSection { |section|
    // Set up scene
    if (section.scene.notNil) {
      section.scene.activate;
    };

    // Apply state
    if (section.state.notNil) {
      section.scene.applyState(section.state);
    };
  }

  playGesture { |gesture|
    var pattern = gesture.asPattern;
    if (pattern.notNil) {
      pattern.play(clock);
    };
  }

  // NRT rendering
  render { |path|
    var score = this.asScore;
    score.recordNRT(
      outputFilePath: path,
      sampleRate: 48000,
      headerFormat: "WAV",
      sampleFormat: "int24"
    );
  }

  asScore {
    var score = Score.new;
    var currentTime = 0;

    project.timeline.sections.do { |section|
      var bundles = this.sectionToBundles(section, currentTime);
      score.add(bundles);
      currentTime = currentTime + section.duration;
    };

    ^score;
  }

  sectionToBundles { |section, startTime|
    // Convert section to OSC bundles
    // Simplified - real implementation would be complex
    ^[
      [startTime, [\s_new, \sineTest, 1000, 0, 1, \freq, 440]]
    ];
  }
}
```

---

## Scene & Audio Classes

### QScene

**Purpose**: Audio scene with layers, macros, FX routing.

```supercollider
QScene {
  var <name;
  var <proxySpace;   // ProxySpace
  var <layers;       // Dict of layer names
  var <macros;       // Dict of macro definitions
  var <fxChain;      // FX routing
  var <mixer;        // QMixer

  *new { |name|
    ^super.newCopyArgs(name).init;
  }

  init {
    proxySpace = ProxySpace.new;
    layers = ();
    macros = ();
    mixer = QMixer(this);
  }

  addLayer { |name, pattern|
    proxySpace[name] = pattern;
    layers[name] = proxySpace[name];
  }

  defineMacro { |name, mappings|
    // mappings = [ [layer, param, min, max, curve], ... ]
    macros[name] = mappings;
  }

  setMacro { |name, value| // value 0..1
    var mappings = macros[name];
    if (mappings.isNil) { ^this };

    mappings.do { |mapping|
      var layer, param, min, max, curve;
      #layer, param, min, max, curve = mapping;
      var scaledValue = value.lincurve(0, 1, min, max, curve ? 0);
      proxySpace[layer].set(param, scaledValue);
    };
  }

  activate {
    proxySpace.push;
    layers.do { |layer| layer.play };
  }

  deactivate {
    layers.do { |layer| layer.stop };
    proxySpace.pop;
  }

  applyState { |state|
    state.keysValuesDo { |param, value|
      // Apply state parameters to scene
      this.set(param, value);
    };
  }
}
```

---

## Summary: Complete Class Count

| Category | Classes | Total LOC (est) |
|----------|---------|-----------------|
| Core | QProject, QTheory | 300 |
| Music Theory | QHarmony, QVoiceLeading, QMelody, QRhythm, QCounterpoint, QForm | 2000 |
| Materials | QPalette, QUnitDB, QUnit, QSelector, QConstraint, QScoring, QGrammar | 1800 |
| Gestures | QGesture + 15 subclasses | 1500 |
| Texture/Voice | QTexture, QVoice, QOrchestration | 600 |
| Timeline | QTimeline, QSection, QConductor | 800 |
| Scene/Audio | QScene, QMixer, QMacro, QFX library | 1200 |
| Rendering | QRenderer, QStemExporter, QMetadata | 600 |
| GUI | QGUI classes | 1200 |
| Total | ~50 classes | **~10,000 LOC** |

This is an achievable scope for a 6-9 month project with proper phasing.
