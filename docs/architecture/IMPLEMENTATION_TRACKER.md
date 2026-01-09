# Quasar Implementation Tracker

## Project Overview
**Goal**: Build a genre-agnostic macro-composition system for SuperCollider with deep music theory integration
**Timeline**: 6-9 months (solo dev) / 4-6 months (team of 3)
**Current Phase**: Planning
**Version Target**: 1.0.0

---

## Phase Status Legend
- ⬜ Not Started
- 🟦 In Progress
- ✅ Complete
- ⚠️ Blocked
- 🔄 Needs Revision

---

## PHASE 0: Core Engine (Weeks 1-2) ⬜
**Goal**: Minimal working system with deterministic playback
**LOC**: ~800 (updated from 600 with theory additions)
**Dependencies**: None
**Exit Criteria**: One example plays consistently with same seed

### Tasks
- [ ] **QProject** - Project container with metadata (80 LOC)
  - [ ] Tempo, seed, key signature, time signature storage
  - [ ] Version tracking (SC version, Quasar version)
  - [ ] Asset path management
  - [ ] Metadata serialization

- [ ] **QState** - Parameter snapshot system (80 LOC)
  - [ ] Dictionary wrapper with validation
  - [ ] State interpolation (morph between states)
  - [ ] State tagging (mood, energy, texture)
  - [ ] Diff/merge for state variants

- [ ] **QScene** - Scene/layer manager (200 LOC)
  - [ ] ProxySpace wrapper
  - [ ] Layer management (bass, harmony, melody, percussion, texture)
  - [ ] Bus routing architecture
  - [ ] Scene state snapshots

- [ ] **QTimeline** - Section sequencer (120 LOC)
  - [ ] Section list with timing
  - [ ] Transition storage
  - [ ] Timeline validation (no overlaps, gaps)
  - [ ] Bar/beat calculation utilities

- [ ] **QConductor** - Playback engine (250 LOC)
  - [ ] Routine-based realtime playback
  - [ ] TempoClock integration
  - [ ] Section transitions
  - [ ] Transport controls (play/stop/seek)

- [ ] **Example: 01_minimal_composition.scd** (70 LOC)
  - [ ] 2-section piece (A/B form)
  - [ ] Deterministic output verification
  - [ ] Basic documentation

**Milestone Review**: ⬜
- [ ] Demo to stakeholders
- [ ] Performance test (CPU usage < 50% for 3 layers)
- [ ] Reproducibility test (3 runs = identical audio)

---

## PHASE 1: Unit Database & Selection (Weeks 3-5) ⬜
**Goal**: Load, tag, and select musical materials deterministically
**LOC**: ~600 (updated)
**Dependencies**: Phase 0
**Exit Criteria**: 50+ units loadable, selection feels intentional

### Tasks
- [ ] **QUnit** - Musical unit wrapper (100 LOC)
  - [ ] Buffer/Pattern abstraction
  - [ ] Metadata (tags, duration, pitch content, dynamics)
  - [ ] Audio feature extraction (RMS, spectral centroid, pitch detection)
  - [ ] Hash generation for reproducibility

- [ ] **QUnitDB** - Unit database (280 LOC)
  - [ ] Folder scanner with recursive search
  - [ ] Manifest generation (JSON)
  - [ ] Tag parser (filename + sidecar JSON)
  - [ ] Query system (filter by tags, features)
  - [ ] Hash verification on load

- [ ] **QSelector** - Selection engine (220 LOC)
  - [ ] Seeded RNG wrapper
  - [ ] Basic scoring (tag match)
  - [ ] Exclusion rules (avoid immediate repeats)
  - [ ] Context tracking (history, last selected)

- [ ] **Example: 02_unit_selection.scd**
  - [ ] Load 50 units from test corpus
  - [ ] Select units for 4 sections
  - [ ] Verify determinism

**Milestone Review**: ⬜
- [ ] Unit library organization workshop
- [ ] Tag taxonomy finalization
- [ ] Performance test (load 1000 units < 2 sec)

---

## PHASE 2: Music Theory Foundation (Weeks 6-8) ⬜
**Goal**: Harmonic, melodic, and rhythmic theory modules
**LOC**: ~900
**Dependencies**: Phase 0, Phase 1
**Exit Criteria**: Generate theory-correct progressions and melodies

### Tasks
- [ ] **QHarmony** - Harmonic system (250 LOC)
  - [ ] Scale/mode definitions (all common scales + microtonal)
  - [ ] Chord construction (triads, 7ths, extended, clusters)
  - [ ] Progression generator (functional harmony, modal, chromatic)
  - [ ] Voice leading calculator (SATB rules, smooth voice leading)
  - [ ] Harmonic rhythm patterns

- [ ] **QMelody** - Melodic system (220 LOC)
  - [ ] Motive definition and transformation
  - [ ] Contour generation (arch, ascending, descending, etc.)
  - [ ] Interval class vectors
  - [ ] Melodic development (repetition, sequence, inversion, retrograde)
  - [ ] Ornamentation rules

- [ ] **QRhythm** - Rhythmic system (180 LOC)
  - [ ] Metric hierarchy (strong/weak beats)
  - [ ] Rhythmic cells and patterns
  - [ ] Syncopation algorithms
  - [ ] Polyrhythm/polymeter support
  - [ ] Swing and groove templates

- [ ] **QCounterpoint** - Contrapuntal rules (250 LOC)
  - [ ] Species counterpoint (1st-5th species)
  - [ ] Consonance/dissonance rules
  - [ ] Motion types (parallel, contrary, oblique, similar)
  - [ ] Voice crossing detection
  - [ ] Counterpoint generator

- [ ] **Example: 03_theory_basics.scd**
  - [ ] Generate chord progression in various styles
  - [ ] Create melody from motive
  - [ ] Apply counterpoint rules

**Milestone Review**: ⬜
- [ ] Theory validation with music theorist
- [ ] Rule correctness testing
- [ ] Genre templates created

---

## PHASE 3: Gestures & Behaviors (Weeks 9-11) ⬜
**Goal**: Musical behavior library (genre-agnostic)
**LOC**: ~1000
**Dependencies**: Phase 2
**Exit Criteria**: 15+ gestures across multiple genres

### Tasks
- [ ] **QGesture** base class (120 LOC)
  - [ ] Pattern output interface
  - [ ] Control curve output interface
  - [ ] Duration/timing handling
  - [ ] Parameter randomization (bounded)

- [ ] **Harmonic Gestures** (200 LOC)
  - [ ] Cadence (authentic, deceptive, half, plagal)
  - [ ] Modulation (pivot chord, common tone, chromatic)
  - [ ] Pedal point
  - [ ] Harmonic sequence

- [ ] **Melodic Gestures** (200 LOC)
  - [ ] Ascending/descending scale runs
  - [ ] Arpeggio patterns
  - [ ] Neighbor tone figures
  - [ ] Call and response phrases
  - [ ] Ornamented cantus firmus

- [ ] **Rhythmic Gestures** (180 LOC)
  - [ ] Accelerando/ritardando
  - [ ] Rhythmic diminution/augmentation
  - [ ] Hocket patterns
  - [ ] Ostinato

- [ ] **Textural Gestures** (180 LOC)
  - [ ] Density increase/decrease
  - [ ] Register expansion/contraction
  - [ ] Heterophonic spreading
  - [ ] Imitative entries (canon, fugue subject)

- [ ] **Dynamic Gestures** (120 LOC)
  - [ ] Crescendo/diminuendo
  - [ ] Dynamic terracing
  - [ ] Accent patterns
  - [ ] Subito changes

- [ ] **Examples: 04_gestures_*.scd** (one per category)

**Milestone Review**: ⬜
- [ ] Gesture audition session
- [ ] Musicality evaluation
- [ ] Performance optimization

---

## PHASE 4: Texture & Orchestration (Weeks 12-14) ⬜
**Goal**: Multi-voice texture management and orchestration
**LOC**: ~850
**Dependencies**: Phase 2, Phase 3
**Exit Criteria**: Generate textures from monophonic to polyphonic

### Tasks
- [ ] **QTexture** - Texture types (180 LOC)
  - [ ] Monophonic
  - [ ] Homophonic (melody + accompaniment)
  - [ ] Polyphonic (independent voices)
  - [ ] Heterophonic (simultaneous variation)
  - [ ] Texture morphing

- [ ] **QVoice** - Voice/part abstraction (150 LOC)
  - [ ] Range constraints (vocal/instrumental)
  - [ ] Tessitura management
  - [ ] Voice state tracking
  - [ ] Articulation and phrasing

- [ ] **QOrchestration** - Instrument combinations (280 LOC)
  - [ ] Instrument family definitions
  - [ ] Doubling rules (octaves, unison)
  - [ ] Balance and blend algorithms
  - [ ] Register spacing (open/closed position)
  - [ ] Orchestral reduction/expansion

- [ ] **QVoiceLeading** - Voice leading engine (240 LOC)
  - [ ] Common tone retention
  - [ ] Stepwise motion preference
  - [ ] Avoid parallel 5ths/octaves
  - [ ] Voice crossing rules
  - [ ] Cost function optimization

- [ ] **Example: 05_textures.scd**
  - [ ] String quartet texture
  - [ ] Piano reduction
  - [ ] Full orchestral texture

**Milestone Review**: ⬜
- [ ] Orchestration test with real instruments
- [ ] Voice leading correctness audit
- [ ] Register distribution analysis

---

## PHASE 5: Form & Structure (Weeks 15-17) ⬜
**Goal**: Large-scale formal archetypes
**LOC**: ~800
**Dependencies**: All previous phases
**Exit Criteria**: Generate complete pieces in multiple forms

### Tasks
- [ ] **QForm** - Form archetypes (350 LOC)
  - [ ] Binary (AB, rounded binary)
  - [ ] Ternary (ABA, da capo)
  - [ ] Rondo (ABACA, ABACABA)
  - [ ] Sonata form (exposition, development, recapitulation)
  - [ ] Theme and variations
  - [ ] Fugue structure
  - [ ] Arch form
  - [ ] Moment form / mobile form
  - [ ] EDM forms (intro/build/drop/break)
  - [ ] Through-composed

- [ ] **QDevelopment** - Developmental techniques (220 LOC)
  - [ ] Motivic development
  - [ ] Fragmentation
  - [ ] Liquidation
  - [ ] Fortspinnung (spinning forth)
  - [ ] Sequence (real, tonal)

- [ ] **QTransition** - Formal transitions (230 LOC)
  - [ ] Elision
  - [ ] Retransition
  - [ ] Codetta/coda
  - [ ] Bridge/link passages
  - [ ] Attacca vs. pause

- [ ] **Example: 06_forms_*.scd** (one per major form type)

**Milestone Review**: ⬜
- [ ] Form coherence listening tests
- [ ] Proportional analysis
- [ ] Transition smoothness evaluation

---

## PHASE 6: Scene System & Macros (Weeks 18-19) ⬜
**Goal**: High-level scene controls and FX routing
**LOC**: ~700
**Dependencies**: Phase 0-4
**Exit Criteria**: Scene macros control multiple parameters musically

### Tasks
- [ ] **QMacro** - Macro parameter system (180 LOC)
  - [ ] One-to-many mappings
  - [ ] Curve types (linear, exponential, custom)
  - [ ] Macro presets (genre-specific)
  - [ ] Macro modulation (LFO, envelope)

- [ ] **QMixer** - Mixing and routing (200 LOC)
  - [ ] Bus architecture
  - [ ] Aux send/return
  - [ ] Parallel processing
  - [ ] Sidechain routing
  - [ ] Stem management

- [ ] **QFX Library** - Effect modules (320 LOC)
  - [ ] Time-based (reverb, delay, chorus)
  - [ ] Dynamics (comp, limiter, gate)
  - [ ] Spectral (filter, EQ, formant)
  - [ ] Distortion (fold, clip, waveshape)
  - [ ] Spatial (pan, width, binaural)

- [ ] **Example: 07_scene_macros.scd**

**Milestone Review**: ⬜
- [ ] Macro mapping workshop
- [ ] FX quality evaluation
- [ ] CPU profiling

---

## PHASE 7: Advanced Selection & Rules (Weeks 20-22) ⬜
**Goal**: Intelligent, context-aware material selection
**LOC**: ~750
**Dependencies**: Phase 1, Phase 2
**Exit Criteria**: Selection produces musically coherent results

### Tasks
- [ ] **QConstraint** - Constraint system (200 LOC)
  - [ ] Constraint definition DSL
  - [ ] Hard vs. soft constraints
  - [ ] Constraint satisfaction solver
  - [ ] Conflict resolution

- [ ] **QScoring** - Advanced scoring (250 LOC)
  - [ ] Multi-factor scoring
  - [ ] Weight tuning system
  - [ ] Context history tracking
  - [ ] Diversity/novelty balance
  - [ ] Style consistency scoring

- [ ] **QGrammar** - Compositional grammar (300 LOC)
  - [ ] Rule definition system
  - [ ] Generative grammar (CFG)
  - [ ] Probabilistic rules
  - [ ] Style learning from examples
  - [ ] Grammar combination/mixing

- [ ] **Example: 08_intelligent_selection.scd**

**Milestone Review**: ⬜
- [ ] A/B testing (random vs. smart selection)
- [ ] Rule tuning session
- [ ] Grammar validation

---

## PHASE 8: Rendering & Export (Weeks 23-24) ⬜
**Goal**: Professional-quality offline rendering
**LOC**: ~600
**Dependencies**: Phase 0, Phase 6
**Exit Criteria**: Bit-identical renders, stem export working

### Tasks
- [ ] **QRenderer** - NRT rendering engine (250 LOC)
  - [ ] Score generation from timeline
  - [ ] Offline rendering via NRT
  - [ ] Progress tracking
  - [ ] Error recovery

- [ ] **QStemExporter** - Stem export (180 LOC)
  - [ ] Per-layer recording
  - [ ] Stem naming conventions
  - [ ] Metadata embedding
  - [ ] Batch rendering

- [ ] **QMetadata** - Render metadata (170 LOC)
  - [ ] Full parameter dump
  - [ ] Unit selection log
  - [ ] Version information
  - [ ] Reproducibility hash
  - [ ] MIDI/MusicXML export (optional)

- [ ] **Example: 09_rendering.scd**

**Milestone Review**: ⬜
- [ ] Determinism test (10 renders, verify identical)
- [ ] Render speed optimization
- [ ] Stem workflow test

---

## PHASE 9: GUI & Performance (Weeks 25-28) ⬜
**Goal**: Visual interface for composition and performance
**LOC**: ~1200
**Dependencies**: All previous phases
**Exit Criteria**: Complete pieces without touching code

### Tasks
- [ ] **QGUIProject** - Project window (200 LOC)
  - [ ] Project settings
  - [ ] Asset browser
  - [ ] Tempo/key controls

- [ ] **QGUITimeline** - Timeline editor (350 LOC)
  - [ ] Section blocks (drag/drop)
  - [ ] Transition editor
  - [ ] Zoom/scroll
  - [ ] Playhead and scrubbing

- [ ] **QGUIScene** - Scene mixer (300 LOC)
  - [ ] Layer view
  - [ ] Macro knobs
  - [ ] FX rack
  - [ ] Meter bridge

- [ ] **QGUITheory** - Theory tools (250 LOC)
  - [ ] Chord palette
  - [ ] Scale selector
  - [ ] Progression builder
  - [ ] Voice leading visualizer

- [ ] **QMIDIMapper** - MIDI integration (100 LOC)
  - [ ] MIDI learn
  - [ ] CC mapping
  - [ ] Note input

- [ ] **Example: 10_gui_workflow.scd**

**Milestone Review**: ⬜
- [ ] User testing session
- [ ] GUI performance optimization
- [ ] Accessibility review

---

## PHASE 10: Parser & DSL (Weeks 29-31) ⬜ [OPTIONAL]
**Goal**: Text-based scripting language
**LOC**: ~700
**Dependencies**: All core phases
**Exit Criteria**: Load YAML/JSON projects

### Tasks
- [ ] **QParser** - YAML/JSON parser (300 LOC)
  - [ ] YAML parsing (use existing lib)
  - [ ] Schema validation
  - [ ] Error reporting with line numbers
  - [ ] Hot reload support

- [ ] **QBuilder** - Project builder from data (250 LOC)
  - [ ] Data structure → object graph
  - [ ] Reference resolution
  - [ ] Dependency ordering

- [ ] **QExporter** - Export to YAML (150 LOC)
  - [ ] Object graph → data structure
  - [ ] Pretty printing
  - [ ] Comment preservation

- [ ] **DSL Spec document**
- [ ] **Example: projects/*.yaml**

**Milestone Review**: ⬜
- [ ] DSL syntax review
- [ ] Round-trip test (load → save → load)
- [ ] Documentation completeness

---

## PHASE 11: Documentation & Examples (Weeks 32-34) ⬜
**Goal**: Complete documentation and example library
**LOC**: N/A (docs only)
**Dependencies**: All phases
**Exit Criteria**: User can learn from docs alone

### Tasks
- [ ] **Quick Start Guide** (schelp)
- [ ] **Tutorial Series** (10+ tutorials)
  - [ ] Tutorial 1: First composition
  - [ ] Tutorial 2: Harmonic progressions
  - [ ] Tutorial 3: Melodic development
  - [ ] Tutorial 4: Counterpoint
  - [ ] Tutorial 5: Orchestration
  - [ ] Tutorial 6: Form archetypes
  - [ ] Tutorial 7: Scene macros
  - [ ] Tutorial 8: Unit libraries
  - [ ] Tutorial 9: Rendering workflow
  - [ ] Tutorial 10: Live performance

- [ ] **API Reference** (all classes)
- [ ] **Genre Templates**
  - [ ] Baroque fugue template
  - [ ] Classical sonata template
  - [ ] Romantic character piece template
  - [ ] Jazz standard template
  - [ ] Minimalist template
  - [ ] EDM template
  - [ ] Ambient template
  - [ ] Experimental/algorithmic template

- [ ] **Video Tutorials** (optional)

**Milestone Review**: ⬜
- [ ] Documentation review by external users
- [ ] Example testing
- [ ] Tutorial walkthrough

---

## PHASE 12: Polish & Release (Weeks 35-36) ⬜
**Goal**: Production-ready 1.0 release
**Dependencies**: All previous phases
**Exit Criteria**: Public release

### Tasks
- [ ] **Bug fixes from user testing**
- [ ] **Performance optimization**
  - [ ] Profiling and hotspot analysis
  - [ ] Memory usage optimization
  - [ ] Startup time optimization

- [ ] **Testing**
  - [ ] Unit tests (80% coverage)
  - [ ] Integration tests
  - [ ] Reproducibility tests
  - [ ] Cross-platform testing (macOS, Linux, Windows)

- [ ] **Release engineering**
  - [ ] Version tagging
  - [ ] Release notes
  - [ ] Installation instructions
  - [ ] Quark packaging

- [ ] **Marketing materials**
  - [ ] Project website
  - [ ] Demo videos
  - [ ] Paper/thesis (if research project)

**Milestone Review**: ⬜
- [ ] Release candidate testing
- [ ] Performance benchmarks
- [ ] Security review
- [ ] License compliance check

---

## Research Extensions (Phase 13+) ⬜ [OPTIONAL]
**Goal**: Advanced features for research use
**Timeline**: Ongoing
**Priority**: Low (post-1.0)

### Possible Extensions
- [ ] **Machine learning integration** (style transfer, mix assist)
- [ ] **Real-time collaboration** (networked composition)
- [ ] **Corpus analysis tools** (analyze existing pieces)
- [ ] **Microtonality expansion** (beyond 12-TET)
- [ ] **Spatialization** (ambisonic, multichannel)
- [ ] **Gestural control** (OSC, sensors)
- [ ] **Live coding mode** (TidalCycles-style patterns)
- [ ] **Notation export** (Lilypond, MusicXML)
- [ ] **Plugin version** (VST/AU for DAW use)

---

## Metrics & KPIs

### Code Quality
- [ ] Test coverage > 75%
- [ ] Documentation coverage > 90%
- [ ] No critical bugs in issue tracker
- [ ] Code review completion rate: 100%

### Performance
- [ ] Load time < 3 seconds (1000 units)
- [ ] Realtime CPU usage < 60% (8 layers)
- [ ] NRT render speed > 10x realtime
- [ ] Memory usage < 500MB (typical project)

### User Adoption (post-release)
- [ ] 100+ downloads in first month
- [ ] 10+ example pieces created by users
- [ ] 5+ contributions from community
- [ ] Forum/Discord activity

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Music theory complexity too high | High | High | Provide simple presets, hide complexity |
| Pattern timing issues | Medium | High | Extensive testing, use Quant religiously |
| Performance problems | Medium | Medium | Profile early, optimize hotspots |
| User learning curve too steep | High | Medium | Excellent docs, many examples |
| SC API changes break compatibility | Low | High | Lock to SC version, document requirements |
| Reproducibility breaks across platforms | Medium | High | Test on all platforms, document quirks |
| Scope creep | High | Medium | Strict phase gates, defer features |

---

## Version History

| Version | Date | Milestone | Status |
|---------|------|-----------|--------|
| 0.1.0 | TBD | Phase 0 complete | ⬜ |
| 0.2.0 | TBD | Phase 1-2 complete | ⬜ |
| 0.3.0 | TBD | Phase 3-4 complete | ⬜ |
| 0.4.0 | TBD | Phase 5-6 complete | ⬜ |
| 0.5.0 | TBD | Phase 7-8 complete | ⬜ |
| 0.9.0 | TBD | Phase 9-10 complete (beta) | ⬜ |
| 1.0.0 | TBD | Phase 11-12 complete (release) | ⬜ |

---

## Team & Roles (if applicable)

| Role | Assignee | Phases | Status |
|------|----------|--------|--------|
| Lead Developer | TBD | All | - |
| Music Theory Consultant | TBD | 2, 4, 5 | - |
| UX Designer | TBD | 9 | - |
| Documentation Writer | TBD | 11 | - |
| Tester | TBD | All | - |

---

## Notes & Decisions

### 2026-01-08: Initial Planning
- Decided to expand from EDM-focused to genre-agnostic
- Added music theory modules (harmony, melody, counterpoint, form)
- Estimated timeline: 36 weeks for full 1.0 release
- Core functionality (Phases 0-8) achievable in ~24 weeks

### Decision Log
- **DSL Language**: Use YAML instead of custom parser (saves ~3 weeks)
- **GUI Framework**: Use built-in SC GUI (QT), not custom (saves ~2 weeks)
- **Pattern System**: Wrap, don't replace SC Patterns (architectural decision)
- **Music Theory**: Use common-practice theory as default, extensible for other systems

---

## Daily/Weekly Progress (to be filled during implementation)

### Week 1
- [ ] Day 1:
- [ ] Day 2:
- [ ] Day 3:
- [ ] Day 4:
- [ ] Day 5:

[Continue for all weeks...]

---

**Last Updated**: 2026-01-08
**Next Review**: TBD
**Overall Progress**: 0% (Planning phase)
