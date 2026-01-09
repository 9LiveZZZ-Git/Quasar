/*
QTimeline - Timeline and formal structure sequencer for Quasar

Manages sections, transitions, and overall temporal structure.

EXAMPLES::
timeline = QTimeline.new(project);
timeline.add(\intro, 8, pattern: Pbind(\\degree, Pseq([0, 2, 4])));
timeline.add(\verse, 16);
timeline.sections.do(_.postInfo);
::

Version: 0.0.1 (Phase 0 - Functional)
*/

QTimeline {
    var <project;
    var <sections;
    var <form;          // QForm archetype (Phase 5)
    var <conductor;     // Back-reference to conductor
    var <totalDuration = 0;

    *new { |project|
        ^super.new.init(project);
    }

    init { |argProject|
        project = argProject;
        sections = List.new;
        totalDuration = 0;
    }

    // Add section
    add { |name, duration, pattern, scene, state, transition|
        var section;

        section = QSection.new(name, duration, pattern, scene, state);

        if(transition.notNil, {
            section.transition = transition;
        });

        sections.add(section);
        totalDuration = totalDuration + duration;

        "QTimeline: Added section '%' (% beats)".format(name, duration).postln;

        ^section;
    }

    // Add section at specific index
    addAt { |index, name, duration, pattern, scene, state|
        var section;

        section = QSection.new(name, duration, pattern, scene, state);
        sections.insert(index, section);

        this.prRecalculateDuration;

        "QTimeline: Inserted section '%' at index %".format(name, index).postln;

        ^section;
    }

    // Remove section by name
    remove { |name|
        var section;

        section = sections.detect({ |s| s.name == name });

        if(section.isNil, {
            "QTimeline: Section '%' not found".format(name).warn;
            ^nil;
        });

        sections.remove(section);
        this.prRecalculateDuration;

        "QTimeline: Removed section '%'".format(name).postln;

        ^section;
    }

    // Remove section by index
    removeAt { |index|
        var section;

        if(index < 0 or: { index >= sections.size }, {
            "QTimeline: Index % out of range".format(index).warn;
            ^nil;
        });

        section = sections.removeAt(index);
        this.prRecalculateDuration;

        "QTimeline: Removed section at index %".format(index).postln;

        ^section;
    }

    // Get section by name
    at { |name|
        ^sections.detect({ |s| s.name == name });
    }

    // Clear all sections
    clear {
        sections.do(_.stop);
        sections = List.new;
        totalDuration = 0;
        "QTimeline: Cleared all sections".postln;
    }

    // Populate timeline with generated material (Phase 5-7)
    populate {
        "QTimeline.populate() - Phase 5-7".postln;
    }

    // Playback control (delegated to conductor)
    play {
        project.conductor.play;
    }

    stop {
        project.conductor.stop;
    }

    pause {
        project.conductor.pause;
    }

    resume {
        project.conductor.resume;
    }

    // Private methods
    prRecalculateDuration {
        totalDuration = sections.sum(_.duration);
    }

    // Iteration
    do { |func|
        sections.do(func);
    }

    collect { |func|
        ^sections.collect(func);
    }

    size {
        ^sections.size;
    }

    // Info
    postInfo {
        "".postln;
        "===========================================".postln;
        "QTimeline Info".postln;
        "===========================================".postln;
        "Total Duration: % beats (% bars at 4/4)".format(
            totalDuration,
            (totalDuration / 4).round(0.01)
        ).postln;
        "Sections:       %".format(sections.size).postln;
        "".postln;

        if(sections.size > 0, {
            "Section List:".postln;
            sections.do({ |section, i|
                "  [%] %: % beats".format(
                    i,
                    section.name,
                    section.duration
                ).postln;
            });
            "".postln;
        });

        "===========================================".postln;
        "".postln;
    }

    postSections {
        "".postln;
        "=== Timeline Sections ===".postln;
        if(sections.size == 0, {
            "No sections".postln;
        }, {
            sections.do({ |section, i|
                section.postInfo;
            });
        });
        "".postln;
    }
}
