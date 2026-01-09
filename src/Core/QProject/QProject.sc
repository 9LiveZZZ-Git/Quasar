/*
QProject - Main project container for Quasar compositions

The root object containing all composition metadata, settings, and subsystems.

EXAMPLES::
// Create project
q = QProject.new;

// Set parameters
q.tempo = 140;
q.keySignature = \dMinor;

// Play
q.play;

// Stop
q.stop;
::

Version: 0.0.1 (Phase 0 - Functional)
*/

QProject {
    // Core settings
    var <tempo = 120;
    var <seed;
    var <rng;              // Random number generator
    var <keySignature;
    var <timeSignature;

    // Subsystems
    var <theory;        // QTheory - music theory engine
    var <palette;       // QPalette - material database (Phase 1)
    var <timeline;      // QTimeline - formal structure
    var <texture;       // QTexture - voice management (Phase 4)
    var <scene;         // QScene - audio scene
    var <conductor;     // QConductor - playback engine
    var <mixer;         // QMixer - audio routing (Phase 6)

    // Metadata
    var <metadata;
    var <created;
    var <modified;
    var <author;
    var <title;

    // State
    var <isPlaying = false;

    *new { |tempo = 120, seed|
        ^super.new.init(tempo, seed);
    }

    *fromTemplate { |templateName|
        var project = this.new;
        project.loadTemplate(templateName);
        ^project;
    }

    init { |argTempo, argSeed|
        tempo = argTempo;
        seed = argSeed ?? { Date.getDate.rawSeconds.asInteger };
        rng = Pseed(seed, Prand([0], inf)).asStream; // Seeded RNG
        created = Date.getDate;
        modified = created;

        this.prInitMetadata;
        this.prInitSubsystems;

        "QProject initialized (seed: %)".format(seed).postln;
    }

    prInitSubsystems {
        // Initialize core subsystems (Phase 0)
        theory = QTheory.new(this);
        timeline = QTimeline.new(this);
        scene = QScene.new(this);
        conductor = QConductor.new(this);

        // Placeholder for future subsystems
        palette = nil;   // Phase 1
        texture = nil;   // Phase 4
        mixer = nil;     // Phase 6
    }

    prInitMetadata {
        metadata = IdentityDictionary[
            \version -> Quasar.version,
            \seed -> seed,
            \created -> created,
            \modified -> modified
        ];
    }

    loadTemplate { |templateName|
        // Load a genre template
        // Implementation: Phase 0-5
        "Loading template: % (stub - Phase 5)".format(templateName).postln;

        // Stub: Set basic defaults based on template
        switch(templateName,
            \baroque, {
                timeSignature = [4, 4];
                keySignature = \dMinor;
            },
            \edm, {
                tempo = 128;
                timeSignature = [4, 4];
            },
            \jazz, {
                tempo = 180;
                timeSignature = [4, 4];
            },
            // Default
            {
                "Unknown template: %".format(templateName).warn;
            }
        );
    }

    // Playback methods
    play {
        if(isPlaying, {
            "Already playing".warn;
            ^this;
        });

        if(timeline.sections.size == 0, {
            "No sections to play. Add sections to timeline first.".warn;
            ^this;
        });

        isPlaying = true;
        conductor.play;
        this;
    }

    stop {
        if(isPlaying.not, {
            "Not playing".warn;
            ^this;
        });

        conductor.stop;
        isPlaying = false;
        this;
    }

    pause {
        conductor.pause;
    }

    resume {
        conductor.resume;
    }

    seek { |beat|
        conductor.seek(beat);
    }

    render { |path, format = \wav, sampleRate = 48000|
        // NRT rendering
        // Implementation: Phase 8 (Rendering)
        "QProject.render() - Phase 8".postln;
    }

    // Random number generation (seeded)
    rand { |lo = 0.0, hi = 1.0|
        // Returns seeded random value between lo and hi
        ^rng.next.linlin(0, 1, lo, hi);
    }

    coin { |prob = 0.5|
        // Returns true with probability prob
        ^this.rand(0, 1) < prob;
    }

    choose { |array|
        // Choose random element from array
        ^array[this.rand(0, array.size).floor];
    }

    // Getters/Setters
    tempo_ { |value|
        tempo = value;
        if(conductor.notNil, {
            conductor.tempo = value;
        });
        modified = Date.getDate;
    }

    keySignature_ { |value|
        keySignature = value;
        modified = Date.getDate;
    }

    timeSignature_ { |value|
        timeSignature = value;
        modified = Date.getDate;
    }

    title_ { |value|
        title = value;
        modified = Date.getDate;
    }

    author_ { |value|
        author = value;
        modified = Date.getDate;
    }

    // Cleanup
    free {
        this.stop;
        scene.free;
        conductor.free;
        "QProject freed".postln;
    }

    postInfo {
        "".postln;
        "===========================================".postln;
        "QProject Info".postln;
        "===========================================".postln;
        "Title:          %".format(title ? "Untitled").postln;
        "Author:         %".format(author ? "Unknown").postln;
        "Tempo:          % BPM".format(tempo).postln;
        "Key:            %".format(keySignature ? "Not set").postln;
        "Time Signature: %".format(timeSignature ? "Not set").postln;
        "Seed:           %".format(seed).postln;
        "Sections:       %".format(timeline.sections.size).postln;
        "Playing:        %".format(isPlaying).postln;
        "Created:        %".format(created.asString).postln;
        "Modified:       %".format(modified.asString).postln;
        "===========================================".postln;
        "".postln;
    }
}
