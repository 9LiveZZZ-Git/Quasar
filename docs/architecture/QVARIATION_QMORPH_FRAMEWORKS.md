# QVariation & QMorph: Variation Generation and State Morphing Frameworks

**Status**: Design Complete ✅
**Phase**: 12 (Weeks 62-65)
**LOC Estimate**: ~2,200 lines
**Classes**: ~12 classes

---

## Philosophy

**Problem**: Musical ideas often need development, transformation, and seamless transitions. Composers need tools to:
- Develop themes (classical variations)
- Create B sections from A material
- Smoothly transition between states (genre, mood, key)
- Generate remixes and reinterpretations

**Solution**:
- **QVariation**: Intelligent variation generation (rhythmic, melodic, harmonic, textural)
- **QMorph**: Smooth state morphing (interpolate between any musical parameters)

**Together**: Develop musical ideas intelligently and create seamless transformations.

---

## QVariation: Intelligent Variation Generator

### Core Capabilities

1. **Rhythmic Variation**
   - Augmentation (notes longer)
   - Diminution (notes shorter)
   - Dotted rhythms
   - Syncopation
   - Metric modulation

2. **Melodic Variation**
   - Inversion (upside down)
   - Retrograde (backwards)
   - Transposition
   - Intervallic expansion/contraction
   - Ornamentation (trills, turns, mordents)

3. **Harmonic Variation**
   - Reharmonization
   - Modal interchange
   - Chromatic alterations
   - Different chord voicings

4. **Textural Variation**
   - Solo → Tutti
   - Homophonic → Polyphonic
   - Density changes
   - Register shifts
   - Orchestration changes

5. **Structural Variation**
   - Fragmentation (use only part of theme)
   - Extension (add measures)
   - Truncation (cut measures)
   - Sequencing

6. **Style Transfer**
   - Play theme in different genre
   - Apply genre-specific transformations

---

## QVariation Architecture

```supercollider
// ===== MAIN ENGINE =====
QVariation {
  var <project;
  var <theme;              // Original musical material
  var <variations;         // Array of generated variations

  *new { |project, theme|
    ^super.newCopyArgs(project, theme).init;
  }

  init {
    variations = [];
  }

  // Generate a variation
  generate { |type, params|
    var variation = switch(type,
      \rhythmic, { QRhythmicVariation(theme, params) },
      \melodic, { QMelodicVariation(theme, params) },
      \harmonic, { QHarmonicVariation(theme, params) },
      \textural, { QTexturalVariation(theme, params) },
      \structural, { QStructuralVariation(theme, params) },
      \style_transfer, { QStyleTransfer(theme, params) }
    );

    variations = variations.add(variation);
    ^variation;
  }

  // Generate classical "Theme and Variations" form
  generateThemeAndVariations { |numVariations=5|
    var form = QForm(\theme_and_variations);

    // Theme (original)
    form.addSection(\theme, theme);

    // Generate variations with increasing complexity
    numVariations.do { |i|
      var complexity = (i + 1) / numVariations;
      var variation = this.generateAutomatic(complexity);
      form.addSection("variation_%".format(i + 1).asSymbol, variation);
    };

    ^form;
  }

  // Automatically choose variation techniques
  generateAutomatic { |complexity=0.5|
    var techniques = this.selectTechniques(complexity);
    var result = theme.deepCopy;

    techniques.do { |tech|
      result = this.applyTechnique(result, tech);
    };

    ^result;
  }

  selectTechniques { |complexity|
    var pool = [
      (\type: \rhythmic, \method: \augmentation, \complexity: 0.2),
      (\type: \rhythmic, \method: \diminution, \complexity: 0.3),
      (\type: \rhythmic, \method: \syncopation, \complexity: 0.5),
      (\type: \melodic, \method: \ornamentation, \complexity: 0.4),
      (\type: \melodic, \method: \inversion, \complexity: 0.6),
      (\type: \melodic, \method: \retrograde, \complexity: 0.7),
      (\type: \harmonic, \method: \reharmonization, \complexity: 0.5),
      (\type: \textural, \method: \density_change, \complexity: 0.4),
      (\type: \structural, \method: \fragmentation, \complexity: 0.6)
    ];

    // Select techniques appropriate for complexity level
    var selected = pool.select { |t| t.complexity <= (complexity + 0.2) };

    // Return 1-3 techniques
    ^selected.scramble.keep(rrand(1, 3));
  }

  applyTechnique { |material, technique|
    ^switch(technique.type,
      \rhythmic, { this.applyRhythmicVariation(material, technique.method) },
      \melodic, { this.applyMelodicVariation(material, technique.method) },
      \harmonic, { this.applyHarmonicVariation(material, technique.method) },
      \textural, { this.applyTexturalVariation(material, technique.method) },
      \structural, { this.applyStructuralVariation(material, technique.method) }
    );
  }
}

// ===== RHYTHMIC VARIATION =====
QRhythmicVariation {
  var <theme, <params;

  *new { |theme, params| ^super.newCopyArgs(theme, params) }

  augmentation { |factor=2.0|
    var result = theme.deepCopy;
    result.notes.do { |note| note.dur = note.dur * factor };
    "Rhythmic augmentation: %x slower".format(factor).postln;
    ^result;
  }

  diminution { |factor=0.5|
    var result = theme.deepCopy;
    result.notes.do { |note| note.dur = note.dur * factor };
    "Rhythmic diminution: %x faster".format(1/factor).postln;
    ^result;
  }

  syncopation { |amount=0.5|
    var result = theme.deepCopy;

    result.notes.do { |note, i|
      // Shift some notes off-beat
      if (amount.coin and: { i < (result.notes.size - 1) }) {
        var shift = note.dur * rrand(0.25, 0.5);
        note.onset = note.onset + shift;
        "Syncopated note %".format(i).postln;
      };
    };

    ^result;
  }

  addDots { |probability=0.3|
    var result = theme.deepCopy;

    result.notes.do { |note|
      if (probability.coin) {
        note.dur = note.dur * 1.5; // Dotted rhythm
        note.isDotted = true;
      };
    };

    "Added dotted rhythms".postln;
    ^result;
  }
}

// ===== MELODIC VARIATION =====
QMelodicVariation {
  var <theme, <params;

  *new { |theme, params| ^super.newCopyArgs(theme, params) }

  inversion { |axis|
    var result = theme.deepCopy;
    axis = axis ? result.notes.collect(_.midinote).mean;

    result.notes.do { |note|
      if (note.isRest.not) {
        var interval = note.midinote - axis;
        note.midinote = axis - interval; // Mirror around axis
      };
    };

    "Melodic inversion around MIDI %".format(axis.round(1)).postln;
    ^result;
  }

  retrograde {
    var result = theme.deepCopy;
    result.notes = result.notes.reverse;
    "Melodic retrograde (backwards)".postln;
    ^result;
  }

  transpose { |semitones|
    var result = theme.deepCopy;

    result.notes.do { |note|
      if (note.isRest.not) {
        note.midinote = note.midinote + semitones;
      };
    };

    "Transposed by % semitones".format(semitones).postln;
    ^result;
  }

  intervalExpansion { |factor=1.5|
    var result = theme.deepCopy;
    var firstNote = result.notes.detect { |n| n.isRest.not };

    if (firstNote.notNil) {
      var anchor = firstNote.midinote;

      result.notes.do { |note|
        if (note.isRest.not) {
          var interval = note.midinote - anchor;
          note.midinote = anchor + (interval * factor);
        };
      };

      "Interval expansion: %x".format(factor).postln;
    };

    ^result;
  }

  ornamentation { |type=\trill|
    var result = theme.deepCopy;

    result.notes.do { |note, i|
      if (note.isRest.not and: { note.dur > 0.5 }) {
        // Add ornament based on type
        switch(type,
          \trill, {
            note.ornament = (
              type: \trill,
              note2: note.midinote + 1, // Half-step trill
              rate: 8 // 8th notes
            );
          },
          \turn, {
            note.ornament = (
              type: \turn,
              notes: [
                note.midinote + 1,
                note.midinote,
                note.midinote - 1,
                note.midinote
              ]
            );
          },
          \mordent, {
            note.ornament = (
              type: \mordent,
              note2: note.midinote - 1
            );
          }
        );
      };
    };

    "Added % ornaments".format(type).postln;
    ^result;
  }
}

// ===== HARMONIC VARIATION =====
QHarmonicVariation {
  var <theme, <params;

  *new { |theme, params| ^super.newCopyArgs(theme, params) }

  reharmonization { |style=\jazz|
    var result = theme.deepCopy;
    var harmony = QHarmony.fromMelody(result);

    // Apply different harmonic treatment
    switch(style,
      \jazz, {
        harmony = this.jazzReharmonization(harmony);
      },
      \chromatic, {
        harmony = this.chromaticReharmonization(harmony);
      },
      \modal, {
        harmony = this.modalReharmonization(harmony);
      }
    );

    result.harmony = harmony;
    "Reharmonized: % style".format(style).postln;
    ^result;
  }

  jazzReharmonization { |harmony|
    // Add extensions, substitutions
    harmony.chords.do { |chord|
      // Add 7th, 9th, etc.
      if (0.7.coin) { chord.addExtension(7) };
      if (0.5.coin) { chord.addExtension(9) };

      // Tritone substitution
      if (0.3.coin and: { chord.function == \dominant }) {
        chord.root = (chord.root + 6) % 12; // Tritone away
        "Tritone sub: % → %".format(
          chord.originalRoot, chord.root
        ).postln;
      };
    };

    ^harmony;
  }

  modalInterchange { |probability=0.3|
    var result = theme.deepCopy;

    // Borrow chords from parallel minor/major
    result.harmony.chords.do { |chord|
      if (probability.coin) {
        chord.mode = chord.mode.switch(
          \major, { \minor },
          \minor, { \major }
        );
      };
    };

    "Applied modal interchange".postln;
    ^result;
  }
}

// ===== TEXTURAL VARIATION =====
QTexturalVariation {
  var <theme, <params;

  *new { |theme, params| ^super.newCopyArgs(theme, params) }

  soloToTutti {
    var result = theme.deepCopy;

    // Add multiple voices/doublings
    var doublings = [\violin, \viola, \cello, \flute];

    doublings.do { |instrument|
      result.addVoice(instrument, theme.melody.transpose(rrand(-12, 12)));
    };

    "Expanded to tutti (% instruments)".format(doublings.size + 1).postln;
    ^result;
  }

  changeDensity { |targetDensity|
    var result = theme.deepCopy;
    var currentDensity = result.notes.size / result.duration;

    if (targetDensity > currentDensity) {
      // Add notes
      result = this.addNotes(result, targetDensity / currentDensity);
    } {
      // Remove notes
      result = this.removeNotes(result, currentDensity / targetDensity);
    };

    "Changed density: % → % notes/sec".format(
      currentDensity.round(0.1), targetDensity.round(0.1)
    ).postln;

    ^result;
  }

  registerShift { |octaves|
    var result = theme.deepCopy;

    result.notes.do { |note|
      if (note.isRest.not) {
        note.midinote = note.midinote + (octaves * 12);
      };
    };

    "Shifted register by % octaves".format(octaves).postln;
    ^result;
  }

  changeArticulation { |newArticulation|
    var result = theme.deepCopy;

    result.notes.do { |note|
      if (note.isRest.not) {
        note.articulation = newArticulation;
      };
    };

    "Changed articulation to %".format(newArticulation).postln;
    ^result;
  }
}

// ===== STRUCTURAL VARIATION =====
QStructuralVariation {
  var <theme, <params;

  *new { |theme, params| ^super.newCopyArgs(theme, params) }

  fragmentation { |fragmentSize=4|
    var result = theme.deepCopy;

    // Take only first N notes
    result.notes = result.notes.keep(fragmentSize);

    "Fragmentation: kept first % notes".format(fragmentSize).postln;
    ^result;
  }

  extension { |repetitions=2|
    var result = theme.deepCopy;

    // Repeat material
    var original = result.notes.copy;
    repetitions.do {
      result.notes = result.notes ++ original;
    };

    "Extended: % repetitions".format(repetitions).postln;
    ^result;
  }

  sequencing { |steps=3, interval=2|
    var result = theme.deepCopy;
    var original = result.notes.copy;

    steps.do { |i|
      var transposed = original.collect { |note|
        var n = note.deepCopy;
        if (n.isRest.not) {
          n.midinote = n.midinote + (interval * (i + 1));
        };
        n;
      };
      result.notes = result.notes ++ transposed;
    };

    "Sequencing: % steps, % semitone intervals".format(steps, interval).postln;
    ^result;
  }
}

// ===== STYLE TRANSFER =====
QStyleTransfer {
  var <theme, <params;

  *new { |theme, params| ^super.newCopyArgs(theme, params) }

  toGenre { |genre|
    var result = theme.deepCopy;
    var template = QGenreTemplate(genre);

    // Apply genre-specific transformations
    result = template.applyRhythmicStyle(result);
    result = template.applyHarmonicStyle(result);
    result = template.applyArticulationStyle(result);
    result = template.applyInstrumentation(result);

    "Style transfer: → %".format(genre).postln;
    ^result;
  }
}
```

---

## QMorph: State Morphing System

### Core Capabilities

1. **Parameter Morphing**
   - Tempo changes (gradual accelerando/ritardando)
   - Key modulation (chromatic interpolation)
   - Energy/intensity fades
   - Dynamics (crescendo/diminuendo)

2. **Genre Morphing**
   - Smoothly transition between genres
   - Interpolate rhythmic patterns
   - Blend harmonic languages

3. **Harmonic Morphing**
   - Key changes with voice leading
   - Mode shifting (major → minor)
   - Chord substitution chains

4. **Timbral Morphing**
   - Crossfade between instruments
   - Spectral interpolation
   - Effect morphing

5. **Spatial Morphing**
   - Pan position changes
   - Stereo width transitions
   - 3D position interpolation

---

## QMorph Architecture

```supercollider
// ===== MAIN ENGINE =====
QMorph {
  var <project;
  var <morphs;             // Active morphs

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    morphs = [];
  }

  // Morph between two states
  morph { |parameterPath, fromValue, toValue, duration, curve=\linear|
    var morphObj = QMorphTransition(
      parameterPath, fromValue, toValue, duration, curve
    );

    morphs = morphs.add(morphObj);

    // Schedule morph
    fork {
      morphObj.execute(project);
      morphs.remove(morphObj);
    };

    ^morphObj;
  }

  // Morph entire sections
  morphSections { |sectionA, sectionB, duration|
    var morphObj = QSectionMorph(sectionA, sectionB, duration);

    fork {
      morphObj.execute(project);
    };

    ^morphObj;
  }

  // Morph genres
  morphGenres { |genreA, genreB, duration|
    var morphObj = QGenreMorph(genreA, genreB, duration);

    fork {
      morphObj.execute(project);
    };

    ^morphObj;
  }
}

// ===== MORPH TRANSITION =====
QMorphTransition {
  var <path, <from, <to, <duration, <curve;
  var <startTime;

  *new { |path, from, to, duration, curve|
    ^super.newCopyArgs(path, from, to, duration, curve);
  }

  execute { |project|
    startTime = Main.elapsedTime;
    var steps = (duration / 0.05).round; // 50ms resolution

    steps.do { |i|
      var progress = i / steps;
      var curved = this.applyCurve(progress);
      var value = from.blend(to, curved);

      // Set parameter
      project.setParameter(path, value);

      "Morph %: % (progress=%)".format(
        path, value.round(0.01), (progress * 100).round(1)
      ).postln;

      (duration / steps).wait;
    };

    // Final value
    project.setParameter(path, to);
    "Morph % complete".format(path).postln;
  }

  applyCurve { |t|
    ^switch(curve,
      \linear, { t },
      \exp, { t.squared },
      \log, { t.sqrt },
      \sine, { sin(t * pi * 0.5) },
      \cosine, { 1 - cos(t * pi * 0.5) },
      \exponential, { (2 ** (t * 10) - 1) / 1023 }
    );
  }
}

// ===== SECTION MORPH =====
QSectionMorph {
  var <sectionA, <sectionB, <duration;

  *new { |sectionA, sectionB, duration|
    ^super.newCopyArgs(sectionA, sectionB, duration);
  }

  execute { |project|
    "Morphing section % → % over %s".format(
      sectionA.name, sectionB.name, duration
    ).postln;

    // Morph multiple parameters in parallel
    fork {
      [
        this.morphTempo,
        this.morphHarmony,
        this.morphEnergy,
        this.morphTexture
      ].do(_.wait);
    };
  }

  morphTempo {
    var tempoA = sectionA.tempo;
    var tempoB = sectionB.tempo;

    ^QMorphTransition(\tempo, tempoA, tempoB, duration, \linear);
  }

  morphHarmony {
    var keyA = sectionA.key;
    var keyB = sectionB.key;

    // Use voice leading for key change
    ^this.keyModulation(keyA, keyB, duration);
  }

  morphEnergy {
    var energyA = sectionA.energy;
    var energyB = sectionB.energy;

    ^QMorphTransition(\energy, energyA, energyB, duration, \exp);
  }

  morphTexture {
    // Crossfade instruments
    ^this.crossfadeTextures(sectionA.layers, sectionB.layers, duration);
  }

  keyModulation { |keyA, keyB, dur|
    // TODO: Implement smart voice leading
    "Key modulation: % → %".format(keyA, keyB).postln;
  }

  crossfadeTextures { |layersA, layersB, dur|
    // Fade out A, fade in B
    fork {
      var steps = (dur / 0.1).round;

      steps.do { |i|
        var progress = i / steps;

        layersA.do { |layer| layer.amp = 1.0 - progress };
        layersB.do { |layer| layer.amp = progress };

        (dur / steps).wait;
      };
    };
  }
}

// ===== GENRE MORPH =====
QGenreMorph {
  var <genreA, <genreB, <duration;

  *new { |genreA, genreB, duration|
    ^super.newCopyArgs(genreA, genreB, duration);
  }

  execute { |project|
    "Morphing genre: % → % over %s".format(
      genreA, genreB, duration
    ).postln;

    var templateA = QGenreTemplate(genreA);
    var templateB = QGenreTemplate(genreB);

    // Morph rhythmic patterns
    this.morphRhythm(templateA, templateB, duration);

    // Morph harmonic language
    this.morphHarmony(templateA, templateB, duration);

    // Morph instrumentation
    this.morphInstrumentation(templateA, templateB, duration);

    // Morph production style
    this.morphProduction(templateA, templateB, duration);
  }

  morphRhythm { |templateA, templateB, dur|
    "Morphing rhythm: % → %".format(
      templateA.rhythmicStyle, templateB.rhythmicStyle
    ).postln;

    // Gradually transition drum patterns
    fork {
      var steps = (dur / 4).round; // Change every 4 beats

      steps.do { |i|
        var progress = i / steps;

        if (progress < 0.5) {
          // Mostly A
          project.scene[\drums].pattern = templateA.drumPattern;
        } {
          // Mostly B
          project.scene[\drums].pattern = templateB.drumPattern;
        };

        4.wait;
      };
    };
  }

  morphHarmony { |templateA, templateB, dur|
    "Morphing harmony: % → %".format(
      templateA.harmonicStyle, templateB.harmonicStyle
    ).postln;

    // TODO: Blend chord progressions
  }

  morphInstrumentation { |templateA, templateB, dur|
    var instsA = templateA.instruments;
    var instsB = templateB.instruments;

    "Morphing instrumentation".postln;

    // Crossfade
    fork {
      var steps = (dur / 0.5).round;

      steps.do { |i|
        var progress = i / steps;

        instsA.do { |inst| inst.amp = 1.0 - progress };
        instsB.do { |inst| inst.amp = progress };

        (dur / steps).wait;
      };
    };
  }

  morphProduction { |templateA, templateB, dur|
    // Morph effects (reverb, distortion, etc.)
    "Morphing production style".postln;
  }
}

// ===== TEMPO MORPH (Utility) =====
QTempoMorph {
  *accelerando { |project, fromTempo, toTempo, duration|
    ^QMorph(project).morph(\tempo, fromTempo, toTempo, duration, \exp);
  }

  *ritardando { |project, fromTempo, toTempo, duration|
    ^QMorph(project).morph(\tempo, fromTempo, toTempo, duration, \log);
  }
}

// ===== KEY MORPH (Utility) =====
QKeyMorph {
  *modulate { |project, fromKey, toKey, duration|
    // Smart modulation with pivot chords
    var pivotChord = this.findPivotChord(fromKey, toKey);

    "Modulating % → % via %".format(fromKey, toKey, pivotChord).postln;

    // TODO: Implement voice-led modulation
  }

  *findPivotChord { |keyA, keyB|
    // Find common chord between keys
    var chordsA = QHarmony.diatonicChords(keyA);
    var chordsB = QHarmony.diatonicChords(keyB);

    var common = chordsA.sect(chordsB);

    if (common.isEmpty) {
      ^nil;
    } {
      ^common.choose;
    };
  }
}
```

---

## Integration Example

```supercollider
(
// ===== COMPOSITION =====
q = QProject(\classical);
q.tempo = 60;

// Theme
var theme = q.theory.melody.generate(\lyrical, key: \Cmajor);
q.timeline.add(\theme, 8.bars, melody: theme);

// ===== VARIATION =====
var variation = QVariation(q, theme);

// Generate 5 variations
var var1 = variation.generate(\rhythmic, (method: \augmentation, factor: 2));
var var2 = variation.generate(\melodic, (method: \inversion));
var var3 = variation.generate(\harmonic, (method: \reharmonization, style: \jazz));
var var4 = variation.generate(\textural, (method: \soloToTutti));
var var5 = variation.generate(\structural, (method: \fragmentation, fragmentSize: 4));

// Add to timeline
q.timeline.add(\variation1, 8.bars, melody: var1);
q.timeline.add(\variation2, 8.bars, melody: var2);
q.timeline.add(\variation3, 8.bars, melody: var3);
q.timeline.add(\variation4, 8.bars, melody: var4);
q.timeline.add(\variation5, 8.bars, melody: var5);

// ===== MORPHING =====
var morph = QMorph(q);

// Morph tempo between sections
morph.morph(\tempo, 60, 120, duration: 8, curve: \exp);

// Morph key
morph.morph(\key, \Cmajor, \Aminor, duration: 4);

// Morph genres (baroque → EDM over 16 bars)
morph.morphGenres(\baroque, \edm, duration: 16);

// ===== RENDER =====
q.render("~/theme_and_variations_morphing.wav");
)
```

---

## Use Cases

### Classical Composition
- Theme and variations form
- Develop motifs throughout piece
- Create B sections from A material

### Remixing & Reinterpretation
- Generate remixes automatically
- Try different genre treatments
- Create alternate versions

### Film Scoring
- Develop leitmotifs
- Smooth transitions between cues
- Adapt themes to different moods

### Adaptive Music
- Morph between states based on gameplay
- Seamless intensity changes
- Genre-fluid compositions

---

## Summary

| Feature | QVariation | QMorph |
|---------|------------|--------|
| **Rhythmic** | Augmentation, diminution, syncopation | Tempo morphing |
| **Melodic** | Inversion, retrograde, ornamentation | Key modulation |
| **Harmonic** | Reharmonization, modal interchange | Smooth chord changes |
| **Textural** | Density, register, articulation | Crossfades |
| **Structural** | Fragmentation, sequencing | Section transitions |
| **Genre** | Style transfer | Genre morphing |
| **LOC** | ~1,400 | ~800 |
| **Classes** | 7 | 5 |

**Total**: ~2,200 LOC, ~12 classes, 4 weeks implementation

---

**QVariation + QMorph = Infinite musical development and seamless transformations**
