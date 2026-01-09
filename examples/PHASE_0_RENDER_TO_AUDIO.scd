/*
PHASE 0 AUDIO RENDERING SCRIPT

This script records the Phase 0 DnB proof of concept to .wav files
for multiple seed variations, demonstrating reproducibility.

INSTRUCTIONS:
1. Boot server
2. Run this script
3. Wait for all recordings to complete (~10 minutes for 3 variations)
4. Find .wav files in: examples/compositions/audio/

NOTE: This uses realtime recording (Server.record).
NRT rendering will be available in Phase 8.

Version: 0.1.0 (Phase 0)
*/

(
// ====================================
// CONFIGURATION
// ====================================

~outputPath = thisProcess.nowExecutingPath.dirname +/+ "compositions/audio/";
~sampleRate = 48000;
~numChannels = 2;
~headerFormat = "wav";
~sampleFormat = "int24";

// Seeds to render
~seedsToRender = [
    (name: "classic", seed: 12345),
    (name: "aggressive", seed: 42),
    (name: "smooth", seed: 99999)
];

"".postln;
"==========================================".postln;
"PHASE 0 AUDIO RENDERING".postln;
"==========================================".postln;
"Output path: %".format(~outputPath).postln;
"Sample rate: % Hz".format(~sampleRate).postln;
"Format: % %".format(~headerFormat, ~sampleFormat).postln;
"Seeds to render: %".format(~seedsToRender.collect(_.name)).postln;
"==========================================".postln;
"".postln;

// ====================================
// LOAD SYNTHDEFS
// ====================================

"Loading SynthDefs...".postln;
load(thisProcess.nowExecutingPath.dirname.dirname +/+ "resources/SynthDefs/dnb_synthdefs.scd");
s.sync;
"SynthDefs loaded!".postln;
"".postln;

// ====================================
// RENDERING FUNCTION
// ====================================

~renderComposition = { |seedData|
    var filename, duration, project;

    filename = "phase0_dnb_" ++ seedData.name ++ "_seed_" ++ seedData.seed ++ ".wav";

    "".postln;
    "==========================================".postln;
    "Rendering: %".format(seedData.name).postln;
    "Seed: %".format(seedData.seed).postln;
    "File: %".format(filename).postln;
    "==========================================".postln;
    "".postln;

    // Create project
    project = QProject.new(tempo: 174, seed: seedData.seed);
    project.title = "Phase 0 DnB - " ++ seedData.name;

    // Calculate duration (72 bars at 174 BPM)
    duration = (288 / (174 / 60)) + 2; // Add 2 seconds for reverb tail

    // ====================================
    // BUILD COMPOSITION (from main demo)
    // ====================================

    // INTRO (16 bars)
    project.timeline.add(
        name: \intro,
        duration: 64,
        pattern: Ppar([
            Pbind(
                \instrument, \dnbKick,
                \dur, 4,
                \amp, 0.5,
                \decay, 0.3
            ),
            Pbind(
                \instrument, \dnbHatClosed,
                \dur, 0.25,
                \amp, Pseq([0.15, 0.08, 0.1, 0.08], inf),
                \decay, 0.04,
                \pan, Pwhite(-0.3, 0.3)
            ),
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

    // BUILDUP (8 bars)
    project.timeline.add(
        name: \buildup,
        duration: 32,
        pattern: Ppar([
            Pbind(
                \instrument, \dnbKick,
                \dur, Pseq([2, 2, 1, 1, 1, 1], inf),
                \amp, 0.6,
                \decay, 0.35
            ),
            Pbind(
                \instrument, \dnbSnare,
                \dur, Pseq([Rest(6), 2, 1, 1], inf),
                \amp, 0.35,
                \tune, Pwhite(-50, 50)
            ),
            Pbind(
                \instrument, \dnbHatClosed,
                \dur, 0.25,
                \amp, Penv([0.1, 0.25], [32], \exp),
                \decay, 0.04
            ),
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

    // DROP 1 (16 bars)
    project.timeline.add(
        name: \drop1,
        duration: 64,
        pattern: Ppar([
            Pbind(
                \instrument, \dnbKick,
                \dur, Pseq([0.75, 0.75, 0.5, 1, 1], inf),
                \amp, 0.7,
                \decay, 0.4
            ),
            Pbind(
                \instrument, \dnbSnare,
                \dur, Pseq([2, 2], inf),
                \amp, 0.4,
                \tune, Pwhite(-30, 30)
            ),
            Pbind(
                \instrument, \dnbHatClosed,
                \dur, Prand([0.25, 0.5, 0.125], inf),
                \amp, Prand([0.15, 0.1, 0.08], inf),
                \decay, Prand([0.03, 0.05], inf),
                \pan, Pwhite(-0.4, 0.4)
            ),
            Pbind(
                \instrument, \dnbHatOpen,
                \dur, Prand([4, 8, Rest(8)], inf),
                \amp, 0.25,
                \decay, 0.15
            ),
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
            Pbind(
                \instrument, \subBass,
                \dur, 2,
                \degree, Pseq([0, 0, 0, 0, -2, 0, 0, 0], inf),
                \octave, 2,
                \scale, Scale.minor,
                \amp, 0.55,
                \legato, 0.95
            ),
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
            Pbind(
                \instrument, \vocalStab,
                \dur, Prand([8, 16, Rest(16)], inf),
                \freq, Prand([200, 250, 180], inf),
                \formant, Prand([400, 600, 800], inf),
                \amp, 0.35
            )
        ])
    );

    // BREAKDOWN (8 bars)
    project.timeline.add(
        name: \breakdown,
        duration: 32,
        pattern: Ppar([
            Pbind(
                \instrument, \dnbKick,
                \dur, 8,
                \amp, 0.4,
                \decay, 0.3
            ),
            Pbind(
                \instrument, \dnbHatClosed,
                \dur, 0.5,
                \amp, 0.1,
                \decay, 0.05,
                \pan, Pwhite(-0.5, 0.5)
            ),
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

    // DROP 2 (16 bars)
    project.timeline.add(
        name: \drop2,
        duration: 64,
        pattern: Ppar([
            Pbind(
                \instrument, \dnbKick,
                \dur, Pseq([0.75, 0.75, 0.5, 0.5, 0.5, 1], inf),
                \amp, 0.75,
                \decay, 0.4
            ),
            Pbind(
                \instrument, \dnbSnare,
                \dur, Pseq([2, 2], inf),
                \amp, 0.45,
                \tune, Pwhite(-20, 20),
                \decay, 0.12
            ),
            Pbind(
                \instrument, \dnbHatClosed,
                \dur, 0.125,
                \amp, Pseq([0.15, 0.08, 0.1, 0.08, 0.12, 0.08, 0.1, 0.08], inf),
                \decay, 0.03,
                \pan, Pwhite(-0.5, 0.5)
            ),
            Pbind(
                \instrument, \dnbHatOpen,
                \dur, Prand([2, 4, Rest(4)], inf),
                \amp, 0.3,
                \decay, 0.18
            ),
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
            Pbind(
                \instrument, \subBass,
                \dur, Pseq([1, 1, 2], inf),
                \degree, Pseq([0, 2, 0, 0, -2, 0], inf),
                \octave, 2,
                \scale, Scale.minor,
                \amp, 0.6,
                \legato, 0.9
            ),
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
            Pbind(
                \instrument, \vocalStab,
                \dur, Prand([4, 8], inf),
                \freq, Prand([180, 200, 220, 250], inf),
                \formant, Prand([500, 700, 900], inf),
                \amp, 0.4
            )
        ])
    );

    // OUTRO (8 bars)
    project.timeline.add(
        name: \outro,
        duration: 32,
        pattern: Ppar([
            Pbind(
                \instrument, \dnbKick,
                \dur, 4,
                \amp, Penv([0.5, 0.1], [32], \exp),
                \decay, 0.3
            ),
            Pbind(
                \instrument, \dnbHatClosed,
                \dur, 0.25,
                \amp, Penv([0.12, 0.02], [32], \exp),
                \decay, 0.05
            ),
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
    // START RECORDING
    // ====================================

    "Starting recording...".postln;
    s.record(~outputPath ++ filename,
        numChannels: ~numChannels,
        sampleFormat: ~sampleFormat,
        headerFormat: ~headerFormat
    );

    1.wait; // Wait for recording to start

    "▶ PLAYING...".postln;
    project.play;

    // Wait for composition to complete
    duration.wait;

    "■ STOPPING...".postln;
    project.stop;

    0.5.wait;

    // Stop recording
    s.stopRecording;

    1.wait; // Wait for file to write

    project.free;

    "✓ Rendered: %".format(filename).postln;
    "".postln;
};

// ====================================
// RENDER ALL VARIATIONS
// ====================================

{
    var startTime, endTime, totalTime;

    startTime = Date.getDate.rawSeconds;

    "Starting batch render...".postln;
    "Estimated time: ~% minutes".format((~seedsToRender.size * 1.8).round(0.1)).postln;
    "".postln;

    ~seedsToRender.do({ |seedData, i|
        "Progress: % / %".format(i + 1, ~seedsToRender.size).postln;
        ~renderComposition.(seedData);
        2.wait; // Pause between renders
    });

    endTime = Date.getDate.rawSeconds;
    totalTime = endTime - startTime;

    "".postln;
    "==========================================".postln;
    "BATCH RENDER COMPLETE!".postln;
    "==========================================".postln;
    "Total time: % minutes".format((totalTime / 60).round(0.1)).postln;
    "Files rendered: %".format(~seedsToRender.size).postln;
    "Output path: %".format(~outputPath).postln;
    "".postln;
    "Generated files:".postln;
    ~seedsToRender.do({ |seedData|
        "  - phase0_dnb_%_seed_%.wav".format(seedData.name, seedData.seed).postln;
    });
    "==========================================".postln;
    "".postln;

}.fork;
)
