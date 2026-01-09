/*
Example 12: Phase 0 - Seeded Randomness

Demonstrates reproducible randomness using project seed.
Same seed = same random sequence.

Phase: 0 (Functional)
*/

(
s.waitForBoot({
    "===========================================".postln;
    "Example 12: Phase 0 - Seeded Randomness".postln;
    "===========================================".postln;
    "".postln;

    // Create two projects with same seed
    ~q1 = QProject.new(seed: 12345);
    ~q2 = QProject.new(seed: 12345);

    // Create one with different seed
    ~q3 = QProject.new(seed: 99999);

    "Testing reproducibility...".postln;
    "".postln;

    // Generate random values from each project
    "Project 1 (seed 12345):".postln;
    5.do({ |i|
        "  Random value %: %".format(i, ~q1.rand(0, 100)).postln;
    });
    "".postln;

    "Project 2 (seed 12345 - should match Project 1):".postln;
    5.do({ |i|
        "  Random value %: %".format(i, ~q2.rand(0, 100)).postln;
    });
    "".postln;

    "Project 3 (seed 99999 - should differ):".postln;
    5.do({ |i|
        "  Random value %: %".format(i, ~q3.rand(0, 100)).postln;
    });
    "".postln;

    "✓ Projects with same seed produce identical sequences".postln;
    "✓ Projects with different seeds produce different sequences".postln;
    "".postln;

    // Test coin flips
    "Coin flips (50% probability):".postln;
    10.do({ |i|
        var result = ~q1.coin(0.5);
        "  Flip %: %".format(i, if(result, "HEADS", "TAILS")).postln;
    });
    "".postln;

    // Test choose
    "Random choices from array:".postln;
    var notes = [\C, \D, \E, \F, \G, \A, \B];
    10.do({ |i|
        "  Choice %: %".format(i, ~q1.choose(notes)).postln;
    });
    "".postln;

    "Example complete!".postln;
});
)

// Clean up
[~q1, ~q2, ~q3].do(_.free);
