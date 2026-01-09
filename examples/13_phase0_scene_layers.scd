/*
Example 13: Phase 0 - Scene Layers

Demonstrates QScene audio layer management.

Phase: 0 (Functional)
*/

(
s.waitForBoot({
    "===========================================".postln;
    "Example 13: Phase 0 - Scene Layers".postln;
    "===========================================".postln;
    "".postln;

    // Create project
    q = QProject.new;

    // Add layers to scene
    "Adding bass layer...".postln;
    q.scene.addLayer(\bass, {
        SinOsc.ar(60) * 0.3 * EnvGen.kr(Env.perc, Impulse.kr(2))
    });

    "Adding melody layer...".postln;
    q.scene.addLayer(\melody, {
        SinOsc.ar(LFNoise1.kr(0.5).range(400, 800)) * 0.2
            * EnvGen.kr(Env.perc(0.01, 0.3), Impulse.kr(4))
    });

    "Adding pad layer...".postln;
    q.scene.addLayer(\pad, {
        Mix.fill(4, {
            SinOsc.ar(LFNoise1.kr(0.1).range(200, 400) + [0, 0.5]) * 0.05
        })
    });

    // Display scene info
    q.scene.postInfo;

    "".postln;
    "Playing layers individually...".postln;

    {
        "Bass...".postln;
        q.scene.play(\bass);
        3.wait;

        "Adding melody...".postln;
        q.scene.play(\melody);
        3.wait;

        "Adding pad...".postln;
        q.scene.play(\pad);
        4.wait;

        "Stopping all...".postln;
        q.scene.stop;

        "".postln;
        "Scene layer demo complete!".postln;
    }.fork;
});
)

// Stop all layers
q.scene.stop;

// Display info
q.scene.postInfo;

// Clean up
q.free;
