/*
Unit Tests for QTimeline (Phase 0)

Tests timeline section management.

Phase: 0
*/

TestQTimelinePhase0 : UnitTest {

    test_add_section {
        var project, section;

        project = QProject.new;

        section = project.timeline.add(\intro, 8);

        this.assertNotNil(section,
            "Section should not be nil");

        this.assertEquals(section.name, \intro,
            "Section name should be 'intro'");

        this.assertEquals(section.duration, 8,
            "Section duration should be 8 beats");

        this.assertEquals(project.timeline.sections.size, 1,
            "Timeline should have 1 section");

        project.free;
    }

    test_multiple_sections {
        var project;

        project = QProject.new;

        project.timeline.add(\intro, 8);
        project.timeline.add(\verse, 16);
        project.timeline.add(\chorus, 16);

        this.assertEquals(project.timeline.sections.size, 3,
            "Timeline should have 3 sections");

        this.assertEquals(project.timeline.totalDuration, 40,
            "Total duration should be 40 beats");

        project.free;
    }

    test_remove_section {
        var project, removed;

        project = QProject.new;

        project.timeline.add(\intro, 8);
        project.timeline.add(\verse, 16);

        removed = project.timeline.remove(\intro);

        this.assertNotNil(removed,
            "Removed section should not be nil");

        this.assertEquals(project.timeline.sections.size, 1,
            "Timeline should have 1 section after removal");

        this.assertEquals(project.timeline.totalDuration, 16,
            "Total duration should be 16 beats after removal");

        project.free;
    }

    test_get_section_by_name {
        var project, section;

        project = QProject.new;

        project.timeline.add(\intro, 8);
        project.timeline.add(\verse, 16);

        section = project.timeline.at(\verse);

        this.assertNotNil(section,
            "Section should be found");

        this.assertEquals(section.duration, 16,
            "Found section should have correct duration");

        project.free;
    }

    test_clear_sections {
        var project;

        project = QProject.new;

        project.timeline.add(\intro, 8);
        project.timeline.add(\verse, 16);
        project.timeline.add(\chorus, 16);

        project.timeline.clear;

        this.assertEquals(project.timeline.sections.size, 0,
            "Timeline should be empty after clear");

        this.assertEquals(project.timeline.totalDuration, 0,
            "Total duration should be 0 after clear");

        project.free;
    }

    test_section_with_pattern {
        var project, section, pattern;

        project = QProject.new;

        pattern = Pbind(\degree, Pseq([0, 2, 4]));
        section = project.timeline.add(\test, 8, pattern: pattern);

        this.assertNotNil(section.pattern,
            "Section should have pattern");

        project.free;
    }
}
