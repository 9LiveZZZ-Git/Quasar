# Quasar: Genre Templates & Examples

## Purpose

This document provides concrete examples of how Quasar's genre-agnostic architecture supports diverse musical styles through **templates** - pre-configured sets of theory rules, constraints, and preferences.

Templates are NOT hard-coded limits—they're starting points. Users can:
- Use a template as-is
- Customize any part
- Mix templates (e.g., Jazz harmony + Minimalist rhythm)
- Create entirely new templates

---

## Template Structure

Every template defines:

```supercollider
QTemplate.<name> = (
  // Music theory configuration
  theory: (
    harmony: <harmonic system settings>,
    melody: <melodic generation rules>,
    rhythm: <rhythmic patterns and meters>,
    counterpoint: <voice leading rules>,
    form: <formal archetype>
  ),

  // Texture defaults
  texture: <texture type and voice count>,

  // Orchestration preferences
  orchestration: (
    ensemble: <instrument group>,
    balance: <mix balance strategy>,
    articulation: <default articulations>
  ),

  // Temporal settings
  tempo: <tempo range and behavior>,

  // Scene macros (performance controls)
  macros: <available macro controls>,

  // Selection constraints (how materials are chosen)
  constraints: <selection rules>
);
```

---

## Classical Music Templates

### 1. Baroque Fugue

**Style**: J.S. Bach, Handel, Vivaldi
**Key Features**: Strict counterpoint, imitative entries, sequences, functional harmony

```supercollider
QTemplate.baroqueFugue = (
  theory: (
    harmony: (
      style: \baroque,
      scales: [\major, \minor, \harmonicMinor],
      progressions: \functional,
      cadences: [\authentic, \plagal, \half],
      sequences: true,
      nonChordTones: [\passing, \neighbor, \suspension],
      dissonanceTreatment: \resolved // All dissonances resolve
    ),

    melody: (
      style: \baroque,
      contour: \stepwiseBias, // Prefer stepwise motion
      leaps: (
        allowed: [3, 4, 5, 8], // m3, M3, P4, P5, P8
        followedBy: \stepwise, // Leaps followed by steps
        maxConsecutive: 2
      ),
      ornamentation: [\trill, \mordent, \turn, \appoggiatura],
      range: \moderate // No extreme ranges
    ),

    rhythm: (
      meter: [4, 4], // or [3, 4], [2, 2]
      subdivision: \sixteenth,
      syncopation: \moderate,
      hemiola: true, // Common in Baroque
      mottoRhythm: true // Rhythmic cells repeated
    ),

    counterpoint: (
      species: [\first, \second, \third],
      rules: \strict,
      parallelFifths: false,
      parallelOctaves: false,
      hiddenFifths: \avoid,
      voiceCrossing: \rare,
      preparation: true, // Dissonances prepared
      resolution: \required
    ),

    form: (
      archetype: \fugue,
      exposition: (
        entries: \staggered,
        order: [\subject, \answer, \subject, \answer],
        keys: [\tonic, \dominant, \tonic, \dominant]
      ),
      episodes: (
        material: \fragmentation,
        keys: \modulating,
        techniques: [\sequence, \transposition, \inversion]
      ),
      middleEntries: (
        keys: [\subdominant, \relative, \supertonic],
        complete: false // Often partial entries
      ),
      stretto: true, // Overlapping entries
      pedal: \dominant // Dominant pedal before final entry
    )
  ),

  texture: (
    type: \polyphonic,
    voices: 4, // SATB typical
    independence: \high // Each voice independent
  ),

  orchestration: (
    ensemble: \harpsichord, // or \organ, \stringQuartet
    balance: \equal, // All voices equal importance
    articulation: \detached, // Baroque style
    dynamics: \terraced // Stepped, not gradual
  ),

  tempo: (
    range: [60, 120],
    style: \steady,
    rubato: false
  ),

  macros: (
    articulation: [\legato, \detached, \staccato],
    registration: \baroque // Harpsichord/organ stops
  ),

  constraints: (
    voiceLeading: \strict,
    dissonance: \controlled,
    range: \enforced
  )
);

// Example usage:
/*
q = QProject.fromTemplate(\baroqueFugue);
q.theory.harmony.scale_(\dMinor);
q.theory.form.exposition(
  subject: [0, 2, 4, 5, 4, 2, 0], // Scale degrees
  answer: \tonal // Generate tonal answer automatically
);
q.theory.form.generate; // Generates full fugue structure
q.play;
*/
```

---

### 2. Classical Sonata

**Style**: Haydn, Mozart, Beethoven (early)
**Key Features**: Sonata form, clear phrases, functional harmony, homophonic texture

```supercollider
QTemplate.classicalSonata = (
  theory: (
    harmony: (
      style: \classical,
      progressions: \functional,
      cadences: [\authentic, \half, \deceptive],
      modulations: [\dominant, \relative, \parallel],
      secondaryDominants: true,
      chromaticism: \moderate
    ),

    melody: (
      style: \classical,
      phrasing: \periodic, // 4+4, 8+8 bar phrases
      sentences: true, // Presentation + continuation
      periods: true, // Antecedent + consequent
      development: [\fragmentation, \sequence, \expansion],
      contour: \balanced // Mix of stepwise and leaps
    ),

    rhythm: (
      meter: [4, 4], // or [3, 4], [6, 8]
      subdivision: \sixteenth,
      albertiBass: true, // Typical accompaniment
      syncopation: \light
    ),

    form: (
      archetype: \sonata,
      exposition: (
        theme1: (
          character: \assertive,
          key: \tonic,
          length: 8.bars
        ),
        transition: (
          modulation: \towardsDominant,
          length: 4.bars
        ),
        theme2: (
          character: \lyrical,
          key: \dominant, // or \relative if minor key
          length: 8.bars
        ),
        codetta: (
          material: \theme1,
          length: 4.bars
        ),
        repeat: true
      ),

      development: (
        material: [\theme1, \theme2, \transition],
        techniques: [\fragmentation, \sequence, \modulation, \tonicization],
        keys: [\subdominant, \supertonic, \submediant],
        intensityCurve: \climax, // Builds to climax
        length: 16.bars
      ),

      recapitulation: (
        theme1: (key: \tonic, length: 8.bars),
        transition: (modified: true, length: 4.bars),
        theme2: (key: \tonic, length: 8.bars), // Resolved to tonic
        codetta: (length: 4.bars)
      ),

      coda: (
        optional: true,
        material: \theme1,
        length: 8.bars
      )
    )
  ),

  texture: (
    type: \homophonic, // Melody + accompaniment
    layers: [\melody, \harmony, \bass]
  ),

  orchestration: (
    ensemble: \pianoSolo, // or \chamberEnsemble, \orchestra
    balance: \pyramid, // Strong bass, lighter top
    dynamics: \gradual, // Crescendo/diminuendo
    articulation: [\legato, \staccato, \marcato, \tenuto]
  ),

  tempo: (
    range: [60, 144],
    movements: [
      (tempo: \allegro, form: \sonata),
      (tempo: \andante, form: \ternary),
      (tempo: \menuetto, form: \minuetTrio),
      (tempo: \allegro, form: \rondo)
    ],
    changes: \rare // Within movements
  ),

  macros: (
    dynamics: [\pp, \p, \mp, \mf, \f, \ff],
    articulation: \classical,
    pedaling: \classical // If piano
  )
);
```

---

### 3. Romantic Character Piece

**Style**: Chopin, Schumann, Brahms
**Key Features**: Rich harmony, rubato, expressive dynamics, chromatic voice leading

```supercollider
QTemplate.romanticCharacter = (
  theory: (
    harmony: (
      style: \romantic,
      chromaticism: \high,
      modulations: [\chromatic, \enharmonic, \thirdRelated],
      extendedHarmony: [\9th, \11th, \13th],
      alterations: [\augmented6th, \neapolitan],
      functionalAmbiguity: true
    ),

    melody: (
      style: \romantic,
      contour: \expressive,
      range: \wide, // Dramatic ranges
      ornamentation: [\grace, \trill, \turn, \arpeggio],
      rubato: true,
      phrasing: \asymmetric // Not always 4+4
    ),

    rhythm: (
      meter: \flexible,
      syncopation: \high,
      crossRhythm: true, // 2-against-3, etc.
      rubato: \expressive,
      temporalFlexibility: \high
    ),

    form: (
      archetype: \ternary, // ABA most common
      sections: (
        A: (mood: \lyrical, length: 16.bars),
        B: (mood: \contrasting, modulation: \distant, length: 16.bars),
        A: (variation: true, coda: true, length: 20.bars)
      )
    )
  ),

  texture: (
    type: \varies,
    changes: \frequent,
    density: \rich // Many notes, thick chords
  ),

  orchestration: (
    ensemble: \piano,
    balance: \melodic, // Melody prominent
    pedaling: \extensive,
    voicing: \rich // Extended chords, wide spacing
  ),

  tempo: (
    range: [40, 120],
    rubato: \extensive,
    agogicAccents: true,
    temporalFlexibility: \very high
  ),

  macros: (
    expression: [0.0, 1.0], // Expressiveness amount
    rubato: [0.0, 1.0],
    pedal: [0.0, 1.0],
    dynamics: [\pp, \p, \mp, \mf, \f, \ff, \fff]
  )
);
```

---

## Jazz Templates

### 4. Bebop

**Style**: Charlie Parker, Dizzy Gillespie, Bud Powell
**Key Features**: Fast tempos, complex harmony, virtuosic lines, swing

```supercollider
QTemplate.bebop = (
  theory: (
    harmony: (
      style: \bebop,
      chords: [\7th, \9th, \11th, \13th, \altered],
      progressions: [\twoFiveOne, \rhythmChanges, \blues],
      substitutions: [\tritone, \secondary, \diminished],
      voicing: \shells, // 3rd and 7th most important
      extensions: \colorful
    ),

    melody: (
      style: \bebop,
      scales: [\bebop, \altered, \diminished, \wholeTone],
      chromaticism: \very high,
      leaps: \wide,
      ornamentation: [\grace, \bend, \scoop, \doit],
      targetTones: \chordTones, // Land on chord tones
      approach: \chromatic // Chromatic approach to targets
    ),

    rhythm: (
      meter: [4, 4],
      swing: 0.66, // Triplet feel
      subdivision: \eighth,
      syncopation: \very high,
      anticipation: true, // Play ahead of beat
      accentPattern: \offbeat
    ),

    form: (
      archetype: \AABA,
      length: 32.bars,
      sections: (
        A: 8.bars,
        A: 8.bars,
        B: 8.bars, // Bridge
        A: 8.bars
      ),
      head: true, // Play melody (head) first
      solos: true, // Improvisation section
      trading: \fours // Trade 4-bar solos
    )
  ),

  texture: (
    type: \polyphonic,
    independence: \high, // Each player improvises
    roles: [\head, \comp, \walking, \swing]
  ),

  orchestration: (
    ensemble: \bebopcCombo,
    voices: (
      frontline: [\trumpet, \sax], // Melody instruments
      rhythm: [\piano, \bass, \drums]
    ),
    balance: \interactive, // Players respond to each other
    articulation: [\swing, \legato, \staccato, \accent]
  ),

  tempo: (
    range: [180, 300], // Very fast!
    style: \steady,
    swing: true
  ),

  macros: (
    swing: [0.5, 0.75], // Swing amount
    density: \improvDensity, // Note density in solos
    energy: [\head, \solos, \trading, \out]
  ),

  constraints: (
    harmonic: \chordTones, // Emphasize chord tones
    approach: \chromatic,
    resolution: \towardChordTones
  )
);
```

---

### 5. Modal Jazz

**Style**: Miles Davis (Kind of Blue), John Coltrane
**Key Features**: Modal harmony, fewer chord changes, spacious texture

```supercollider
QTemplate.modalJazz = (
  theory: (
    harmony: (
      style: \modal,
      modes: [\dorian, \phrygian, \lydian, \mixolydian, \aeolian],
      chordChanges: \minimal, // Stay on one or two chords
      voicings: \quartal, // Quartal harmony (4ths)
      functional: false, // No V-I resolutions
      pedal: true // Pedal points common
    ),

    melody: (
      style: \modal,
      scales: \modal,
      development: \motivic, // Develop short motives
      space: \important, // Rests matter
      contour: \horizontal, // Long, flowing lines
      repetition: \hypnotic
    ),

    rhythm: (
      meter: [4, 4],
      swing: 0.60, // Lighter swing
      pulse: \relaxed,
      polyrhythm: true,
      subdivision: \flexible
    ),

    form: (
      archetype: \modal,
      sections: (
        intro: (modal center: \d, mode: \dorian, length: 16.bars),
        A: (modal center: \eb, mode: \mixolydian, length: 16.bars),
        B: (modal center: \f, mode: \lydian, length: 16.bars),
        A: (return: true)
      ),
      openness: \high // Less strict form
    )
  ),

  texture: (
    type: \polyphonic,
    density: \sparse, // More space
    interaction: \collective improvisation
  ),

  orchestration: (
    ensemble: \modalQuintet,
    balance: \conversational,
    dynamics: \subtle
  ),

  tempo: (
    range: [60, 140],
    feel: \relaxed
  ),

  macros: (
    modalColor: \modeSelection,
    density: [0.2, 0.8],
    space: [0.4, 0.9] // Amount of space/silence
  )
);
```

---

## Electronic / Experimental Templates

### 6. Minimalism

**Style**: Steve Reich, Philip Glass, Terry Riley
**Key Features**: Repetitive patterns, gradual process, phasing, additive rhythm

```supercollider
QTemplate.minimalism = (
  theory: (
    harmony: (
      style: \modal,
      progressions: \static, // Very slow harmonic rhythm
      changes: \gradual,
      tonality: \ambiguous,
      pedal: true
    ),

    melody: (
      style: \minimalist,
      patterns: \repetitive,
      development: [\phasing, \additive, \subtractive],
      motives: \short, // Very short cells
      transformation: \gradual
    ),

    rhythm: (
      meter: \steady,
      patterns: \ostinato,
      pulses: \multiple, // Polyrhythmic pulses
      processes: (
        phasing: true, // Reich-style phasing
        additive: true, // Glass-style additive
        metric modulation: true
      ),
      subdivision: \constant
    ),

    form: (
      archetype: \processual,
      structure: \emergent, // Form emerges from process
      sections: \gradual, // No clear boundaries
      processes: [\phasing, \additive, \canonic, \metricModulation],
      duration: \extended // Often long pieces
    )
  ),

  texture: (
    type: \homorhythmic, // Often same rhythm all voices
    evolution: \gradual,
    density: \variesSlowly
  ),

  orchestration: (
    ensemble: \flexible, // Various ensembles work
    doubling: \extensive, // Much octave doubling
    balance: \blended
  ),

  tempo: (
    range: [100, 180],
    style: \constant,
    changes: \gradual // Metric modulation
  ),

  macros: (
    density: \additive, // Add/subtract notes
    phase: \continuous, // Phasing relationship
    pulseRate: \metricModulation
  ),

  constraints: (
    change: \gradual, // All changes gradual
    repetition: \required
  )
);
```

---

### 7. EDM (Electronic Dance Music)

**Style**: House, Techno, Dubstep, Trance
**Key Features**: 4/4 beat, build/drop structure, synthesized timbres

```supercollider
QTemplate.edm = (
  theory: (
    harmony: (
      style: \simple,
      progressions: [\fourChord, \twoChord],
      complexity: \low,
      bass: \rootNotes, // Bass plays roots
      stabs: true // Chord stabs
    ),

    melody: (
      style: \hook,
      repetition: \very high,
      range: \narrow,
      catchiness: \priority,
      vocoding: \optional
    ),

    rhythm: (
      meter: [4, 4],
      kick: \fourOnTheFloor, // Kick on every beat
      hihat: \sixteenth, // 16th note hihats
      snare: \backbeat, // Beats 2 and 4
      syncopation: \controlled,
      buildups: \filterSweeps
    ),

    form: (
      archetype: \edm,
      sections: [
        (name: \intro, length: 8.bars, energy: 0.2, layers: \minimal),
        (name: \build1, length: 8.bars, energy: [0.2, 0.8], filter: \opening),
        (name: \drop1, length: 16.bars, energy: 0.9, layers: \maximal),
        (name: \break, length: 8.bars, energy: 0.3, layers: \melodic),
        (name: \build2, length: 8.bars, energy: [0.3, 0.9], filter: \opening),
        (name: \drop2, length: 16.bars, energy: 1.0, layers: \maximal, variation: true),
        (name: \outro, length: 8.bars, energy: [0.8, 0.1], layers: \decreasing)
      ],
      transitions: [\riser, \impact, \tapeStop, \reverseFill, \whiteNoise]
    )
  ),

  texture: (
    type: \layered,
    layers: [\sub, \bass, \lead, \pad, \pluck, \drums, \fx],
    density: \sectional // Changes by section
  ),

  orchestration: (
    ensemble: \electronic,
    layers: (
      sub: (range: [20, 80], role: \foundation),
      bass: (range: [40, 300], role: \groove),
      lead: (range: [1000, 8000], role: \melody),
      pad: (range: [200, 2000], role: \texture),
      drums: (role: \rhythm)
    ),
    balance: \pyramidWithLeadSpotlight,
    sidechain: true // Sidechain compression from kick
  ),

  tempo: (
    range: [100, 180],
    style: \constant,
    genres: (
      house: 120-128,
      techno: 125-135,
      dubstep: 140,
      dnb: 170-180,
      trance: 130-140
    )
  ),

  macros: (
    energy: [0.0, 1.0], // Master energy control
    filter: [20, 20000], // Global filter sweep
    sidechain: [0.0, 1.0], // Sidechain depth
    width: [0.0, 1.0], // Stereo width
    space: [0.0, 1.0], // Reverb/delay amount
    dirt: [0.0, 1.0], // Distortion/saturation
    motion: [0.0, 1.0], // Modulation depth
    impact: \trigger // Impact one-shots
  ),

  constraints: (
    beatAlign: \strict, // Everything quantized to grid
    lowEndClarity: true, // Keep low end clean
    dynamics: \compressed // Heavy compression
  ),

  gestures: (
    riser: (
      pitch: \ascending,
      filter: \opening,
      volume: \crescendo,
      duration: [4, 8].bars
    ),
    drop: (
      impact: \kickSnare,
      cutFilter: true,
      energy: \max
    ),
    tapeStop: (
      pitchDown: true,
      slowdown: true,
      duration: [0.5, 2].bars
    ),
    reverseFill: (
      reverse: true,
      duration: [0.5, 1].bars
    )
  )
);
```

---

### 8. Ambient

**Style**: Brian Eno, Stars of the Lid, Tim Hecker
**Key Features**: Atmospheric, slow evolution, no clear rhythm, spacious

```supercollider
QTemplate.ambient = (
  theory: (
    harmony: (
      style: \modal,
      progressions: \drifting,
      tonality: \ambiguous,
      dissonance: \beautifulDissonance,
      resolution: \optional,
      suspensions: \extended
    ),

    melody: (
      style: \sparse,
      contour: \floating,
      rhythm: \free,
      development: \morphing,
      foreground: false // Melody not always present
    ),

    rhythm: (
      meter: \free,
      pulse: \implied, // Often no clear pulse
      rhythm: \atmospheric,
      events: \sparse
    ),

    form: (
      archetype: \openForm,
      structure: \continuous,
      sections: \overlapping,
      development: \textural,
      climax: \optional
    )
  ),

  texture: (
    type: \layered,
    density: \breathing, // Waxes and wanes
    evolution: \slow,
    layers: \overlapping
  ),

  orchestration: (
    ensemble: \padsAndTextures,
    layers: (
      deepPad: (range: [30, 200], evolution: \very slow),
      midPad: (range: [200, 2000], evolution: \slow),
      highShimmer: (range: [2000, 12000], evolution: \slow),
      sparse events: (range: \wide, occurrence: \rare)
    ),
    balance: \blended,
    space: \extensive // Heavy reverb/delay
  ),

  tempo: (
    style: \rubato,
    bpm: \irrelevant, // Often no clear tempo
    changes: \morphing
  ),

  macros: (
    space: [0.5, 1.0], // Always spacious
    brightness: [0.2, 0.8],
    density: [0.1, 0.6],
    dissonance: [0.0, 0.5],
    motion: [0.0, 0.3] // Slow modulation
  ),

  constraints: (
    change: \gradual,
    attack: \soft, // No hard attacks
    dynamics: \gentle,
    space: \required
  )
);
```

---

### 9. Algorithmic / Experimental

**Style**: Xenakis, Stockhausen, Cage
**Key Features**: Parametric control, stochastic processes, unconventional structures

```supercollider
QTemplate.algorithmic = (
  theory: (
    harmony: (
      style: \parametric,
      organization: [\intervallic, \spectral, \stochastic],
      tonality: \optional,
      constraints: \minimal
    ),

    melody: (
      style: \nontraditional,
      generation: [\stochastic, \deterministic, \chaotic],
      contour: \mathematical,
      material: [\pitch, \noise, \silence, \extended techniques]
    ),

    rhythm: (
      meter: \variable,
      organization: [\stochastic, \periodic, \aperiodic],
      density: \parametric,
      processes: [\cellular automata, \fractal, \markov]
    ),

    form: (
      archetype: \generative,
      structure: [\emergent, \predetermined, \mobile],
      sections: \definedByProcess,
      time: [\linear, \circular, \nonlinear]
    )
  ),

  texture: (
    type: \parametric,
    density: [\clouds, \pointillistic, \massive],
    organization: [\stochastic, \deterministic]
  ),

  tempo: (
    control: \parametric,
    changes: [\continuous, \discrete, \stochastic]
  ),

  macros: (
    chaos: [0.0, 1.0], // Degree of randomness
    density: [0.0, 1.0],
    register: [20, 20000],
    timbre: \exploratory,
    spatialLocation: [\fixed, \moving, \stochastic]
  ),

  constraints: (
    // Constraints defined by the algorithmic process
    process: \primary,
    traditional rules: \optional
  ),

  processes: (
    stochastic: (
      distribution: [\uniform, \gaussian, \exponential, \cauchy],
      parameters: \timeVarying
    ),
    deterministic: (
      algorithms: [\cellular automata, \l-systems, \chaos],
      mappings: \parameterSpace
    ),
    hybrid: (
      control: \mixed,
      balance: \tunable
    )
  )
);
```

---

## Using Templates

### Load and Use

```supercollider
// Use template as-is
q = QProject.fromTemplate(\baroqueFugue);
q.play;

// Customize specific aspects
q = QProject.fromTemplate(\classicalSonata);
q.theory.harmony.style_(\romantic); // Mix in romantic harmony
q.theory.form.recapitulation.theme2.key_(\tonic); // Ensure theme2 in tonic
q.play;

// Mix templates
q = QProject(tempo: 120, seed: 42);
q.theory.harmony.loadFrom(QTemplate.jazz);     // Jazz harmony
q.theory.rhythm.loadFrom(QTemplate.minimalist); // Minimalist rhythm
q.theory.form.loadFrom(QTemplate.edm);         // EDM structure
q.play;

// Create custom template
QTemplate.myStyle = (
  theory: (
    harmony: QTemplate.baroque.theory.harmony,
    melody: QTemplate.jazz.theory.melody,
    rhythm: QTemplate.minimalist.theory.rhythm,
    form: QTemplate.ternary
  ),
  // ... rest of definition
);
```

---

## Template Comparison Matrix

| Feature | Baroque | Classical | Romantic | Bebop | Modal Jazz | Minimalism | EDM | Ambient | Algorithmic |
|---------|---------|-----------|----------|-------|------------|------------|-----|---------|-------------|
| **Harmony Complexity** | Medium | Medium | High | Very High | Low-Med | Low | Low | Low | Variable |
| **Voice Independence** | High | Low-Med | Medium | High | High | Low | Low | Low | Variable |
| **Rhythmic Complexity** | Medium | Low-Med | High | Very High | Medium | High (Process) | Low | Very Low | Variable |
| **Formal Strictness** | High | High | Medium | Medium | Low | Medium | High | Very Low | Variable |
| **Tempo Stability** | High | High | Low | High | Medium | Very High | Very High | N/A | Variable |
| **Improvisation** | Low | Very Low | Low | Very High | Very High | None | Low | Medium | Variable |
| **Timbre Importance** | Low | Low | Medium | Low | Medium | Medium | Very High | Very High | Very High |
| **Typical Duration** | 5-10min | 15-30min | 3-8min | 3-5min | 8-15min | 15-60min | 4-7min | 20-60min | Variable |

---

## Next Steps

1. **Implement core templates** (Baroque, Classical, EDM, Ambient) in Phase 2
2. **Create template editor GUI** in Phase 9
3. **Build example library** with one piece per template in Phase 11
4. **Community templates** - users can share custom templates post-release

---

**Template Philosophy**: Templates are **training wheels**, not **rails**. They help you start quickly but never prevent you from going your own way.
