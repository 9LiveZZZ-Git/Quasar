# Quasar Examples

This directory contains example compositions and demonstrations of Quasar features.

## Current Status: Phase Zero (Skeleton)

The examples in this directory currently demonstrate the **skeleton structure** of Quasar. They show the API design and how the framework will be used, but actual music generation is not yet implemented.

## Example Index

### Getting Started

- **00_hello_quasar.scd** - Verify Quasar installation and basic project creation
- **01_project_creation.scd** - Different ways to create and configure projects
- **02_theory_exploration.scd** - Access theory subsystems (skeleton)

### Core Composition (Coming in Phase 0-7)

- 03_unit_selection.scd - Unit database and intelligent selection
- 04_harmony_generation.scd - Chord progressions and voice leading
- 05_melody_generation.scd - Melodic contours and development
- 06_rhythm_patterns.scd - Rhythmic patterns and syncopation
- 07_timeline_structure.scd - Building formal structures

### Genre Templates (Coming in Phase 0-7)

- 10_baroque_fugue.scd - Four-voice fugue with counterpoint
- 11_classical_sonata.scd - Sonata form with development
- 12_jazz_standard.scd - AABA form with chord changes
- 13_edm_track.scd - Intro/build/drop/break structure
- 14_minimalism.scd - Gradual process composition

### Production (Coming in Phase 8)

- 20_mixing.scd - Automatic mixing with QMix
- 21_mastering.scd - Mastering for different platforms
- 22_poses.scd - Musical poses and micro-gestures
- 23_lofi_mess.scd - Controlled imperfection with QMess

### Advanced (Coming in Phase 9-18)

- 30_klotho_integration.scd - Using Klotho CAC toolkit
- 31_orchestration.scd - Orchestration validation and humanization
- 32_spatial_audio.scd - 3D audio and Dolby Atmos
- 33_adaptive_music.scd - Game/installation music
- 34_live_performance.scd - Live coding and cue systems
- 35_corpus_learning.scd - Learn from existing music

## How to Use Examples

1. **Start SuperCollider**
2. **Boot the audio server**: `s.boot;`
3. **Open an example file**
4. **Execute the code**: Cmd+Enter (Mac) or Ctrl+Enter (Linux/Windows)

## Contributing Examples

If you create interesting compositions with Quasar, please consider contributing them!

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## Example Template

```supercollider
/*
Example XX: Title

Brief description of what this example demonstrates.

Phase: X
Status: Working / Skeleton / In Progress
*/

(
s.waitForBoot({
    "=== Example XX: Title ===".postln;

    // Your code here

    "Example complete!".postln;
});
)
```

---

**Phase Zero Complete**: Basic skeleton examples available
**Coming Soon**: Phase 0-7 will add functioning composition examples
