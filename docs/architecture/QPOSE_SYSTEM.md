# QPose: Musical Pose & Micro-Gesture System

## Overview

**QPose** handles the micro-compositional layer—small musical embellishments, accents, and timing offsets that bring compositions to life. These are the subtle details that grab listeners' attention, create groove, and add professional polish.

### What is a "Pose"?

A **pose** is a micro-compositional gesture that:
- Lasts from a few milliseconds to 1-2 beats
- Accentuates, punctuates, or embellishes the main composition
- Creates tension, release, or surprise
- Adds humanization and groove

**Examples**:
- Woosh/riser before a kick
- Sub drop on the "and" of beat 4
- Snare roll into a section change
- Micro-timing offsets for groove
- Ghost notes and grace notes
- Impact sounds on downbeats
- Filter sweeps and stutters

---

## Architecture

```
QPose (Base Class)
├── QAccent         - Emphasis on specific beats
├── QTransitionPose - Gestures between sections
├── QGroovePose     - Microtiming and humanization
├── QImpactPose     - Attention-grabbing hits
├── QFillPose       - Fills and rolls
├── QGhostPose      - Subtle ghost notes
└── QEffectPose     - Sound design poses (sweeps, glitches)
```

---

## QPose Base Class

```supercollider
QPose {
  var <name;
  var <duration;      // Duration in beats
  var <timing;        // Placement: \before, \on, \after, \between
  var <target;        // What beat/event to attach to
  var <layer;         // Which layer to affect
  var <parameters;    // Pose-specific params

  *new { |name, duration=0.25|
    ^super.newCopyArgs(name, duration).init;
  }

  init {
    timing = \on;
    parameters = ();
  }

  // Generate events for this pose
  asPattern { }

  // Generate control curve for this pose
  asEnvelope { }

  // Attach pose to a beat
  attachTo { |beat, timing=\on|
    target = beat;
    this.timing = timing;
  }

  asData {
    ^(
      type: this.class.name,
      name: name,
      duration: duration,
      timing: timing,
      target: target,
      parameters: parameters
    )
  }
}
```

---

## 1. QAccent - Beat Accentuation

**Purpose**: Emphasize specific beats with volume, filter, or timbral changes.

### Features

```supercollider
QAccent : QPose {
  var <accentType;   // \volume, \filter, \pitch, \timbre
  var <intensity;    // 0..1
  var <curve;        // Accent shape

  *new { |type=\volume, intensity=0.5|
    ^super.new(\accent).initAccent(type, intensity);
  }

  initAccent { |type, intens|
    accentType = type;
    intensity = intens;
    duration = 0.05; // Short accent
  }

  asPattern {
    case
    { accentType == \volume } {
      // Sudden volume increase
      ^Pbind(
        \amp, Penv(
          Env([1, 1 + intensity, 1], [0.01, duration - 0.01], \lin),
          timeScale: duration
        )
      )
    }
    { accentType == \filter } {
      // Filter sweep accent
      ^Pbind(
        \cutoff, Penv(
          Env([1000, 8000, 1000], [0.02, duration - 0.02], \exp),
          timeScale: duration
        )
      )
    }
    { accentType == \pitch } {
      // Pitch bend accent
      ^Pbind(
        \detune, Penv(
          Env([0, intensity * 100, 0], [0.01, duration - 0.01], \sin),
          timeScale: duration
        )
      )
    };
  }

  // Common accent types
  *downbeatAccent { |intensity=0.7|
    ^QAccent(\volume, intensity).timing_(\on);
  }

  *offbeatAccent { |intensity=0.4|
    ^QAccent(\filter, intensity).timing_(\between);
  }

  *ghostAccent { |intensity=0.2|
    // Very subtle accent (ghost note)
    ^QAccent(\volume, intensity).timing_(\before);
  }
}
```

---

## 2. QTransitionPose - Section Transitions

**Purpose**: Musical gestures that lead into or out of sections.

### Features

```supercollider
QTransitionPose : QPose {
  var <poseType; // \riser, \drop, \tapeStop, \reverse, \stutter, \impact

  *wooshUp { |duration=1|
    // Classic woosh/riser before a drop
    ^QTransitionPose.new(\wooshUp, duration).initWoosh;
  }

  initWoosh {
    poseType = \wooshUp;
    parameters = (
      startFreq: 200,
      endFreq: 8000,
      startAmp: 0.1,
      endAmp: 0.9,
      noise: true,
      filterResonance: 4
    );
  }

  asPattern {
    case
    { poseType == \wooshUp } {
      ^Pbind(
        \instrument, \noiseWoosh,
        \freq, Penv(
          Env([parameters.startFreq, parameters.endFreq],
              [duration], \exp)
        ),
        \amp, Penv(
          Env([parameters.startAmp, parameters.endAmp],
              [duration], \exp)
        ),
        \resonance, parameters.filterResonance,
        \dur, duration
      )
    }
    { poseType == \subDrop } {
      ^Pbind(
        \instrument, \subDrop,
        \freq, Penv(
          Env([80, 40], [duration], \exp)
        ),
        \amp, Penv(
          Env([0, 1], [duration * 0.1, duration * 0.9], [\exp, \lin])
        ),
        \dur, duration
      )
    }
    { poseType == \tapeStop } {
      ^Pbind(
        \rate, Penv(
          Env([1, 0.1], [duration], -8) // Severe slowdown
        ),
        \dur, duration
      )
    }
    { poseType == \reverse } {
      // Play last bar reversed
      ^Pbind(
        \rate, -1, // Reverse
        \dur, duration
      )
    };
  }

  // Common transition types
  *riser { |duration=2, startPitch=100, endPitch=8000|
    ^QTransitionPose(\riser, duration).init((
      type: \riser,
      startPitch: startPitch,
      endPitch: endPitch,
      noise: true
    ));
  }

  *subDrop { |duration=0.5|
    // Heavy sub drop
    ^QTransitionPose(\subDrop, duration).init((
      startFreq: 80,
      endFreq: 35,
      attack: 0.01,
      decay: duration
    ));
  }

  *impactHit {
    // Short impact sound (whip, clap, noise burst)
    ^QTransitionPose(\impact, 0.05).init((
      layers: [\kick, \snare, \noise],
      stack: true // All layers hit together
    ));
  }

  *tapeStop { |duration=1|
    ^QTransitionPose(\tapeStop, duration);
  }

  *reverseFill { |duration=1|
    // Reverse cymbal or fill
    ^QTransitionPose(\reverse, duration);
  }

  *stutter { |division=16, repeats=8|
    // Stutter effect (repeat tiny slices)
    ^QTransitionPose(\stutter, repeats / division).init((
      sliceLength: 1 / division,
      repeats: repeats
    ));
  }
}
```

---

## 3. QGroovePose - Microtiming & Humanization

**Purpose**: Add groove, swing, and humanization through timing offsets.

### Features

```supercollider
QGroovePose : QPose {
  var <grooveType;  // \swing, \shuffle, \microshift, \drunk
  var <amount;      // Intensity of groove

  *swing { |amount=0.66|
    // Classic swing (triplet feel)
    ^QGroovePose(\swing, amount);
  }

  *microshift { |amount=0.02|
    // Random microtiming shifts (humanization)
    ^QGroovePose(\microshift, amount);
  }

  *drunk { |amount=0.1|
    // Larger random timing variations (loose feel)
    ^QGroovePose(\drunk, amount);
  }

  applyToPattern { |pattern|
    // Modify pattern timing
    case
    { grooveType == \swing } {
      // Swing every other note
      var swingOffset = Pseq([0, amount - 0.5], inf);
      pattern.collect { |event, i|
        event.put(\timingOffset, swingOffset.next * event.dur);
        event;
      };
    }
    { grooveType == \microshift } {
      // Small random offsets
      pattern.collect { |event|
        event.put(\timingOffset, rrand(amount.neg, amount));
        event;
      };
    }
    { grooveType == \drunk } {
      // Larger random offsets with bias
      var bias = 0;
      pattern.collect { |event|
        bias = bias + rrand(amount.neg, amount);
        bias = bias.clip(amount.neg * 2, amount * 2); // Limit drift
        event.put(\timingOffset, bias);
        event;
      };
    }
    { grooveType == \push } {
      // Rush: play slightly ahead
      pattern.collect { |event|
        event.put(\timingOffset, amount.neg); // Negative = earlier
        event;
      };
    }
    { grooveType == \drag } {
      // Lay back: play slightly behind
      pattern.collect { |event|
        event.put(\timingOffset, amount); // Positive = later
        event;
      };
    };
  }

  // Preset groove templates
  *jDilla {
    // J Dilla-style off-grid feel
    ^QGroovePose(\microshift, 0.05).timing_(\varies);
  }

  *funk {
    // Tight on 1 and 3, laid back on 2 and 4
    ^QGroovePose(\funkGroove, 0.03);
  }

  *neosoul {
    // Drunk but musical
    ^QGroovePose(\drunk, 0.08);
  }

  *robotic {
    // Perfect quantization (removes groove)
    ^QGroovePose(\quantize, 0.0);
  }
}
```

---

## 4. QImpactPose - Attention Grabbers

**Purpose**: Sudden, attention-grabbing sonic events.

### Features

```supercollider
QImpactPose : QPose {
  var <impactType;

  *hit { |intensity=0.9|
    // Single massive hit (kick + clap + noise)
    ^QImpactPose(\hit, intensity);
  }

  *riserHit { |riserDuration=0.5, intensity=0.9|
    // Quick riser into massive hit
    ^QImpactPose(\riserHit).init((
      riserDuration: riserDuration,
      intensity: intensity
    ));
  }

  *subHit {
    // Very low frequency hit (feel in chest)
    ^QImpactPose(\subHit).init((
      freq: 40,
      decay: 0.8
    ));
  }

  *whipCrack {
    // High-frequency crack (transition punctuation)
    ^QImpactPose(\whipCrack);
  }

  *downsweep { |duration=0.3|
    // Opposite of riser (pitch falls rapidly)
    ^QImpactPose(\downsweep, duration);
  }

  asPattern {
    case
    { impactType == \hit } {
      ^Ppar([
        Pbind(\instrument, \kick, \amp, 1.0, \freq, 50, \dur, 0.1),
        Pbind(\instrument, \clap, \amp, 0.8, \dur, 0.1),
        Pbind(\instrument, \noiseBurst, \amp, 0.6, \dur, 0.05)
      ])
    }
    { impactType == \subHit } {
      ^Pbind(
        \instrument, \sub,
        \freq, parameters.freq,
        \amp, 1.0,
        \decay, parameters.decay,
        \dur, parameters.decay
      )
    };
  }
}
```

---

## 5. QFillPose - Fills and Rolls

**Purpose**: Drum fills, snare rolls, and rhythmic flourishes.

### Features

```supercollider
QFillPose : QPose {
  var <fillType;

  *snareRoll { |duration=1, density=16|
    // Classic snare roll
    ^QFillPose(\snareRoll, duration).init((
      instrument: \snare,
      hits: density,
      crescendo: true
    ));
  }

  *tomFill { |pattern|
    // Tom-tom fill (high to low or vice versa)
    ^QFillPose(\tomFill).init((
      pattern: pattern // e.g., [high, mid, low, floor]
    ));
  }

  *fillFlam {
    // Flammed fill (grace notes before main notes)
    ^QFillPose(\flam).init((
      graceDuration: 0.02,
      graceAmp: 0.4
    ));
  }

  *buildupRoll { |duration=2|
    // Intensifying roll (EDM buildup)
    ^QFillPose(\buildupRoll, duration).init((
      startDensity: 4,
      endDensity: 32,
      crescendo: true,
      filterSweep: true
    ));
  }

  asPattern {
    case
    { fillType == \snareRoll } {
      var hits = parameters.hits;
      var amps = if (parameters.crescendo) {
        Array.interpolation(hits, 0.4, 1.0);
      } {
        Array.fill(hits, 0.7);
      };

      ^Pbind(
        \instrument, parameters.instrument,
        \dur, duration / hits,
        \amp, Pseq(amps)
      )
    }
    { fillType == \buildupRoll } {
      // Accelerating roll with filter sweep
      var densityCurve = Env(
        [parameters.startDensity, parameters.endDensity],
        [duration],
        \exp
      );

      ^Pbind(
        \instrument, \snare,
        \dur, Penv(densityCurve).reciprocal, // Faster over time
        \amp, Penv(Env([0.4, 1.0], [duration], \lin)),
        \cutoff, Penv(Env([500, 8000], [duration], \exp))
      )
    };
  }
}
```

---

## 6. QGhostPose - Ghost Notes

**Purpose**: Very quiet, subtle notes that add texture and groove.

### Features

```supercollider
QGhostPose : QPose {
  var <ghostType;
  var <velocity; // Very low (0.1-0.3)

  *hiHatGhost { |pattern|
    // Ghost hi-hat pattern
    ^QGhostPose(\hiHatGhost).init((
      pattern: pattern,
      velocity: 0.15
    ));
  }

  *snareGhost {
    // Ghost snare (barely audible)
    ^QGhostPose(\snareGhost).init((
      velocity: 0.2,
      timing: \offbeat
    ));
  }

  *bassGhost {
    // Ghost bass note (subtle low-end movement)
    ^QGhostPose(\bassGhost).init((
      velocity: 0.25,
      duration: 0.05
    ));
  }

  asPattern {
    ^Pbind(
      \instrument, parameters.instrument ? \snare,
      \amp, parameters.velocity,
      \dur, parameters.duration ? 0.1,
      \filterCutoff, 2000 // Darker than main notes
    )
  }
}
```

---

## 7. QEffectPose - Sound Design Poses

**Purpose**: Creative sound design gestures (glitches, stutters, sweeps).

### Features

```supercollider
QEffectPose : QPose {
  var <effectType;

  *filterSweep { |start=100, end=10000, duration=1|
    ^QEffectPose(\filterSweep, duration).init((
      startFreq: start,
      endFreq: end,
      resonance: 4
    ));
  }

  *bitCrush { |duration=0.5|
    // Degradation effect
    ^QEffectPose(\bitCrush, duration).init((
      startBits: 16,
      endBits: 4,
      startSR: 44100,
      endSR: 8000
    ));
  }

  *stutter { |sliceLength=0.0625, repeats=8|
    // Stutter/glitch effect
    ^QEffectPose(\stutter).init((
      sliceLength: sliceLength,
      repeats: repeats
    ));
  }

  *glitch {
    // Random glitchy artifacts
    ^QEffectPose(\glitch).init((
      density: 0.7,
      types: [\stutter, \bitCrush, \reverse, \pitch]
    ));
  }

  *vinylStop { |duration=2|
    // Vinyl stop effect (pitch down + slowdown)
    ^QEffectPose(\vinylStop, duration);
  }

  asPattern {
    case
    { effectType == \filterSweep } {
      ^Pbind(
        \cutoff, Penv(
          Env([parameters.startFreq, parameters.endFreq],
              [duration], \exp)
        ),
        \resonance, parameters.resonance,
        \dur, duration
      )
    }
    { effectType == \stutter } {
      // Repeat a tiny slice multiple times
      ^Pbind(
        \bufStartPos, Pseq([0], parameters.repeats),
        \bufDur, parameters.sliceLength,
        \dur, parameters.sliceLength
      )
    };
  }
}
```

---

## Integration with Quasar

### Attaching Poses to Timeline

```supercollider
// Add poses to a section
section = QSection(\drop, 16.bars);

// Woosh up before the drop
section.addPose(
  QTransitionPose.wooshUp(duration: 1),
  timing: \before
);

// Impact hit exactly on the downbeat
section.addPose(
  QImpactPose.hit,
  beat: 0,
  timing: \on
);

// Sub drop on the "and" of beat 4 in bar 8
section.addPose(
  QTransitionPose.subDrop,
  beat: 7.5, // Bar 8, beat 4.5
  timing: \on
);

// Snare roll in last bar
section.addPose(
  QFillPose.snareRoll(duration: 1),
  beat: 15,
  timing: \on
);

// Microtiming groove on entire section
section.applyGroove(
  QGroovePose.microshift(amount: 0.03)
);
```

### Pose Library

```supercollider
QPoseLibrary {
  classvar <presets;

  *initClass {
    presets = (
      // EDM poses
      edmDrop: [
        QTransitionPose.wooshUp(2),
        QImpactPose.hit,
        QTransitionPose.subDrop(0.5)
      ],

      edmBuild: [
        QFillPose.buildupRoll(8),
        QEffectPose.filterSweep(100, 12000, 8)
      ],

      // Hip-hop poses
      hiphopFill: [
        QFillPose.snareRoll(0.5),
        QGhostPose.hiHatGhost
      ],

      jDillaGroove: QGroovePose.jDilla,

      // Trap poses
      trapRoll: QFillPose.buildupRoll(1).init((
        startDensity: 16,
        endDensity: 64 // Very fast
      )),

      trapDrop: [
        QImpactPose.hit,
        QTransitionPose.subDrop(1),
        QAccent.downbeatAccent(0.9)
      ],

      // Drum & Bass poses
      dnbFill: QFillPose(\amen).init(( // Amen break-style fill
        pattern: \classic
      )),

      // Transition poses
      impactCut: QTransitionPose.impactHit,
      tapeStop: QTransitionPose.tapeStop(1.5),
      reverseCymbal: QTransitionPose.reverseFill(1),
      riser: QTransitionPose.riser(2),
      downsweep: QImpactPose.downsweep(0.5)
    );
  }

  *get { |name| ^presets[name] }

  *edmDropSequence {
    // Complete EDM drop pose sequence
    ^[
      // 2 bars before drop
      (pose: QTransitionPose.riser(2), beat: -2, timing: \on),

      // Last bar: buildup roll
      (pose: QFillPose.buildupRoll(1), beat: -1, timing: \on),

      // Exactly on drop: impact + sub
      (pose: QImpactPose.hit, beat: 0, timing: \on),
      (pose: QTransitionPose.subDrop(0.5), beat: 0, timing: \on),

      // Accent every downbeat in drop
      (pose: QAccent.downbeatAccent(0.8), beats: [0, 4, 8, 12], timing: \on)
    ];
  }
}
```

---

## Pose Sequencer

```supercollider
QPoseSequencer {
  var <section;
  var <poses;     // Array of (pose, beat, timing)
  var <groove;    // Global groove for section

  *new { |section|
    ^super.newCopyArgs(section, [], nil);
  }

  // Add pose at specific beat
  addAt { |pose, beat, timing=\on|
    poses = poses.add((
      pose: pose,
      beat: beat,
      timing: timing
    ));
  }

  // Add pose sequence (multiple poses with timings)
  addSequence { |sequence|
    sequence.do { |item|
      this.addAt(item.pose, item.beat, item.timing);
    };
  }

  // Apply groove to entire section
  applyGroove { |groovePose|
    groove = groovePose;
  }

  // Generate final pattern with all poses
  asPattern {
    var mainPattern = section.asPattern;

    // Apply groove if set
    if (groove.notNil) {
      mainPattern = groove.applyToPattern(mainPattern);
    };

    // Layer all poses at correct times
    var posePatterns = poses.collect { |item|
      var pose = item.pose;
      var beat = item.beat;
      var pattern = pose.asPattern;

      // Offset pattern to start at correct beat
      Pfuncn({ beat.wait; pattern.play }, 1);
    };

    // Combine main pattern with all poses
    ^Ppar([mainPattern] ++ posePatterns);
  }
}
```

---

## Genre-Specific Pose Templates

### EDM Template
```supercollider
QPoseTemplate.edm = (
  buildSection: [
    (pose: QFillPose.buildupRoll(8), beat: 0),
    (pose: QEffectPose.filterSweep(100, 16000, 8), beat: 0),
    (pose: QTransitionPose.riser(2), beat: 6)
  ],

  dropSection: [
    (pose: QImpactPose.riserHit(0.5), beat: 0),
    (pose: QTransitionPose.subDrop(0.5), beat: 0),
    (pose: QAccent.downbeatAccent(0.9), beats: [0, 4, 8, 12, 16])
  ],

  breakSection: [
    (pose: QEffectPose.vinylStop(1), beat: -1)
  ]
);
```

### Hip-Hop Template
```supercollider
QPoseTemplate.hiphop = (
  groove: QGroovePose.jDilla,

  fillPositions: [3.5, 7.5, 15.5], // Standard fill positions

  fills: [
    QFillPose.snareRoll(0.5),
    QGhostPose.hiHatGhost,
    QFillPose.flam
  ]
);
```

---

## Microtiming Tables (Advanced)

```supercollider
QMicrotiming {
  classvar <tables;

  *initClass {
    tables = (
      // Classic drum machine swing
      mpc60: [ // MPC-60 swing table
        0, 0.055, 0.111, 0.139,  // 16th note offsets
        0.167, 0.222, 0.278, 0.306,
        0.333, 0.389, 0.444, 0.472,
        0.5, 0.556, 0.611, 0.639
      ],

      // J Dilla "drunken" feel
      jDilla: [
        0, 0.048, 0.112, 0.143,
        0.171, 0.231, 0.284, 0.318,
        0.337, 0.394, 0.451, 0.479,
        0.503, 0.562, 0.617, 0.648
      ],

      // Strict quantization (no humanization)
      quantized: Array.series(16, 0, 1/16),

      // Random humanization
      humanized: { Array.fill(16, { |i| (i/16) + rrand(-0.01, 0.01) }) }
    );
  }

  *apply { |pattern, table|
    var offsets = tables[table];
    pattern.collect { |event, i|
      var offset = offsets.wrapAt(i);
      event.put(\timingOffset, offset - (i / 16)); // Relative offset
      event;
    };
  }
}
```

---

## Next: Integration with Klotho

See **KLOTHO_INTEGRATION.md** for how QPose integrates with Klotho's Chronos (timing), Tonos (pitch), and Dynatos (dynamics) modules.

---

**QPose: The details that make music feel alive.**
