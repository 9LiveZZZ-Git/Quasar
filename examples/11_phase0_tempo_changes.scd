/*
Example 11: Phase 0 - Tempo Changes

Demonstrates tempo control and dynamic changes during playback setup.

Phase: 0 (Functional)
*/

(
s.waitForBoot({
    "===========================================".postln;
    "Example 11: Phase 0 - Tempo Changes".postln;
    "===========================================".postln;
    "".postln;

    // Create project with initial tempo
    q = QProject.new(tempo: 80);

    "Initial tempo: % BPM".format(q.tempo).postln;

    // Add a simple pattern
    q.timeline.add(
        \test,
        16,
        pattern: Pbind(
            \degree, Pseq([0, 2, 4, 5, 7], inf),
            \dur, 0.5,
            \amp, 0.2
        )
    );

    // Change tempo before playing
    q.tempo = 140;

    "Changed tempo to: % BPM".format(q.tempo).postln;
    "".postln;

    // Display info
    q.postInfo;

    // Play
    "Starting playback at 140 BPM...".postln;
    { 1.wait; q.play; }.fork;
});
)

// Stop
q.stop;

// Change tempo for next time
q.tempo = 100;
q.postInfo;

// Clean up
q.free;
