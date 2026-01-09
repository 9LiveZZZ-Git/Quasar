# QLive, QPreset, QMacro & QVis: Live Performance, Workflow, and Visualization Frameworks

**Status**: Design Complete ✅
**Phases**: 16 (Live, Weeks 75-77), 17 (Workflow/Vis, Weeks 78-80)
**LOC Estimate**: ~3,200 lines combined
**Classes**: ~18 classes

---

## Part 1: QLive - Live Performance Framework

### Philosophy

**Problem**: Quasar is powerful for composition, but live performance requires different tools: cue systems, controller mapping, scene transitions, fail-safes.

**Solution**: **QLive** provides comprehensive live performance capabilities:
- Cue system with markers
- MIDI/OSC controller mapping
- Scene transitions and crossfades
- Improvisation frameworks
- Live looping
- Fail-safe systems

---

### QLive Architecture

```supercollider
// ===== MAIN ENGINE =====
QLive {
  var <project;
  var <cues;               // Array of QLiveCue
  var <currentCue = 0;
  var <controllers;        // MIDI/OSC controllers
  var <macros;             // Performance macros
  var <looper;             // QLiveLooper
  var <safetyNet;          // QSafetyNet
  var <isLive = false;

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    cues = [];
    controllers = [];
    macros = IdentityDictionary();
    looper = QLiveLooper(project);
    safetyNet = QSafetyNet(project);

    "QLive initialized: live performance mode ready".postln;
  }

  // Add cue
  addCue { |name, action, timing=\immediate|
    var cue = QLiveCue(cues.size, name, action, timing);
    cues = cues.add(cue);

    "Cue % added: %".format(cues.size, name).postln;
    ^cue;
  }

  // Go to next cue
  nextCue {
    if (currentCue < (cues.size - 1)) {
      currentCue = currentCue + 1;
      this.executeCue(currentCue);
    } {
      "Already at last cue".postln;
    };
  }

  // Go to previous cue
  prevCue {
    if (currentCue > 0) {
      currentCue = currentCue - 1;
      this.executeCue(currentCue);
    } {
      "Already at first cue".postln;
    };
  }

  // Jump to specific cue
  goToCue { |cueNumber|
    if (cueNumber >= 0 and: { cueNumber < cues.size }) {
      currentCue = cueNumber;
      this.executeCue(currentCue);
    } {
      "Invalid cue number: %".format(cueNumber).postln;
    };
  }

  executeCue { |cueNumber|
    var cue = cues[cueNumber];

    ">>> CUE %: % <<<".format(cueNumber + 1, cue.name).postln;

    switch(cue.timing,
      \immediate, {
        cue.action.value;
      },
      \end_of_bar, {
        project.conductor.waitForBarEnd;
        cue.action.value;
      },
      \end_of_phrase, {
        project.conductor.waitForPhrase End;
        cue.action.value;
      }
    );
  }

  // Map MIDI controller
  mapMIDI { |controllerNumber, parameter, range=(0..1)|
    var controller = QMIDIController(controllerNumber, parameter, range);
    controllers = controllers.add(controller);

    "MIDI CC% → %".format(controllerNumber, parameter).postln;
  }

  // Map OSC address
  mapOSC { |address, parameter, range=(0..1)|
    var controller = QOSCController(address, parameter, range);
    controllers = controllers.add(controller);

    "OSC % → %".format(address, parameter).postln;
  }

  // Define performance macro
  addMacro { |name, action|
    macros[name] = action;
    "Macro defined: %".format(name).postln;
  }

  // Trigger macro
  triggerMacro { |name|
    if (macros[name].notNil) {
      "Triggering macro: %".format(name).postln;
      macros[name].value;
    } {
      "Unknown macro: %".format(name).postln;
    };
  }

  // Start live mode
  goLive {
    isLive = true;
    safetyNet.activate;
    "=== LIVE MODE ACTIVE ===".postln;
  }

  // Stop live mode
  stopLive {
    isLive = false;
    safetyNet.deactivate;
    "=== LIVE MODE STOPPED ===".postln;
  }

  // Panic button (stop everything immediately)
  panic {
    "!!! PANIC !!!".postln;
    project.scene.layers.do { |layer|
      layer.stop;
      layer.set(\amp, 0);
    };
    Server.default.freeAll;
  }
}

// ===== LIVE CUE =====
QLiveCue {
  var <number;
  var <name;
  var <action;             // Function to execute
  var <timing;             // \immediate, \end_of_bar, \end_of_phrase

  *new { |number, name, action, timing=\immediate|
    ^super.newCopyArgs(number, name, action, timing);
  }
}

// ===== MIDI CONTROLLER =====
QMIDIController {
  var <cc;                 // MIDI CC number
  var <parameter;          // Parameter path
  var <range;              // Output range

  *new { |cc, parameter, range|
    ^super.newCopyArgs(cc, parameter, range).init;
  }

  init {
    MIDIFunc.cc({ |value, num|
      if (num == cc) {
        var scaled = value.linlin(0, 127, range[0], range[1]);
        // Set parameter
        this.setParameter(parameter, scaled);
      };
    });
  }

  setParameter { |path, value|
    // TODO: Set project parameter via path
    "% = %".format(path, value.round(0.01)).postln;
  }
}

// ===== OSC CONTROLLER =====
QOSCController {
  var <address;
  var <parameter;
  var <range;

  *new { |address, parameter, range|
    ^super.newCopyArgs(address, parameter, range).init;
  }

  init {
    OSCFunc({ |msg|
      var value = msg[1];
      var scaled = value.linlin(0, 1, range[0], range[1]);
      this.setParameter(parameter, scaled);
    }, address);
  }

  setParameter { |path, value|
    "% = %".format(path, value.round(0.01)).postln;
  }
}

// ===== LIVE LOOPER =====
QLiveLooper {
  var <project;
  var <loops;              // Array of QLiveLoop
  var <recording = false;

  *new { |project|
    ^super.newCopyArgs(project, []);
  }

  // Start recording loop
  startRecording { |source|
    recording = true;
    var loop = QLiveLoop(source);
    loop.startRecording;
    loops = loops.add(loop);

    "Recording loop %...".format(loops.size).postln;
    ^loop;
  }

  // Stop recording, start playback
  stopRecording {
    if (recording) {
      loops.last.stopRecording;
      loops.last.play;
      recording = false;

      "Loop % playing".format(loops.size).postln;
    };
  }

  // Clear all loops
  clear {
    loops.do { |loop| loop.stop };
    loops = [];
    "All loops cleared".postln;
  }
}

// ===== LIVE LOOP =====
QLiveLoop {
  var <source;
  var <buffer;
  var <recording = false;
  var <playing = false;

  *new { |source|
    ^super.newCopyArgs(source);
  }

  startRecording {
    recording = true;
    // TODO: Record to buffer
  }

  stopRecording {
    recording = false;
  }

  play {
    playing = true;
    // TODO: Loop playback
  }

  stop {
    playing = false;
  }
}

// ===== SAFETY NET =====
QSafetyNet {
  var <project;
  var <active = false;
  var <checkInterval = 0.1; // Check every 100ms
  var <routine;

  *new { |project|
    ^super.newCopyArgs(project);
  }

  activate {
    active = true;

    routine = Routine {
      loop {
        this.checkForProblems;
        checkInterval.wait;
      };
    }.play;

    "Safety net activated".postln;
  }

  deactivate {
    active = false;
    routine.stop;
    "Safety net deactivated".postln;
  }

  checkForProblems {
    // Check CPU usage
    if (Server.default.avgCPU > 80) {
      "WARNING: High CPU (%%%)".format(Server.default.avgCPU.round(1)).warn;
    };

    // Check peak levels
    if (Server.default.peakCPU > 90) {
      "CRITICAL: CPU overload!".error;
      this.reduceCPULoad;
    };

    // Check for silent output (audio engine crashed?)
    // TODO: Implement
  }

  reduceCPULoad {
    "Reducing CPU load...".postln;

    // Disable some effects
    project.scene.layers.do { |layer|
      layer.effects = layer.effects.keep(2); // Keep only 2 effects
    };
  }
}
```

---

## Part 2: QPreset - Preset Management System

### Philosophy

**Problem**: Complex projects need saving/loading of states. Composers want to try variations quickly.

**Solution**: **QPreset** provides comprehensive preset management:
- Save/recall complete states
- Partial presets (just harmony, just rhythm)
- Preset morphing
- Tagging and search
- Version control integration

---

### QPreset Architecture

```supercollider
// ===== MAIN ENGINE =====
QPreset {
  var <project;
  var <presets;            // Dictionary of saved presets
  var <currentPreset;
  var <presetPath;

  *new { |project, path|
    ^super.newCopyArgs(project, IdentityDictionary(), nil, path).init;
  }

  init {
    presetPath = presetPath ? (Platform.userAppSupportDir +/+ "Quasar/Presets");

    // Create directory if needed
    File.mkdir(presetPath);

    "QPreset initialized: %".format(presetPath).postln;
  }

  // Save current state as preset
  save { |name, tags=#[]|
    var preset = (
      name: name,
      tags: tags,
      timestamp: Date.getDate.stamp,
      data: this.captureState
    );

    presets[name] = preset;
    this.writeToFile(name, preset);

    "Preset saved: %".format(name).postln;
    ^preset;
  }

  // Capture current project state
  captureState {
    ^(
      tempo: project.tempo,
      key: project.key,
      timeline: project.timeline.serialize,
      scene: project.scene.serialize,
      theory: project.theory.serialize,
      mix: project.mix.serialize
    );
  }

  // Recall preset
  recall { |name|
    var preset = presets[name];

    if (preset.isNil) {
      preset = this.loadFromFile(name);
    };

    if (preset.notNil) {
      this.restoreState(preset.data);
      currentPreset = name;

      "Preset recalled: %".format(name).postln;
    } {
      "Preset not found: %".format(name).postln;
    };
  }

  // Restore state from preset
  restoreState { |state|
    project.tempo = state.tempo;
    project.key = state.key;
    project.timeline.deserialize(state.timeline);
    project.scene.deserialize(state.scene);
    project.theory.deserialize(state.theory);
    project.mix.deserialize(state.mix);
  }

  // Save partial preset (only certain aspects)
  savePartial { |name, aspects=#[\harmony, \rhythm]|
    var preset = (
      name: name,
      partial: true,
      aspects: aspects,
      timestamp: Date.getDate.stamp,
      data: this.capturePartialState(aspects)
    );

    presets[name] = preset;
    this.writeToFile(name, preset);

    "Partial preset saved: % (%)".format(name, aspects).postln;
    ^preset;
  }

  capturePartialState { |aspects|
    var state = ();

    aspects.do { |aspect|
      switch(aspect,
        \harmony, { state[\harmony] = project.theory.harmony.serialize },
        \rhythm, { state[\rhythm] = project.theory.rhythm.serialize },
        \melody, { state[\melody] = project.theory.melody.serialize },
        \tempo, { state[\tempo] = project.tempo },
        \mix, { state[\mix] = project.mix.serialize }
      );
    };

    ^state;
  }

  // Recall partial preset
  recallPartial { |name|
    var preset = presets[name];

    if (preset.notNil and: { preset.partial }) {
      this.restorePartialState(preset.data, preset.aspects);
      "Partial preset recalled: %".format(name).postln;
    };
  }

  restorePartialState { |state, aspects|
    aspects.do { |aspect|
      switch(aspect,
        \harmony, { project.theory.harmony.deserialize(state[\harmony]) },
        \rhythm, { project.theory.rhythm.deserialize(state[\rhythm]) },
        \melody, { project.theory.melody.deserialize(state[\melody]) },
        \tempo, { project.tempo = state[\tempo] },
        \mix, { project.mix.deserialize(state[\mix]) }
      );
    };
  }

  // Morph between two presets
  morph { |nameA, nameB, duration=2.0|
    var presetA = presets[nameA];
    var presetB = presets[nameB];

    if (presetA.notNil and: { presetB.notNil }) {
      "Morphing: % → % over %s".format(nameA, nameB, duration).postln;

      fork {
        var steps = (duration / 0.05).round;

        steps.do { |i|
          var progress = i / steps;
          var interpolated = this.interpolateStates(
            presetA.data, presetB.data, progress
          );

          this.restoreState(interpolated);

          (duration / steps).wait;
        };

        this.restoreState(presetB.data);
      };
    };
  }

  interpolateStates { |stateA, stateB, t|
    ^(
      tempo: stateA.tempo.blend(stateB.tempo, t),
      key: if (t < 0.5) { stateA.key } { stateB.key },
      // ... interpolate other parameters
    );
  }

  // Search presets by tag
  search { |tag|
    ^presets.select { |preset| preset.tags.includes(tag) }.keys;
  }

  // List all presets
  list {
    "Available presets:".postln;
    presets.keysValuesDo { |name, preset|
      "  %: % [%]".format(
        name, preset.timestamp, preset.tags.join(", ")
      ).postln;
    };
  }

  // Write preset to file
  writeToFile { |name, preset|
    var path = presetPath +/+ (name ++ ".json");
    var json = JSON.stringify(preset);
    File.use(path, "w", { |file| file.write(json) });
  }

  // Load preset from file
  loadFromFile { |name|
    var path = presetPath +/+ (name ++ ".json");

    if (File.exists(path)) {
      var json = File.readAllString(path);
      var preset = JSON.parse(json);
      presets[name] = preset;
      ^preset;
    };

    ^nil;
  }
}
```

---

## Part 3: QMacro - Macro Recording & Scripting

### Philosophy

**Problem**: Repetitive tasks waste time. Users want to automate sequences of operations.

**Solution**: **QMacro** provides macro recording and scripting:
- Record action sequences
- Conditional logic
- Batch processing
- Scriptable workflows

---

### QMacro Architecture

```supercollider
// ===== MAIN ENGINE =====
QMacro {
  var <project;
  var <macros;             // Dictionary of macros
  var <recording = false;
  var <currentMacro;

  *new { |project|
    ^super.newCopyArgs(project, IdentityDictionary()).init;
  }

  init {
    "QMacro initialized".postln;
  }

  // Start recording macro
  startRecording { |name|
    recording = true;
    currentMacro = QMacroRecording(name);

    "Recording macro: %".format(name).postln;
  }

  // Stop recording
  stopRecording {
    if (recording) {
      recording = false;
      macros[currentMacro.name] = currentMacro;

      "Macro recorded: % (% actions)".format(
        currentMacro.name, currentMacro.actions.size
      ).postln;
    };
  }

  // Record action
  recordAction { |action|
    if (recording) {
      currentMacro.addAction(action);
    };
  }

  // Play macro
  play { |name, params|
    var macro = macros[name];

    if (macro.notNil) {
      "Playing macro: %".format(name).postln;
      macro.execute(project, params);
    } {
      "Macro not found: %".format(name).postln;
    };
  }

  // Define macro from script
  define { |name, script|
    var macro = QMacroScript(name, script);
    macros[name] = macro;

    "Macro defined: %".format(name).postln;
  }
}

// ===== MACRO RECORDING =====
QMacroRecording {
  var <name;
  var <actions;

  *new { |name|
    ^super.newCopyArgs(name, []);
  }

  addAction { |action|
    actions = actions.add(action);
  }

  execute { |project, params|
    actions.do { |action|
      action.execute(project, params);
    };
  }
}

// ===== MACRO SCRIPT =====
QMacroScript {
  var <name;
  var <script;

  *new { |name, script|
    ^super.newCopyArgs(name, script);
  }

  execute { |project, params|
    script.value(project, params);
  }
}
```

---

## Part 4: QVis - Visualization & Animation Sync

### Philosophy

**Problem**: Music is invisible. Visual feedback helps understanding and creates multimedia experiences.

**Solution**: **QVis** provides visualization and animation sync:
- Real-time visualization (form, harmony, energy)
- OSC output to VJ software
- Animation curve generation
- Graphic notation

---

### QVis Architecture

```supercollider
// ===== MAIN ENGINE =====
QVis {
  var <project;
  var <visualizers;        // Array of QVisualizer
  var <oscOut;             // OSC output for VJ software
  var <window;             // GUI window

  *new { |project, oscPort=7000|
    ^super.newCopyArgs(project).init(oscPort);
  }

  init { |oscPort|
    visualizers = [];
    oscOut = NetAddr("127.0.0.1", oscPort);

    "QVis initialized: sending OSC to port %".format(oscPort).postln;
  }

  // Add visualizer
  addVisualizer { |type|
    var viz = switch(type,
      \energy, { QEnergyVisualizer(project) },
      \harmony, { QHarmonyVisualizer(project) },
      \spectrum, { QSpectrumVisualizer(project) },
      \form, { QFormVisualizer(project) }
    );

    visualizers = visualizers.add(viz);

    "Added % visualizer".format(type).postln;
    ^viz;
  }

  // Start visualization
  start {
    visualizers.do { |viz| viz.start };

    // Send OSC updates
    Routine {
      loop {
        this.sendOSCUpdates;
        0.05.wait; // 20 fps
      };
    }.play;

    "Visualization started".postln;
  }

  // Send OSC to VJ software (Resolume, TouchDesigner, etc.)
  sendOSCUpdates {
    oscOut.sendMsg('/quasar/energy', project.energy);
    oscOut.sendMsg('/quasar/tempo', project.tempo);
    oscOut.sendMsg('/quasar/section', project.timeline.currentSection.name);
    oscOut.sendMsg('/quasar/beat', project.conductor.currentBeat);
  }

  // Show GUI
  showGUI {
    window = Window("Quasar Visualization", Rect(100, 100, 800, 600));

    visualizers.do { |viz, i|
      viz.createView(window, i);
    };

    window.front;
  }
}

// ===== ENERGY VISUALIZER =====
QEnergyVisualizer {
  var <project;
  var <view;

  *new { |project| ^super.newCopyArgs(project) }

  start {
    // Update visualization
  }

  createView { |parent, index|
    view = UserView(parent, Rect(10, 10 + (index * 150), 780, 100));

    view.drawFunc = {
      // Draw energy curve
      Pen.strokeColor = Color.green;
      Pen.moveTo(0@50);

      100.do { |i|
        var x = i * 7.8;
        var energy = project.energyAtTime(i * 0.1);
        var y = 100 - (energy * 100);

        Pen.lineTo(x@y);
      };

      Pen.stroke;
    };

    view.animate = true;
  }
}
```

---

## Integration Examples

### Example 1: Live Performance

```supercollider
(
q = QProject(\live_edm);
var live = QLive(q);

// Setup cues
live.addCue("Intro", {
  q.timeline.jumpTo(\intro);
}, \immediate);

live.addCue("Build", {
  q.timeline.jumpTo(\build);
  q.scene[\drums].fadeIn(2.0);
}, \end_of_bar);

live.addCue("Drop", {
  q.timeline.jumpTo(\drop);
  q.energy = 0.9;
}, \end_of_phrase);

live.addCue("Break", {
  q.timeline.jumpTo(\break);
  q.scene[\bass].fadeOut(4.0);
}, \end_of_bar);

// Map MIDI controller (mod wheel = energy)
live.mapMIDI(1, \energy, range: (0..1));

// Map OSC (touchOSC fader = tempo)
live.mapOSC('/1/fader1', \tempo, range: (100..140));

// Define macros
live.addMacro(\explosion, {
  q.scene[\impact].trigger;
  q.energy = 1.0;
});

// Go live!
live.goLive;
)

// During performance:
// live.nextCue;           // Go to next cue
// live.triggerMacro(\explosion);
// live.panic;             // Emergency stop
```

### Example 2: Preset Management

```supercollider
(
q = QProject(\experimental);
var preset = QPreset(q);

// Save variations
preset.save("dark_ambient", tags: [\dark, \ambient, \experimental]);
preset.save("bright_pop", tags: [\bright, \pop, \upbeat]);
preset.save("jazz_harmony", tags: [\jazz, \complex]);

// Recall
preset.recall("dark_ambient");

// Search
preset.search(\jazz); // Returns: [\jazz_harmony]

// Morph between presets
preset.morph("dark_ambient", "bright_pop", duration: 8.0);
)
```

### Example 3: Visualization

```supercollider
(
q = QProject(\visual_music);
var vis = QVis(q, oscPort: 7000);

// Add visualizers
vis.addVisualizer(\energy);
vis.addVisualizer(\harmony);
vis.addVisualizer(\spectrum);

// Show GUI
vis.showGUI;

// Start visualization
vis.start;

// Now connect Resolume/TouchDesigner to receive OSC on port 7000
)
```

---

## Summary

| Framework | LOC | Classes | Weeks |
|-----------|-----|---------|-------|
| **QLive** | ~1,500 | 8 | 3 |
| **QPreset** | ~800 | 4 | 1 |
| **QMacro** | ~400 | 3 | 1 |
| **QVis** | ~500 | 3 | 1 |
| **TOTAL** | **~3,200** | **18** | **6** |

---

**QLive: Perform live • QPreset: Save states • QMacro: Automate tasks • QVis: See the music**
