/*
Unit Tests for QScene (Phase 0)

Tests audio scene management.

Phase: 0
*/

TestQScenePhase0 : UnitTest {

    test_scene_creation {
        var project;

        project = QProject.new;

        this.assertNotNil(project.scene,
            "Scene should be created");

        this.assertNotNil(project.scene.layers,
            "Layers dictionary should be initialized");

        project.free;
    }

    test_add_layer {
        var project, proxy;

        project = QProject.new;

        proxy = project.scene.addLayer(\test, { SinOsc.ar(440) * 0.1 });

        this.assertNotNil(proxy,
            "Proxy should not be nil");

        this.assertEquals(project.scene.layers.size, 1,
            "Scene should have 1 layer");

        project.free;
    }

    test_remove_layer {
        var project;

        project = QProject.new;

        project.scene.addLayer(\test, { SinOsc.ar(440) * 0.1 });
        project.scene.removeLayer(\test);

        this.assertEquals(project.scene.layers.size, 0,
            "Scene should have 0 layers after removal");

        project.free;
    }

    test_get_layer {
        var project, proxy;

        project = QProject.new;

        project.scene.addLayer(\test, { SinOsc.ar(440) * 0.1 });
        proxy = project.scene.at(\test);

        this.assertNotNil(proxy,
            "Should be able to get layer by name");

        project.free;
    }

    test_clear_all_layers {
        var project;

        project = QProject.new;

        project.scene.addLayer(\layer1, { SinOsc.ar(440) * 0.1 });
        project.scene.addLayer(\layer2, { SinOsc.ar(550) * 0.1 });
        project.scene.addLayer(\layer3, { SinOsc.ar(660) * 0.1 });

        this.assertEquals(project.scene.layers.size, 3,
            "Should have 3 layers");

        project.scene.clear;

        this.assertEquals(project.scene.layers.size, 0,
            "Should have 0 layers after clear");

        project.free;
    }
}
