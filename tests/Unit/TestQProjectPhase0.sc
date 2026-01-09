/*
Unit Tests for QProject (Phase 0)

Tests Phase 0 functionality:
- Project creation with subsystems
- Tempo management
- Seeded randomness
- Play/stop control

Phase: 0
*/

TestQProjectPhase0 : UnitTest {

    test_subsystem_initialization {
        var project;

        project = QProject.new;

        this.assertNotNil(project.theory,
            "Theory subsystem should be initialized");

        this.assertNotNil(project.timeline,
            "Timeline subsystem should be initialized");

        this.assertNotNil(project.scene,
            "Scene subsystem should be initialized");

        this.assertNotNil(project.conductor,
            "Conductor subsystem should be initialized");

        project.free;
    }

    test_seeded_randomness {
        var project1, project2, vals1, vals2;

        project1 = QProject.new(seed: 12345);
        project2 = QProject.new(seed: 12345);

        // Generate same sequence
        vals1 = 10.collect({ project1.rand(0, 100) });
        vals2 = 10.collect({ project2.rand(0, 100) });

        vals1.do({ |val, i|
            this.assertEquals(val, vals2[i],
                "Same seed should produce same random sequence");
        });

        project1.free;
        project2.free;
    }

    test_tempo_setting {
        var project;

        project = QProject.new(tempo: 120);
        this.assertEquals(project.tempo, 120,
            "Initial tempo should be 120");

        project.tempo = 140;
        this.assertEquals(project.tempo, 140,
            "Tempo should update to 140");

        this.assertEquals(project.conductor.tempo, 140,
            "Conductor tempo should sync with project");

        project.free;
    }

    test_template_loading {
        var project;

        project = QProject.fromTemplate(\baroque);

        this.assertNotNil(project,
            "Template project should not be nil");

        this.assertEquals(project.keySignature, \dMinor,
            "Baroque template should set key to D minor");

        project.free;
    }

    test_playback_without_sections {
        var project;

        project = QProject.new;

        // Should warn but not crash
        project.play;

        this.assertEquals(project.isPlaying, false,
            "Should not play without sections");

        project.free;
    }

    test_metadata_management {
        var project;

        project = QProject.new;
        project.title = "Test Composition";
        project.author = "Test Author";

        this.assertEquals(project.title, "Test Composition",
            "Title should be set");

        this.assertEquals(project.author, "Test Author",
            "Author should be set");

        this.assertNotNil(project.created,
            "Created date should be set");

        project.free;
    }

    test_free_cleanup {
        var project;

        project = QProject.new;

        // Should not throw error
        project.free;

        this.assert(true, "Free should complete without error");
    }
}
