/*
PHASE 0 HEADLESS RENDERING
This script runs the rendering in headless mode using NullAudioDriver
*/

(
var continue = Condition.new;

// Configure server for headless rendering
Server.default.options.device = "Dummy";
Server.default.options.numOutputBusChannels = 2;
Server.default.options.numInputBusChannels = 2;
Server.default.options.sampleRate = 48000;
Server.default.options.memSize = 8192 * 16;
Server.default.options.blockSize = 64;

// Boot server
"Booting server for headless rendering...".postln;

s.waitForBoot({
    var outputPath, seeds, currentIndex = 0;

    outputPath = thisProcess.nowExecutingPath.dirname +/+ "compositions/audio/";

    // Ensure output directory exists
    File.mkdir(outputPath);

    seeds = [
        (name: "classic", seed: 12345),
        (name: "aggressive", seed: 42),
        (name: "smooth", seed: 99999)
    ];

    "Server booted! Loading SynthDefs...".postln;

    // Load SynthDefs
    (thisProcess.nowExecutingPath.dirname.dirname +/+ "resources/SynthDefs/dnb_synthdefs.scd").load;

    s.sync;

    "SynthDefs loaded! Starting renders...".postln;
    "".postln;

    // Render function
    ~renderSeed = { |seedData, callback|
        var filename, duration, project;
        var seed = seedData.seed;

        filename = outputPath ++ "phase0_dnb_" ++ seedData.name ++ "_seed_" ++ seed ++ ".wav";

        "=========================================".postln;
        ("Rendering: " ++ seedData.name).postln;
        ("Seed: " ++ seed).postln;
        ("Output: " ++ filename).postln;
        "=========================================".postln;
        "".postln;

        // Create project
        project = QProject.new(tempo: 174, seed: seed);
        project.title = "Phase 0 DnB - " ++ seedData.name;

        // Build composition (simplified - just one section for testing)
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

        // Calculate duration
        duration = project.timeline.totalDuration / (project.tempo / 60);

        // Start recording
        s.record(filename, numChannels: 2);

        "▶ PLAYING...".postln;
        project.play;

        // Wait for completion
        {
            (duration + 1).wait;
            "■ STOPPING...".postln;
            project.stop;
            0.5.wait;
            s.stopRecording;
            1.wait;
            project.free;
            ("✓ Rendered: " ++ filename).postln;
            "".postln;
            callback.value;
        }.fork;
    };

    // Render all seeds sequentially
    ~renderNext = {
        if(currentIndex < seeds.size, {
            ~renderSeed.(seeds[currentIndex], {
                currentIndex = currentIndex + 1;
                2.wait; // Pause between renders
                ~renderNext.value;
            });
        }, {
            "".postln;
            "=========================================".postln;
            "ALL RENDERS COMPLETE!".postln;
            "=========================================".postln;
            ("Output directory: " ++ outputPath).postln;
            "".postln;

            // Exit
            1.wait;
            0.exit;
        });
    };

    // Start rendering
    ~renderNext.value;
});

)
