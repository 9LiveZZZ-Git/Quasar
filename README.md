# Quasar 2.0

**The Complete CAC Ecosystem for SuperCollider**

*From composition to Dolby Atmos masters, with AI assistance and live performance*

---

## What is Quasar?

Quasar is a **high-level compositional framework** for SuperCollider that enables composers to work at the level of **musical ideas** rather than individual notes. It combines deep music theory knowledge with deterministic algorithms to generate complete musical pieces from structural descriptions.

### Core Concept

Instead of writing:
```supercollider
// Low-level: individual notes and parameters
Pbind(\freq, Pseq([440, 494, 523]), \dur, 0.5).play;
```

You work with:
```supercollider
// High-level: musical concepts
q = QProject.fromTemplate(\classicalSonata);
q.theory.form.exposition.theme1 = QMelody.fromMotive([0, 2, 4]);
q.theory.harmony.progression(\functional);
q.play; // Generates complete sonata-form movement
```

---

## All 19 Frameworks + Complete UX/UI

Quasar 2.0 is a complete CAC ecosystem with 19 integrated frameworks covering every aspect of music creation, plus a revolutionary user interface:

### 🎼 **Core Composition** (Quasar Core)
- Genre-agnostic architecture (Baroque → EDM → Experimental)
- Deep music theory (harmony, melody, rhythm, counterpoint, form)
- Unit database & intelligent material selection
- Timeline & scene management
- Seeded randomness (perfect reproducibility)
- 9+ genre templates included

### 🎚️ **Production & Aesthetics**
- **QPose**: Musical poses & micro-gestures (risers, drops, swing, J Dilla grooves)
- **QMix**: Professional automatic mixing & mastering (gain staging, spatial mix, dynamics, EQ, effects, LUFS targeting)
- **QMess**: Controlled imperfection (lo-fi, glitch, tape/vinyl artifacts, happy accidents)

### 🎻 **Orchestration & Realism**
- **QOrch**: Deep orchestration system (range validation, playability checks, timbral blending, idiomatic writing)
- **QHuman**: Advanced humanization (breath, vibrato, bowing, micro-dynamics, performance fatigue)

### 🎧 **Immersive Audio**
- **QSpatial**: 3D spatial audio (stereo, binaural, 5.1, 7.1.4 Dolby Atmos, Ambisonics 1st-4th order, VBAP)
- Distance modeling, trajectories, room simulation, HRTF rendering

### 🔄 **Variation & Morphing**
- **QVariation**: Intelligent variation generator (rhythmic, melodic, harmonic, textural, structural variations)
- **QMorph**: State morphing system (tempo, key, genre, timbral morphing with smooth transitions)

### 🎮 **Adaptive & Interactive**
- **QAdapt**: Adaptive music engine (vertical remixing, horizontal resequencing, game/installation music)
- Context-aware (OSC/MIDI input → musical changes)
- Rule-based adaptation with conditional logic

### 🤖 **Analysis & AI**
- **QAnalyze**: Musical analysis (key/chord detection, tempo/meter, form analysis, motif extraction, style classification)
- **QAssist**: AI composition assistant (smart completion, chord suggestions, conflict detection, auto-improvements)

### 🎬 **Media & Sync**
- **QSync**: Media synchronization (SMPTE timecode, hit point alignment, tempo mapping, frame-accurate rendering)
- **QKlotho**: Klotho CAC toolkit integration (rhythm trees, harmonic trees, microtonal systems, notation export)

### 🎭 **Live Performance**
- **QLive**: Complete live performance system (cue system, MIDI/OSC mapping, macros, live looping, safety nets, panic button)

### 🗂️ **Workflow & Visualization**
- **QPreset**: Preset management (save/recall states, partial presets, preset morphing, tagging & search)
- **QMacro**: Macro recording & scripting (action sequences, conditional logic, batch processing)
- **QVis**: Visualization & animation sync (real-time viz, OSC to VJ software, graphic notation)

### 📚 **Corpus & Learning**
- **QCorpus**: Corpus-based composition (import MIDI/audio, pattern mining, style learning, Markov chains, concatenative synthesis)
- Learn from existing music, generate in learned styles
- Musical mosaicking (target-based synthesis from corpus segments)
- Style transfer (apply style of piece A to piece B)

### 🖥️ **Complete UX/UI System**
- **5 Interface Modes**: Quick Start (beginners) → Block Composer → Node Patch → Code Editor → Live Performance
- **Block-Based Programming**: Visual drag-drop, parameter tweaking, see generated code
- **Node System**: Connect frameworks with dataflow programming (MIDI, audio, theory, control signals)
- **Real-Time Preview**: <65ms latency, live audio feedback, instant parameter changes
- **Multi-Level Access**: Templates (beginners) → Parameters (intermediate) → Code (experts)
- **AI-Assisted but Human-Controlled**: Suggestions, not decisions
- **Template Library**: 9 genre templates, workflow templates, framework demos
- **Live Performance Optimized**: Low latency, cue system, controller mapping, safety nets

---

## Project Status

**Current Phase**: Planning / Architecture Design Complete ✅
**Version**: 0.0.1 (pre-alpha) → 2.0.0 target
**Timeline**: 88 weeks (22 months) for complete ecosystem
**Total LOC**: ~39,000 lines across ~150 classes
**Frameworks**: 19 complete systems + Full UX/UI
**Documentation**: 17+ comprehensive markdown files (~500 KB)

### Milestones
- **22 weeks**: Core composition system
- **37 weeks**: + Production tools + Klotho integration
- **60 weeks**: + All advanced frameworks (spatial, adaptive, analysis, live)
- **66 weeks**: + Corpus-based composition
- **78 weeks**: + Complete UX/UI (block-based GUI, node system, 5 interface modes)
- **88 weeks**: Release with docs, polish, and templates

### Speed Goals
- **Beginners**: Professional track in **5 minutes** (templates)
- **Intermediate**: AI-assisted composition in **15 minutes**
- **Advanced**: Orchestral score in **30 minutes**
- **Experts**: Live performance in **real-time** (<65ms latency)

See [IMPLEMENTATION_TRACKER_UPDATED.md](IMPLEMENTATION_TRACKER_UPDATED.md) for detailed roadmap.

---

## Documentation

### Getting Started
- [Quick Start Guide](docs/QuickStart.md) *(coming soon)*
- [Installation](INSTALL.md) *(coming soon)*
- [Tutorial Series](docs/tutorials/) *(coming soon)*

### Architecture
- [**ARCHITECTURE.md**](ARCHITECTURE.md) - Genre-agnostic design principles
- [**OBJECT_MODEL.md**](OBJECT_MODEL.md) - Complete class hierarchy and APIs
- [**OBJECT_MODEL_PART2.md**](OBJECT_MODEL_PART2.md) - Materials, selection, rendering
- [**GENRE_TEMPLATES.md**](GENRE_TEMPLATES.md) - 9 genre templates with examples

### Development
- [**IMPLEMENTATION_TRACKER.md**](IMPLEMENTATION_TRACKER.md) - Phase-by-phase plan with progress tracking
- [Contributing Guidelines](docs/CONTRIBUTING.md) *(coming soon)*
- [API Reference](docs/API.md) *(coming soon)*

---

## Quick Example

Here's what composing with Quasar looks like:

### Example 1: Baroque Fugue

```supercollider
(
// Create project from template
q = QProject.fromTemplate(\baroqueFugue);

// Set key and tempo
q.keySignature = \dMinor;
q.tempo = 80;

// Define fugue subject
q.theory.form.exposition.subject = [0, 2, 4, 5, 4, 2, 0]; // Scale degrees

// Generate fugue structure (exposition, episodes, stretto)
q.theory.form.generate;

// Generate 4-voice counterpoint
q.theory.counterpoint.species = \third;
q.texture.voices = 4; // SATB

// Play in realtime
q.play;

// Or render offline
q.render("~/my_fugue.wav", stems: true);
)
```

**Result**: A complete 4-voice fugue in D minor with proper exposition, episodes, and stretto.

---

### Example 2: EDM Drop

```supercollider
(
q = QProject.fromTemplate(\edm);
q.tempo = 128;
q.seed = 42; // Reproducible

// Load sample library
q.palette.loadUnits("~/Samples/EDM_Kit");

// Define form
q.timeline.add(\intro, 8.bars, energy: 0.2);
q.timeline.add(\build, 8.bars, energy: [0.2, 0.8], transition: \riser);
q.timeline.add(\drop, 16.bars, energy: 0.9, transition: \impact);
q.timeline.add(\break, 8.bars, energy: 0.3);
q.timeline.add(\drop2, 16.bars, energy: 1.0, variant: true);
q.timeline.add(\outro, 8.bars, energy: [0.6, 0.1]);

// Configure scene macros
q.scene.defineMacro(\energy, [
  [\sub, \amp, 0.5, 1.0],
  [\bass, \filter, 200, 8000],
  [\drums, \density, 0.2, 0.9]
]);

// Generate and play
q.play;
)
```

**Result**: A full EDM track with intro/build/drop/break structure, automatically selecting appropriate samples.

---

### Example 3: Jazz Standard

```supercollider
(
q = QProject.fromTemplate(\bebop);
q.tempo = 220; // Fast bebop tempo
q.keySignature = \fMajor;

// Define AABA form (32 bars)
q.theory.form.archetype = \AABA;

// Harmonic progression (rhythm changes)
q.theory.harmony.progression(\rhythmChanges);

// Generate bebop melody over changes
q.theory.melody.style = \bebop;
q.theory.melody.scales = [\bebop, \altered];

// Add swing
q.theory.rhythm.swing = 0.66;

// Play head, then solos, then out
q.form.sections = [\head, \solos, \head];

q.play;
)
```

---

### Example 4: Algorithmic / Experimental

```supercollider
(
q = QProject.fromTemplate(\algorithmic);

// Stochastic harmony
q.theory.harmony.organization = \stochastic;
q.theory.harmony.distribution = \gaussian;

// Cellular automaton rhythm
q.theory.rhythm.process = \cellularAutomaton;
q.theory.rhythm.rule = 110; // Rule 110

// Fractal form
q.theory.form.structure = \fractal;
q.theory.form.depth = 3;

// High chaos parameter
q.macros.chaos = 0.8;

q.play;
)
```

---

### Example 5: Lo-Fi with QMess

```supercollider
(
q = QProject.fromTemplate(\lofiHipHop);
q.tempo = 85;

// Load samples
q.palette.loadUnits("~/Samples/LoFi");

// Compose basic beat
q.theory.rhythm.pattern(\lofiDrums);
q.theory.harmony.progression([\i, \bVII, \IV, \V]);

// === ADD QMESS - CONTROLLED IMPERFECTION ===
var mess = QMess(q, messLevel: 0.5);

// 1. Timbral mess - tape artifacts and lo-fi
mess.timbralMess.tapeArtifact(q.scene[\drums], type: \warble);
mess.timbralMess.vinylArtifacts(q.scene[\bass], density: 0.4);
mess.timbralMess.lofi(q.scene[\melody], severity: 0.6);

// 2. Rhythmic mess - J Dilla-style timing
mess.rhythmicMess.timingError(
  q.scene[\drums],
  amount: 0.03, // 30ms variation
  probability: 0.5 // Half the notes affected
);

// 3. Pitch mess - slight warble (tape wow/flutter)
mess.pitchMess.detune(q.scene[\melody], amount: 0.15);

// 4. Structural mess - incomplete phrase (leave listener wanting more)
q.timeline[\chorus].melody = mess.structuralMess.incompletePhrase(
  q.timeline[\chorus].melody,
  cutPoint: 0.75 // Cut at 75%
);

// 5. Production mess - slight imbalance (human feel)
mess.productionMess.imbalance(q.scene.layers);

q.play;
// Result: Lo-fi beat with controlled imperfection - sounds "lived in"
)
```

---

## Genre Template Comparison

| Template | Harmony | Texture | Form | Best For |
|----------|---------|---------|------|----------|
| **Baroque Fugue** | Functional | Polyphonic (4 voices) | Fugue (exposition/episodes) | Contrapuntal, imitative works |
| **Classical Sonata** | Functional | Homophonic | Sonata form | Structured, developmental pieces |
| **Romantic Character** | Chromatic, rich | Varies | Ternary (ABA) | Expressive, emotional works |
| **Bebop** | Complex jazz | Polyphonic | AABA / 12-bar blues | Fast, virtuosic jazz |
| **Modal Jazz** | Modal centers | Sparse, interactive | Open form | Spacious, exploratory jazz |
| **Minimalism** | Static/modal | Homorhythmic | Processual | Repetitive, gradual change |
| **EDM** | Simple, repetitive | Layered | Intro/Build/Drop/Break | Dance music, electronic |
| **Ambient** | Drifting, ambiguous | Evolving textures | Open form | Atmospheric, background |
| **Algorithmic** | Parametric | Variable | Generative | Experimental, research |

See [GENRE_TEMPLATES.md](GENRE_TEMPLATES.md) for complete template definitions.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        QProject                              │
│  ┌────────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  QTheory   │  │ QPalette │  │QTimeline │  │ QTexture │  │
│  └────────────┘  └──────────┘  └──────────┘  └──────────┘  │
│        │              │              │              │        │
│  ┌─────▼──────┐  ┌───▼────┐    ┌────▼────┐    ┌────▼────┐ │
│  │ QHarmony   │  │QUnitDB │    │QSection │    │ QVoice  │ │
│  │ QMelody    │  │QUnit   │    │         │    │         │ │
│  │ QRhythm    │  │        │    │         │    │         │ │
│  │QCounterpnt │  │        │    │         │    │         │ │
│  │ QForm      │  │        │    │         │    │         │ │
│  └────────────┘  └────────┘    └─────────┘    └─────────┘ │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              QConductor (Playback)                   │   │
│  │  ┌──────────┐  ┌──────────┐  ┌────────────────────┐│   │
│  │  │ Realtime │  │   NRT    │  │   Stem Export      ││   │
│  │  │ Routine  │  │  Score   │  │                    ││   │
│  │  └──────────┘  └──────────┘  └────────────────────┘│   │
│  └─────────────────────────────────────────────────────┘   │
│                           │                                 │
│                           ▼                                 │
│              ┌────────────────────────┐                     │
│              │   SuperCollider        │                     │
│              │   (Patterns, Ndefs,    │                     │
│              │    SynthDefs, Busses)  │                     │
│              └────────────────────────┘                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Phases

| Phase | Deliverable | Timeline | Status |
|-------|-------------|----------|--------|
| **0** | Core engine (QProject, QScene, QTimeline, QConductor) | Weeks 1-2 | ⬜ Not Started |
| **1** | Unit database & selection (QUnitDB, QSelector) | Weeks 3-5 | ⬜ Not Started |
| **2** | Music theory foundation (QHarmony, QMelody, QRhythm) | Weeks 6-8 | ⬜ Not Started |
| **3** | Gestures & behaviors (15+ gesture classes) | Weeks 9-11 | ⬜ Not Started |
| **4** | Texture & orchestration (QTexture, QVoice) | Weeks 12-14 | ⬜ Not Started |
| **5** | Form & structure (QForm with 8+ archetypes) | Weeks 15-17 | ⬜ Not Started |
| **6** | Scene system & macros (QScene, QMacro, FX) | Weeks 18-19 | ⬜ Not Started |
| **7** | Advanced selection & rules (constraints, scoring) | Weeks 20-22 | ⬜ Not Started |
| **8** | Rendering & export (NRT, stems, metadata) | Weeks 23-24 | ⬜ Not Started |
| **9** | GUI & performance (timeline editor, mixer) | Weeks 25-28 | ⬜ Not Started |
| **10** | DSL parser (YAML/JSON projects) | Weeks 29-31 | ⬜ Optional |
| **11** | Documentation & examples | Weeks 32-34 | ⬜ Not Started |
| **12** | Polish & release (testing, optimization) | Weeks 35-36 | ⬜ Not Started |

**Estimated Total**: 36 weeks (9 months) for solo developer
**Core Functionality** (Phases 0-8): 24 weeks (6 months)

See [IMPLEMENTATION_TRACKER.md](IMPLEMENTATION_TRACKER.md) for detailed task breakdown.

---

## Design Principles

### 1. **Music Theory First**
Musical concepts (scales, chords, voice leading) are first-class primitives, not afterthoughts.

### 2. **Reproducibility is Non-Negotiable**
Same seed → same piece, forever. Essential for research and archival purposes.

### 3. **No Genre Bias**
Core architecture supports ANY musical style. Genre-specific knowledge lives in templates, not core code.

### 4. **Abstraction Layers**
Work at any level:
- **High**: "Use sonata form with this theme"
- **Mid**: "Generate melody from this motive"
- **Low**: "Play these exact MIDI notes"

### 5. **Transparent, Not Magic**
Every algorithm is inspectable. Generated code can be extracted and modified.

### 6. **SuperCollider Native**
Leverage SC's strengths (Patterns, NodeProxies, NRT rendering). Don't reinvent what works.

### 7. **Extensibility Everywhere**
Users can add:
- Custom scales/chords
- Custom gestures
- Custom selection rules
- Custom formal archetypes
- Custom templates

---

## Use Cases

### 🎓 **Music Education**
- Teach music theory concepts interactively
- Generate counterpoint exercises
- Explore harmonic progressions
- Study formal structures

### 🔬 **Algorithmic Composition Research**
- Reproducible experiments
- Constraint-based composition studies
- Rule-based vs. stochastic comparison
- Large-scale form generation

### 🎹 **Compositional Tool**
- Quickly sketch musical ideas
- Generate variations on themes
- Explore "what if" scenarios
- Rapid prototyping of forms

### 🎮 **Game Audio / Interactive Music**
- Generate adaptive music systems
- Context-aware background music
- Procedural music that sounds composed
- Deterministic music for replays

### 🎧 **Sound Design**
- Create evolving soundscapes
- Generate stems for mixing
- Build macro-controlled scenes
- Design complex gesture libraries

---

## Technical Requirements

### Required
- **SuperCollider**: 3.13.0 or later
- **Operating System**: macOS, Linux, or Windows
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 500MB for software, variable for samples

### Optional
- **Quarks**: (To be determined based on implementation)
- **Audio interface**: For realtime performance
- **MIDI controller**: For macro control

---

## Comparison to Other Systems

| Feature | Quasar | OpenMusic | PWGL | Nyquist | ChucK |
|---------|--------|-----------|------|---------|-------|
| **Music Theory** | ✅ Deep | ✅ Deep | ✅ Deep | ❌ None | ❌ None |
| **Genre-Agnostic** | ✅ Yes | ✅ Yes | ✅ Yes | ⚠️ Partial | ⚠️ Partial |
| **Reproducible** | ✅ Yes | ✅ Yes | ✅ Yes | ⚠️ Partial | ⚠️ Partial |
| **Realtime** | ✅ Yes | ❌ No | ❌ No | ❌ No | ✅ Yes |
| **NRT Rendering** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes | ⚠️ Partial |
| **Learning Curve** | Medium | High | High | Low | Medium |
| **Open Source** | ✅ Yes | ✅ Yes | ❌ No | ✅ Yes | ✅ Yes |
| **Active Development** | 🆕 New | ⚠️ Slow | ⚠️ Slow | ⚠️ Slow | ✅ Active |

**Quasar's Niche**: Combines OpenMusic's music theory depth with SuperCollider's realtime capabilities and modern reproducibility practices.

---

## Contributing

Quasar is in early development. Contributions welcome!

Areas where help is needed:
- Music theory algorithm implementation
- SynthDef library creation
- Documentation and tutorials
- Testing across platforms
- Example compositions

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) *(coming soon)* for guidelines.

---

## License

**To Be Determined** (likely GPL-3.0 or MIT)

---

## Roadmap

### Short Term (3 months)
- [ ] Phase 0-2 implementation (core + theory)
- [ ] Basic fugue and sonata examples working
- [ ] Unit selection and constraint system
- [ ] Alpha release for testing

### Medium Term (6 months)
- [ ] Phases 3-6 (gestures, texture, form, scenes)
- [ ] All 9 genre templates implemented
- [ ] NRT rendering and stem export
- [ ] Beta release

### Long Term (9 months)
- [ ] GUI and performance system
- [ ] Complete documentation
- [ ] Example library (20+ pieces)
- [ ] **Version 1.0 Release**

### Future
- [ ] Plugin architecture for extensions
- [ ] Community template library
- [ ] Integration with other tools (Lilypond, DAWs)
- [ ] Advanced AI-assisted features (optional)

---

## Credits

**Architecture & Design**: Luc Freiburg
**SuperCollider**: James McCartney and the SC community
**Inspiration**: OpenMusic (IRCAM), PWGL, Nyquist, Klotho

---

## Contact & Community

- **Issue Tracker**: [GitHub Issues](#) *(coming soon)*
- **Forum**: [scsynth.org](#) *(coming soon)*
- **Discord**: [Quasar Community](#) *(coming soon)*
- **Email**: [quasar@example.com](#) *(coming soon)*

---

## Acknowledgments

Quasar builds on decades of research in:
- Computer music (IRCAM, CCRMA, MIT Media Lab)
- Music theory (Tonal Harmony, species counterpoint)
- Algorithmic composition (Xenakis, Hiller, Cope)
- SuperCollider ecosystem

Special thanks to the music theory and algorithmic composition research communities.

---

**Status**: Pre-Alpha | **Version**: 0.0.1 | **Last Updated**: 2026-01-08
