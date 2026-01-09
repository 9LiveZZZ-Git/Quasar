/*
Unit Tests for QProject

Tests basic project creation and configuration.

Phase: Zero (Skeleton)
*/

TestQProject : UnitTest {

    test_new_project_creation {
        var project;

        project = QProject.new;

        this.assertNotNil(project,
            "Project should not be nil");

        this.assertEquals(project.tempo, 120,
            "Default tempo should be 120 BPM");

        this.assertNotNil(project.seed,
            "Seed should be automatically generated");
    }

    test_project_with_custom_tempo {
        var project;

        project = QProject.new(tempo: 140);

        this.assertEquals(project.tempo, 140,
            "Tempo should be set to 140 BPM");
    }

    test_project_with_custom_seed {
        var project;

        project = QProject.new(seed: 12345);

        this.assertEquals(project.seed, 12345,
            "Seed should be set to 12345");
    }

    test_tempo_setter {
        var project;

        project = QProject.new;
        project.tempo = 160;

        this.assertEquals(project.tempo, 160,
            "Tempo should be updated to 160 BPM");
    }

    test_metadata_initialization {
        var project;

        project = QProject.new;

        this.assertNotNil(project.metadata,
            "Metadata should be initialized");

        this.assertNotNil(project.created,
            "Created date should be set");

        this.assertEquals(
            project.metadata[\version],
            Quasar.version,
            "Metadata should contain Quasar version"
        );
    }

    test_from_template {
        var project;

        // Template loading not yet implemented
        // This test will pass once Phase 0-5 is complete
        project = QProject.fromTemplate(\baroque);

        this.assertNotNil(project,
            "Project from template should not be nil");
    }
}
