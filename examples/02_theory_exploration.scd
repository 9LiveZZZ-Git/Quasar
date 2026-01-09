/*
Example 02: Theory Exploration

Demonstrates accessing theory subsystems.

Phase: Zero (Skeleton)
Status: Skeleton only - actual theory generation not yet implemented
*/

(
s.waitForBoot({
    "=== Example 02: Theory Exploration ===".postln;
    "".postln;

    // Create project
    q = QProject.new;

    // Access theory subsystems
    "Exploring theory subsystems:".postln;
    "".postln;

    "1. QTheory:".postln;
    q.theory.postInfo;

    "2. Harmony (not yet implemented):".postln;
    // Once implemented (Phase 2):
    // prog = q.theory.harmony.progression(\authentic);
    "   q.theory.harmony.progression(\\authentic) -> []".postln;

    "3. Melody (not yet implemented):".postln;
    // Once implemented (Phase 2):
    // mel = q.theory.melody.fromContour(\arch, length: 8);
    "   q.theory.melody.fromContour(\\arch, length: 8) -> []".postln;

    "4. Rhythm (not yet implemented):".postln;
    // Once implemented (Phase 2):
    // pattern = q.theory.rhythm.pattern(\sonClave);
    "   q.theory.rhythm.pattern(\\sonClave) -> []".postln;

    "5. Counterpoint (not yet implemented):".postln;
    // Once implemented (Phase 2):
    // cp = q.theory.counterpoint.generate([60, 62, 64]);
    "   q.theory.counterpoint.generate([60, 62, 64]) -> []".postln;

    "6. Form (not yet implemented):".postln;
    // Once implemented (Phase 5):
    // q.theory.form.exposition(theme1: \heroic);
    "   q.theory.form.exposition(theme1: \\heroic)".postln;

    "".postln;
    "Example complete!".postln;
    "".postln;
    "Note: Actual implementation will be in Phase 2 and Phase 5".postln;
});
)
