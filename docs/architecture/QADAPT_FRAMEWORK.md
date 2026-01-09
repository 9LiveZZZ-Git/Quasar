# QAdapt: Adaptive Music Engine

**Status**: Design Complete ✅
**Phase**: 13 (Weeks 66-68)
**LOC Estimate**: ~1,500 lines
**Classes**: ~8 classes

---

## Philosophy

**Problem**: Static music doesn't respond to context. Games, installations, and interactive experiences need music that adapts to user actions, environmental conditions, or narrative events.

**Solution**: **QAdapt** provides a comprehensive adaptive music engine with:
- Vertical remixing (add/remove layers)
- Horizontal resequencing (change section order)
- Parameter mapping (game state → musical parameters)
- Branching paths and transitions
- Context-aware music generation

**Key Insight**: Music as a reactive system, not a linear timeline.

---

## Core Capabilities

### 1. **Vertical Remixing**
- Add/remove layers based on intensity
- Smooth layer transitions
- Maintain musical coherence

### 2. **Horizontal Resequencing**
- Jump between sections
- Branch based on conditions
- Loop sections indefinitely

### 3. **Parameter Mapping**
- Map external data to musical parameters
- OSC/MIDI input → music changes
- Context awareness (time, weather, user state)

### 4. **Transition System**
- Seamless section transitions
- Beat/bar-aligned jumps
- Crossfades and fade-outs

### 5. **Rule-Based Adaptation**
- Define rules for music behavior
- Conditional logic
- Priority system for conflicting rules

---

## Architecture

```supercollider
// ===== MAIN ENGINE =====
QAdapt {
  var <project;
  var <context;            // QAdaptContext (external state)
  var <rules;              // Array of QAdaptRule
  var <transitionEngine;   // QTransitionEngine
  var <layerController;    // QLayerController
  var <currentSection;     // Active section
  var <intensity = 0.5;    // Global intensity (0-1)

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    context = QAdaptContext();
    rules = [];
    transitionEngine = QTransitionEngine(project);
    layerController = QLayerController(project);
    currentSection = project.timeline.sections.first;

    "QAdapt initialized: adaptive music engine active".postln;
  }

  // Add adaptation rule
  addRule { |rule|
    rules = rules.add(rule);
    "Added rule: %".format(rule.name).postln;
  }

  // Update context (called externally)
  updateContext { |key, value|
    context.set(key, value);
    this.evaluateRules;
  }

  // Evaluate all rules and adapt music
  evaluateRules {
    var actions = [];

    // Collect triggered actions
    rules.do { |rule|
      if (rule.evaluate(context)) {
        actions = actions ++ rule.actions;
      };
    };

    // Sort by priority and execute
    actions.sortBy({ |a| a.priority.neg }).do { |action|
      this.executeAction(action);
    };
  }

  // Execute adaptation action
  executeAction { |action|
    switch(action.type,
      \set_intensity, {
        this.setIntensity(action.value);
      },
      \add_layer, {
        layerController.addLayer(action.layer, action.fadeTime);
      },
      \remove_layer, {
        layerController.removeLayer(action.layer, action.fadeTime);
      },
      \transition_to, {
        transitionEngine.transitionTo(action.section, action.timing);
      },
      \set_parameter, {
        project.setParameter(action.path, action.value);
      }
    );
  }

  // Set global intensity (0-1)
  setIntensity { |value|
    intensity = value.clip(0, 1);
    "Intensity: %".format((intensity * 100).round(1)).postln;

    // Update layers based on intensity
    layerController.updateForIntensity(intensity);
  }

  // Manual section jump
  jumpTo { |sectionName, timing=\immediate|
    var section = project.timeline.getSection(sectionName);
    transitionEngine.transitionTo(section, timing);
  }
}

// ===== ADAPT CONTEXT =====
QAdaptContext {
  var <data;               // Dictionary of context data

  *new {
    ^super.new.init;
  }

  init {
    data = IdentityDictionary();
  }

  set { |key, value|
    var oldValue = data[key];
    data[key] = value;

    if (oldValue != value) {
      "Context: % = % (was: %)".format(key, value, oldValue).postln;
    };
  }

  get { |key|
    ^data[key];
  }

  // Convenience accessors
  intensity { ^data[\intensity] ? 0.5 }
  tension { ^data[\tension] ? 0.5 }
  playerHealth { ^data[\playerHealth] ? 1.0 }
  enemiesNearby { ^data[\enemiesNearby] ? 0 }
  timeOfDay { ^data[\timeOfDay] ? \day }
  temperature { ^data[\temperature] ? 20 }
}

// ===== ADAPT RULE =====
QAdaptRule {
  var <name;
  var <condition;          // Function that returns true/false
  var <actions;            // Actions to take when true
  var <cooldown = 0;       // Min time between triggers (seconds)
  var <lastTrigger = 0;

  *new { |name, condition, actions, cooldown=0|
    ^super.newCopyArgs(name, condition, actions, cooldown);
  }

  evaluate { |context|
    var now = Main.elapsedTime;

    // Check cooldown
    if ((now - lastTrigger) < cooldown) {
      ^false;
    };

    // Evaluate condition
    var result = condition.value(context);

    if (result) {
      lastTrigger = now;
      "Rule triggered: %".format(name).postln;
    };

    ^result;
  }
}

// ===== LAYER CONTROLLER =====
QLayerController {
  var <project;
  var <activeLayers;       // Currently active layers
  var <layerIntensities;   // Intensity thresholds per layer

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    activeLayers = [];
    layerIntensities = IdentityDictionary();

    // Auto-detect layers and assign intensities
    project.scene.layers.do { |layer, i|
      var intensity = i / project.scene.layers.size;
      layerIntensities[layer.name] = intensity;
    };
  }

  // Set intensity threshold for layer
  setLayerIntensity { |layerName, threshold|
    layerIntensities[layerName] = threshold;
  }

  // Update layers based on global intensity
  updateForIntensity { |intensity|
    project.scene.layers.do { |layer|
      var threshold = layerIntensities[layer.name] ? 0.5;

      if (intensity >= threshold) {
        this.addLayer(layer.name, fadeTime: 2.0);
      } {
        this.removeLayer(layer.name, fadeTime: 2.0);
      };
    };
  }

  // Add layer with fade
  addLayer { |layerName, fadeTime=1.0|
    if (activeLayers.includes(layerName).not) {
      var layer = project.scene.getLayer(layerName);

      fork {
        var steps = (fadeTime / 0.05).round;

        steps.do { |i|
          var amp = i / steps;
          layer.set(\amp, amp);
          (fadeTime / steps).wait;
        };

        activeLayers = activeLayers.add(layerName);
        "Layer added: %".format(layerName).postln;
      };
    };
  }

  // Remove layer with fade
  removeLayer { |layerName, fadeTime=1.0|
    if (activeLayers.includes(layerName)) {
      var layer = project.scene.getLayer(layerName);

      fork {
        var steps = (fadeTime / 0.05).round;

        steps.do { |i|
          var amp = 1.0 - (i / steps);
          layer.set(\amp, amp);
          (fadeTime / steps).wait;
        };

        activeLayers.remove(layerName);
        "Layer removed: %".format(layerName).postln;
      };
    };
  }
}

// ===== TRANSITION ENGINE =====
QTransitionEngine {
  var <project;
  var <currentSection;
  var <transitioning = false;

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    currentSection = project.timeline.sections.first;
  }

  // Transition to new section
  transitionTo { |section, timing=\end_of_bar|
    if (transitioning) {
      "Already transitioning, ignoring".postln;
      ^this;
    };

    transitioning = true;

    switch(timing,
      \immediate, {
        this.transitionImmediate(section);
      },
      \end_of_bar, {
        this.transitionOnBarEnd(section);
      },
      \end_of_section, {
        this.transitionOnSectionEnd(section);
      },
      \crossfade, { |duration=2.0|
        this.transitionCrossfade(section, duration);
      }
    );
  }

  transitionImmediate { |section|
    "Transitioning immediately: % → %".format(
      currentSection.name, section.name
    ).postln;

    currentSection = section;
    project.timeline.jumpTo(section);
    transitioning = false;
  }

  transitionOnBarEnd { |section|
    "Transitioning on bar end: % → %".format(
      currentSection.name, section.name
    ).postln;

    // Wait for current bar to finish
    fork {
      project.conductor.waitForBarEnd;
      currentSection = section;
      project.timeline.jumpTo(section);
      transitioning = false;
    };
  }

  transitionOnSectionEnd { |section|
    "Transitioning on section end: % → %".format(
      currentSection.name, section.name
    ).postln;

    fork {
      project.conductor.waitForSectionEnd;
      currentSection = section;
      project.timeline.jumpTo(section);
      transitioning = false;
    };
  }

  transitionCrossfade { |section, duration|
    "Crossfading: % → % (over %s)".format(
      currentSection.name, section.name, duration
    ).postln;

    fork {
      var stepsvar = (duration / 0.05).round;

      // Start new section immediately (at 0 volume)
      section.layers.do { |layer| layer.set(\amp, 0) };
      project.timeline.jumpTo(section);

      // Crossfade
      steps.do { |i|
        var progress = i / steps;

        currentSection.layers.do { |layer|
          layer.set(\amp, 1.0 - progress);
        };
        section.layers.do { |layer|
          layer.set(\amp, progress);
        };

        (duration / steps).wait;
      };

      currentSection = section;
      transitioning = false;
    };
  }
}
```

---

## Rule Examples

```supercollider
// ===== HIGH TENSION RULE =====
var highTensionRule = QAdaptRule(
  name: \high_tension,
  condition: { |ctx| ctx.tension > 0.7 },
  actions: [
    (type: \set_intensity, value: 0.9, priority: 10),
    (type: \add_layer, layer: \percussion, fadeTime: 1.0, priority: 9),
    (type: \set_parameter, path: \tempo, value: 140, priority: 8)
  ],
  cooldown: 5.0 // Don't retrigger for 5 seconds
);

adapt.addRule(highTensionRule);

// ===== LOW HEALTH RULE =====
var lowHealthRule = QAdaptRule(
  name: \low_health,
  condition: { |ctx| ctx.playerHealth < 0.3 },
  actions: [
    (type: \transition_to, section: \danger, timing: \end_of_bar, priority: 10),
    (type: \add_layer, layer: \dark_pad, fadeTime: 2.0, priority: 9)
  ],
  cooldown: 10.0
);

adapt.addRule(lowHealthRule);

// ===== NIGHTTIME RULE =====
var nightRule = QAdaptRule(
  name: \nighttime,
  condition: { |ctx| ctx.timeOfDay == \night },
  actions: [
    (type: \remove_layer, layer: \bright_leads, fadeTime: 4.0, priority: 5),
    (type: \add_layer, layer: \ambient_night, fadeTime: 4.0, priority: 5),
    (type: \set_parameter, path: \brightness, value: 0.3, priority: 4)
  ]
);

adapt.addRule(nightRule);

// ===== ENEMY PROXIMITY RULE =====
var enemyProximityRule = QAdaptRule(
  name: \enemies_nearby,
  condition: { |ctx| ctx.enemiesNearby > 2 },
  actions: [
    (type: \transition_to, section: \combat, timing: \end_of_bar, priority: 10),
    (type: \set_intensity, value: 0.8, priority: 9)
  ],
  cooldown: 3.0
);

adapt.addRule(enemyProximityRule);
```

---

## OSC Integration

```supercollider
(
// ===== SETUP OSC LISTENER =====
var adapt = QAdapt(q);

OSCFunc({ |msg, time, addr, port|
  var intensity = msg[1]; // 0.0 - 1.0
  adapt.updateContext(\intensity, intensity);
}, '/game/intensity');

OSCFunc({ |msg|
  var health = msg[1]; // 0.0 - 1.0
  adapt.updateContext(\playerHealth, health);
}, '/game/player/health');

OSCFunc({ |msg|
  var enemies = msg[1].asInteger;
  adapt.updateContext(\enemiesNearby, enemies);
}, '/game/enemies/count');

OSCFunc({ |msg|
  var section = msg[1].asSymbol;
  adapt.jumpTo(section, timing: \end_of_bar);
}, '/game/section/change');

"OSC listeners active on port 57120".postln;
)

// ===== GAME ENGINE SENDS OSC =====
// Example from Unity/Unreal/Godot:
// OSCClient.Send("/game/intensity", 0.75);
// OSCClient.Send("/game/player/health", 0.3);
// OSCClient.Send("/game/enemies/count", 5);
```

---

## Complete Example

```supercollider
(
// ===== COMPOSITION =====
q = QProject(\game_music);
q.tempo = 120;

// Define sections
q.timeline.add(\explore, 16.bars, energy: 0.3);
q.timeline.add(\combat, 16.bars, energy: 0.8);
q.timeline.add(\danger, 16.bars, energy: 0.9);
q.timeline.add(\victory, 8.bars, energy: 0.6);

// Define layers with intensity thresholds
q.scene.addLayer(\ambient, \pad);           // Always on
q.scene.addLayer(\melody, \lead);           // Intensity > 0.3
q.scene.addLayer(\bass, \subbass);          // Intensity > 0.5
q.scene.addLayer(\drums, \kit);             // Intensity > 0.7
q.scene.addLayer(\percussion, \perc);       // Intensity > 0.8

// ===== ADAPTIVE ENGINE =====
var adapt = QAdapt(q);

// Configure layer intensities
adapt.layerController.setLayerIntensity(\ambient, 0.0);
adapt.layerController.setLayerIntensity(\melody, 0.3);
adapt.layerController.setLayerIntensity(\bass, 0.5);
adapt.layerController.setLayerIntensity(\drums, 0.7);
adapt.layerController.setLayerIntensity(\percussion, 0.8);

// Add rules
adapt.addRule(QAdaptRule(
  \high_intensity,
  { |ctx| ctx.intensity > 0.8 },
  [(type: \transition_to, section: \combat, timing: \end_of_bar, priority: 10)]
));

adapt.addRule(QAdaptRule(
  \low_intensity,
  { |ctx| ctx.intensity < 0.3 },
  [(type: \transition_to, section: \explore, timing: \end_of_bar, priority: 10)]
));

adapt.addRule(QAdaptRule(
  \low_health,
  { |ctx| ctx.playerHealth < 0.3 },
  [(type: \transition_to, section: \danger, timing: \immediate, priority: 10)]
));

// ===== SIMULATION =====
fork {
  var time = 0;

  loop {
    // Simulate game state changes
    adapt.updateContext(\intensity, sin(time * 0.1).linlin(-1, 1, 0, 1));
    adapt.updateContext(\playerHealth, 0.8.rand + 0.2);
    adapt.updateContext(\enemiesNearby, rrand(0, 5));

    2.wait;
    time = time + 2;
  };
};

"Adaptive music system running".postln;
)
```

---

## Use Cases

### Video Games
- Combat intensity scaling
- Health-based music changes
- Location-based themes
- Dynamic boss music

### Installations
- Visitor count → music density
- Time of day → mood
- Weather → texture
- Temperature → tempo

### Interactive Performances
- MIDI controller → live remixing
- Audience interaction → music response
- Biometric data → emotional music

### VR/AR Experiences
- User position → spatial music
- Interaction → musical feedback
- Story progression → theme development

---

## Summary

| Feature | Description | LOC |
|---------|-------------|-----|
| **Vertical Remixing** | Add/remove layers | ~300 |
| **Horizontal Resequencing** | Section jumps | ~200 |
| **Parameter Mapping** | External → musical params | ~150 |
| **Rule Engine** | Conditional adaptation | ~400 |
| **Transition System** | Smooth transitions | ~300 |
| **Layer Controller** | Intensity-based layers | ~150 |
| **TOTAL** | — | **~1,500** |

**Classes**: 8 (QAdapt, QAdaptContext, QAdaptRule, QLayerController, QTransitionEngine, and helpers)

**Implementation**: 3 weeks (Weeks 66-68)

---

**QAdapt: Music that responds to the world**
