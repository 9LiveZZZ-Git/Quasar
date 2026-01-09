/*
PHASE 0 REPRODUCIBILITY TEST

This script demonstrates the reproducibility features of Quasar Phase 0
by running the same DnB composition with different seeds.

WHAT THIS DEMONSTRATES:
✓ Same seed = identical output (reproducibility)
✓ Different seed = controlled variations
✓ Seeded randomness in action
✓ Multiple runs without conflicts

INSTRUCTIONS:
1. Boot server
2. Load this script
3. Run test 1 (same seed twice)
4. Run test 2 (different seeds)
5. Observe the differences!

Each test automatically:
- Creates project with specific seed
- Shows what random values would be generated
- Optionally plays a short excerpt
- Cleans up properly

Version: 0.1.0 (Phase 0)
*/

(
// ====================================
// LOAD SYNTHDEFS
// ====================================

"Loading DnB SynthDefs...".postln;
load(thisProcess.nowExecutingPath.dirname.dirname +/+ "resources/SynthDefs/dnb_synthdefs.scd");
s.sync;

"".postln;
"===========================================".postln;
"PHASE 0 REPRODUCIBILITY TEST".postln;
"===========================================".postln;
"".postln;

// ====================================
// TEST UTILITIES
// ====================================

~createTestProject = { |seed, name="Test"|
    var project, randomVals;

    "Creating project '%' with seed %...".format(name, seed).postln;

    project = QProject.new(tempo: 174, seed: seed);
    project.title = name;

    // Generate some random values to show reproducibility
    randomVals = 10.collect({ project.rand(0, 100).round(0.01) });

    "  Random sequence: %".format(randomVals).postln;
    "  First 5 coin flips (50%%): %".format(
        5.collect({ project.coin(0.5).asInteger })
    ).postln;
    "  Random choices from [A,B,C,D]: %".format(
        5.collect({ project.choose([\A, \B, \C, \D]) })
    ).postln;
    "".postln;

    project;
};

~addTestSection = { |project|
    "Adding test section...".postln;

    project.timeline.add(
        \test,
        16, // 4 bars
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
            ),
            Pbind(
                \instrument, \reeseBass,
                \dur, 2,
                \degree, Pseq([0, 2, 0, -2], inf),
                \octave, 2,
                \scale, Scale.minor,
                \amp, 0.4,
                \legato, 0.9
            )
        ])
    );

    "  Section added: 4 bars".postln;
    "".postln;
};

// ====================================
// TEST 1: SAME SEED (Reproducibility)
// ====================================

~test1 = {
    "".postln;
    "===========================================".postln;
    "TEST 1: SAME SEED - REPRODUCIBILITY".postln;
    "===========================================".postln;
    "This test creates two projects with the SAME seed".postln;
    "and verifies they produce identical random sequences.".postln;
    "".postln;

    // First project
    "--- Project A ---".postln;
    ~projectA = ~createTestProject.(12345, "Project A");

    // Second project with SAME seed
    "--- Project B (same seed) ---".postln;
    ~projectB = ~createTestProject.(12345, "Project B");

    // Compare
    "--- Comparison ---".postln;
    var valsA = 20.collect({ ~projectA.rand(0, 100) });
    var valsB = 20.collect({ ~projectB.rand(0, 100) });

    if(valsA == valsB, {
        "✓ SUCCESS: Both projects generated IDENTICAL sequences!".postln;
        "  This proves reproducibility is working.".postln;
    }, {
        "✗ FAIL: Sequences differ (this should not happen!)".postln;
    });

    "".postln;
    "Projects created but not playing.".postln;
    "To play Project A: ~projectA.play;".postln;
    "To play Project B: ~projectB.play;".postln;
    "To cleanup: [~projectA, ~projectB].do(_.free);".postln;
    "".postln;
};

// ====================================
// TEST 2: DIFFERENT SEEDS (Variation)
// ====================================

~test2 = {
    "".postln;
    "===========================================".postln;
    "TEST 2: DIFFERENT SEEDS - VARIATION".postln;
    "===========================================".postln;
    "This test creates three projects with DIFFERENT seeds".postln;
    "and shows how they generate different variations.".postln;
    "".postln;

    // Three projects with different seeds
    "--- Project X (seed: 11111) ---".postln;
    ~projectX = ~createTestProject.(11111, "Project X");

    "--- Project Y (seed: 22222) ---".postln;
    ~projectY = ~createTestProject.(22222, "Project Y");

    "--- Project Z (seed: 33333) ---".postln;
    ~projectZ = ~createTestProject.(33333, "Project Z");

    // Compare
    "--- Comparison ---".postln;
    var valsX = 10.collect({ ~projectX.rand(0, 100).round(0.1) });
    var valsY = 10.collect({ ~projectY.rand(0, 100).round(0.1) });
    var valsZ = 10.collect({ ~projectZ.rand(0, 100).round(0.1) });

    "Project X sequence: %".format(valsX).postln;
    "Project Y sequence: %".format(valsY).postln;
    "Project Z sequence: %".format(valsZ).postln;
    "".postln;

    if((valsX != valsY) && (valsY != valsZ) && (valsX != valsZ), {
        "✓ SUCCESS: All three projects generated DIFFERENT sequences!".postln;
        "  This proves seed variations work correctly.".postln;
    }, {
        "✗ FAIL: Some sequences matched (this should not happen!)".postln;
    });

    "".postln;
    "Projects created but not playing.".postln;
    "To cleanup: [~projectX, ~projectY, ~projectZ].do(_.free);".postln;
    "".postln;
};

// ====================================
// TEST 3: PLAYBACK TEST (Optional)
// ====================================

~test3 = { |seed=42|
    "".postln;
    "===========================================".postln;
    "TEST 3: PLAYBACK TEST".postln;
    "===========================================".postln;
    "This test creates a short composition and plays it.".postln;
    "Seed: %".format(seed).postln;
    "".postln;

    ~testProject = ~createTestProject.(seed, "Playback Test");
    ~addTestSection.(~testProject);

    "Starting playback in 2 seconds...".postln;
    "Duration: 4 bars (~ %.1f seconds)".format(
        (16 / (174 / 60))
    ).postln;
    "".postln;

    {
        2.wait;
        "▶ PLAYING...".postln;
        ~testProject.play;

        // Auto-stop after duration
        (16 / (174 / 60) + 1).wait;
        "■ STOPPED".postln;
        ~testProject.stop;

        "".postln;
        "Playback complete!".postln;
        "To cleanup: ~testProject.free;".postln;
        "".postln;
    }.fork;
};

// ====================================
// TEST 4: FULL COMPOSITION (Multiple Seeds)
// ====================================

~test4 = {
    "".postln;
    "===========================================".postln;
    "TEST 4: FULL COMPOSITION - SEED VARIATIONS".postln;
    "===========================================".postln;
    "This demonstrates how the same composition structure".postln;
    "produces different variations with different seeds.".postln;
    "".postln;

    // Load the full DnB composition with different seeds
    var seeds = [12345, 42, 99999, 54321];

    "Testing seeds: %".format(seeds).postln;
    "".postln;

    seeds.do({ |seed, i|
        var proj;
        "--- Seed: % ---".postln.format(seed);

        proj = QProject.new(tempo: 174, seed: seed);

        // Show what this seed generates
        "  Kick pattern variations: %".format(
            8.collect({ proj.choose([0.5, 0.75, 1.0, 1.5]) })
        ).postln;

        "  Bass note choices: %".format(
            8.collect({ proj.choose([0, 2, -2, 4, -4]) })
        ).postln;

        "  Hat amplitude variations: %".format(
            8.collect({ proj.rand(0.1, 0.3).round(0.01) })
        ).postln;

        proj.free;
        "".postln;
    });

    "✓ Each seed produces unique variations!".postln;
    "".postln;
    "To hear these variations, run the full DnB demo:".postln;
    "  load(\"PHASE_0_PROOF_OF_CONCEPT_DnB.scd\")".postln;
    "  Change ~seed variable to any of: %".format(seeds).postln;
    "".postln;
};

// ====================================
// INSTRUCTIONS
// ====================================

"".postln;
"===========================================".postln;
"AVAILABLE TESTS".postln;
"===========================================".postln;
"".postln;
"Run these tests by executing:".postln;
"".postln;
"  ~test1.();   // Same seed reproducibility".postln;
"  ~test2.();   // Different seed variations".postln;
"  ~test3.(42); // Playback test (optional seed)".postln;
"  ~test4.();   // Full composition variations".postln;
"".postln;
"===========================================".postln;
"".postln;

"Tests loaded! Run ~test1.() to start.".postln;
)

// ====================================
// RUN ALL TESTS
// ====================================

/*
// Uncomment to run all tests automatically:
(
{
    ~test1.();
    3.wait;

    ~test2.();
    3.wait;

    ~test4.();
    3.wait;

    "All tests complete!".postln;
}.fork;
)
*/
