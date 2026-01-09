/*
PHASE 0 NON-REALTIME RENDERING
This script renders audio using SuperCollider's NRT (Non-Realtime) mode
which doesn't require audio hardware or realtime processing.
*/

(
var outputPath, seeds, renderSeed;

outputPath = thisProcess.nowExecutingPath.dirname +/+ "compositions/audio/";

seeds = [
    (name: "classic", seed: 12345),
    (name: "aggressive", seed: 42),
    (name: "smooth", seed: 99999)
];

// Load SynthDefs
("Loading SynthDefs...").postln;
thisProcess.nowExecutingPath.dirname.dirname +/+ "resources/SynthDefs/dnb_synthdefs.scd".load;

renderSeed = { |seedData|
    var filename, score, tempo, seedValue, project;
    var kickPattern, snarePattern, hatPattern, bassPattern;

    filename = outputPath ++ "phase0_dnb_" ++ seedData.name ++ "_seed_" ++ seedData.seed ++ ".wav";
    tempo = 174;
    seedValue = seedData.seed;

    ("").postln;
    ("Rendering: " ++ seedData.name).postln;
    ("Seed: " ++ seedData.seed).postln;
    ("Output: " ++ filename).postln;

    // Create score
    score = Score.new;

    // Add SynthDef loading to score
    score.add([0.0, [\d_recv, SynthDescLib.global.at(\dnbKick).def.asBytes]]);
    score.add([0.0, [\d_recv, SynthDescLib.global.at(\dnbSnare).def.asBytes]]);
    score.add([0.0, [\d_recv, SynthDescLib.global.at(\dnbHatClosed).def.asBytes]]);
    score.add([0.0, [\d_recv, SynthDescLib.global.at(\dnbHatOpen).def.asBytes]]);
    score.add([0.0, [\d_recv, SynthDescLib.global.at(\reeseBass).def.asBytes]]);
    score.add([0.0, [\d_recv, SynthDescLib.global.at(\subBass).def.asBytes]]);
    score.add([0.0, [\d_recv, SynthDescLib.global.at(\dnbPad).def.asBytes]]);
    score.add([0.0, [\d_recv, SynthDescLib.global.at(\dnbArp).def.asBytes]]);
    score.add([0.0, [\d_recv, SynthDescLib.global.at(\vocalStab).def.asBytes]]);

    // Calculate duration
    // 72 bars at 174 BPM = 288 beats
    // Duration = beats / (BPM / 60)
    var duration = 288 / (tempo / 60);

    // For NRT, we need to convert patterns to explicit events
    // This is complex - let's use a simpler approach for now

    ("NRT rendering requires pattern-to-score conversion").postln;
    ("This is a complex transformation not yet implemented").postln;
    ("Please use the realtime rendering script instead:").postln;
    ("  load(\"examples/PHASE_0_RENDER_TO_AUDIO.scd\")").postln;

    // score.recordNRT(
    //     outputFilePath: filename,
    //     headerFormat: "wav",
    //     sampleFormat: "int24",
    //     duration: duration,
    //     sampleRate: 48000,
    //     action: { ("✓ Rendered: " ++ filename).postln; }
    // );
};

("").postln;
("NRT rendering not yet implemented for Phase 0").postln;
("").postln;
("For audio rendering, please use:").postln;
("  1. Open SuperCollider IDE (scide)").postln;
("  2. Boot server: s.boot;").postln;
("  3. Run: load(\"examples/PHASE_0_RENDER_TO_AUDIO.scd\");").postln;
("").postln;

)
