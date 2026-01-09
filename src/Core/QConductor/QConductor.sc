/*
QConductor - Playback engine for Quasar

Handles timing, section changes, and playback control using TempoClock
and Routine-based playback.

EXAMPLES::
conductor = QConductor(project);
conductor.play;
conductor.stop;
::

Version: 0.0.1 (Phase 0 - Functional)
*/

QConductor {
    var <project;
    var <clock;
    var <routine;
    var <position = 0;     // Current beat position
    var <isPlaying = false;
    var <isPaused = false;
    var <currentSection;
    var <sectionIndex = 0;

    *new { |project|
        ^super.new.init(project);
    }

    init { |argProject|
        project = argProject;
        clock = TempoClock.new(project.tempo / 60);
        position = 0;
    }

    play {
        if(isPlaying, {
            "QConductor: Already playing".warn;
            ^this;
        });

        if(project.timeline.sections.size == 0, {
            "QConductor: No sections to play".warn;
            ^this;
        });

        isPlaying = true;
        isPaused = false;
        sectionIndex = 0;
        position = 0;

        "QConductor: Starting playback at % BPM".format(this.tempo).postln;

        // Start playback routine
        routine = Routine({
            project.timeline.sections.do({ |section, i|
                this.prPlaySection(section, i);
            });

            // Playback complete
            "QConductor: Playback complete".postln;
            isPlaying = false;
        });

        clock.play(routine);
        this;
    }

    prPlaySection { |section, index|
        var duration;

        currentSection = section;
        sectionIndex = index;

        "QConductor: Playing section '%' (% beats)".format(
            section.name,
            section.duration
        ).postln;

        // Start section
        section.start(clock);

        // Wait for section duration
        duration = section.duration;
        duration.wait;

        // Stop section
        section.stop;

        // Update position
        position = position + duration;
    }

    stop {
        if(isPlaying.not, {
            "QConductor: Not playing".warn;
            ^this;
        });

        "QConductor: Stopping playback".postln;

        // Stop routine
        if(routine.notNil, {
            routine.stop;
            routine = nil;
        });

        // Stop current section if any
        if(currentSection.notNil, {
            currentSection.stop;
        });

        isPlaying = false;
        isPaused = false;
        position = 0;
        sectionIndex = 0;
        currentSection = nil;

        this;
    }

    pause {
        if(isPlaying.not, {
            "QConductor: Not playing".warn;
            ^this;
        });

        if(isPaused, {
            "QConductor: Already paused".warn;
            ^this;
        });

        "QConductor: Pausing".postln;
        clock.pause;
        isPaused = true;
        this;
    }

    resume {
        if(isPlaying.not, {
            "QConductor: Not playing".warn;
            ^this;
        });

        if(isPaused.not, {
            "QConductor: Not paused".warn;
            ^this;
        });

        "QConductor: Resuming".postln;
        clock.resume;
        isPaused = false;
        this;
    }

    seek { |beat|
        // Jump to position
        // Full implementation in Phase 0+
        "QConductor: Seek to beat % (limited support in Phase 0)".format(beat).postln;
        position = beat;
        this;
    }

    // Tempo control
    tempo {
        ^clock.tempo * 60;
    }

    tempo_ { |bpm|
        clock.tempo = bpm / 60;
        "QConductor: Tempo changed to % BPM".format(bpm).postln;
    }

    // Score generation for NRT rendering
    asScore {
        // Generate Score for NRT rendering
        // Implementation: Phase 8 (Rendering)
        "QConductor.asScore() - Phase 8".postln;
        ^Score([]);
    }

    // Cleanup
    free {
        this.stop;
        if(clock.notNil, {
            clock.clear;
        });
        "QConductor freed".postln;
    }

    postInfo {
        "".postln;
        "=== QConductor Info ===".postln;
        "Tempo:           % BPM".format(this.tempo).postln;
        "Position:        % beats".format(position).postln;
        "Playing:         %".format(isPlaying).postln;
        "Paused:          %".format(isPaused).postln;
        "Current Section: %".format(currentSection !? _.name ?? "None").postln;
        "Section Index:   %/%".format(
            sectionIndex,
            project.timeline.sections.size
        ).postln;
        "".postln;
    }
}
