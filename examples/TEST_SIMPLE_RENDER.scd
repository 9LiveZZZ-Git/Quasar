/*
TEST SIMPLE RENDER - Minimal test to isolate crash
*/

(
// Set environment
thisProcess.platform.recordingsDir = thisProcess.nowExecutingPath.dirname +/+ "compositions/audio/";

Server.default = Server.local;
s = Server.default;

s.options.device = nil;
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 0;
s.options.sampleRate = 48000;
s.options.memSize = 8192 * 16;

"==========================================".postln;
"TEST: Simple Render".postln;
"==========================================".postln;

s.waitForBoot({
    var filename, duration, project;

    "Server booted!".postln;

    // Load SynthDefs
    "Loading SynthDefs...".postln;
    (thisProcess.nowExecutingPath.dirname.dirname +/+ "resources/SynthDefs/dnb_synthdefs.scd").load;
    s.sync;
    "SynthDefs loaded!".postln;

    filename = thisProcess.nowExecutingPath.dirname +/+ "compositions/audio/TEST_simple.wav";

    // Create simple project
    project = QProject.new(tempo: 174, seed: 12345);

    // Just ONE simple section
    project.timeline.add(
        name: \test,
        duration: 32,  // 8 bars
        pattern: Ppar([
            Pbind(\instrument, \dnbKick, \dur, 1, \amp, 0.5),
            Pbind(\instrument, \dnbSnare, \dur, 2, \amp, 0.3),
            Pbind(\instrument, \dnbHatClosed, \dur, 0.25, \amp, 0.15)
        ])
    );

    duration = project.timeline.totalDuration / (project.tempo / 60);
    "Duration: % seconds".format(duration).postln;

    // Start recording
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

        "✓ Test render complete!".postln;

        2.wait;
        0.exit;
    }.fork;
}, {
    "ERROR: Server failed to boot!".postln;
    2.wait;
    0.exit;
});
)
