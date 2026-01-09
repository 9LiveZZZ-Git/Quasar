/*
Example 01: Project Creation

Demonstrates different ways to create and configure a QProject.

Phase: Zero (Skeleton)
Status: Skeleton only - actual features not yet implemented
*/

(
s.waitForBoot({
    "=== Example 01: Project Creation ===".postln;
    "".postln;

    // Method 1: Create with defaults
    "1. Create project with defaults:".postln;
    ~project1 = QProject.new;
    ~project1.postInfo;

    // Method 2: Create with custom tempo and seed
    "2. Create project with custom settings:".postln;
    ~project2 = QProject.new(tempo: 140, seed: 12345);
    ~project2.postInfo;

    // Method 3: Create from template (skeleton only)
    "3. Create from template (not yet implemented):".postln;
    ~project3 = QProject.fromTemplate(\baroque);
    ~project3.postInfo;

    // Configure project metadata
    "4. Configure project metadata:".postln;
    ~project1.title = "My First Composition";
    ~project1.author = "Composer Name";
    ~project1.keySignature = \dMinor;
    ~project1.timeSignature = [4, 4];
    ~project1.postInfo;

    "".postln;
    "Example complete!".postln;
});
)
