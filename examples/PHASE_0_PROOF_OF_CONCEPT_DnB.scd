/*
PHASE 0 PROOF OF CONCEPT: Modern Drum & Bass Track

This demonstrates the full capabilities of Quasar Phase 0 by creating
a complete, professional-sounding DnB track with:

- Full track structure (intro, buildup, drop, breakdown, drop 2, outro)
- Modern DnB elements (174 BPM, Reese bass, breakbeats)
- Multiple patterns and sections
- Reproducible with seeds (same seed = same track)
- Clean architecture showcasing Phase 0 features

FEATURES DEMONSTRATED:
✓ QProject with seeded randomness
✓ QTimeline with multiple sections
✓ QConductor playback
✓ QScene audio layers
✓ Pattern-based composition
✓ Tempo control (174 BPM DnB standard)
✓ Clean startup/shutdown

INSTRUCTIONS:
1. Boot server
2. Load SynthDefs
3. Run this script
4. Try different seeds for variations!

Version: 0.1.0 (Phase 0)
Duration: ~90 seconds (174 BPM)
*/

(
// ====================================
// CONFIGURATION
// ====================================

// Change this seed for different variations!
// Same seed = identical track (reproducibility test)
~seed = 12345; // Try: 42, 99999, 54321, etc.

~tempo = 174; // Standard DnB tempo

"".postln;
"===========================================".postln;
"PHASE 0 PROOF OF CONCEPT".postln;
"Modern Drum & Bass Track".postln;
"===========================================".postln;
"Tempo: % BPM".format(~tempo).postln;
"Seed:  % (change for variations)".format(~seed).postln;
"===========================================".postln;
"".postln;

// ====================================
// LOAD SYNTHDEFS
// ====================================

"Loading DnB SynthDefs...".postln;
load(thisProcess.nowExecutingPath.dirname.dirname +/+ "resources/SynthDefs/dnb_synthdefs.scd");

// Wait for SynthDefs to load
s.sync;

"SynthDefs loaded!".postln;
"".postln;

// ====================================
// CREATE PROJECT
// ====================================

"Creating Quasar project...".postln;
q = QProject.new(tempo: ~tempo, seed: ~seed);
q.title = "Phase 0 DnB Demo";
q.author = "Quasar";

"".postln;

// ====================================
// SECTION 1: INTRO (16 bars)
// ====================================

"Adding INTRO section...".postln;

q.timeline.add(
    name: \intro,
    duration: 64, // 16 bars at 4/4

    pattern: Ppar([
        // Kick - every 4 beats
        Pbind(
            \instrument, \dnbKick,
            \dur, 4,
            \amp, 0.5,
            \decay, 0.3
        ),

        // Hi-hats - 16th notes
        Pbind(
            \instrument, \dnbHatClosed,
            \dur, 0.25,
            \amp, Pseq([0.15, 0.08, 0.1, 0.08], inf),
            \decay, 0.04,
            \pan, Pwhite(-0.3, 0.3)
        ),

        // Pad - atmospheric
        Pbind(
            \instrument, \dnbPad,
            \dur, 16,
            \degree, Pseq([0, 2, 4, 7], inf),
            \octave, 4,
            \scale, Scale.minor,
            \amp, 0.15,
            \cutoff, 1500,
            \legato, 1.5
        )
    ])
);

// ====================================
// SECTION 2: BUILDUP (8 bars)
// ====================================

"Adding BUILDUP section...".postln;

q.timeline.add(
    name: \buildup,
    duration: 32, // 8 bars

    pattern: Ppar([
        // Kick - building energy
        Pbind(
            \instrument, \dnbKick,
            \dur, Pseq([2, 2, 1, 1, 1, 1], inf),
            \amp, 0.6,
            \decay, 0.35
        ),

        // Snare - building
        Pbind(
            \instrument, \dnbSnare,
            \dur, Pseq([Rest(6), 2, 1, 1], inf),
            \amp, 0.35,
            \tune, Pwhite(-50, 50)
        ),

        // Hi-hats - intensifying
        Pbind(
            \instrument, \dnbHatClosed,
            \dur, 0.25,
            \amp, Penv([0.1, 0.25], [32], \exp), // Build energy
            \decay, 0.04
        ),

        // Reese bass - hint
        Pbind(
            \instrument, \reeseBass,
            \dur, 8,
            \degree, Pseq([0], inf),
            \octave, 2,
            \scale, Scale.minor,
            \amp, 0.25,
            \cutoff, 600,
            \detune, 3,
            \legato, 0.9
        ),

        // Arp - building tension
        Pbind(
            \instrument, \dnbArp,
            \dur, 0.5,
            \degree, Pseq([0, 2, 4, 7, 9, 7, 4, 2], inf),
            \octave, 5,
            \scale, Scale.minor,
            \amp, Penv([0.15, 0.3], [32], \exp)
        )
    ])
);

// ====================================
// SECTION 3: DROP 1 (16 bars)
// ====================================

"Adding DROP 1 section...".postln;

q.timeline.add(
    name: \drop1,
    duration: 64, // 16 bars

    pattern: Ppar([
        // Kick - DnB pattern (2-step)
        Pbind(
            \instrument, \dnbKick,
            \dur, Pseq([0.75, 0.75, 0.5, 1, 1], inf),
            \amp, 0.7,
            \decay, 0.4
        ),

        // Snare - on the 2 and 4
        Pbind(
            \instrument, \dnbSnare,
            \dur, Pseq([2, 2], inf),
            \amp, 0.4,
            \tune, Pwhite(-30, 30)
        ),

        // Hi-hats - complex rhythm
        Pbind(
            \instrument, \dnbHatClosed,
            \dur, Prand([0.25, 0.5, 0.125], inf),
            \amp, Prand([0.15, 0.1, 0.08], inf),
            \decay, Prand([0.03, 0.05], inf),
            \pan, Pwhite(-0.4, 0.4)
        ),

        // Open hat accents
        Pbind(
            \instrument, \dnbHatOpen,
            \dur, Prand([4, 8, Rest(8)], inf),
            \amp, 0.25,
            \decay, 0.15
        ),

        // Reese bass - main bassline
        Pbind(
            \instrument, \reeseBass,
            \dur, Pseq([1, 1, 0.5, 0.5, 2, 1, 1, 1], inf),
            \degree, Pseq([0, 0, 2, 0, 0, -2, 0, 0], inf),
            \octave, 2,
            \scale, Scale.minor,
            \amp, 0.45,
            \cutoff, Pwhite(700, 1200),
            \detune, 3,
            \res, 0.4,
            \legato, 0.9
        ),

        // Sub bass - foundation
        Pbind(
            \instrument, \subBass,
            \dur, 2,
            \degree, Pseq([0, 0, 0, 0, -2, 0, 0, 0], inf),
            \octave, 2,
            \scale, Scale.minor,
            \amp, 0.55,
            \legato, 0.95
        ),

        // Pad - atmosphere
        Pbind(
            \instrument, \dnbPad,
            \dur, 8,
            \degree, Pseq([0, 2, 4, 7], inf),
            \octave, 4,
            \scale, Scale.minor,
            \amp, 0.18,
            \cutoff, 2000,
            \legato, 1.3
        ),

        // Vocal stabs - accent
        Pbind(
            \instrument, \vocalStab,
            \dur, Prand([8, 16, Rest(16)], inf),
            \freq, Prand([200, 250, 180], inf),
            \formant, Prand([400, 600, 800], inf),
            \amp, 0.35
        )
    ])
);

// ====================================
// SECTION 4: BREAKDOWN (8 bars)
// ====================================

"Adding BREAKDOWN section...".postln;

q.timeline.add(
    name: \breakdown,
    duration: 32, // 8 bars

    pattern: Ppar([
        // Kick - sparse
        Pbind(
            \instrument, \dnbKick,
            \dur, 8,
            \amp, 0.4,
            \decay, 0.3
        ),

        // Hi-hats - reduced
        Pbind(
            \instrument, \dnbHatClosed,
            \dur, 0.5,
            \amp, 0.1,
            \decay, 0.05,
            \pan, Pwhite(-0.5, 0.5)
        ),

        // Pad - dominant
        Pbind(
            \instrument, \dnbPad,
            \dur, 8,
            \degree, Pseq([4, 7, 0, 2], inf),
            \octave, 4,
            \scale, Scale.minor,
            \amp, 0.25,
            \cutoff, 3000,
            \legato, 1.5
        ),

        // Arp - melodic element
        Pbind(
            \instrument, \dnbArp,
            \dur, 0.25,
            \degree, Pseq([0, 2, 4, 7, 9, 11, 9, 7], inf),
            \octave, 5,
            \scale, Scale.minor,
            \amp, 0.25
        )
    ])
);

// ====================================
// SECTION 5: DROP 2 (16 bars)
// ====================================

"Adding DROP 2 section (variation)...".postln;

q.timeline.add(
    name: \drop2,
    duration: 64, // 16 bars

    pattern: Ppar([
        // Kick - aggressive pattern
        Pbind(
            \instrument, \dnbKick,
            \dur, Pseq([0.75, 0.75, 0.5, 0.5, 0.5, 1], inf),
            \amp, 0.75,
            \decay, 0.4
        ),

        // Snare - tight
        Pbind(
            \instrument, \dnbSnare,
            \dur, Pseq([2, 2], inf),
            \amp, 0.45,
            \tune, Pwhite(-20, 20),
            \decay, 0.12
        ),

        // Hi-hats - rolling
        Pbind(
            \instrument, \dnbHatClosed,
            \dur, 0.125,
            \amp, Pseq([0.15, 0.08, 0.1, 0.08, 0.12, 0.08, 0.1, 0.08], inf),
            \decay, 0.03,
            \pan, Pwhite(-0.5, 0.5)
        ),

        // Open hats
        Pbind(
            \instrument, \dnbHatOpen,
            \dur, Prand([2, 4, Rest(4)], inf),
            \amp, 0.3,
            \decay, 0.18
        ),

        // Reese bass - varied pattern
        Pbind(
            \instrument, \reeseBass,
            \dur, Pseq([0.5, 0.5, 1, 1, 0.5, 0.5, 1, 1], inf),
            \degree, Pseq([0, 2, 0, -2, 0, 4, 0, -2], inf),
            \octave, 2,
            \scale, Scale.minor,
            \amp, 0.5,
            \cutoff, Pwhite(800, 1400),
            \detune, Pwhite(2, 4),
            \res, 0.35,
            \legato, 0.85
        ),

        // Sub bass
        Pbind(
            \instrument, \subBass,
            \dur, Pseq([1, 1, 2], inf),
            \degree, Pseq([0, 2, 0, 0, -2, 0], inf),
            \octave, 2,
            \scale, Scale.minor,
            \amp, 0.6,
            \legato, 0.9
        ),

        // Pad - layered
        Pbind(
            \instrument, \dnbPad,
            \dur, 16,
            \degree, Pseq([0, 4, 2, 7], inf),
            \octave, 4,
            \scale, Scale.minor,
            \amp, 0.2,
            \cutoff, 2500,
            \legato, 1.4
        ),

        // Vocal stabs - more frequent
        Pbind(
            \instrument, \vocalStab,
            \dur, Prand([4, 8], inf),
            \freq, Prand([180, 200, 220, 250], inf),
            \formant, Prand([500, 700, 900], inf),
            \amp, 0.4
        )
    ])
);

// ====================================
// SECTION 6: OUTRO (8 bars)
// ====================================

"Adding OUTRO section...".postln;

q.timeline.add(
    name: \outro,
    duration: 32, // 8 bars

    pattern: Ppar([
        // Kick - fading
        Pbind(
            \instrument, \dnbKick,
            \dur, 4,
            \amp, Penv([0.5, 0.1], [32], \exp),
            \decay, 0.3
        ),

        // Hi-hats - fading
        Pbind(
            \instrument, \dnbHatClosed,
            \dur, 0.25,
            \amp, Penv([0.12, 0.02], [32], \exp),
            \decay, 0.05
        ),

        // Pad - fading out
        Pbind(
            \instrument, \dnbPad,
            \dur, 8,
            \degree, Pseq([0, -2, -4, -7], inf),
            \octave, 4,
            \scale, Scale.minor,
            \amp, Penv([0.2, 0.05], [32], \exp),
            \cutoff, Penv([2000, 800], [32], \exp),
            \legato, 1.5
        )
    ])
);

// ====================================
// DISPLAY INFO
// ====================================

"".postln;
q.timeline.postInfo;

"===========================================".postln;
"Track Structure:".postln;
"  1. Intro     (16 bars) - Sparse, atmospheric".postln;
"  2. Buildup   (8 bars)  - Building tension".postln;
"  3. Drop 1    (16 bars) - Full energy".postln;
"  4. Breakdown (8 bars)  - Melodic break".postln;
"  5. Drop 2    (16 bars) - Maximum energy".postln;
"  6. Outro     (8 bars)  - Fade out".postln;
"".postln;
"Total: 72 bars / % beats".format(q.timeline.totalDuration).postln;
"Duration: ~% seconds at % BPM".format(
    (q.timeline.totalDuration / (q.tempo / 60)).round(1),
    q.tempo
).postln;
"===========================================".postln;
"".postln;

// ====================================
// PLAYBACK INSTRUCTIONS
// ====================================

"Ready to play!".postln;
"".postln;
"Commands:".postln;
"  q.play;     // Start playback".postln;
"  q.stop;     // Stop playback".postln;
"  q.pause;    // Pause".postln;
"  q.resume;   // Resume".postln;
"  q.free;     // Clean up".postln;
"".postln;
"Starting playback in 3 seconds...".postln;
"".postln;

// Auto-play after delay
{
    3.wait;
    "▶ PLAYING...".postln;
    "".postln;
    q.play;
}.fork;
)

// ====================================
// MANUAL CONTROLS
// ====================================

// Stop playback
// q.stop;

// Restart
// q.play;

// Show info
// q.postInfo;
// q.timeline.postInfo;
// q.conductor.postInfo;

// Clean up when done
// q.free;
