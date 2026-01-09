/*
Hello Quasar - Getting Started Example

This is a minimal example demonstrating how to create a QProject
and verify that Quasar is working.

Phase: Zero (Skeleton)
Status: Demonstrates skeleton structure only
*/

(
// Boot server
s.waitForBoot({
    "Server booted!".postln;

    // Create a new project
    "Creating QProject...".postln;
    q = QProject.new(tempo: 120, seed: 42);

    // Display project info
    q.postInfo;

    // Display Quasar info
    Quasar.postInfo;

    "".postln;
    "===========================================".postln;
    "Hello, Quasar!".postln;
    "".postln;
    "Phase Zero skeleton is working correctly.".postln;
    "Ready for implementation!".postln;
    "===========================================".postln;
    "".postln;
});
)
