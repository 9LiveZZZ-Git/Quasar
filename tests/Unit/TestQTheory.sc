/*
Unit Tests for QTheory

Tests music theory subsystem initialization.

Phase: Zero (Skeleton)
*/

TestQTheory : UnitTest {

    test_theory_initialization {
        var project, theory;

        project = QProject.new;
        theory = project.theory;

        this.assertNotNil(theory,
            "Theory should not be nil");

        this.assertEquals(theory.class, QTheory,
            "Theory should be instance of QTheory");
    }

    test_harmony_subsystem {
        var project, harmony;

        project = QProject.new;
        harmony = project.theory.harmony;

        this.assertNotNil(harmony,
            "Harmony subsystem should not be nil");

        this.assertEquals(harmony.class, QHarmony,
            "Harmony should be instance of QHarmony");
    }

    test_melody_subsystem {
        var project, melody;

        project = QProject.new;
        melody = project.theory.melody;

        this.assertNotNil(melody,
            "Melody subsystem should not be nil");

        this.assertEquals(melody.class, QMelody,
            "Melody should be instance of QMelody");
    }

    test_rhythm_subsystem {
        var project, rhythm;

        project = QProject.new;
        rhythm = project.theory.rhythm;

        this.assertNotNil(rhythm,
            "Rhythm subsystem should not be nil");

        this.assertEquals(rhythm.class, QRhythm,
            "Rhythm should be instance of QRhythm");
    }

    test_counterpoint_subsystem {
        var project, counterpoint;

        project = QProject.new;
        counterpoint = project.theory.counterpoint;

        this.assertNotNil(counterpoint,
            "Counterpoint subsystem should not be nil");

        this.assertEquals(counterpoint.class, QCounterpoint,
            "Counterpoint should be instance of QCounterpoint");
    }

    test_form_subsystem {
        var project, form;

        project = QProject.new;
        form = project.theory.form;

        this.assertNotNil(form,
            "Form subsystem should not be nil");

        this.assertEquals(form.class, QForm,
            "Form should be instance of QForm");
    }
}
