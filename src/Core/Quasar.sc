/*
Quasar - High-level Computer-Aided Composition framework for SuperCollider

Main class for Quasar framework initialization and global settings.

Version: 0.0.1 (Phase Zero)
License: GPL-3.0
*/

Quasar {
    classvar <version = "0.0.1";
    classvar <samplePath;
    classvar <resourcePath;
    classvar <initialized = false;

    *initClass {
        "Quasar framework loading...".postln;
        this.prInitializePaths;
        initialized = true;
        "Quasar % loaded successfully".format(version).postln;
    }

    *prInitializePaths {
        var basePath = this.filenameSymbol.asString.dirname.dirname;
        resourcePath = basePath +/+ "resources";
        samplePath = resourcePath +/+ "samples";
    }

    *postInfo {
        "".postln;
        "=====================================".postln;
        "Quasar CAC Framework".postln;
        "Version: %".format(version).postln;
        "=====================================".postln;
        "".postln;
        "Core Frameworks:".postln;
        "  - QProject:      Project container".postln;
        "  - QTheory:       Music theory engine".postln;
        "  - QTimeline:     Timeline & form".postln;
        "  - QScene:        Audio scene management".postln;
        "  - QConductor:    Playback engine".postln;
        "".postln;
        "Documentation: See README.md".postln;
        "Examples:      See examples/".postln;
        "".postln;
    }
}
