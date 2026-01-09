/*
PHASE 0 AUTOMATIC RENDERING - Headless Mode
Attempts to render without GUI interaction
*/

(
// Set environment to non-interactive
thisProcess.platform.recordingsDir = thisProcess.nowExecutingPath.dirname +/+ "compositions/audio/";

// Server options for headless operation
Server.default = Server.local;
s = Server.default;

s.options.device = nil; // Try system default
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 0;
s.options.sampleRate = 48000;
s.options.memSize = 8192 * 16;
s.options.maxNodes = 1024 * 4;
s.options.numBuffers = 1024 * 16;
s.options.blockSize = 64;

// Disable GUI (not needed for headless)

"==========================================".postln;
"PHASE 0 AUTOMATIC AUDIO RENDERING".postln;
"==========================================".postln;
"".postln;
"Configuring headless mode...".postln;

// Boot server and render
s.waitForBoot({
    var outputPath = thisProcess.nowExecutingPath.dirname +/+ "compositions/audio/";
    var seeds, currentIndex = 0;

    "Server booted successfully!".postln;
    "Output directory: %".format(outputPath).postln;
    "".postln;

    // Load SynthDefs
    "Loading SynthDefs...".postln;
    (thisProcess.nowExecutingPath.dirname.dirname +/+ "resources/SynthDefs/dnb_synthdefs.scd").load;

    s.sync;

    "SynthDefs loaded!".postln;
    "".postln;

    // Seeds to render
    seeds = [
        (name: "classic", seed: 12345),
        (name: "aggressive", seed: 42),
        (name: "smooth", seed: 99999)
    ];

    // Render function
    ~renderOne = { |seedData, callback|
        var filename, duration, project, startTime;

        filename = outputPath ++ "phase0_dnb_" ++ seedData.name ++ "_seed_" ++ seedData.seed ++ ".wav";

        "==========================================".postln;
        "Rendering: %".format(seedData.name).postln;
        "Seed: %".format(seedData.seed).postln;
        "File: %".format(filename).postln;
        "==========================================".postln;
        "".postln;

        // Create project
        project = QProject.new(tempo: 174, seed: seedData.seed);

        // Add all sections (simplified for testing - just intro)
        project.timeline.add(
            name: \test,
            duration: 16, // Just 4 bars for testing
            pattern: Ppar([
                Pbind(
                    \instrument, \dnbKick,
                    \dur, 1,
                    \amp, 0.5
                ),
                Pbind(
                    \instrument, \dnbHatClosed,
                    \dur, 0.25,
                    \amp, 0.15
                )
            ])
        );

        // Calculate duration
        duration = project.timeline.totalDuration / (project.tempo / 60);

        "Starting recording...".postln;
        startTime = Date.getDate.rawSeconds;

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

            "✓ Rendered: %".format(filename).postln;
            "   Duration: % seconds".format((Date.getDate.rawSeconds - startTime).round(0.1)).postln;
            "".postln;

            callback.value;
        }.fork;
    };

    // Render all sequentially
    ~renderNext = {
        if(currentIndex < seeds.size, {
            ~renderOne.(seeds[currentIndex], {
                currentIndex = currentIndex + 1;
                1.wait;
                ~renderNext.value;
            });
        }, {
            "".postln;
            "==========================================".postln;
            "ALL RENDERS COMPLETE!".postln;
            "==========================================".postln;
            "Output: %".format(outputPath).postln;
            "".postln;

            // List files
            "Generated files:".postln;
            PathName(outputPath).files.do({ |file|
                if(file.extension == "wav", {
                    ("  - " ++ file.fileName).postln;
                });
            });

            2.wait;
            0.exit;
        });
    };

    "Starting render sequence...".postln;
    "".postln;
    ~renderNext.value;
}, {
    "ERROR: Server failed to boot!".postln;
    "".postln;
    "This might be due to:".postln;
    "  - No audio device available".postln;
    "  - Jack/ALSA not configured".postln;
    "  - Server already running".postln;
    "".postln;
    "Please use the manual method:".postln;
    "  ./RENDER_AUDIO_NOW.sh".postln;
    "".postln;
    2.wait;
    0.exit;
});
)
