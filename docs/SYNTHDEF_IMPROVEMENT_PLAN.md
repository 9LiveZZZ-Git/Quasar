# DnB SynthDef Improvement Plan

**Goal**: Professional-quality modern Drum & Bass synthesis
**Current Status**: Basic sounds, need significant enhancement
**Target**: Industry-standard neurofunk/liquid DnB production quality

---

## Current Issues Identified

### 1. Kick Drum ❌
- **Issue**: Frequency too high (50Hz start)
- **Issue**: Not enough body/weight
- **Issue**: Missing layered approach (sub + mid + click)
- **Target**: 30-40Hz fundamental, proper pitch envelope, punchy and deep

### 2. Snare ⚠️
- **Issue**: Basic structure but lacks body
- **Issue**: Needs more layering (body + crack + noise)
- **Issue**: Missing FM/ring modulation for modern character
- **Target**: Crisp, cutting snare with body and presence

### 3. Hi-Hats ❌
- **Issue**: Too quiet (amp 0.15 closed, 0.2 open)
- **Issue**: Filtering too narrow, lacks air and presence
- **Issue**: Missing metallic character
- **Target**: Bright, crisp, audible hats with proper stereo width

### 4. Reese Bass ❌
- **Issue**: Basic detuned saws only
- **Issue**: Missing chorus/phasing for movement
- **Issue**: Needs multiple filter stages
- **Issue**: Lacks low-end weight
- **Target**: Thick, moving, evolving Reese with proper low end

### 5. Sub Bass ❌
- **Issue**: Plain sine wave, too simple
- **Issue**: Missing harmonics for audibility
- **Issue**: Envelope too generic
- **Target**: Felt sub with subtle harmonics, tight envelope

### 6. Pad ⚠️
- **Issue**: Static, no movement
- **Issue**: Needs modulation and evolving character
- **Issue**: Lacks depth and width
- **Target**: Lush, evolving pad with movement and space

---

## Improvement Strategy

### Phase 1: Critical Fixes (Drums)
These are the most audible issues affecting the track quality.

#### 1.1 Kick Drum - Professional Design
```
Layered approach:
- SUB layer: 30-40Hz sine, tight pitch envelope (2 octaves down in 50ms)
- BODY layer: 60-80Hz sine/triangle, medium decay
- CLICK layer: Noise burst 2-8kHz, very short (1-3ms)
- MID layer: 150-300Hz for presence

Envelope:
- Attack: 0-1ms (instant)
- Decay: 200-400ms (varies with tempo)
- Curve: Exponential for natural punch

Processing:
- Saturation for harmonics
- Subtle compression
- HP filter at 25Hz (clean up rumble)
```

#### 1.2 Snare - Layered & Punchy
```
Three-layer approach:
- BODY: 180-220Hz fundamental (FM synth or sine)
- CRACK: Ring modulation 800-1200Hz
- NOISE: Filtered white noise 1.5-8kHz

Envelope:
- Body: Medium decay (100-150ms)
- Crack: Short decay (50ms)
- Noise: Short to medium (80-120ms)

Processing:
- Saturation/distortion for grit
- Transient shaping
- Stereo widening on noise component
```

#### 1.3 Hi-Hats - Bright & Present
```
Better synthesis:
- Multiple noise sources (white + pink)
- 6-pole bandpass filtering 6-12kHz
- Resonant peaks for metallic character
- Higher amplitude (0.4-0.6 for closed, 0.5-0.7 for open)

Closed hat:
- Decay: 30-60ms
- Tight, crisp

Open hat:
- Decay: 150-300ms
- More resonance, longer tail
- Subtle pitch modulation
```

### Phase 2: Bass Enhancement

#### 2.1 Reese Bass - Movement & Character
```
Advanced synthesis:
- 6-8 detuned oscillators (saws + squares)
- Detune range: 0-20 cents spread
- Multiple filter stages:
  * LP filter with envelope
  * BP filter for vowel-like character
  * Notch filter for movement
- LFO modulation on filters
- Chorus/ensemble effect
- Subtle phasing

Frequency range:
- Fundamental: 40-80Hz
- Harmonics: Up to 2-3kHz
- Movement: Slow evolving (0.5-2Hz LFO)

Processing:
- Multiband saturation
- OTT-style compression
- Stereo widening above 150Hz (keep low end mono)
```

#### 2.2 Sub Bass - Felt & Powerful
```
Enhanced design:
- Primary: Pure sine 30-80Hz
- Secondary: Subtle 2nd/3rd harmonic for audibility
- Envelope: Fast attack (1-5ms), medium release (100-200ms)
- Mono output (critical!)

Techniques:
- Subtle distortion for harmonics
- Pitch envelope (subtle, 2-3 semitones for 20ms)
- Sidechain compression trigger point
```

### Phase 3: Atmosphere

#### 3.1 Pad - Lush & Evolving
```
Complex synthesis:
- 12-16 detuned oscillators
- Mix of waveforms (saw, square, triangle)
- Multiple LFOs:
  * Filter cutoff (slow 0.1-0.5Hz)
  * Amplitude (slow 0.05-0.2Hz)
  * Pan/width (very slow 0.02-0.1Hz)
- Stereo spread (different tuning L/R)

Filtering:
- LP filter with slow envelope
- HP filter to remove mud
- Comb filtering for movement

Effects (built-in):
- Chorus
- Subtle phasing
- Reverb send capability
```

---

## Technical Specifications

### Modern DnB Frequency Ranges

| Element | Fundamental | Harmonics | Notes |
|---------|-------------|-----------|-------|
| **Kick** | 30-50Hz | Up to 8kHz | Sub-heavy, punchy click |
| **Snare** | 180-250Hz | 2-10kHz | Body + crack + air |
| **Hi-hats** | N/A | 6-16kHz | Bright, crisp, present |
| **Reese Bass** | 40-80Hz | Up to 3kHz | Thick, moving, evolving |
| **Sub Bass** | 30-80Hz | Minimal | Pure, felt, mono |
| **Pad** | 200Hz+ | Full range | Lush, wide, atmospheric |

### Amplitude Targets (Mix-Ready)

| Element | Peak Level | RMS Level | Notes |
|---------|-----------|-----------|-------|
| **Kick** | -3dB | -12dB | Loudest element |
| **Snare** | -6dB | -15dB | Punchy transient |
| **Hi-hats** | -12dB | -24dB | Present but not harsh |
| **Reese Bass** | -6dB | -12dB | Consistent power |
| **Sub Bass** | -9dB | -15dB | Felt not heard |
| **Pad** | -18dB | -30dB | Background atmosphere |

### Processing Chain

```
Individual SynthDef:
1. Oscillators
2. Internal modulation (envelopes, LFOs)
3. Filtering
4. Saturation/distortion
5. Final amplitude
6. Stereo placement

Post-processing (in mix):
- EQ
- Compression
- Reverb/delay (sends)
- Limiting
```

---

## Implementation Priority

### High Priority (Critical for track quality):
1. ✅ **Kick** - Most noticeable issue
2. ✅ **Reese Bass** - Core of DnB sound
3. ✅ **Sub Bass** - Foundation of low end
4. ✅ **Hi-hats** - Rhythm and energy

### Medium Priority (Enhance track):
5. ✅ **Snare** - Add punch and character
6. ✅ **Pad** - Atmosphere and depth

### Low Priority (Nice to have):
7. ⚪ **Arp** - Already functional
8. ⚪ **Vocal Stab** - Already functional

---

## Code Structure

Each improved SynthDef will include:

```supercollider
SynthDef(\improvedSynth, {
    // 1. Parameters (with sensible defaults)
    |out=0, amp=0.5, pan=0, freq=440, gate=1|

    // 2. Local variables
    var sig, env, filter, mod;

    // 3. Envelopes
    env = EnvGen.kr(Env.adsr(...), gate, doneAction: 2);

    // 4. Oscillators (layered if needed)
    sig = [layer1, layer2, layer3];

    // 5. Modulation
    mod = LFO, envelope modulation, etc.

    // 6. Filtering (multi-stage if needed)
    sig = FilterType.ar(sig, freq, res);

    // 7. Processing (saturation, etc.)
    sig = (sig * drive).tanh;

    // 8. Final mix and output
    sig = Mix(sig) * env;
    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;
```

---

## Testing Plan

### 1. Individual Testing
- Test each SynthDef in isolation
- Verify frequency content (spectrum analyzer)
- Check amplitude levels
- Listen for artifacts/clicks

### 2. Mix Testing
- Test in context with other elements
- Check for masking issues
- Verify stereo field
- Check low-end mono compatibility

### 3. Comparison
- Compare to reference DnB tracks
- Match frequency balance
- Match perceived loudness
- Match character and vibe

---

## Success Criteria

Each SynthDef must meet these standards:

✅ **Kick**:
- Deep sub presence (30-40Hz audible on spectrum)
- Punchy transient (visible on waveform)
- Clean, no clicks or artifacts
- Proper decay time for 174 BPM

✅ **Snare**:
- Clear, cutting through mix
- Balanced body and crack
- Proper stereo width
- No harshness

✅ **Hi-hats**:
- Clearly audible in mix
- Bright but not harsh
- Proper stereo movement
- Tight timing

✅ **Reese Bass**:
- Thick, moving sound
- Proper low-end weight
- Evolving character
- No muddiness

✅ **Sub Bass**:
- Felt in chest/body
- Mono and centered
- Clean, no distortion (unless intended)
- Proper headroom

✅ **Pad**:
- Lush and wide
- Evolving movement
- Sits in background
- No harshness

---

## Reference Tracks (Neurofunk/DnB)

Listen to these for sound design reference:
- Noisia - "Tentacles" (drums, bass design)
- Mefjus - "Suicide Bassline" (Reese character)
- Phace - "Cold Champagne" (overall production)
- Black Sun Empire - "Arrakis" (drums and energy)
- Current Value - "Dark Rain" (sound design)

Focus on:
- Kick punch and weight
- Reese movement and character
- Hi-hat presence
- Sub bass power
- Overall mix balance

---

## Timeline

1. **Kick improvement**: 30 minutes (most critical)
2. **Reese bass enhancement**: 45 minutes (complex)
3. **Sub bass refinement**: 20 minutes
4. **Hi-hat improvement**: 20 minutes
5. **Snare enhancement**: 30 minutes
6. **Pad design**: 30 minutes
7. **Testing & tweaking**: 30 minutes
8. **Re-render audio**: 10 minutes

**Total estimated time**: ~3.5 hours for professional quality

---

**Let's create industry-standard DnB synthesis!** 🎵
