/*
QTheory - Music theory system for Quasar

Centralizes all theory-related functionality: harmony, melody, rhythm,
counterpoint, and form.

EXAMPLES::
theory = QTheory.new;
theory.harmony.progression(\authentic);
::

Version: 0.0.1 (Phase Zero - Skeleton)
*/

QTheory {
    var <project;
    var <harmony;       // QHarmony
    var <melody;        // QMelody
    var <rhythm;        // QRhythm
    var <counterpoint;  // QCounterpoint
    var <form;          // QForm

    *new { |project|
        ^super.new.init(project);
    }

    init { |argProject|
        project = argProject;
        this.prInitModules;
    }

    prInitModules {
        // Initialize theory modules (skeleton)
        // Actual implementation in Phase 2
        harmony = QHarmony.new(this);
        melody = QMelody.new(this);
        rhythm = QRhythm.new(this);
        counterpoint = QCounterpoint.new(this);
        form = QForm.new(this);
    }

    postInfo {
        "".postln;
        "=== QTheory Info ===".postln;
        "Harmony:      %".format(harmony.class).postln;
        "Melody:       %".format(melody.class).postln;
        "Rhythm:       %".format(rhythm.class).postln;
        "Counterpoint: %".format(counterpoint.class).postln;
        "Form:         %".format(form.class).postln;
        "".postln;
    }
}
