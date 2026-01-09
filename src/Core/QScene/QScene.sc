/*
QScene - Audio scene management for Quasar

A scene is a ProxySpace wrapper + layer management + macro controls.

EXAMPLES::
scene = QScene(project);
scene.addLayer(\bass, { SinOsc.ar(60) * 0.3 });
scene.play(\bass);
::

Version: 0.0.1 (Phase 0 - Functional)
*/

QScene {
    var <project;
    var <name;
    var <proxySpace;
    var <layers;        // Dictionary of layer proxies
    var <macros;        // Macro controls (Phase 6)
    var <fxChain;       // FX routing (Phase 6)
    var <state;         // Current state

    *new { |project, name|
        ^super.new.init(project, name);
    }

    init { |argProject, argName|
        project = argProject;
        name = argName ?? \main;
        layers = IdentityDictionary.new;
        macros = IdentityDictionary.new;

        // Create ProxySpace if not already exists
        if(currentEnvironment.isKindOf(ProxySpace).not, {
            proxySpace = ProxySpace.new(Server.default);
            proxySpace.makeTempoClock;
        }, {
            proxySpace = currentEnvironment;
        });

        "QScene initialized: %".format(name).postln;
    }

    // Layer management
    addLayer { |layerName, source, fadeTime = 0.1|
        var proxy;

        if(layers.includesKey(layerName), {
            "QScene: Layer '%' already exists, replacing".format(layerName).warn;
        });

        // Create NodeProxy in ProxySpace
        proxySpace.use({
            proxy = layerName.ar;
            proxy.fadeTime = fadeTime;
            proxy.source = source;
        });

        layers.put(layerName, proxy);

        "QScene: Added layer '%'".format(layerName).postln;

        ^proxy;
    }

    // Play layer
    play { |layerName|
        var proxy;

        proxy = layers.at(layerName);

        if(proxy.isNil, {
            "QScene: Layer '%' not found".format(layerName).warn;
            ^nil;
        });

        proxySpace.use({
            proxy.play;
        });

        "QScene: Playing layer '%'".format(layerName).postln;

        ^proxy;
    }

    // Stop layer
    stop { |layerName|
        var proxy;

        if(layerName.isNil, {
            // Stop all layers
            layers.do({ |proxy|
                proxy.stop;
            });
            "QScene: Stopped all layers".postln;
            ^this;
        });

        proxy = layers.at(layerName);

        if(proxy.isNil, {
            "QScene: Layer '%' not found".format(layerName).warn;
            ^nil;
        });

        proxy.stop;

        "QScene: Stopped layer '%'".format(layerName).postln;

        ^proxy;
    }

    // Remove layer
    removeLayer { |layerName|
        var proxy;

        proxy = layers.at(layerName);

        if(proxy.isNil, {
            "QScene: Layer '%' not found".format(layerName).warn;
            ^nil;
        });

        proxy.clear;
        layers.removeAt(layerName);

        "QScene: Removed layer '%'".format(layerName).postln;

        ^proxy;
    }

    // Get layer
    at { |layerName|
        ^layers.at(layerName);
    }

    // Set layer source
    set { |layerName, source, fadeTime|
        var proxy;

        proxy = layers.at(layerName);

        if(proxy.isNil, {
            "QScene: Layer '%' not found, creating".format(layerName).postln;
            ^this.addLayer(layerName, source, fadeTime);
        });

        if(fadeTime.notNil, {
            proxy.fadeTime = fadeTime;
        });

        proxy.source = source;

        "QScene: Updated layer '%'".format(layerName).postln;

        ^proxy;
    }

    // Macro controls (stub - Phase 6)
    defineMacro { |macroName, mappings|
        macros.put(macroName, mappings);
        "QScene: Defined macro '%' (Phase 6 - stub)".format(macroName).postln;
    }

    setMacro { |macroName, value|
        "QScene: Set macro '%' to % (Phase 6 - stub)".format(
            macroName, value
        ).postln;
    }

    // Clear all layers
    clear {
        layers.do({ |proxy|
            proxy.clear;
        });
        layers = IdentityDictionary.new;
        "QScene: Cleared all layers".postln;
    }

    // Cleanup
    free {
        this.stop(nil); // Stop all layers
        this.clear;
        "QScene freed".postln;
    }

    // Info
    postInfo {
        "".postln;
        "=== QScene: % ===".format(name).postln;
        "Layers:   %".format(layers.size).postln;
        "Macros:   %".format(macros.size).postln;
        "".postln;

        if(layers.size > 0, {
            "Layer List:".postln;
            layers.keysValuesDo({ |name, proxy|
                "  % - playing: %".format(
                    name,
                    proxy.isPlaying
                ).postln;
            });
            "".postln;
        });
    }
}
