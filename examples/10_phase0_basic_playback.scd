/*
Example 10: Phase 0 - Basic Playback

Demonstrates the core Phase 0 functionality:
- Create project
- Add sections to timeline
- Play and stop cleanly

Phase: 0 (Functional)
*/

(
s.waitForBoot({
    "===========================================".postln;
    "Example 10: Phase 0 - Basic Playback".postln;
    "===========================================".postln;
    "".postln;

    // Create project
    q = QProject.new(tempo: 120, seed: 42);

    // Add sections to timeline
    q.timeline.add(
        name: \intro,
        duration: 8,
        pattern: Pbind(
            \instrument, \default,
            \degree, Pseq([0, 2, 4, 5, 4, 2], inf),
            \dur, 0.5,
            \amp, 0.2
        )
    );

    q.timeline.add(
        name: \verse,
        duration: 16,
        pattern: Pbind(
            \instrument, \default,
            \degree, Pseq([0, 2, 4, 7, 4, 2, 0, -3], inf),
            \dur, 0.25,
            \amp, 0.15
        )
    );

    q.timeline.add(
        name: \outro,
        duration: 8,
        pattern: Pbind(
            \instrument, \default,
            \degree, Pseq([0, -2, -4, -7], inf),
            \dur, 1,
            \amp, 0.1
        )
    );

    // Display timeline info
    q.timeline.postInfo;

    "".postln;
    "Starting playback in 2 seconds...".postln;
    "Total duration: 32 beats (8 bars at 120 BPM)".postln;
    "".postln;

    // Play after delay
    {
        2.wait;
        q.play;
    }.fork;
});
)

// Stop playback
q.stop;

// Display project info
q.postInfo;

// Display conductor info
q.conductor.postInfo;

// Clean up
q.free;
