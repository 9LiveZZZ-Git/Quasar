# Quasar: Professional Mixing & Mastering Framework

## QMix - Intelligent Automatic Mixing System

---

## Overview

**QMix** is a comprehensive, content-aware automatic mixing and mastering framework integrated into Quasar. It provides professional-quality mix automation while remaining **transparent, deterministic, and overridable**.

### Design Philosophy

1. **Content-Aware**: Analyzes audio content (spectral, dynamic, spatial) to make intelligent decisions
2. **Deterministic**: Same input + same seed = same mix (critical for reproducibility)
3. **Transparent**: All decisions logged and inspectable
4. **Overridable**: User can override any automated decision
5. **Non-Creative**: Serves the composition, doesn't replace musical decisions
6. **Genre-Aware**: Uses template-based defaults but adapts to content

---

## Architecture

```
QMixEngine
├── QGainStaging       - Automatic gain staging and leveling
├── QSpatialMix        - Stereo field, panning, width management
├── QDynamicsChain     - Compression, limiting, gating
├── QEQEngine          - Content-aware EQ and spectral shaping
├── QEffectsChain      - Reverb, delay, modulation, saturation
├── QAutomation        - Musical automation curves
├── QMastering         - Final mastering chain
├── QMetering          - Real-time and offline analysis
└── QMixSession        - Mix state management and recall
```

---

## Module 1: QGainStaging

**Purpose**: Automatic gain staging, headroom management, and level optimization.

### Features

#### 1.1 Input Gain Analysis
```supercollider
QGainStaging {
  var <project;
  var <targetHeadroom = -6; // dB below 0dBFS
  var <referenceLevel = -18; // LUFS integrated
  var <peakCeiling = -1; // dBTP (true peak)

  // Per-layer analysis
  analyzeLayer { |layer|
    var analysis = (
      peakLevel: this.findPeak(layer),
      rmsLevel: this.computeRMS(layer),
      crestFactor: this.computeCrestFactor(layer),
      lufs: this.computeLUFS(layer),
      truePeak: this.computeTruePeak(layer),
      dynamicRange: this.computeDynamicRange(layer)
    );
    ^analysis;
  }

  // Automatic gain adjustment
  autoGain { |layer, target=\balanced|
    var analysis = this.analyzeLayer(layer);
    var gain = case
    { target == \balanced } {
      // Balance to reference level
      referenceLevel - analysis.lufs;
    }
    { target == \peak } {
      // Optimize for peak headroom
      (peakCeiling - targetHeadroom) - analysis.peakLevel;
    }
    { target == \layer } {
      // Layer-relative gain (bass louder, highs softer)
      this.layerTargetGain(layer) - analysis.lufs;
    };
    ^gain;
  }

  // Layer-specific target levels (genre-aware)
  layerTargetGain { |layer|
    var layerName = layer.name;
    var template = project.template;

    ^case
    { layerName == \kick } { -12 } // Kick loudest
    { layerName == \bass } { -15 }
    { layerName == \snare } { -16 }
    { layerName == \lead } { -18 }
    { layerName == \pad } { -22 }
    { layerName == \fx } { -26 }
    { -18 }; // Default
  }
}
```

#### 1.2 Headroom Management
- **Dynamic headroom allocation**: Reserves headroom based on section dynamics
- **Intelligent clipping prevention**: Predicts and prevents digital clipping
- **Gain riding**: Subtle automation to maintain consistent levels

#### 1.3 Layer Balance
```supercollider
// Automatic layer balancing
balanceLayers { |layers, style=\mix|
  var balances = case
  { style == \mix } {
    // Standard mix pyramid (bass louder, highs softer)
    (
      kick: 0,      // Reference (loudest)
      bass: -3,
      snare: -4,
      lead: -6,
      harmony: -8,
      pad: -10,
      fx: -14
    )
  }
  { style == \master } {
    // Pre-master balance (more compressed)
    (
      kick: 0,
      bass: -2,
      snare: -2,
      lead: -4,
      harmony: -5,
      pad: -7,
      fx: -10
    )
  }
  { style == \stems } {
    // Stem export balance (less processed)
    (
      kick: 0,
      bass: -1,
      snare: -2,
      lead: -3,
      harmony: -4,
      pad: -5,
      fx: -8
    )
  };

  layers.do { |layer|
    var target = balances[layer.name] ? -6;
    layer.set(\amp, target.dbamp);
  };
}
```

---

## Module 2: QSpatialMix

**Purpose**: Stereo field management, panning, width, and spatial positioning.

### Features

#### 2.1 Intelligent Panning
```supercollider
QSpatialMix {
  var <project;
  var <spatialMap; // Frequency → pan mapping

  // Content-aware autopan
  autoPan { |layer, strategy=\spectral|
    case
    { strategy == \spectral } {
      // Pan based on spectral centroid
      var centroid = this.analyzeCentroid(layer);
      var pan = centroid.linlin(200, 8000, -0.3, 0.3); // Subtle
      layer.set(\pan, pan);
    }
    { strategy == \layerRole } {
      // Pan based on layer role
      var panMap = (
        kick: 0,       // Center
        bass: 0,       // Center
        snare: 0,      // Center
        lead: 0.2,     // Slight right (convention)
        harmony: -0.3, // Left
        pad: 0,        // Center (will be widened)
        fx: 0          // Center (will be widened)
      );
      layer.set(\pan, panMap[layer.name] ? 0);
    }
    { strategy == \LCR } {
      // L-C-R mixing (classic)
      var lcr = [-1, 0, 1].choose;
      layer.set(\pan, lcr);
    }
    { strategy == \spread } {
      // Spread voices across stereo field
      var voices = layer.voices ? 1;
      var pans = Array.interpolation(voices, -0.7, 0.7);
      pans;
    };
  }

  // Stereo width control
  width { |layer, amount=0.5|
    // 0 = mono, 1 = full width, >1 = hyper-wide
    // Uses mid-side processing
    layer.set(\width, amount);
  }

  // Frequency-dependent width (Haas effect, MS EQ)
  frequencyWidth { |layer|
    // Low frequencies narrow (mono bass)
    // High frequencies wide (spacious highs)
    var widthCurve = Env([0.0, 0.3, 1.0], [200, 2000], \exp);
    layer.set(\widthCurve, widthCurve);
  }

  // Spatial separation (prevent masking)
  separateLayers { |layers|
    // Analyze spectral overlap
    var overlaps = this.computeSpectralOverlap(layers);

    // Pan conflicting layers apart
    overlaps.do { |conflict|
      var layer1 = conflict.layer1;
      var layer2 = conflict.layer2;
      layer1.set(\pan, -0.4);
      layer2.set(\pan, 0.4);
    };
  }
}
```

#### 2.2 Haas Effect & Delays
```supercollider
// Subtle stereo widening via Haas effect
haasWidening { |layer, delayMs=15, mix=0.3|
  // Delay one channel slightly (5-35ms)
  // Creates width without phase issues
  layer.addFX(\haas, (
    delayTime: delayMs * 0.001,
    mix: mix
  ));
}
```

#### 2.3 Mid-Side Processing
```supercollider
// M/S encoding for independent mid/side processing
msProcess { |layer, midGain=0, sideGain=0, midEQ, sideEQ|
  // Encode to M/S
  // Process independently
  // Decode back to L/R
  layer.addFX(\msProcessor, (
    midGain: midGain.dbamp,
    sideGain: sideGain.dbamp,
    midEQ: midEQ,
    sideEQ: sideEQ
  ));
}
```

---

## Module 3: QDynamicsChain

**Purpose**: Compression, limiting, gating, transient shaping.

### Features

#### 3.1 Content-Aware Compression
```supercollider
QDynamicsChain {
  var <project;

  // Analyze and apply appropriate compression
  autoCompress { |layer, style=\transparent|
    var analysis = (
      dynamicRange: this.computeDynamicRange(layer),
      transientRatio: this.computeTransientRatio(layer),
      sustainRatio: 1 - this.computeTransientRatio(layer),
      rms: this.computeRMS(layer)
    );

    var settings = case
    { style == \transparent } {
      // Gentle compression for glue
      (
        threshold: -24,
        ratio: 2,
        attack: 30,
        release: 100,
        knee: 6,
        makeupGain: \auto
      )
    }
    { style == \punch } {
      // Fast attack for transients
      (
        threshold: -18,
        ratio: 4,
        attack: 1,
        release: 50,
        knee: 3,
        makeupGain: \auto
      )
    }
    { style == \glue } {
      // Slow attack, medium release
      (
        threshold: -20,
        ratio: 3,
        attack: 50,
        release: 200,
        knee: 6,
        makeupGain: \auto
      )
    }
    { style == \smash } {
      // Heavy compression (EDM, rock)
      (
        threshold: -12,
        ratio: 8,
        attack: 5,
        release: 100,
        knee: 1,
        makeupGain: \auto
      )
    };

    // Adjust based on content analysis
    if (analysis.transientRatio > 0.7) {
      settings.attack = settings.attack * 0.5; // Faster for transient material
    };

    layer.addFX(\compressor, settings);
  }

  // Multiband compression
  multibandCompress { |layer, bands=3|
    var crossovers = case
    { bands == 2 } { [800] }
    { bands == 3 } { [200, 2000] }
    { bands == 4 } { [100, 500, 3000] };

    layer.addFX(\multibandComp, (
      crossovers: crossovers,
      ratios: [3, 4, 3], // Mid compressed more
      thresholds: [-18, -15, -20],
      attacks: [10, 5, 3],
      releases: [100, 50, 80]
    ));
  }

  // Sidechain compression
  sidechainCompress { |target, trigger, amount=0.5|
    // Classic EDM pumping
    target.addFX(\sidechainComp, (
      trigger: trigger, // Usually kick
      threshold: -20,
      ratio: 8,
      attack: 1,
      release: 150,
      mix: amount
    ));
  }
}
```

#### 3.2 Limiting
```supercollider
// Intelligent limiting (prevent clipping, add loudness)
limit { |layer, ceiling=-0.3, style=\transparent|
  var settings = case
  { style == \transparent } {
    (
      ceiling: ceiling,
      release: 50,
      lookahead: 5,
      oversampling: 4
    )
  }
  { style == \loud } {
    (
      ceiling: -0.1,
      release: 30,
      lookahead: 10,
      oversampling: 8,
      saturation: 0.2 // Add warmth
    )
  };

  layer.addFX(\limiter, settings);
}
```

#### 3.3 Gating & Transient Shaping
```supercollider
// Noise gate
gate { |layer, threshold=-40, attack=1, release=50|
  layer.addFX(\gate, (
    threshold: threshold,
    attack: attack,
    release: release,
    hysteresis: 6 // Prevent chattering
  ));
}

// Transient shaper (enhance/reduce attack/sustain)
shapeTransients { |layer, attack=1.0, sustain=1.0|
  // attack > 1 = more punch
  // sustain > 1 = more body
  layer.addFX(\transientShaper, (
    attack: attack,
    sustain: sustain
  ));
}
```

---

## Module 4: QEQEngine

**Purpose**: Content-aware EQ, spectral shaping, masking prevention.

### Features

#### 4.1 Automatic EQ
```supercollider
QEQEngine {
  var <project;

  // Content-aware EQ
  autoEQ { |layer, target=\balanced|
    var spectrum = this.analyzeSpectrum(layer);
    var eqCurve = this.generateEQCurve(spectrum, target);
    layer.addFX(\eq, eqCurve);
  }

  // Generate EQ curve based on content
  generateEQCurve { |spectrum, target|
    case
    { target == \balanced } {
      // Flatten spectrum to target curve
      var targetCurve = this.targetCurve(\neutral);
      var correction = targetCurve - spectrum;
      correction.clip(-12, 12); // Limit boost/cut
    }
    { target == \bright } {
      // High shelf boost
      [\highShelf, 8000, 3, 0.7]
    }
    { target == \warm } {
      // Low shelf boost, high shelf cut
      [
        [\lowShelf, 200, 2, 0.7],
        [\highShelf, 8000, -2, 0.7]
      ]
    }
    { target == \clear } {
      // Cut mud, boost presence
      [
        [\bell, 300, -3, 1.5],  // Cut mud
        [\bell, 3000, 3, 1.0]   // Boost presence
      ]
    };
  }

  // Surgical EQ (remove resonances, notch filtering)
  surgicalEQ { |layer|
    var resonances = this.detectResonances(layer);
    resonances.do { |freq, i|
      layer.addEQBand(\notch, freq, -6, 3.0); // Narrow Q
    };
  }

  // Dynamic EQ (EQ with compression)
  dynamicEQ { |layer, freq, threshold, ratio|
    layer.addFX(\dynamicEQ, (
      frequency: freq,
      threshold: threshold,
      ratio: ratio,
      attack: 10,
      release: 50
    ));
  }
}
```

#### 4.2 Spectral Masking Prevention
```supercollider
// Detect and resolve spectral masking
preventMasking { |layers|
  var conflicts = this.detectMasking(layers);

  conflicts.do { |conflict|
    var masker = conflict.masker;     // Louder layer
    var masked = conflict.masked;     // Quieter layer
    var freqRange = conflict.freqRange;

    // Solution 1: Duck masker at conflict frequency
    masker.addEQBand(\bell, freqRange.center, -3, 1.5);

    // Solution 2: Boost masked at conflict frequency
    masked.addEQBand(\bell, freqRange.center, 3, 1.5);

    // Solution 3: Pan apart
    masker.set(\pan, -0.3);
    masked.set(\pan, 0.3);
  };
}

// Spectral conflict detection
detectMasking { |layers|
  var conflicts = [];
  layers.do { |layer1, i|
    layers[(i+1)..].do { |layer2|
      var overlap = this.computeSpectralOverlap(layer1, layer2);
      if (overlap.severity > 0.6) {
        conflicts = conflicts.add((
          masker: overlap.louder,
          masked: overlap.quieter,
          freqRange: overlap.freqRange,
          severity: overlap.severity
        ));
      };
    };
  };
  ^conflicts;
}
```

---

## Module 5: QEffectsChain

**Purpose**: Reverb, delay, modulation, saturation, creative FX.

### Features

#### 5.1 Reverb Engine
```supercollider
QEffectsChain {
  var <project;

  // Content-aware reverb
  autoReverb { |layer, space=\medium|
    var settings = case
    { space == \small } {
      (size: 0.3, predelay: 10, damping: 0.7, mix: 0.15)
    }
    { space == \medium } {
      (size: 0.6, predelay: 20, damping: 0.5, mix: 0.25)
    }
    { space == \large } {
      (size: 0.9, predelay: 40, damping: 0.3, mix: 0.35)
    }
    { space == \plate } {
      (size: 0.5, predelay: 5, damping: 0.2, mix: 0.20, type: \plate)
    }
    { space == \spring } {
      (size: 0.4, predelay: 0, damping: 0.1, mix: 0.30, type: \spring)
    };

    // Adjust based on layer role
    if (layer.name == \bass) {
      settings.mix = settings.mix * 0.3; // Less reverb on bass
    };

    layer.addFX(\reverb, settings);
  }

  // Frequency-dependent reverb decay
  spectralReverb { |layer|
    // High frequencies decay faster (realistic)
    layer.addFX(\spectralReverb, (
      lowDecay: 3.0,
      midDecay: 2.0,
      highDecay: 1.0,
      crossovers: [200, 2000]
    ));
  }
}
```

#### 5.2 Delay
```supercollider
// Automatic delay (tempo-synced)
autoDelay { |layer, sync=true|
  var delayTime = if (sync) {
    // Sync to tempo (quarter note, eighth, etc.)
    (60 / project.tempo) * [0.25, 0.5, 1.0].choose;
  } {
    rrand(0.1, 0.5);
  };

  layer.addFX(\delay, (
    delayTime: delayTime,
    feedback: 0.4,
    mix: 0.2,
    filter: \lowpass, // High-cut on feedback
    filterFreq: 4000
  ));
}
```

#### 5.3 Modulation Effects
```supercollider
// Chorus/Flanger/Phaser
modulate { |layer, type=\chorus|
  case
  { type == \chorus } {
    layer.addFX(\chorus, (
      rate: 0.5,
      depth: 0.02,
      voices: 3,
      mix: 0.3
    ));
  }
  { type == \flanger } {
    layer.addFX(\flanger, (
      rate: 0.2,
      depth: 0.005,
      feedback: 0.6,
      mix: 0.4
    ));
  }
  { type == \phaser } {
    layer.addFX(\phaser, (
      rate: 0.3,
      stages: 6,
      feedback: 0.5,
      mix: 0.3
    ));
  };
}
```

#### 5.4 Saturation & Warmth
```supercollider
// Harmonic saturation (analog warmth)
saturate { |layer, amount=0.3, type=\tape|
  case
  { type == \tape } {
    layer.addFX(\tapeSaturation, (
      drive: amount,
      bias: 0.1,
      wow: 0.02,
      flutter: 0.01
    ));
  }
  { type == \tube } {
    layer.addFX(\tubeSaturation, (
      drive: amount,
      asymmetry: 0.3,
      tone: 0.5
    ));
  }
  { type == \digital } {
    layer.addFX(\bitCrush, (
      bits: 12 - (amount * 6), // 12-bit to 6-bit
      sampleRate: 44100 - (amount * 20000)
    ));
  };
}
```

---

## Module 6: QAutomation

**Purpose**: Musical automation curves for mix parameters.

### Features

#### 6.1 Content-Aware Automation
```supercollider
QAutomation {
  var <project;
  var <automationLanes; // Dict of parameter → automation curve

  // Generate filter sweep automation
  filterSweep { |layer, start, end, duration, curve=\exp|
    var sweep = Env([start, end], [duration], curve);
    layer.automate(\cutoff, sweep);
  }

  // Volume automation (rides, fades)
  volumeRide { |layer, curve, duration|
    // Curve can be: \fadeIn, \fadeOut, \swell, \dip
    var env = case
    { curve == \fadeIn } {
      Env([0, 1], [duration], \sin);
    }
    { curve == \fadeOut } {
      Env([1, 0], [duration], \sin);
    }
    { curve == \swell } {
      Env([0.3, 1.0, 0.3], [duration*0.5, duration*0.5], \sin);
    }
    { curve == \dip } {
      Env([1.0, 0.3, 1.0], [duration*0.5, duration*0.5], \sin);
    };

    layer.automate(\amp, env);
  }

  // Rhythmic automation (pumping, ducking)
  rhythmicAutomation { |layer, param, pattern, depth=0.5|
    // Automate parameter in rhythm with the music
    // E.g., filter cutoff pulses on the beat
    var rhythm = pattern.asTempoClock(project.tempo);
    layer.automate(param, rhythm, depth: depth);
  }

  // Macro automation (one control → many parameters)
  automat eMacro { |macro, curve|
    // E.g., "energy" macro rises over 8 bars
    var env = Env([0.2, 0.9], [8 * project.beatsPerBar], \exp);
    project.scene.automateMacro(macro, env);
  }
}
```

---

## Module 7: QMastering

**Purpose**: Final mastering chain for commercial-quality output.

### Features

#### 7.1 Mastering Chain
```supercollider
QMastering {
  var <project;

  // Full mastering chain
  master { |targetLUFS=-14, ceiling=-0.3, style=\streaming|
    var chain = [];

    // 1. Surgical EQ (fix problems)
    chain = chain.add(this.surgicalMasterEQ);

    // 2. Multiband compression (control dynamics per band)
    chain = chain.add(this.masterbandComp(style));

    // 3. Harmonic exciter (add warmth/brightness)
    chain = chain.add(this.harmonicExciter);

    // 4. Stereo enhancer (widen or focus)
    chain = chain.add(this.stereoEnhancer(style));

    // 5. Final EQ (tonal balance)
    chain = chain.add(this.finalMasterEQ(style));

    // 6. Limiter (loudness + ceiling)
    chain = chain.add(this.masterLimiter(targetLUFS, ceiling));

    // 7. Dithering (if rendering to 16-bit)
    chain = chain.add(this.dither);

    ^chain;
  }

  // Multiband mastering compression
  multibandComp { |style|
    var settings = case
    { style == \streaming } {
      // Louder for streaming (Spotify, Apple Music)
      (
        crossovers: [100, 500, 3000],
        ratios: [3, 4, 4, 3],
        thresholds: [-24, -20, -18, -22],
        attacks: [30, 10, 5, 3],
        releases: [200, 100, 50, 80]
      )
    }
    { style == \vinyl } {
      // Less compression, more dynamics
      (
        crossovers: [100, 2000],
        ratios: [2, 3, 2],
        thresholds: [-30, -24, -28],
        attacks: [50, 20, 10],
        releases: [300, 150, 100]
      )
    }
    { style == \broadcast } {
      // Heavy limiting for broadcast
      (
        crossovers: [100, 500, 3000],
        ratios: [6, 8, 6, 4],
        thresholds: [-18, -15, -15, -20],
        attacks: [10, 5, 3, 5],
        releases: [100, 50, 40, 60]
      )
    };

    ^QFX.multibandComp(settings);
  }

  // Master limiter with loudness targeting
  masterLimiter { |targetLUFS, ceiling|
    // Analyze current LUFS
    var currentLUFS = this.measureLUFS(project.masterBus);
    var makeupGain = targetLUFS - currentLUFS;

    ^QFX.limiter((
      ceiling: ceiling,
      makeupGain: makeupGain,
      release: 50,
      lookahead: 10,
      oversampling: 8,
      truePeak: true // Prevent inter-sample peaks
    ));
  }

  // Harmonic exciter (subtle saturation)
  harmonicExciter {
    ^QFX.harmonicExciter((
      drive: 0.2,
      harmonics: [2, 3, 4], // 2nd, 3rd, 4th harmonics
      mix: 0.15
    ));
  }

  // Stereo enhancement
  stereoEnhancer { |style|
    case
    { style == \wide } {
      ^QFX.stereoEnhancer((width: 1.2, lowBypass: 120)); // Wider, mono bass
    }
    { style == \focused } {
      ^QFX.stereoEnhancer((width: 0.8)); // Narrower
    }
    { style == \mono } {
      ^QFX.stereoEnhancer((width: 0.0)); // Full mono
    };
  }
}
```

#### 7.2 Loudness Standards
```supercollider
// Match loudness to target platform
matchLoudness { |platform|
  var targets = (
    spotify: -14, // LUFS integrated
    appleMusic: -16,
    youtube: -13,
    soundcloud: -10, // Louder
    vinyl: -18,      // More dynamic
    broadcast: -23,  // EBU R128
    film: -27        // Very dynamic
  );

  var target = targets[platform] ? -14;
  this.master(targetLUFS: target);
}
```

---

## Module 8: QMetering

**Purpose**: Real-time and offline audio analysis.

### Features

```supercollider
QMetering {
  var <project;

  // Comprehensive metering
  meter { |layer|
    ^(
      peak: this.peakMeter(layer),
      rms: this.rmsMeter(layer),
      lufs: this.lufsMeter(layer),
      truePeak: this.truePeakMeter(layer),
      spectrum: this.spectrumAnalyzer(layer),
      phase: this.phaseCorrelation(layer),
      dynamicRange: this.dynamicRangeMeter(layer)
    );
  }

  // LUFS metering (EBU R128 compliant)
  lufsMeter { |layer|
    // Integrated, short-term, momentary
    ^(
      integrated: this.computeLUFS(layer, window: \integrated),
      shortTerm: this.computeLUFS(layer, window: 3.0), // 3 second window
      momentary: this.computeLUFS(layer, window: 0.4)  // 400ms window
    );
  }

  // Spectrum analyzer
  spectrumAnalyzer { |layer, bands=31|
    // 1/3 octave or FFT
    ^this.computeSpectrum(layer, bands);
  }

  // Phase correlation meter (mono compatibility)
  phaseCorrelation { |layer|
    // Returns -1 (opposite phase) to +1 (in phase)
    ^this.computePhaseCorrelation(layer);
  }

  // Dynamic range meter
  dynamicRangeMeter { |layer|
    // PLR (Peak to Loudness Ratio) or DR meter
    var peak = this.findPeak(layer);
    var lufs = this.computeLUFS(layer);
    ^peak - lufs; // Dynamic range in dB
  }
}
```

---

## Module 9: QMixSession

**Purpose**: Mix state management, recall, A/B comparison.

### Features

```supercollider
QMixSession {
  var <project;
  var <sessions; // Array of saved mix states

  // Save current mix state
  save { |name|
    var state = (
      name: name,
      timestamp: Date.localtime,
      layers: project.scene.layers.collect { |layer|
        layer.getState; // Gain, pan, FX, automation
      },
      masterChain: project.masterChain.getState,
      metadata: (
        lufs: this.measureLUFS,
        peak: this.measurePeak,
        notes: ""
      )
    );
    sessions = sessions.add(state);
    ^state;
  }

  // Recall mix state
  recall { |name|
    var state = sessions.detect { |s| s.name == name };
    if (state.notNil) {
      state.layers.do { |layerState, i|
        project.scene.layers[i].setState(layerState);
      };
      project.masterChain.setState(state.masterChain);
    };
  }

  // A/B comparison
  compare { |nameA, nameB|
    // Load A, play 8 bars, load B, play 8 bars, repeat
    fork {
      loop {
        this.recall(nameA);
        8.wait;
        this.recall(nameB);
        8.wait;
      };
    };
  }

  // Export mix settings as JSON
  export { |path|
    var data = sessions.collect { |s| s.asData };
    data.writeJSON(path);
  }
}
```

---

## Integration with Quasar

### Automatic Mix Workflow

```supercollider
// Example: Automatic mix of an EDM track
(
q = QProject.fromTemplate(\edm);
q.tempo = 128;

// Load samples
q.palette.loadUnits("~/Samples/EDM");

// Compose track (Quasar handles this)
q.theory.form.generate;
q.timeline.populate;

// === AUTOMATIC MIXING ===
var mix = QMixEngine(q);

// 1. Gain staging
mix.gainStaging.balanceLayers(q.scene.layers, style: \mix);

// 2. Spatial mixing
q.scene.layers.do { |layer|
  mix.spatial.autoPan(layer, strategy: \layerRole);
  mix.spatial.width(layer, amount: 0.6);
};

// 3. Dynamics
mix.dynamics.autoCompress(q.scene[\bass], style: \glue);
mix.dynamics.autoCompress(q.scene[\lead], style: \transparent);
mix.dynamics.sidechainCompress(q.scene[\bass], q.scene[\kick], amount: 0.7);

// 4. EQ
mix.eq.autoEQ(q.scene[\bass], target: \clear);
mix.eq.preventMasking([q.scene[\bass], q.scene[\kick]]);

// 5. Effects
mix.effects.autoReverb(q.scene[\lead], space: \medium);
mix.effects.autoDelay(q.scene[\lead], sync: true);

// 6. Mastering
mix.mastering.master(targetLUFS: -14, ceiling: -0.3, style: \streaming);

// 7. Save mix session
mix.session.save(\version1);

// === RENDER ===
q.render("~/my_track_mixed.wav", stems: false);
)
```

---

## Genre-Specific Mix Templates

### EDM Mix Template
```supercollider
QMixTemplate.edm = (
  gainStaging: (
    kick: 0, bass: -3, lead: -6, pad: -10
  ),
  spatial: (
    kick: (pan: 0, width: 0),
    bass: (pan: 0, width: 0.2),
    lead: (pan: 0.2, width: 0.7),
    pad: (pan: 0, width: 1.0)
  ),
  dynamics: (
    kick: (comp: \none),
    bass: (comp: \glue, sidechain: \kick),
    lead: (comp: \transparent),
    master: (comp: \heavy, limit: -0.1)
  ),
  effects: (
    lead: (reverb: \medium, delay: \quarter),
    pad: (reverb: \large, chorus: true)
  ),
  mastering: (
    targetLUFS: -9, // Loud!
    style: \streaming
  )
);
```

### Classical Mix Template
```supercollider
QMixTemplate.classical = (
  gainStaging: (
    balance: \orchestral // Natural balance
  ),
  spatial: (
    strategy: \orchestralSpread, // Mimic concert hall positions
    width: 0.8
  ),
  dynamics: (
    comp: \minimal, // Preserve dynamics!
    limit: \transparent
  ),
  effects: (
    reverb: \concertHall,
    delay: \none
  ),
  mastering: (
    targetLUFS: -18, // Dynamic
    style: \classical
  )
);
```

---

## Deterministic Mixing

All mix decisions are **seeded and reproducible**:

```supercollider
q.mixSeed = 42;
mix = QMixEngine(q);
mix.autoMix; // Same seed = same mix decisions

// Log all decisions
mix.log;
/*
[QMix] Gain: kick = 0.0 dB
[QMix] Gain: bass = -3.2 dB (auto-balanced)
[QMix] Pan: lead = 0.18 (spectral autopan)
[QMix] Comp: bass = threshold -20dB, ratio 3:1 (content-aware)
[QMix] EQ: bass = cut 300Hz -3dB (masking prevention vs kick)
...
*/
```

---

## Next: Implementation Plan

See updated **IMPLEMENTATION_TRACKER.md** for integration of QMix into the development phases.

**Estimated additional LOC**: ~3,500 (QMix framework)
**New phases**: 2 phases (Mixing + Mastering)
**Timeline addition**: +4-5 weeks

---

**QMix: Professional mixes, automatically. Transparent, deterministic, overridable.**
