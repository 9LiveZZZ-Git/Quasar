# QMess: Controlled Musical Imperfection Framework

## Overview

**QMess** is a framework for introducing intentional, musically-meaningful "mistakes" and imperfections. These aren't random errors—they're carefully curated moments of controlled chaos that create tension, interest, and modern aesthetic.

### Philosophy

> "The right mistake at the right time is more interesting than perfection."

QMess embraces:
- **Lo-fi aesthetics** (tape artifacts, degradation)
- **Expectation violation** (incomplete phrases, deceptive resolutions)
- **Intentional wrongness** (out-of-tune, timing errors)
- **Glitch as feature** (digital artifacts, stutters)
- **Negative space** (sudden silence, breath)
- **Happy accidents** (things that shouldn't work but do)

---

## Design Principles

1. **Controlled**: Mess is deliberate, not random
2. **Musical**: Serves the composition (tension, release, interest)
3. **Contextual**: Aware of genre and style conventions
4. **Probabilistic**: Can be rare or frequent
5. **Recoverable**: Can return to "correct" state
6. **Seeded**: Reproducible "randomness"

---

## Architecture

```
QMess (Base System)
├── QTimbralMess    - Distortion, degradation, saturation
├── QPitchMess      - Detuning, wrong notes, microtonality
├── QRhythmicMess   - Timing errors, dropped beats, stutters
├── QHarmonicMess   - Wrong chords, dissonance, suspensions
├── QStructuralMess - Incomplete phrases, false starts, cuts
├── QProductionMess - Lo-fi, tape artifacts, bit-crushing
├── QDynamicMess    - Clipping, sudden changes, imbalance
└── QSpatialMess    - Pan jumps, width changes, mono collapses
```

---

## 1. QTimbralMess - Timbral Imperfection

**Purpose**: Introduce controlled sonic degradation and saturation.

### Features

```supercollider
QTimbralMess {
  var <project;
  var <messLevel; // 0 = clean, 1 = very messy

  // Overdrive/distortion (the bass example you mentioned)
  overdrive { |layer, amount=0.7, probability=0.3|
    // Randomly overdrive the layer beyond "proper" levels
    if (probability.coin) {
      layer.addFX(\overdrive, (
        drive: rrand(amount, amount * 1.5),
        type: [\hard, \soft, \fuzz, \fold].choose,
        mix: rrand(0.5, 1.0)
      ));

      "Mess: Overdrove % by %x".format(layer.name, amount).postln;
    };
  }

  // Bit-crushing (digital degradation)
  degrade { |layer, severity=0.5|
    var bits = severity.linexp(0, 1, 16, 4); // 16-bit down to 4-bit
    var sampleRate = severity.linexp(0, 1, 44100, 4000);

    layer.addFX(\bitCrush, (
      bits: bits,
      sampleRate: sampleRate,
      mix: severity
    ));

    "Mess: Degraded % to %-bit".format(layer.name, bits.round).postln;
  }

  // Tape artifacts (warble, dropout, noise)
  tapeArtifact { |layer, type=\warble|
    case
    { type == \warble } {
      // Pitch instability (tape speed fluctuation)
      layer.addFX(\tapeWarble, (
        rate: rrand(0.5, 2.0), // Slow warble
        depth: rrand(0.02, 0.1), // Pitch variation
        noise: rrand(0.01, 0.05) // Tape hiss
      ));
    }
    { type == \dropout } {
      // Random audio dropouts
      layer.addFX(\tapeDropout, (
        probability: 0.05, // 5% chance per beat
        duration: rrand(0.05, 0.2) // 50-200ms
      ));
    }
    { type == \saturation } {
      // Tape saturation (warm overdrive)
      layer.addFX(\tapeSaturation, (
        drive: rrand(0.3, 0.7),
        harmonics: [2, 3], // Even harmonics (warm)
        flutter: rrand(0.01, 0.03)
      ));
    };
  }

  // Vinyl crackle/pop
  vinylArtifacts { |layer, density=0.3|
    layer.addFX(\vinylCrackle, (
      crackleRate: density.linlin(0, 1, 0.1, 2.0), // Pops per second
      hiss: density * 0.05,
      rumble: density * 0.02 // Low-frequency rumble
    ));
  }

  // Lo-fi filter (bandwidth reduction)
  lofi { |layer, severity=0.5|
    // Reduce frequency range (like old radio/phone)
    var lowCut = severity.linexp(0, 1, 20, 300);
    var highCut = severity.linexp(0, 1, 20000, 3000);

    layer.addFX(\bandpass, (
      lowFreq: lowCut,
      highFreq: highCut,
      resonance: rrand(0.5, 2.0)
    ));
  }
}
```

---

## 2. QPitchMess - Pitch Imperfection

**Purpose**: Intentional detuning and "wrong" notes that create tension.

### Features

```supercollider
QPitchMess {
  var <project;

  // Microtonal detuning (slightly out of tune)
  detune { |layer, amount=0.2, probability=0.3|
    // amount in semitones (0.1 = 10 cents = noticeable but not "wrong")
    layer.pattern.collect { |event|
      if (probability.coin) {
        var detune = rrand(amount.neg, amount);
        event[\detune] = detune * 100; // Convert to cents
        "Mess: Detuned note by % cents".format(detune * 100).postln;
      };
      event;
    };
  }

  // "Wrong" note injection
  wrongNote { |layer, probability=0.1|
    // Replace correct note with chromatically adjacent note
    layer.pattern.collect { |event|
      if (probability.coin) {
        var shift = [-1, 1].choose; // Half-step up or down
        event[\midinote] = event[\midinote] + shift;
        "Mess: Injected wrong note (shifted by % semitone)".format(shift).postln;
      };
      event;
    };
  }

  // Out-of-scale notes (break the scale)
  scaleBreak { |layer, probability=0.05|
    // Inject chromatic notes not in the current scale
    var scale = project.theory.harmony.scale;
    var allNotes = (0..11); // Chromatic
    var outOfScale = allNotes.difference(scale);

    layer.pattern.collect { |event|
      if (probability.coin) {
        var wrongPC = outOfScale.choose;
        var octave = (event[\midinote] / 12).floor;
        event[\midinote] = (octave * 12) + wrongPC;
        "Mess: Scale break - injected out-of-scale note".postln;
      };
      event;
    };
  }

  // Pitch bend glitches
  bendGlitch { |layer|
    // Sudden, brief pitch bends (like a broken synth)
    layer.addFX(\pitchBendGlitch, (
      probability: 0.1,
      bendAmount: rrand(2, 12), // Semitones
      duration: rrand(0.01, 0.05), // Very brief
      direction: [\up, \down].choose
    ));
  }

  // Vibrato that's too fast or too slow
  weirdVibrato { |layer, type=\tooFast|
    case
    { type == \tooFast } {
      // Unnaturally fast vibrato (nervous)
      layer.set(\vibratoRate, rrand(8, 15)); // Normal is 5-7 Hz
    }
    { type == \tooSlow } {
      // Unnaturally slow wobble
      layer.set(\vibratoRate, rrand(0.5, 2));
    }
    { type == \random } {
      // Random vibrato rate changes
      layer.automate(\vibratoRate,
        Pwhite(3, 10).asStream
      );
    };
  }
}
```

---

## 3. QRhythmicMess - Rhythmic Imperfection

**Purpose**: Timing errors, dropped beats, stutters, unexpected stops.

### Features

```supercollider
QRhythmicMess {
  var <project;

  // Rush/drag (play ahead or behind the beat)
  timingError { |layer, amount=0.05, probability=0.2|
    // amount in beats (0.05 = 50ms at 120 BPM)
    layer.pattern.collect { |event|
      if (probability.coin) {
        var offset = rrand(amount.neg, amount);
        event[\timingOffset] = offset;
        "Mess: Timing error - % ms %".format(
          (offset * 500).round,
          if(offset > 0, "late", "early")
        ).postln;
      };
      event;
    };
  }

  // Dropped beat (suddenly skip a beat)
  dropBeat { |section, probability=0.05|
    // Randomly drop beats (silence when you expect sound)
    section.timeline.beats.do { |beat, i|
      if (probability.coin) {
        section.silenceBeat(beat);
        "Mess: Dropped beat % (unexpected silence)".format(beat).postln;
      };
    };
  }

  // Stutter/repeat (like a skipping CD)
  stutter { |layer, sliceLength=0.0625, repeats|
    // Repeat a tiny slice multiple times
    repeats = repeats ? rrand(3, 8);

    layer.addFX(\stutter, (
      sliceLength: sliceLength,
      repeats: repeats,
      probability: 0.1 // 10% chance per beat
    ));

    "Mess: Stutter effect (% repeats)".format(repeats).postln;
  }

  // Tempo fluctuation (drunk tempo)
  tempoWobble { |amount=0.05|
    // Tempo varies randomly (like a tired drummer)
    var baseTempo = project.tempo;

    project.conductor.clock.tempo = Env(
      Array.fill(32, { baseTempo * rrand(1 - amount, 1 + amount) }),
      Array.fill(31, 1),
      \step
    ).asStream;

    "Mess: Tempo wobble (±%%)".format((amount * 100).round).postln;
  }

  // Incomplete pattern (stop early)
  cutOffEarly { |pattern, probability=0.1|
    // Pattern ends before it "should" (incomplete phrase)
    if (probability.coin) {
      var cutPoint = rrand(0.6, 0.9); // Cut 10-40% early
      var newLength = (pattern.length * cutPoint).floor;
      pattern = pattern.keep(newLength);

      "Mess: Cut pattern early (% of original length)".format(
        (cutPoint * 100).round
      ).postln;
    };
    ^pattern;
  }

  // False start (start something then stop)
  falseStart { |section, gesture|
    // Play first 0.5-1 second of a gesture then silence
    var duration = rrand(0.5, 1.0);

    section.addGesture(gesture, duration: duration);
    section.addSilence(rrand(0.2, 0.5)); // Brief silence after

    "Mess: False start (gesture cut after %s)".format(duration).postln;
  }

  // Unexpected rest (sudden silence mid-phrase)
  unexpectedRest { |layer, duration=0.5, probability=0.05|
    layer.pattern.collect { |event, i|
      if (probability.coin) {
        // Insert silence
        event[\amp] = 0;
        event[\dur] = duration;
        "Mess: Unexpected rest (% beat silence)".format(duration).postln;
      };
      event;
    };
  }
}
```

---

## 4. QHarmonicMess - Harmonic Imperfection

**Purpose**: Wrong chords, unresolved dissonance, deceptive progressions.

### Features

```supercollider
QHarmonicMess {
  var <project;

  // Wrong chord (substitute with chromatically related chord)
  wrongChord { |progression, index, probability=0.1|
    if (probability.coin) {
      var chord = progression[index];
      var substitute = this.findWrongChord(chord);
      progression[index] = substitute;

      "Mess: Wrong chord at position % (% instead of %)".format(
        index, substitute, chord
      ).postln;
    };
    ^progression;
  }

  findWrongChord { |chord|
    // Find a chord that's "wrong" but interesting
    var root = chord[0];
    var substitutes = [
      root + 1,  // Chromatic up
      root - 1,  // Chromatic down
      root + 6,  // Tritone (very wrong!)
      root + 3,  // Mediant
      root - 3   // Submediant
    ];
    ^substitutes.choose;
  }

  // Unresolved tension (don't resolve dissonance)
  unresolvedDissonance { |progression|
    // Take expected resolution (V → I) and skip the resolution
    progression.do { |chord, i|
      if (this.isDominant(chord) and: { i < (progression.size - 1) }) {
        if (0.3.coin) { // 30% chance
          // Remove the resolution chord
          progression.removeAt(i + 1);
          "Mess: Unresolved dominant (no resolution)".postln;
        };
      };
    };
    ^progression;
  }

  // Added dissonance (inject dissonant notes)
  addDissonance { |chord, severity=0.5|
    // Add minor 2nd or tritone to chord
    var dissonantIntervals = [1, 6]; // m2, tritone
    var numAdd = (severity * 2).round.clip(1, 2);

    numAdd.do {
      var interval = dissonantIntervals.choose;
      var dissonantNote = chord[0] + interval;
      chord = chord.add(dissonantNote);
    };

    "Mess: Added % dissonant note(s) to chord".format(numAdd).postln;
    ^chord;
  }

  // Modal mixture (borrow from parallel mode)
  modalBorrow { |progression, probability=0.2|
    // If in major, borrow minor chords (and vice versa)
    progression.collect { |chord, i|
      if (probability.coin) {
        // Flatten or sharpen the third
        var third = chord[1];
        chord[1] = third + [-1, 1].choose;
        "Mess: Modal mixture at position %".format(i).postln;
      };
      chord;
    };
  }

  // Suspended without resolution
  suspendedHang { |chord|
    // Replace third with fourth (sus4) and don't resolve
    var root = chord[0];
    var fifth = chord[2];
    ^[root, root + 5, fifth]; // Root, 4th, 5th (no 3rd)
  }
}
```

---

## 5. QStructuralMess - Structural Imperfection

**Purpose**: Incomplete phrases, unexpected cuts, false starts.

### Features

```supercollider
QStructuralMess {
  var <project;

  // Incomplete phrase (the example you mentioned)
  incompletePhrase { |melody, cutPoint|
    // Cut melody before it reaches its expected conclusion
    cutPoint = cutPoint ? rrand(0.6, 0.85);
    var newLength = (melody.size * cutPoint).round;
    var incomplete = melody.keep(newLength);

    "Mess: Incomplete phrase (cut at %%, listener expects more)".format(
      (cutPoint * 100).round
    ).postln;

    ^incomplete;
  }

  // Sudden section change (no transition)
  abruptCut { |fromSection, toSection|
    // No transition gesture, just hard cut
    fromSection.transition = nil;

    "Mess: Abrupt cut (no transition from % to %)".format(
      fromSection.name, toSection.name
    ).postln;
  }

  // Repeat section unexpectedly
  unexpectedRepeat { |section, probability=0.1|
    if (probability.coin) {
      // Repeat section when form doesn't call for it
      project.timeline.insertSection(section, after: section);

      "Mess: Unexpected repeat of section %".format(section.name).postln;
    };
  }

  // False ending (sound like it's ending, but continue)
  falseEnding { |section|
    // Add cadence gesture that sounds final, then continue
    section.addGesture(QGesture.cadence(\authentic));
    section.addSilence(rrand(1, 2)); // Pregnant pause
    // ... but then section continues

    "Mess: False ending (sounds final but continues)".postln;
  }

  // Premature climax
  prematureClimax { |timeline|
    // Place climax earlier than expected (60% instead of 75%)
    var climaxPoint = timeline.duration * 0.6;
    timeline.setClimax(climaxPoint);

    "Mess: Premature climax (early peak leaves listener hanging)".postln;
  }

  // Anti-climax (avoid climax altogether)
  antiClimax { |timeline|
    // Build tension but never release it
    timeline.removeClimax;
    timeline.endWithTension(true);

    "Mess: Anti-climax (no peak, just tension → end)".postln;
  }

  // Section too short/long
  wrongDuration { |section, factor|
    factor = factor ? rrand(0.5, 1.5); // 50% to 150% of expected
    var newDuration = section.duration * factor;
    section.duration = newDuration;

    "Mess: Section % is % (factor %)".format(
      section.name,
      if(factor < 1, "too short", "too long"),
      factor
    ).postln;
  }
}
```

---

## 6. QProductionMess - Production Imperfection

**Purpose**: Lo-fi production, mixing errors, artifacts.

### Features

```supercollider
QProductionMess {
  var <project;

  // Imbalanced mix (some things too loud/soft)
  imbalance { |layers|
    layers.do { |layer|
      if (0.3.coin) {
        var factor = rrand(0.3, 2.0);
        layer.set(\amp, layer.amp * factor);

        "Mess: Layer % is % (factor %)".format(
          layer.name,
          if(factor > 1, "too loud", "too quiet"),
          factor
        ).postln;
      };
    };
  }

  // Clipping (digital overs)
  clip { |layer, probability=0.1|
    if (probability.coin) {
      layer.set(\amp, layer.amp * rrand(1.5, 3.0)); // Way too loud
      "Mess: Layer % is clipping!".format(layer.name).postln;
    };
  }

  // Stereo field collapse (sudden mono)
  monoCollapse { |layer, duration=1|
    // Suddenly collapse to mono then back to stereo
    layer.automate(\width, Env([1, 0, 1], [duration * 0.1, duration * 0.9]));

    "Mess: Stereo collapse for %s".format(duration).postln;
  }

  // Extreme panning (hard left/right)
  extremePan { |layer|
    var pan = [-1, 1].choose; // Hard left or right
    layer.set(\pan, pan);

    "Mess: Extreme pan (% hard %)".format(
      layer.name, if(pan < 0, "left", "right")
    ).postln;
  }

  // Reverb wash (too much reverb)
  reverbWash { |layer|
    layer.addFX(\reverb, (
      size: 0.99, // Huge space
      mix: rrand(0.7, 1.0), // Very wet
      predelay: 0
    ));

    "Mess: Reverb wash on %".format(layer.name).postln;
  }

  // Digital glitch (buffer underrun simulation)
  digitalGlitch { |layer|
    layer.addFX(\glitch, (
      probability: 0.05, // 5% chance per buffer
      types: [\stutter, \silence, \pitch, \reverse],
      duration: rrand(0.01, 0.1)
    ));
  }

  // Phase issues (invert phase randomly)
  phaseFlip { |layer, probability=0.1|
    if (probability.coin) {
      layer.set(\phase, -1); // Invert phase
      "Mess: Phase flip on %".format(layer.name).postln;
    };
  }
}
```

---

## 7. QDynamicMess - Dynamic Imperfection

**Purpose**: Unexpected volume changes, imbalance, clipping.

### Features

```supercollider
QDynamicMess {
  var <project;

  // Sudden dynamic change
  suddenChange { |layer, probability=0.1|
    layer.pattern.collect { |event|
      if (probability.coin) {
        var factor = rrand(0.2, 3.0);
        event[\amp] = event[\amp] * factor;

        "Mess: Sudden % change (factor %)".format(
          if(factor > 1, "loud", "soft"),
          factor
        ).postln;
      };
      event;
    };
  }

  // Compression pumping (over-compressed)
  overCompress { |layer|
    layer.addFX(\compressor, (
      threshold: -30, // Very low threshold
      ratio: 10,      // Heavy compression
      attack: 0.1,
      release: 10,    // Slow release (pumping)
      makeupGain: 20  // Bring back up (loud)
    ));

    "Mess: Over-compression pumping on %".format(layer.name).postln;
  }

  // Dynamic imbalance (some notes much louder)
  imbalancePattern { |layer|
    layer.pattern.collect { |event, i|
      // Every Nth note is much louder
      if (i % 4 == 0) {
        event[\amp] = event[\amp] * rrand(2, 4);
        "Mess: Loud accent on beat %".format(i).postln;
      };
      event;
    };
  }

  // Fade that doesn't complete
  incompleteFade { |layer, direction=\out|
    var env = if (direction == \out) {
      Env([1, 0.3], [4]); // Fade out but not to zero
    } {
      Env([0.3, 1], [4]); // Fade in but not from zero
    };

    layer.automate(\amp, env);
    "Mess: Incomplete fade %".format(direction).postln;
  }
}
```

---

## 8. QSpatialMess - Spatial Imperfection

**Purpose**: Pan jumps, width changes, spatial confusion.

### Features

```supercollider
QSpatialMess {
  var <project;

  // Pan jump (sudden pan position change)
  panJump { |layer, probability=0.1|
    layer.pattern.collect { |event|
      if (probability.coin) {
        var newPan = rrand(-1.0, 1.0);
        event[\pan] = newPan;
        "Mess: Pan jump to %".format(
          if(newPan < -0.3, "left", if(newPan > 0.3, "right", "center"))
        ).postln;
      };
      event;
    };
  }

  // Width flutter (stereo width changes rapidly)
  widthFlutter { |layer|
    layer.automate(\width,
      Env(
        Array.fill(16, { rrand(0, 1) }), // Random widths
        Array.fill(15, 0.25),            // Every quarter beat
        \step
      )
    );

    "Mess: Width flutter on %".format(layer.name).postln;
  }

  // Spatial confusion (elements in wrong spatial position)
  spatialConfusion { |layers|
    // Put bass on sides, leads in center (opposite of convention)
    layers.do { |layer|
      case
      { layer.name == \bass } {
        layer.set(\pan, [-0.8, 0.8].choose); // Bass to sides!
      }
      { layer.name == \lead } {
        layer.set(\pan, 0); // Lead to center
        layer.set(\width, 0.2); // Narrow lead
      }
      { layer.name == \pad } {
        layer.set(\width, 0.1); // Narrow pad (usually wide)
      };
    };

    "Mess: Spatial confusion (unconventional positioning)".postln;
  }
}
```

---

## QMess Master Controller

```supercollider
QMess {
  var <project;
  var <messLevel; // 0 = clean, 1 = maximum chaos
  var <categories; // Which types of mess to apply

  var <timbralMess, <pitchMess, <rhythmicMess, <harmonicMess;
  var <structuralMess, <productionMess, <dynamicMess, <spatialMess;

  *new { |project, messLevel=0.3|
    ^super.newCopyArgs(project, messLevel).init;
  }

  init {
    timbralMess = QTimbralMess(project);
    pitchMess = QPitchMess(project);
    rhythmicMess = QRhythmicMess(project);
    harmonicMess = QHarmonicMess(project);
    structuralMess = QStructuralMess(project);
    productionMess = QProductionMess(project);
    dynamicMess = QDynamicMess(project);
    spatialMess = QSpatialMess(project);

    categories = [
      \timbral, \pitch, \rhythmic, \harmonic,
      \structural, \production, \dynamic, \spatial
    ];
  }

  // Apply all types of mess based on messLevel
  messItUp { |targetCategories|
    targetCategories = targetCategories ? categories;

    targetCategories.do { |category|
      var probability = messLevel; // Higher mess = more likely

      if (probability.coin) {
        this.applyCategory(category);
      };
    };
  }

  applyCategory { |category|
    case
    { category == \timbral } {
      [\overdrive, \degrade, \tapeArtifact, \lofi].choose.postln;
      timbralMess.perform([\overdrive, \degrade, \tapeArtifact, \lofi].choose,
        project.scene.layers.choose
      );
    }
    { category == \pitch } {
      pitchMess.perform([\detune, \wrongNote, \scaleBreak].choose,
        project.scene.layers.choose
      );
    }
    { category == \rhythmic } {
      rhythmicMess.perform([\timingError, \dropBeat, \stutter].choose,
        project.timeline.currentSection
      );
    }
    { category == \harmonic } {
      harmonicMess.perform([\wrongChord, \unresolvedDissonance, \addDissonance].choose,
        project.theory.harmony.chordProgression
      );
    }
    { category == \structural } {
      structuralMess.perform([\incompletePhrase, \abruptCut, \falseEnding].choose,
        project.timeline.currentSection
      );
    }
    { category == \production } {
      productionMess.perform([\imbalance, \clip, \reverbWash].choose,
        project.scene.layers
      );
    }
    { category == \dynamic } {
      dynamicMess.perform([\suddenChange, \overCompress].choose,
        project.scene.layers.choose
      );
    }
    { category == \spatial } {
      spatialMess.perform([\panJump, \widthFlutter].choose,
        project.scene.layers.choose
      );
    };
  }

  // Preset mess profiles
  *lofi { |project|
    var mess = QMess(project, messLevel: 0.6);
    mess.categories = [\timbral, \production];
    ^mess;
  }

  *experimental { |project|
    var mess = QMess(project, messLevel: 0.8);
    ^mess; // All categories
  }

  *subtle { |project|
    var mess = QMess(project, messLevel: 0.2);
    mess.categories = [\pitch, \rhythmic, \dynamic];
    ^mess;
  }

  *glitch { |project|
    var mess = QMess(project, messLevel: 0.9);
    mess.categories = [\timbral, \rhythmic, \production];
    ^mess;
  }
}
```

---

## Genre-Specific Mess Profiles

### Lo-Fi Hip-Hop
```supercollider
QMessProfile.lofiHipHop = (
  messLevel: 0.5,
  timbral: (
    tapeArtifact: 0.7,
    vinylCrackle: 0.6,
    degrade: 0.4
  ),
  pitch: (
    detune: 0.3 // Slight warble
  ),
  rhythmic: (
    timingError: 0.4, // Laid-back feel
    stutter: 0.1
  ),
  production: (
    lofi: 0.8, // Heavy bandwidth reduction
    imbalance: 0.3
  )
);
```

### Experimental/Noise
```supercollider
QMessProfile.experimental = (
  messLevel: 0.9,
  timbral: (
    overdrive: 0.7,
    degrade: 0.6
  ),
  pitch: (
    wrongNote: 0.5,
    scaleBreak: 0.4,
    bendGlitch: 0.6
  ),
  rhythmic: (
    dropBeat: 0.3,
    stutter: 0.5,
    unexpectedRest: 0.4
  ),
  harmonic: (
    wrongChord: 0.5,
    unresolvedDissonance: 0.7,
    addDissonance: 0.6
  ),
  structural: (
    incompletePhrase: 0.5,
    abruptCut: 0.6,
    antiClimax: 0.4
  )
);
```

### Indie/Alternative (Subtle Mess)
```supercollider
QMessProfile.indie = (
  messLevel: 0.3,
  timbral: (
    lofi: 0.3,
    tapeArtifact: 0.2
  ),
  pitch: (
    detune: 0.2 // Slight pitch drift
  ),
  rhythmic: (
    timingError: 0.3, // Human feel
    incompletePhrase: 0.2 // Unfinished thoughts
  ),
  production: (
    imbalance: 0.2,
    reverbWash: 0.3 // Dreamy
  )
);
```

---

## Integration with Quasar

### Example Usage

```supercollider
(
// Create project
q = QProject.fromTemplate(\edm);

// Add QMess
var mess = QMess(q, messLevel: 0.4);

// Apply specific mess types
mess.timbralMess.overdrive(q.scene[\bass], amount: 0.8); // Overdrive bass!

mess.structuralMess.incompletePhrase(
  q.timeline[\build].melody,
  cutPoint: 0.7 // Cut at 70% (leave listener wanting more)
);

mess.rhythmicMess.dropBeat(
  q.timeline[\drop],
  probability: 0.1 // Occasional dropped beats
);

// Or mess everything up automatically
mess.messItUp; // Applies random mess based on messLevel

q.play;
)
```

### Deterministic Mess
```supercollider
(
// Mess is reproducible with seed
q.seed = 42;
q.messSeed = 99; // Separate seed for mess

var mess = QMess(q);
mess.messItUp;

// Same seeds = same "mistakes" every time
)
```

---

## Practical Applications

### 1. Incomplete Phrase (Your Example)
```supercollider
// Build tension by cutting phrase early
var melody = q.theory.melody.fromContour(\arch, length: 16);
melody = mess.structuralMess.incompletePhrase(melody, cutPoint: 0.75);
// Listener expects 16 notes but gets 12 → creates longing
```

### 2. Overdrive Bass (Your Example)
```supercollider
// "Happy accident" - bass sounds better overdriven
mess.timbralMess.overdrive(q.scene[\bass], amount: 0.9);
// Beyond "proper" levels but works musically
```

### 3. Spaces of Rest (Your Example)
```supercollider
// Unexpected silence creates breathing room
mess.rhythmicMess.unexpectedRest(
  q.scene[\drums],
  duration: 1.0,
  probability: 0.05
);
// Occasional 1-beat rests when you don't expect them
```

### 4. J Dilla-Style Timing
```supercollider
// Slightly off-grid but feels right
mess.rhythmicMess.timingError(
  q.scene[\drums],
  amount: 0.03, // 30ms variation
  probability: 0.6 // Most notes affected
);
```

### 5. Lo-Fi Production
```supercollider
// Tape artifacts + bandwidth reduction
mess.timbralMess.tapeArtifact(q.scene[\pad], type: \warble);
mess.productionMess.lofi(q.scene[\pad], severity: 0.6);
```

---

## Philosophy: When to Use QMess

### Good Reasons:
✅ Create tension (unresolved dissonance)
✅ Add character (lo-fi aesthetic)
✅ Humanize (timing errors, pitch drift)
✅ Generate interest (unexpected events)
✅ Subvert expectations (wrong notes that work)
✅ Express emotion (imperfection as vulnerability)

### Bad Reasons:
❌ Random chaos for chaos's sake
❌ Covering up bad composition
❌ Making things "weird" without purpose
❌ Overusing effects (too much mess = noise)

---

## Next: Integration into Implementation Plan

QMess adds **~1000 LOC** across 8 mess modules.
**Timeline**: +2 weeks (Phase 8f)

See updated **IMPLEMENTATION_TRACKER_UPDATED.md** for integration.

---

**QMess: Controlled chaos. Happy accidents. Musical wrongness that's actually right.**
