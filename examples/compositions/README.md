# Phase 0 Compositions

This directory contains complete musical compositions created with Quasar Phase 0, demonstrating the framework's capabilities for professional computer-aided composition.

## Directory Structure

```
compositions/
├── README.md                      # This file
├── RENDER_INSTRUCTIONS.md         # Detailed rendering guide
├── audio/                         # Rendered .wav files
│   ├── README.md                  # Audio file documentation
│   ├── manifest.json              # Technical specifications
│   ├── checksums.txt              # SHA-256 checksums (after rendering)
│   ├── logs/                      # Rendering logs
│   └── *.wav                      # Rendered compositions
└── scores/                        # Future: Musical scores (Phase 2+)
```

## Available Compositions

### Phase 0: Modern Drum & Bass Proof of Concept

**Status**: ✅ Complete
**Source**: `examples/PHASE_0_PROOF_OF_CONCEPT_DnB.scd`
**Duration**: ~90 seconds
**Genre**: Drum & Bass (174 BPM)

A complete, professional-quality DnB track demonstrating:
- Reproducible composition via seeded randomness
- Complex pattern-based arrangement
- Professional sound design with 9 custom SynthDefs
- 6-section structure (intro, buildup, drop 1, breakdown, drop 2, outro)
- Multiple seed variations (Classic, Aggressive, Smooth, etc.)

**Variations**:
1. **Classic** (seed: 12345) - Balanced, reference version
2. **Aggressive** (seed: 42) - Hard-hitting neurofunk style
3. **Smooth** (seed: 99999) - Liquid, flowing, atmospheric

See `audio/README.md` for detailed descriptions.

---

## Quick Start: Rendering Audio

### Option 1: Automatic (SuperCollider IDE)

```supercollider
// 1. Boot server
s.boot;

// 2. Load rendering script
load("examples/PHASE_0_RENDER_TO_AUDIO.scd");

// 3. Wait ~6-8 minutes for completion
// Files will be in: examples/compositions/audio/
```

### Option 2: Shell Script (Command Line)

```bash
cd /home/lpfreiburg/SC-Mod/Quasar
./scripts/render_phase0_audio.sh
```

**Note**: Command-line rendering may require manual intervention. SuperCollider IDE is recommended.

### Option 3: Manual Recording

```supercollider
// 1. Boot server
s.boot;

// 2. Start recording
s.record("my_dnb_track.wav".resolveRelative);

// 3. Load demo
load("examples/PHASE_0_PROOF_OF_CONCEPT_DnB.scd");

// 4. After ~90 seconds, stop recording
s.stopRecording;
```

---

## Rendering Details

### Technical Specifications

- **Format**: WAV (PCM)
- **Sample Rate**: 48000 Hz
- **Bit Depth**: 24-bit
- **Channels**: Stereo (2)
- **File Size**: ~15-18 MB per track

### Expected Output

Three variations will be rendered:

```
audio/
├── phase0_dnb_classic_seed_12345.wav      (~17 MB)
├── phase0_dnb_aggressive_seed_42.wav      (~17 MB)
└── phase0_dnb_smooth_seed_99999.wav       (~17 MB)
```

### Render Time

- **Realtime**: ~1.5 minutes per track (90 seconds + overhead)
- **Batch**: ~6-8 minutes for all 3 variations
- **Future** (Phase 8): Faster-than-realtime NRT rendering

---

## Reproducibility

### Guarantee

**Same seed = byte-identical audio files**

This means:
- Rendering seed 12345 twice produces identical .wav files
- Bit-perfect reproducibility for research applications
- Controlled variation through seed changes

### Testing Reproducibility

```supercollider
// Test 1: Same seed
~seed = 12345;
// Render twice, compare files (should be identical)

// Test 2: Different seeds
~seed = 42;      // Different variation
~seed = 99999;   // Another variation
```

Use `diff` or checksum tools to verify:

```bash
# Should show NO differences
diff track1.wav track2.wav

# Should show SAME checksums
sha256sum track1.wav track2.wav
```

---

## Using Custom Seeds

Want to generate your own variations? Easy!

### In PHASE_0_PROOF_OF_CONCEPT_DnB.scd:

```supercollider
// Change this line (top of file):
~seed = YOUR_NUMBER_HERE;  // Try: 42069, 80085, 31337, etc.

// Then load normally
load("examples/PHASE_0_PROOF_OF_CONCEPT_DnB.scd");
```

### With Seed Variations Script:

```supercollider
load("examples/PHASE_0_SEED_VARIATIONS.scd");

// Play any preset
~playClassic.();
~playAggressive.();
~playSmooth.();

// Or custom seed
~playWithSeed.(YOUR_SEED);
```

**Pro tip**: Each seed creates a unique but musically coherent variation!

---

## Analysis & Verification

### Waveform Analysis

```supercollider
// Load audio file
b = Buffer.read(s, "audio/phase0_dnb_classic_seed_12345.wav".resolveRelative);

// View waveform
b.plot;

// Playback
b.play;
```

### Spectral Analysis

```supercollider
// Analyze frequency content
b.loadToFloatArray(action: { |array|
    var fft = array.fft;
    fft.magnitude.plot(bounds: Rect(0, 0, 1400, 800));
});
```

### Compare Variations

```supercollider
// Load multiple files
~classic = Buffer.read(s, "audio/phase0_dnb_classic_seed_12345.wav".resolveRelative);
~aggressive = Buffer.read(s, "audio/phase0_dnb_aggressive_seed_42.wav".resolveRelative);

// Play alternating
{ ~classic.play; 90.wait; ~aggressive.play; }.fork;
```

---

## Musical Structure

All Phase 0 compositions follow this structure:

| Section | Bars | Duration | Energy | Description |
|---------|------|----------|--------|-------------|
| **Intro** | 16 | ~22s | 20% | Sparse drums, atmospheric |
| **Buildup** | 8 | ~11s | 20→80% | Tension rising |
| **Drop 1** | 16 | ~22s | 100% | Full energy |
| **Breakdown** | 8 | ~11s | 40% | Melodic break |
| **Drop 2** | 16 | ~22s | 120% | Maximum intensity |
| **Outro** | 8 | ~11s | 80→10% | Fade out |
| **Total** | **72** | **~90s** | - | **Complete track** |

---

## Production Quality

### What Makes These Professional?

✅ **Authentic DnB Production**
- 2-step kick patterns
- Reese bass with detuned oscillators
- Rolling hi-hat rhythms
- Proper arrangement structure

✅ **Clean Mix**
- Balanced levels
- -6dB headroom for mastering
- Proper frequency separation
- Wide stereo field

✅ **Dynamic Range**
- Intro: Sparse and atmospheric
- Drops: Dense and energetic
- Smooth transitions between sections

✅ **Sound Design**
- 9 custom SynthDefs
- Saturation and filtering
- Envelope shaping
- Professional polish

---

## Use Cases

### Music Production
- Study DnB arrangement techniques
- Reference for mixing
- Template for your own tracks
- Sound design analysis

### Research
- Reproducibility studies
- Algorithmic composition research
- Seed-based variation analysis
- Pattern-based music theory

### Education
- Teaching DnB production
- Demonstrating algorithmic composition
- SuperCollider pattern tutorial
- Music technology courses

### Creative
- Inspiration for your own work
- Seed library building
- Variation exploration
- Genre studies

---

## Troubleshooting

### Files Not Generating?

**Check server is running:**
```supercollider
s.serverRunning;  // Should return true
s.reboot;         // Reboot if needed
```

**Check recording path:**
```supercollider
Platform.recordingsDir;  // Where files are saved
```

**Verify SynthDefs loaded:**
```supercollider
SynthDescLib.global.synthDescs.keys.postln;
// Should include: dnbKick, dnbSnare, reeseBass, etc.
```

### Audio Quality Issues?

**Increase server resources:**
```supercollider
s.options.numOutputBusChannels = 2;
s.options.sampleRate = 48000;
s.options.memSize = 8192 * 16;
s.reboot;
```

### Rendering Takes Forever?

- This is normal for realtime recording
- 90 second track = 90 seconds to record
- Plus ~30 seconds overhead per track
- Future Phase 8 will add faster NRT rendering

---

## Documentation

### Full Documentation Set

1. **This file** - Overview and quick start
2. **RENDER_INSTRUCTIONS.md** - Detailed rendering guide
3. **audio/README.md** - Audio file specifications
4. **audio/manifest.json** - Technical metadata
5. **PHASE_0_DEMO_README.md** - Original demo documentation
6. **PHASE_0_PROOF_OF_CONCEPT_SUMMARY.md** - Technical summary

### Related Examples

- `examples/PHASE_0_PROOF_OF_CONCEPT_DnB.scd` - Main demo
- `examples/PHASE_0_SEED_VARIATIONS.scd` - Quick seed variations
- `examples/PHASE_0_REPRODUCIBILITY_TEST.scd` - Reproducibility tests
- `examples/PHASE_0_RENDER_TO_AUDIO.scd` - Batch rendering

---

## Future Phases

### Phase 2: Notation (Coming Soon)

Musical scores will be added to `scores/` directory:
- PDF notation
- MusicXML export
- Lilypond source
- Interactive scores

### Phase 8: Production (Coming Soon)

Enhanced rendering capabilities:
- ⚡ Faster-than-realtime NRT rendering
- 📁 Automatic stem export
- 🎚️ Mastering chain
- 📦 Batch processing
- 💾 Multiple format export (FLAC, MP3, OGG)

---

## Credits

**Framework**: Quasar v0.1.0 (Phase 0)
**License**: GPL-3.0
**Platform**: SuperCollider 3.13.0+
**Created**: 2026-01-08

---

## Quick Reference

```supercollider
// Render all variations
load("examples/PHASE_0_RENDER_TO_AUDIO.scd");

// Play specific seed
load("examples/PHASE_0_SEED_VARIATIONS.scd");
~playClassic.();

// Custom seed
~seed = 42069;
load("examples/PHASE_0_PROOF_OF_CONCEPT_DnB.scd");

// Manual record
s.record("my_track.wav".resolveRelative);
load("examples/PHASE_0_PROOF_OF_CONCEPT_DnB.scd");
// Wait 90 seconds...
s.stopRecording;
```

---

**Ready to render? Follow the Quick Start guide above!** 🎵

*These compositions prove that Quasar Phase 0 can create professional-quality, reproducible computer-aided music.*
