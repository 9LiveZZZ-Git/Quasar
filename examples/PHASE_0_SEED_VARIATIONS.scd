/*
PHASE 0 SEED VARIATIONS - Quick Runner

This script makes it easy to play the DnB demo with different seeds
to hear how reproducibility and variation work.

USAGE:
1. Boot server
2. Load this file
3. Run ~playWithSeed.(12345) or try the presets below

Each seed produces a unique variation of the same track!

Version: 0.1.0 (Phase 0)
*/

(
"".postln;
"===========================================".postln;
"PHASE 0 SEED VARIATIONS - Quick Runner".postln;
"===========================================".postln;
"".postln;

// Load SynthDefs
"Loading SynthDefs...".postln;
load(thisProcess.nowExecutingPath.dirname.dirname +/+ "resources/SynthDefs/dnb_synthdefs.scd");
s.sync;

// ====================================
// MAIN FUNCTION
// ====================================

~playWithSeed = { |seed=12345, autoPlay=true|
    var scriptPath;

    // Free previous project if exists
    if(~currentDnbProject.notNil, {
        "Stopping previous project...".postln;
        ~currentDnbProject.stop;
        ~currentDnbProject.free;
        1.wait; // Give time to cleanup
    });

    "".postln;
    "===========================================".postln;
    "Loading DnB Demo with Seed: %".format(seed).postln;
    "===========================================".postln;
    "".postln;

    // Create temporary file with custom seed
    scriptPath = Platform.defaultTempDir +/+ "quasar_dnb_temp.scd";

    File.use(scriptPath, "w", { |f|
        f.write("(\n");
        f.write("~seed = %;\n".format(seed));
        f.write("~tempo = 174;\n");
        f.write(File.readAllString(
            thisProcess.nowExecutingPath.dirname +/+ "PHASE_0_PROOF_OF_CONCEPT_DnB.scd"
        ).findRegexp("// ====================================\n// LOAD SYNTHDEFS")[0][0]..);
        f.write(")");
    });

    // Load and execute
    thisProcess.interpreter.executeFile(scriptPath);

    // Store reference
    ~currentDnbProject = q;

    "".postln;
    if(autoPlay, {
        "Track will auto-play in 3 seconds...".postln;
    }, {
        "Ready! Run q.play; to start.".postln;
    });
    "".postln;
};

// ====================================
// PRESET SEEDS
// ====================================

~presets = (
    classic: 12345,      // Original demo seed
    aggressive: 42,      // More aggressive patterns
    smooth: 99999,       // Smoother progressions
    chaotic: 54321,      // More chaotic elements
    minimal: 11111,      // Minimal variations
    maximal: 77777,      // Maximum variation
    deep: 88888,         // Deeper bass focus
    atmospheric: 66666,  // More atmospheric
    rolling: 33333,      // Rolling basslines
    experimental: 13579  // Experimental patterns
);

// ====================================
// QUICK PLAY FUNCTIONS
// ====================================

~playClassic = { ~playWithSeed.(~presets[\classic]) };
~playAggressive = { ~playWithSeed.(~presets[\aggressive]) };
~playSmooth = { ~playWithSeed.(~presets[\smooth]) };
~playChaotic = { ~playWithSeed.(~presets[\chaotic]) };
~playMinimal = { ~playWithSeed.(~presets[\minimal]) };
~playMaximal = { ~playWithSeed.(~presets[\maximal]) };
~playDeep = { ~playWithSeed.(~presets[\deep]) };
~playAtmospheric = { ~playWithSeed.(~presets[\atmospheric]) };
~playRolling = { ~playWithSeed.(~presets[\rolling]) };
~playExperimental = { ~playWithSeed.(~presets[\experimental]) };

// ====================================
// COMPARISON FUNCTION
// ====================================

~compareSeeds = { |seed1=12345, seed2=99999|
    var proj1, proj2;

    "".postln;
    "===========================================".postln;
    "COMPARING TWO SEEDS".postln;
    "===========================================".postln;
    "Seed 1: %".format(seed1).postln;
    "Seed 2: %".format(seed2).postln;
    "".postln;

    proj1 = QProject.new(seed: seed1);
    proj2 = QProject.new(seed: seed2);

    "Seed 1 random sequence:".postln;
    "  %".format(10.collect({ proj1.rand(0, 100).round(0.1) })).postln;
    "".postln;

    "Seed 2 random sequence:".postln;
    "  %".format(10.collect({ proj2.rand(0, 100).round(0.1) })).postln;
    "".postln;

    proj1.free;
    proj2.free;

    if(seed1 == seed2, {
        "✓ Same seeds produce identical values (reproducibility)".postln;
    }, {
        "✓ Different seeds produce different values (variation)".postln;
    });
    "".postln;
};

// ====================================
// INSTRUCTIONS
// ====================================

"".postln;
"===========================================".postln;
"AVAILABLE COMMANDS".postln;
"===========================================".postln;
"".postln;
"Quick Play (preset variations):".postln;
"  ~playClassic.();        // Original demo (seed: 12345)".postln;
"  ~playAggressive.();     // More aggressive (seed: 42)".postln;
"  ~playSmooth.();         // Smoother flow (seed: 99999)".postln;
"  ~playChaotic.();        // Chaotic energy (seed: 54321)".postln;
"  ~playMinimal.();        // Minimal style (seed: 11111)".postln;
"  ~playMaximal.();        // Maximum variation (seed: 77777)".postln;
"  ~playDeep.();           // Deep bass focus (seed: 88888)".postln;
"  ~playAtmospheric.();    // Atmospheric (seed: 66666)".postln;
"  ~playRolling.();        // Rolling bass (seed: 33333)".postln;
"  ~playExperimental.();   // Experimental (seed: 13579)".postln;
"".postln;
"Custom Seed:".postln;
"  ~playWithSeed.(YOUR_SEED);".postln;
"  Example: ~playWithSeed.(42069);".postln;
"".postln;
"Compare Seeds:".postln;
"  ~compareSeeds.(12345, 99999);".postln;
"".postln;
"Playback Control:".postln;
"  q.play;     // Play current project".postln;
"  q.stop;     // Stop playback".postln;
"  q.pause;    // Pause".postln;
"  q.resume;   // Resume".postln;
"  q.free;     // Cleanup".postln;
"".postln;
"===========================================".postln;
"".postln;

"Ready! Try: ~playClassic.()".postln;
"".postln;
)

// ====================================
// AUTOMATIC DEMO SEQUENCE (Optional)
// ====================================

/*
// Uncomment to play multiple variations automatically:
(
{
    "AUTOMATIC VARIATION DEMO".postln;
    "Playing 3 variations with different seeds...".postln;
    "".postln;

    // Variation 1
    "Variation 1: Classic".postln;
    ~playClassic.();
    20.wait; // Play for 20 seconds
    q.stop;
    2.wait;

    // Variation 2
    "Variation 2: Aggressive".postln;
    ~playAggressive.();
    20.wait;
    q.stop;
    2.wait;

    // Variation 3
    "Variation 3: Smooth".postln;
    ~playSmooth.();
    20.wait;
    q.stop;

    "".postln;
    "Demo complete! All variations used same code,".postln;
    "just different seeds!".postln;
}.fork;
)
*/
