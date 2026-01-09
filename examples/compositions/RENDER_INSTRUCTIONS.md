# Phase 0 Audio Rendering Instructions

This guide explains how to render the Phase 0 DnB proof of concept to audio files.

## Quick Start (Realtime Recording)

### In SuperCollider IDE:

1. **Boot the server:**
   ```supercollider
   s.boot;
   ```

2. **Run the rendering script:**
   ```supercollider
   load("PHASE_0_RENDER_TO_AUDIO.scd");
   ```

3. **Wait for completion** (~6-8 minutes for 3 variations)

4. **Find your files** in: `examples/compositions/audio/`

---

## Alternative: Manual Recording

If you prefer to record manually while listening:

### For each seed variation:

1. **Boot server and prepare:**
   ```supercollider
   s.boot;

   // Start recording
   s.record("phase0_dnb_classic_seed_12345.wav".resolveRelative);
   ```

2. **Load and play the demo:**
   ```supercollider
   // Set seed
   ~seed = 12345;  // Try: 42, 99999, 54321, etc.

   // Load demo
   load("PHASE_0_PROOF_OF_CONCEPT_DnB.scd");
   ```

3. **Wait for playback to complete** (~90 seconds)

4. **Stop recording:**
   ```supercollider
   s.stopRecording;
   ```

5. **Repeat** with different seeds:
   - Classic: 12345
   - Aggressive: 42
   - Smooth: 99999
   - Chaotic: 54321
   - Minimal: 11111
   - Maximal: 77777

---

## Alternative: Using Seed Variations Script

### Quick recording with presets:

1. **Boot server and start recording:**
   ```supercollider
   s.boot;
   s.record("phase0_dnb_aggressive.wav".resolveRelative);
   ```

2. **Load variations script:**
   ```supercollider
   load("PHASE_0_SEED_VARIATIONS.scd");
   ```

3. **Play a preset:**
   ```supercollider
   ~playAggressive.();
   ```

4. **Stop recording after completion:**
   ```supercollider
   s.stopRecording;
   ```

---

## Command-Line Rendering (Advanced)

For headless/batch rendering, use the NRT script:

```bash
cd /home/lpfreiburg/SC-Mod/Quasar/examples
sclang PHASE_0_RENDER_NRT.scd
```

This requires SuperCollider to be in your PATH.

---

## Expected Output Files

After rendering, you should have these files in `examples/compositions/audio/`:

```
phase0_dnb_classic_seed_12345.wav       (~90 seconds, 48kHz, 24-bit)
phase0_dnb_aggressive_seed_42.wav       (~90 seconds, 48kHz, 24-bit)
phase0_dnb_smooth_seed_99999.wav        (~90 seconds, 48kHz, 24-bit)
```

Each file demonstrates:
- ✓ Same code, different seed
- ✓ Unique variations
- ✓ Reproducibility (same seed = identical audio)
- ✓ Professional DnB production quality

---

## File Specifications

- **Format**: WAV (PCM)
- **Sample Rate**: 48000 Hz
- **Bit Depth**: 24-bit
- **Channels**: Stereo (2)
- **Duration**: ~90 seconds per track
- **File Size**: ~15-20 MB per file

---

## Verification

To verify reproducibility:

1. Record the same seed twice
2. Compare the waveforms (should be identical)
3. Try different seeds (should be different but musically coherent)

---

## Troubleshooting

### Recording not starting:

```supercollider
// Check server is running
s.serverRunning;

// Reboot if needed
s.reboot;
```

### Files not appearing:

```supercollider
// Check recording path
s.recHeaderFormat;
s.recSampleFormat;

// Check default recording directory
Platform.recordingsDir;
```

### Audio quality issues:

```supercollider
// Increase server resources
s.options.numOutputBusChannels = 2;
s.options.sampleRate = 48000;
s.options.memSize = 8192 * 16;
s.reboot;
```

---

## Notes

- **Phase 0** uses realtime recording (Server.record)
- **Phase 8** will add professional NRT rendering with:
  - Faster than realtime rendering
  - Exact sample-accurate output
  - Batch processing
  - Automatic stem export
  - Mastering chain

For now, realtime recording captures the full Phase 0 experience including any subtle timing variations from the pattern engine.

---

**Ready to render? Follow Quick Start above!**
