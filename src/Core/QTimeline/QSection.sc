/*
QSection - Timeline section for Quasar

Represents a single section in a timeline with name, duration, pattern, and state.

EXAMPLES::
section = QSection(\intro, 8, pattern: Pbind(\\degree, Pseq([0, 2, 4])));
section.start(clock);
::

Version: 0.0.1 (Phase 0 - Functional)
*/

QSection {
    var <name;
    var <duration;      // In beats
    var <pattern;       // Pattern to play
    var <scene;         // QScene (optional)
    var <state;         // State dictionary (optional)
    var <transition;    // Transition gesture (Phase 3)
    var <metadata;

    // Playback state
    var <eventStream;
    var <isPlaying = false;

    *new { |name, duration, pattern, scene, state|
        ^super.new.init(name, duration, pattern, scene, state);
    }

    init { |argName, argDuration, argPattern, argScene, argState|
        name = argName;
        duration = argDuration;
        pattern = argPattern;
        scene = argScene;
        state = argState ?? { IdentityDictionary.new };
        metadata = IdentityDictionary.new;
    }

    start { |clock|
        if(isPlaying, {
            "QSection '%': Already playing".format(name).warn;
            ^this;
        });

        isPlaying = true;

        // Play pattern if provided
        if(pattern.notNil, {
            eventStream = pattern.play(clock, quant: 0);
        });

        this;
    }

    stop {
        if(isPlaying.not, {
            ^this;
        });

        // Stop pattern
        if(eventStream.notNil, {
            eventStream.stop;
            eventStream = nil;
        });

        isPlaying = false;
        this;
    }

    // Setters
    duration_ { |value|
        duration = value;
    }

    pattern_ { |value|
        pattern = value;
    }

    scene_ { |value|
        scene = value;
    }

    state_ { |value|
        state = value;
    }

    // Metadata
    addMetadata { |key, value|
        metadata.put(key, value);
    }

    getMetadata { |key|
        ^metadata.at(key);
    }

    postInfo {
        "".postln;
        "=== QSection: % ===".format(name).postln;
        "Duration:  % beats".format(duration).postln;
        "Pattern:   %".format(pattern.notNil).postln;
        "Scene:     %".format(scene.notNil).postln;
        "Playing:   %".format(isPlaying).postln;
        "".postln;
    }
}
