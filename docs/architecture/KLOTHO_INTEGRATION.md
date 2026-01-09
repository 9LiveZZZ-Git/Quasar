# Quasar ↔ Klotho Integration

## Overview

**Quasar** and **Klotho** are designed to work synergistically, combining their strengths:

- **Quasar**: High-level macro-composition, mixing/mastering, genre templates, playback engine
- **Klotho**: Low-level musical computation, advanced algorithms, Python-powered CAC toolkit

Together, they form a **complete composition ecosystem** from abstract mathematical processes to final rendered audio.

---

## Architecture Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                         User Layer                               │
│  "I want a fugue in D minor with Klotho-generated subject"      │
└───────────────────────┬─────────────────────────────────────────┘
                        │
        ┌───────────────▼────────────────┐
        │        QUASAR (SC)              │
        │  - High-level composition       │
        │  - Genre templates              │
        │  - Scene/timeline management    │
        │  - Mixing/mastering             │
        │  - Real-time playback           │
        │  - NRT rendering                │
        └───────────┬────────────────────┘
                    │  QKlotho Bridge
                    ▼
        ┌───────────────────────────────┐
        │      KLOTHO (Python)           │
        │  ┌────────────────────────┐   │
        │  │ Topos   (Topology)     │   │
        │  │ Chronos (Time)         │   │
        │  │ Tonos   (Pitch)        │   │
        │  │ Dynatos (Dynamics)     │   │
        │  │ Thetos  (Composition)  │   │
        │  │ Semeios (Notation)     │   │
        │  └────────────────────────┘   │
        └───────────┬────────────────────┘
                    │  OSC / JSON / MIDI
                    ▼
        ┌───────────────────────────────┐
        │   SuperCollider Audio Engine   │
        └────────────────────────────────┘
```

---

## Communication Layer: QKlotho Bridge

### QKlotho Class

```supercollider
QKlotho {
  classvar <pythonProcess;   // Python subprocess
  classvar <oscPort = 57120; // OSC communication port
  classvar <pythonPath;      // Path to Klotho Python

  var <project;              // QProject instance
  var <klothoModules;        // Active Klotho modules

  *initClass {
    // Find Klotho installation
    pythonPath = this.findKlotho;

    // Start Python bridge process
    pythonProcess = this.startPythonBridge;

    // Set up OSC responders
    this.setupOSC;
  }

  *findKlotho {
    var paths = [
      "/home/lpfreiburg/SC-Mod/Klotho/Klotho",
      Platform.userAppSupportDir +/+ "Klotho",
      "~/Klotho".standardizePath
    ];

    paths.do { |path|
      if (PathName(path).isFolder) {
        "Found Klotho at: %".format(path).postln;
        ^path;
      };
    };

    Error("Klotho not found! Install from: github.com/kr4g/Klotho").throw;
  }

  *startPythonBridge {
    // Start Python subprocess with Klotho bridge script
    var bridgeScript = pythonPath +/+ "sc_bridge.py";
    var cmd = "python3 % --port %".format(bridgeScript, oscPort);

    ^Pipe(cmd, "w");
  }

  *setupOSC {
    // Receive Klotho output via OSC
    OSCdef(\klothoSequence, { |msg|
      var sequence = msg[1..].asString.parseJSON;
      this.receiveSequence(sequence);
    }, '/klotho/sequence');

    OSCdef(\klothoRhythm, { |msg|
      var rhythm = msg[1..].asString.parseJSON;
      this.receiveRhythm(rhythm);
    }, '/klotho/rhythm');

    OSCdef(\klothoHarmony, { |msg|
      var harmony = msg[1..].asString.parseJSON;
      this.receiveHarmony(harmony);
    }, '/klotho/harmony');
  }

  // === Send to Klotho ===

  sendCommand { |module, method, args|
    // Send OSC to Python bridge
    var addr = NetAddr("127.0.0.1", 57121); // Python listens on 57121
    addr.sendMsg('/klotho/command', module, method, args.asJSON);
  }

  // Generate rhythm tree in Klotho
  generateRhythmTree { |divisions, depth|
    this.sendCommand(\chronos, \rhythm_tree, (
      divisions: divisions,
      depth: depth
    ));
  }

  // Generate harmonic tree in Klotho
  generateHarmonicTree { |fundamentals, depth|
    this.sendCommand(\tonos, \harmonic_tree, (
      fundamentals: fundamentals,
      depth: depth
    ));
  }

  // Generate pitch lattice in Klotho
  generateLattice { |dimensions, generators|
    this.sendCommand(\tonos, \tone_lattice, (
      dimensions: dimensions,
      generators: generators
    ));
  }

  // Generate envelope in Klotho
  generateEnvelope { |type, duration, params|
    this.sendCommand(\dynatos, \envelope, (
      type: type,
      duration: duration,
      params: params
    ));
  }

  // === Receive from Klotho ===

  *receiveSequence { |sequence|
    // Convert Klotho sequence to Quasar pattern
    var pattern = this.sequenceToPattern(sequence);
    // Trigger callback or store in buffer
    QKlothoBuffer.add(\sequence, pattern);
  }

  *sequenceToPattern { |sequence|
    // Klotho sequences are arrays of events: [pitch, dur, amp, ...]
    ^Pbind(
      \freq, Pseq(sequence.collect(_.pitch).midiccps),
      \dur, Pseq(sequence.collect(_.dur)),
      \amp, Pseq(sequence.collect(_.amp))
    );
  }

  *receiveRhythm { |rhythm|
    // Convert Klotho rhythm tree to SC pattern
    var pattern = Pbind(
      \dur, Pseq(rhythm.durations),
      \amp, Pseq(rhythm.amplitudes ? 0.7)
    );
    QKlothoBuffer.add(\rhythm, pattern);
  }

  *receiveHarmony { |harmony|
    // Convert Klotho harmonic tree to chord progression
    var chords = harmony.chords.collect { |chord|
      chord.pitches.midiccps;
    };
    QKlothoBuffer.add(\harmony, chords);
  }
}

// Buffer for Klotho-generated data
QKlothoBuffer {
  classvar <buffers;

  *initClass {
    buffers = ();
  }

  *add { |key, data|
    buffers[key] = data;
  }

  *get { |key|
    ^buffers[key];
  }
}
```

---

## Integration Use Cases

### 1. Klotho-Generated Rhythms → Quasar Composition

```supercollider
(
// Create Quasar project
q = QProject(tempo: 120, seed: 42);

// Generate rhythm tree in Klotho
QKlotho.generateRhythmTree(
  divisions: [2, 3, 5], // Binary, ternary, quintuple subdivisions
  depth: 3
);

// Wait for Klotho to process (async)
fork {
  2.wait; // Give Klotho time to compute

  // Retrieve generated rhythm
  var rhythm = QKlothoBuffer.get(\rhythm);

  // Use rhythm in Quasar scene
  q.scene.addLayer(\drums, rhythm);
  q.play;
};
)
```

---

### 2. Klotho Harmonic Tree → Quasar Voice Leading

```supercollider
(
// Generate harmonic tree in Klotho
QKlotho.generateHarmonicTree(
  fundamentals: [100, 150], // Two fundamental frequencies
  depth: 4                  // 4 levels of partials
);

fork {
  2.wait;

  // Get generated harmonies
  var harmonies = QKlothoBuffer.get(\harmony);

  // Convert to Quasar chord progression
  q.theory.harmony.chordProgression = harmonies.collect { |freqs|
    freqs.cpsmidi.round; // Convert Hz → MIDI
  };

  // Apply Quasar voice leading
  var voicing = q.theory.harmony.voiceLead(
    q.theory.harmony.chordProgression,
    voices: 4
  );

  // Play voiced progression
  q.scene.addLayer(\harmony, Pbind(
    \midinote, Pseq(voicing.flat),
    \dur, 2
  ));

  q.play;
};
)
```

---

### 3. Klotho Envelopes → Quasar Automation

```supercollider
(
// Generate complex envelope in Klotho
QKlotho.generateEnvelope(
  type: \polynomial,
  duration: 8,
  params: (
    coefficients: [0.1, 0.3, -0.2, 0.5],
    range: [0, 1]
  )
);

fork {
  1.wait;

  var env = QKlothoBuffer.get(\envelope);

  // Use envelope for filter automation in Quasar
  q.scene[\lead].automate(\cutoff,
    env.linexp(0, 1, 200, 8000) // Map envelope to filter range
  );

  q.play;
};
)
```

---

### 4. Klotho Lattice → Quasar Microtonal Scale

```supercollider
(
// Generate 3D pitch lattice in Klotho
QKlotho.generateLattice(
  dimensions: 3,
  generators: [3/2, 5/4, 7/4] // Just intonation generators
);

fork {
  2.wait;

  var lattice = QKlothoBuffer.get(\lattice);

  // Define microtonal scale from lattice
  q.theory.harmony.scale = \klothoLattice;
  q.theory.harmony.scaleTuning = lattice.pitches; // Array of frequency ratios

  // Compose with microtonal scale
  q.theory.melody.fromContour(\arch, length: 16);
  q.play;
};
)
```

---

## Bi-Directional Integration

### Quasar → Klotho: Send Composition for Notation

```supercollider
(
// Compose in Quasar
q = QProject.fromTemplate(\classicalSonata);
q.theory.form.generate;

// Export Quasar composition to Klotho for notation
QKlotho.exportToKlotho(q, format: \lilypond);

// Klotho generates Lilypond file → PDF score
)
```

### Klotho → Quasar: Algorithmic Material Generation

```supercollider
(
// Use Klotho's stochastic algorithms to generate material
QKlotho.sendCommand(\topos, \markov_chain, (
  states: [\A, \B, \C],
  transitions: [
    [0.5, 0.3, 0.2],  // From A: 50% to A, 30% to B, 20% to C
    [0.2, 0.6, 0.2],  // From B
    [0.3, 0.3, 0.4]   // From C
  ],
  length: 64
));

fork {
  1.wait;
  var sequence = QKlothoBuffer.get(\markov);

  // Map states to musical gestures in Quasar
  q.scene.addLayer(\gestures, Pbind(
    \gesture, Pseq(sequence.collect { |state|
      case
      { state == \A } { q.gestureLibrary[\riser] }
      { state == \B } { q.gestureLibrary[\drop] }
      { state == \C } { q.gestureLibrary[\fill] }
    })
  ));
};
)
```

---

## Klotho Modules → Quasar Mappings

| Klotho Module | Quasar System | Integration Point |
|---------------|---------------|-------------------|
| **Topos** (Topology) | QTimeline, QForm | Abstract structure generation → formal archetypes |
| **Chronos** (Time) | QRhythm, QPose | Rhythm trees, microtiming → rhythmic patterns |
| **Tonos** (Pitch) | QHarmony, QMelody | Harmonic trees, lattices → scales, chords, voice leading |
| **Dynatos** (Dynamics) | QDynamics, QAutomation | Envelopes, amplitude curves → automation lanes |
| **Thetos** (Composition) | QProject, QScene | Parameter trees → compositional assembly |
| **Semeios** (Notation) | QRenderer | Score export → notation, visualization |

---

## Extended Integration: Klotho-SC Extension

The **Klotho-SC** extension provides direct SC access to Klotho functionality.

### EventScheduler Integration

```supercollider
(
// Use Klotho's EventScheduler with Quasar
var scheduler = EventScheduler(tempo: 120);

// Schedule Quasar sections
scheduler.schedule(0.0, {
  q.timeline.playSection(\intro);
});

scheduler.schedule(8.0, {
  q.timeline.playSection(\build);
});

scheduler.schedule(16.0, {
  // Klotho-generated rhythm for drop
  QKlotho.generateRhythmTree([2, 2, 2, 2], depth: 2);
  1.wait;
  var rhythm = QKlothoBuffer.get(\rhythm);
  q.scene.addLayer(\drums, rhythm);
  q.timeline.playSection(\drop);
});

scheduler.play;
)
```

---

## Workflow Examples

### Workflow 1: Klotho Generates, Quasar Produces

```supercollider
(
// Step 1: Generate materials in Klotho (Python)
QKlotho.sendCommand(\thetos, \generate_composition, (
  style: \minimalist,
  duration: 120, // seconds
  density: 0.7
));

// Step 2: Receive composition from Klotho
fork {
  3.wait;

  var composition = QKlothoBuffer.get(\composition);

  // Step 3: Load into Quasar
  q = QProject.fromKlothoData(composition);

  // Step 4: Apply Quasar mixing/mastering
  var mix = QMixEngine(q);
  mix.autoMix;
  mix.mastering.master(targetLUFS: -14);

  // Step 5: Render
  q.render("~/klotho_quasar_piece.wav");
};
)
```

### Workflow 2: Quasar Composes, Klotho Notates

```supercollider
(
// Step 1: Compose in Quasar
q = QProject.fromTemplate(\baroqueFugue);
q.theory.harmony.scale_(\dMinor);
q.theory.form.generate; // Generate fugue

// Step 2: Export to Klotho for notation
QKlotho.exportComposition(q);

// Klotho (Python side) generates:
// - Lilypond score (.ly)
// - PDF score (.pdf)
// - MusicXML (.xml)
// - MIDI (.mid)
)
```

### Workflow 3: Hybrid Composition

```supercollider
(
// Combine Klotho's algorithmic power with Quasar's high-level control
q = QProject(tempo: 140, seed: 99);

// Use Klotho for complex rhythm generation
QKlotho.generateRhythmTree([3, 5, 7], depth: 4); // Prime number subdivisions

// Use Klotho for microtonal harmony
QKlotho.generateLattice(dimensions: 5, generators: [3/2, 5/4, 7/4, 11/8, 13/8]);

fork {
  3.wait;

  // Get Klotho-generated materials
  var rhythm = QKlothoBuffer.get(\rhythm);
  var harmony = QKlothoBuffer.get(\lattice);

  // Apply Quasar's compositional logic
  q.theory.harmony.scaleTuning = harmony.pitches;
  q.theory.rhythm.pattern_(\klothoRhythm);
  q.theory.rhythm.rhythmPattern = rhythm;

  // Use Quasar's scene/macro system
  q.scene.defineMacro(\energy, [
    [\bass, \amp, 0.3, 1.0],
    [\drums, \density, 0.2, 0.9]
  ]);

  // Use Quasar's form system
  q.timeline.add(\intro, 8.bars);
  q.timeline.add(\build, 8.bars, energy: [0.2, 0.8]);
  q.timeline.add(\climax, 16.bars, energy: 0.9);

  // Use Quasar's mixing/mastering
  var mix = QMixEngine(q);
  mix.autoMix;

  q.play;
};
)
```

---

## Python Bridge Script

**File**: `Klotho/sc_bridge.py`

```python
#!/usr/bin/env python3
"""
Klotho ↔ SuperCollider Bridge
Receives OSC from SC, executes Klotho functions, sends results back.
"""

from pythonosc import dispatcher, osc_server, udp_client
from klotho.chronos.rhythm_trees import RhythmTree
from klotho.tonos.systems.harmonic_trees import HarmonicTree
from klotho.tonos.systems.tone_lattices import ToneLattice
from klotho.dynatos.envelopes import Envelope
import json

# OSC endpoints
SC_IP = "127.0.0.1"
SC_PORT = 57120  # Send to SC
PYTHON_PORT = 57121  # Receive from SC

sc_client = udp_client.SimpleUDPClient(SC_IP, SC_PORT)

def handle_command(unused_addr, module, method, args_json):
    """Handle commands from SuperCollider"""
    args = json.loads(args_json)

    if module == "chronos":
        if method == "rhythm_tree":
            result = generate_rhythm_tree(args)
            sc_client.send_message("/klotho/rhythm", json.dumps(result))

    elif module == "tonos":
        if method == "harmonic_tree":
            result = generate_harmonic_tree(args)
            sc_client.send_message("/klotho/harmony", json.dumps(result))
        elif method == "tone_lattice":
            result = generate_lattice(args)
            sc_client.send_message("/klotho/lattice", json.dumps(result))

    elif module == "dynatos":
        if method == "envelope":
            result = generate_envelope(args)
            sc_client.send_message("/klotho/envelope", json.dumps(result))

def generate_rhythm_tree(args):
    """Generate rhythm tree using Klotho"""
    tree = RhythmTree(
        divisions=args['divisions'],
        depth=args['depth']
    )
    return {
        'durations': tree.get_durations(),
        'amplitudes': tree.get_amplitudes()
    }

def generate_harmonic_tree(args):
    """Generate harmonic tree using Klotho"""
    tree = HarmonicTree(
        fundamentals=args['fundamentals'],
        depth=args['depth']
    )
    return {
        'chords': [
            {'pitches': chord.to_midi()}
            for chord in tree.get_chords()
        ]
    }

def generate_lattice(args):
    """Generate tone lattice using Klotho"""
    lattice = ToneLattice(
        dimensions=args['dimensions'],
        generators=args['generators']
    )
    return {
        'pitches': lattice.get_frequency_ratios()
    }

def generate_envelope(args):
    """Generate envelope using Klotho"""
    env = Envelope.from_type(
        env_type=args['type'],
        duration=args['duration'],
        **args['params']
    )
    return {
        'points': env.to_array()
    }

if __name__ == "__main__":
    disp = dispatcher.Dispatcher()
    disp.map("/klotho/command", handle_command)

    server = osc_server.ThreadingOSCUDPServer(
        ("127.0.0.1", PYTHON_PORT), disp
    )

    print(f"Klotho bridge listening on port {PYTHON_PORT}")
    print(f"Sending to SuperCollider on port {SC_PORT}")
    server.serve_forever()
```

---

## Installation & Setup

### 1. Install Klotho (Python)

```bash
cd /home/lpfreiburg/SC-Mod/Klotho/Klotho
pip install -e .
```

### 2. Install Klotho-SC (SuperCollider Extension)

```supercollider
// Already installed at /home/lpfreiburg/SC-Mod/Klotho/Klotho-SC
// Add to SC extensions or include in Quasar
```

### 3. Install Python OSC Library

```bash
pip install python-osc
```

### 4. Start Bridge (Automatic)

```supercollider
// Quasar automatically starts bridge on init
QKlotho.initClass; // Called automatically when Quasar loads
```

---

## Benefits of Integration

| Capability | Klotho | Quasar | Integrated |
|------------|--------|--------|------------|
| **Complex Rhythm Generation** | ✅ | ⚠️ | ✅✅ Klotho generates, Quasar plays |
| **Microtonal Systems** | ✅ | ⚠️ | ✅✅ Klotho lattices, Quasar renders |
| **Real-time Playback** | ❌ | ✅ | ✅✅ Klotho generates, Quasar performs |
| **Mixing/Mastering** | ❌ | ✅ | ✅✅ Quasar's QMix framework |
| **Notation Export** | ✅ | ❌ | ✅✅ Klotho's Semeios module |
| **Genre Templates** | ❌ | ✅ | ✅✅ Quasar templates + Klotho algorithms |
| **Mathematical Rigor** | ✅ | ⚠️ | ✅✅ Klotho's advanced algorithms |
| **User-Friendly API** | ⚠️ | ✅ | ✅✅ Quasar's high-level interface |

---

## Future Integration Points

### Phase 1 (Immediate)
- [x] OSC bridge setup
- [x] Basic rhythm tree integration
- [x] Harmonic tree integration
- [ ] EventScheduler integration

### Phase 2 (Medium-term)
- [ ] Full Topos integration (graph algorithms)
- [ ] Klotho parameter trees → Quasar scenes
- [ ] Bidirectional MIDI/OSC
- [ ] Notation export workflow

### Phase 3 (Long-term)
- [ ] Klotho GUI integration with Quasar timeline
- [ ] Live coding environment (Klotho algorithms + Quasar playback)
- [ ] Shared project file format (.quasar + .klotho)
- [ ] Cloud rendering (Klotho compute cluster + Quasar render farm)

---

**Klotho + Quasar = Complete CAC ecosystem from mathematical abstraction to mastered audio.**
