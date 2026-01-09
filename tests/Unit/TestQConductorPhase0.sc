/*
Unit Tests for QConductor (Phase 0)

Tests playback engine functionality.

Phase: 0
*/

TestQConductorPhase0 : UnitTest {

    test_tempo_control {
        var project;

        project = QProject.new(tempo: 120);

        this.assertEquals(project.conductor.tempo, 120,
            "Conductor tempo should match project");

        project.conductor.tempo = 140;

        this.assertEquals(project.conductor.tempo, 140,
            "Conductor tempo should update");

        project.free;
    }

    test_playback_state {
        var project;

        project = QProject.new;
        project.timeline.add(\test, 4);

        this.assertEquals(project.conductor.isPlaying, false,
            "Should not be playing initially");

        project.free;
    }

    test_position_tracking {
        var project;

        project = QProject.new;

        this.assertEquals(project.conductor.position, 0,
            "Position should start at 0");

        project.free;
    }

    test_clock_creation {
        var project;

        project = QProject.new(tempo: 120);

        this.assertNotNil(project.conductor.clock,
            "Clock should be created");

        this.assertEquals(project.conductor.clock.tempo, 2,
            "Clock tempo should be 2 beats per second (120 BPM)");

        project.free;
    }
}
