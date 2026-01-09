/*
RENDER FULL PHASE 0 DnB TRACK - Using Working Method
Based on the successful PHASE_0_AUTO_RENDER.scd approach
*/

(
// Set environment to non-interactive
thisProcess.platform.recordingsDir = thisProcess.nowExecutingPath.dirname +/+ "compositions/audio/";

// Server options for headless operation
Server.default = Server.local;
s = Server.default;

s.options.device = nil;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 0;
s.options.sampleRate = 48000;
s.options.memSize = 8192 * 16;
s.options.maxNodes = 1024 * 4;
s.options.numBuffers = 1024 * 16;
s.options.blockSize = 64;

"==========================================".postln;
"RENDERING FULL PHASE 0 DnB TRACK".postln;
"==========================================".postln;
"".postln;

// Boot server and render
s.waitForBoot({
    var outputPath = thisProcess.nowExecutingPath.dirname +/+ "compositions/audio/";
    var filename, duration, project, startTime;

    "Server booted successfully!".postln;
    "Output directory: %".format(outputPath).postln;
    "".postln;

    // Load SynthDefs
    "Loading SynthDefs...".postln;
    (thisProcess.nowExecutingPath.dirname.dirname +/+ "resources/SynthDefs/dnb_synthdefs.scd").load;

    s.sync;

    "SynthDefs loaded!".postln;
    "".postln;

    // Configure
    filename = outputPath ++ "phase0_dnb_FULL_TRACK_seed_12345.wav";

    "==========================================".postln;
    "Rendering: FULL TRACK (all 6 sections)".postln;
    "Seed: 12345".postln;
    "Tempo: 174 BPM".postln;
    "File: %".format(filename).postln;
    "==========================================".postln;
    "".postln;

    // Create project with FULL TRACK
    project = QProject.new(tempo: 174, seed: 12345);

    // ====== INTRO (16 bars) ======
    project.timeline.add(
        name: \intro,
        duration: 64,
        pattern: Ppar([
            Pbind(\instrument, \dnbKick, \dur, 4, \amp, 0.5, \decay, 0.3),
            Pbind(\instrument, \dnbHatClosed, \dur, 0.25, \amp, Pseq([0.15, 0.08, 0.1, 0.08], inf), \decay, 0.04, \pan, Pwhite(-0.3, 0.3)),
            Pbind(\instrument, \dnbPad, \dur, 16, \degree, Pseq([0, 2, 4, 7], inf), \octave, 4, \scale, Scale.minor, \amp, 0.15, \cutoff, 1500, \legato, 1.5)
        ])
    );

    // ====== BUILDUP (8 bars) ======
    project.timeline.add(
        name: \buildup,
        duration: 32,
        pattern: Ppar([
            Pbind(\instrument, \dnbKick, \dur, Pseq([2, 2, 1, 1, 1, 1], inf), \amp, 0.6, \decay, 0.35),
            Pbind(\instrument, \dnbSnare, \dur, Pseq([Rest(6), 2, 1, 1], inf), \amp, 0.35, \tune, Pwhite(-50, 50)),
            Pbind(\instrument, \dnbHatClosed, \dur, 0.25, \amp, Penv([0.1, 0.25], [32], \exp), \decay, 0.04),
            Pbind(\instrument, \reeseBass, \dur, 8, \degree, Pseq([0], inf), \octave, 2, \scale, Scale.minor, \amp, 0.25, \cutoff, 600, \detune, 3, \legato, 0.9),
            Pbind(\instrument, \dnbArp, \dur, 0.5, \degree, Pseq([0, 2, 4, 7, 9, 7, 4, 2], inf), \octave, 5, \scale, Scale.minor, \amp, Penv([0.15, 0.3], [32], \exp))
        ])
    );

    // ====== DROP 1 (16 bars) ======
    project.timeline.add(
        name: \drop1,
        duration: 64,
        pattern: Ppar([
            Pbind(\instrument, \dnbKick, \dur, Pseq([0.75, 0.75, 0.5, 1, 1], inf), \amp, 0.7, \decay, 0.4),
            Pbind(\instrument, \dnbSnare, \dur, Pseq([2, 2], inf), \amp, 0.4, \tune, Pwhite(-30, 30)),
            Pbind(\instrument, \dnbHatClosed, \dur, Prand([0.25, 0.5, 0.125], inf), \amp, Prand([0.15, 0.1, 0.08], inf), \decay, Prand([0.03, 0.05], inf), \pan, Pwhite(-0.4, 0.4)),
            Pbind(\instrument, \dnbHatOpen, \dur, Prand([4, 8, Rest(8)], inf), \amp, 0.25, \decay, 0.15),
            Pbind(\instrument, \reeseBass, \dur, Pseq([1, 1, 0.5, 0.5, 2, 1, 1, 1], inf), \degree, Pseq([0, 0, 2, 0, 0, -2, 0, 0], inf), \octave, 2, \scale, Scale.minor, \amp, 0.45, \cutoff, Pwhite(700, 1200), \detune, 3, \res, 0.4, \legato, 0.9),
            Pbind(\instrument, \subBass, \dur, 2, \degree, Pseq([0, 0, 0, 0, -2, 0, 0, 0], inf), \octave, 2, \scale, Scale.minor, \amp, 0.55, \legato, 0.95),
            Pbind(\instrument, \dnbPad, \dur, 8, \degree, Pseq([0, 2, 4, 7], inf), \octave, 4, \scale, Scale.minor, \amp, 0.18, \cutoff, 2000, \legato, 1.3),
            Pbind(\instrument, \vocalStab, \dur, Prand([8, 16, Rest(16)], inf), \freq, Prand([200, 250, 180], inf), \formant, Prand([400, 600, 800], inf), \amp, 0.35)
        ])
    );

    // ====== BREAKDOWN (8 bars) ======
    project.timeline.add(
        name: \breakdown,
        duration: 32,
        pattern: Ppar([
            Pbind(\instrument, \dnbKick, \dur, 8, \amp, 0.4, \decay, 0.3),
            Pbind(\instrument, \dnbHatClosed, \dur, 0.5, \amp, 0.1, \decay, 0.05, \pan, Pwhite(-0.5, 0.5)),
            Pbind(\instrument, \dnbPad, \dur, 8, \degree, Pseq([4, 7, 0, 2], inf), \octave, 4, \scale, Scale.minor, \amp, 0.25, \cutoff, 3000, \legato, 1.5),
            Pbind(\instrument, \dnbArp, \dur, 0.25, \degree, Pseq([0, 2, 4, 7, 9, 11, 9, 7], inf), \octave, 5, \scale, Scale.minor, \amp, 0.25)
        ])
    );

    // ====== DROP 2 (16 bars) ======
    project.timeline.add(
        name: \drop2,
        duration: 64,
        pattern: Ppar([
            Pbind(\instrument, \dnbKick, \dur, Pseq([0.75, 0.75, 0.5, 0.5, 0.5, 1], inf), \amp, 0.75, \decay, 0.4),
            Pbind(\instrument, \dnbSnare, \dur, Pseq([2, 2], inf), \amp, 0.45, \tune, Pwhite(-20, 20), \decay, 0.12),
            Pbind(\instrument, \dnbHatClosed, \dur, 0.125, \amp, Pseq([0.15, 0.08, 0.1, 0.08, 0.12, 0.08, 0.1, 0.08], inf), \decay, 0.03, \pan, Pwhite(-0.5, 0.5)),
            Pbind(\instrument, \dnbHatOpen, \dur, Prand([2, 4, Rest(4)], inf), \amp, 0.3, \decay, 0.18),
            Pbind(\instrument, \reeseBass, \dur, Pseq([0.5, 0.5, 1, 1, 0.5, 0.5, 1, 1], inf), \degree, Pseq([0, 2, 0, -2, 0, 4, 0, -2], inf), \octave, 2, \scale, Scale.minor, \amp, 0.5, \cutoff, Pwhite(800, 1400), \detune, Pwhite(2, 4), \res, 0.35, \legato, 0.85),
            Pbind(\instrument, \subBass, \dur, Pseq([1, 1, 2], inf), \degree, Pseq([0, 2, 0, 0, -2, 0], inf), \octave, 2, \scale, Scale.minor, \amp, 0.6, \legato, 0.9),
            Pbind(\instrument, \dnbPad, \dur, 16, \degree, Pseq([0, 4, 2, 7], inf), \octave, 4, \scale, Scale.minor, \amp, 0.2, \cutoff, 2500, \legato, 1.4),
            Pbind(\instrument, \vocalStab, \dur, Prand([4, 8], inf), \freq, Prand([180, 200, 220, 250], inf), \formant, Prand([500, 700, 900], inf), \amp, 0.4)
        ])
    );

    // ====== OUTRO (8 bars) ======
    project.timeline.add(
        name: \outro,
        duration: 32,
        pattern: Ppar([
            Pbind(\instrument, \dnbKick, \dur, 4, \amp, Penv([0.5, 0.1], [32], \exp), \decay, 0.3),
            Pbind(\instrument, \dnbHatClosed, \dur, 0.25, \amp, Penv([0.12, 0.02], [32], \exp), \decay, 0.05),
            Pbind(\instrument, \dnbPad, \dur, 8, \degree, Pseq([0, -2, -4, -7], inf), \octave, 4, \scale, Scale.minor, \amp, Penv([0.2, 0.05], [32], \exp), \cutoff, Penv([2000, 800], [32], \exp), \legato, 1.5)
        ])
    );

    "".postln;
    "Track created with 6 sections:".postln;
    "  1. Intro (16 bars)".postln;
    "  2. Buildup (8 bars)".postln;
    "  3. Drop 1 (16 bars)".postln;
    "  4. Breakdown (8 bars)".postln;
    "  5. Drop 2 (16 bars)".postln;
    "  6. Outro (8 bars)".postln;
    "".postln;

    // Calculate duration
    duration = project.timeline.totalDuration / (project.tempo / 60);
    "Total duration: ~% seconds".format(duration.round(1)).postln;
    "".postln;

    "Starting recording...".postln;
    startTime = Date.getDate.rawSeconds;

    // Start recording (using working method)
    s.record(filename, numChannels: 2);

    {
        0.5.wait;
        "▶ PLAYING...".postln;
        project.play;

        (duration + 0.5).wait;

        "■ STOPPING...".postln;
        project.stop;

        0.5.wait;
        s.stopRecording;

        1.wait;
        project.free;

        "".postln;
        "==========================================".postln;
        "✓ FULL TRACK RENDERED SUCCESSFULLY!".postln;
        "==========================================".postln;
        "File: %".format(filename).postln;
        "Duration: % seconds".format((Date.getDate.rawSeconds - startTime).round(0.1)).postln;
        "".postln;

        2.wait;
        0.exit;
    }.fork;
}, {
    "ERROR: Server failed to boot!".postln;
    2.wait;
    0.exit;
});
)
