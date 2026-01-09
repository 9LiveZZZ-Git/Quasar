# QSpatial: 3D Spatial Audio Framework

**Status**: Design Complete ✅
**Phase**: 11 (Weeks 59-61)
**LOC Estimate**: ~1,800 lines
**Classes**: ~10 classes

---

## Philosophy

**Problem**: Stereo mixing is limiting. Modern audio demands immersive 3D spatial experiences for VR/AR, Dolby Atmos, installations, and headphone listening.

**Solution**: **QSpatial** provides comprehensive 3D audio positioning, movement, and rendering for multiple output formats.

**Key Insight**: Abstract spatial composition (x, y, z coordinates) with format-agnostic rendering (stereo, 5.1, 7.1.4, binaural, Ambisonics).

---

## Core Capabilities

### 1. **Spatial Positioning**
- 3D Cartesian coordinates (x, y, z)
- Spherical coordinates (azimuth, elevation, distance)
- Named positions ("front-center", "overhead", "surround-left")

### 2. **Sound Movement & Trajectories**
- Linear paths (A → B)
- Circular/spiral trajectories
- Bezier curves
- Random walks
- Pattern-based movement (figure-8, orbits)

### 3. **Distance Modeling**
- Amplitude attenuation (inverse-square law)
- High-frequency rolloff (air absorption)
- Early reflections
- Doppler shift

### 4. **Output Format Rendering**
- **Stereo**: Intensity stereo, phantom center
- **Binaural**: HRTF-based 3D for headphones
- **Surround**: 5.1, 7.1, 7.1.4 (Dolby Atmos)
- **Ambisonics**: 1st-4th order B-format
- **VBAP**: Vector-based amplitude panning
- **DBAP**: Distance-based amplitude panning

### 5. **Room Simulation**
- Early reflections (walls, floor, ceiling)
- Reverberation (RT60, diffusion)
- Room size and material characteristics
- Occlusion/obstruction

---

## Architecture

```supercollider
// ===== MAIN ENGINE =====
QSpatial {
  var <project;
  var <scene;              // QSpatialScene
  var <renderer;           // QSpatialRenderer
  var <format;             // Output format
  var <sources;            // Array of QSpatialSource

  *new { |project, format=\stereo|
    ^super.newCopyArgs(project, format).init;
  }

  init {
    scene = QSpatialScene();
    sources = [];
    renderer = QSpatialRenderer(format);

    "QSpatial initialized: % output".format(format).postln;
  }

  // Add a spatial source
  addSource { |layer, position=(0, 0, 0)|
    var source = QSpatialSource(layer, position);
    sources = sources.add(source);
    scene.addSource(source);
    ^source;
  }

  // Move a source
  move { |source, toPosition, duration=1.0, curve=\linear|
    var trajectory = QTrajectory(
      source.position,
      toPosition,
      duration,
      curve
    );
    source.trajectory = trajectory;
  }

  // Render spatially
  render { |outputPath|
    renderer.render(sources, scene, outputPath);
  }

  // Change output format
  setFormat { |newFormat|
    format = newFormat;
    renderer = QSpatialRenderer(format);
    "Changed to % output".format(format).postln;
  }
}

// ===== SPATIAL SOURCE =====
QSpatialSource {
  var <layer;              // Audio layer
  var <position;           // (x, y, z) in meters
  var <trajectory;         // QTrajectory or nil
  var <directivity;        // Radiation pattern
  var <distance;           // Distance from listener
  var <azimuth;            // Angle (degrees)
  var <elevation;          // Angle (degrees)

  *new { |layer, position=(0, 0, 0)|
    ^super.newCopyArgs(layer, position).init;
  }

  init {
    this.updateSpherical;
    directivity = QDirectivity(\omnidirectional);
  }

  // Update position
  setPosition { |x, y, z|
    position = [x, y, z];
    this.updateSpherical;
  }

  // Convert to spherical
  updateSpherical {
    distance = sqrt(position[0].squared + position[1].squared + position[2].squared);
    azimuth = atan2(position[1], position[0]).raddeg; // -180 to 180
    elevation = asin(position[2] / distance.max(0.01)).raddeg; // -90 to 90

    "Source at: x=% y=% z=% | az=°% el=°% dist=%m".format(
      position[0].round(0.1), position[1].round(0.1), position[2].round(0.1),
      azimuth.round(1), elevation.round(1), distance.round(0.1)
    ).postln;
  }

  // Update position over time (for trajectories)
  updateTrajectory { |time|
    if (trajectory.notNil) {
      var newPos = trajectory.positionAt(time);
      this.setPosition(newPos[0], newPos[1], newPos[2]);
    };
  }
}

// ===== SPATIAL SCENE =====
QSpatialScene {
  var <sources;
  var <listener;           // QListener
  var <room;               // QRoom

  *new {
    ^super.new.init;
  }

  init {
    sources = [];
    listener = QListener();
    room = QRoom(\medium); // Default medium-sized room
  }

  addSource { |source|
    sources = sources.add(source);
  }

  removeSource { |source|
    sources.remove(source);
  }
}

// ===== LISTENER =====
QListener {
  var <position;
  var <orientation;        // Forward vector
  var <up;                 // Up vector

  *new {
    ^super.new.init;
  }

  init {
    position = [0, 0, 0];
    orientation = [0, 1, 0]; // Looking forward (positive Y)
    up = [0, 0, 1];          // Z is up
  }

  setPosition { |x, y, z|
    position = [x, y, z];
  }

  setOrientation { |azimuth, elevation|
    // Convert to forward vector
    var az = azimuth.degrad;
    var el = elevation.degrad;

    orientation = [
      cos(el) * sin(az),
      cos(el) * cos(az),
      sin(el)
    ];
  }
}

// ===== ROOM =====
QRoom {
  var <size;               // (width, length, height) in meters
  var <rt60;               // Reverberation time (seconds)
  var <materials;          // Wall materials
  var <reflections;        // Early reflections on/off

  *new { |preset=\medium|
    ^super.new.init(preset);
  }

  init { |preset|
    switch(preset,
      \small, {
        size = [5, 6, 3];
        rt60 = 0.3;
        materials = \absorptive;
      },
      \medium, {
        size = [10, 12, 4];
        rt60 = 0.8;
        materials = \balanced;
      },
      \large, {
        size = [20, 25, 8];
        rt60 = 1.5;
        materials = \reflective;
      },
      \hall, {
        size = [40, 50, 15];
        rt60 = 2.5;
        materials = \reflective;
      }
    );

    reflections = true;
  }
}

// ===== TRAJECTORY =====
QTrajectory {
  var <startPos, <endPos;
  var <duration;
  var <curve;
  var <startTime;

  *new { |startPos, endPos, duration, curve=\linear|
    ^super.newCopyArgs(startPos, endPos, duration, curve).init;
  }

  init {
    startTime = Main.elapsedTime;
  }

  // Get position at time t (0 to duration)
  positionAt { |t|
    var progress = (t / duration).clip(0, 1);
    var curved = this.applyCurve(progress);

    ^startPos.blend(endPos, curved);
  }

  applyCurve { |t|
    ^switch(curve,
      \linear, { t },
      \exp, { t.squared },
      \log, { t.sqrt },
      \sine, { sin(t * pi * 0.5) },
      \cosine, { 1 - cos(t * pi * 0.5) }
    );
  }

  // Special trajectories
  *circular { |center, radius, duration, plane=\xy|
    ^QCircularTrajectory(center, radius, duration, plane);
  }

  *spiral { |center, startRadius, endRadius, duration, turns=2|
    ^QSpiralTrajectory(center, startRadius, endRadius, duration, turns);
  }
}

// ===== CIRCULAR TRAJECTORY =====
QCircularTrajectory : QTrajectory {
  var <center, <radius, <plane;

  *new { |center, radius, duration, plane=\xy|
    ^super.new.initCircular(center, radius, duration, plane);
  }

  initCircular { |ctr, rad, dur, pln|
    center = ctr;
    radius = rad;
    duration = dur;
    plane = pln;
    startTime = Main.elapsedTime;
  }

  positionAt { |t|
    var angle = (t / duration) * 2pi;
    var x, y, z;

    switch(plane,
      \xy, {
        x = center[0] + (radius * cos(angle));
        y = center[1] + (radius * sin(angle));
        z = center[2];
      },
      \xz, {
        x = center[0] + (radius * cos(angle));
        y = center[1];
        z = center[2] + (radius * sin(angle));
      },
      \yz, {
        x = center[0];
        y = center[1] + (radius * cos(angle));
        z = center[2] + (radius * sin(angle));
      }
    );

    ^[x, y, z];
  }
}

// ===== SPATIAL RENDERER =====
QSpatialRenderer {
  var <format;
  var <decoder;            // Format-specific decoder

  *new { |format=\stereo|
    ^super.newCopyArgs(format).init;
  }

  init {
    decoder = switch(format,
      \stereo, { QStereoDecoder() },
      \binaural, { QBinauralDecoder() },
      \surround_51, { QSurroundDecoder(\surround_51) },
      \surround_71, { QSurroundDecoder(\surround_71) },
      \atmos_714, { QSurroundDecoder(\atmos_714) },
      \ambisonics_1, { QAmbisonicsDecoder(1) },
      \ambisonics_3, { QAmbisonicsDecoder(3) },
      \vbap, { QVBAPDecoder() }
    );
  }

  render { |sources, scene, outputPath|
    "Rendering % sources to % format...".format(
      sources.size, format
    ).postln;

    // Render each source
    sources.do { |source|
      decoder.decode(source, scene);
    };

    // Export
    decoder.export(outputPath);
  }
}

// ===== STEREO DECODER =====
QStereoDecoder {
  decode { |source, scene|
    var azimuth = source.azimuth;
    var distance = source.distance;

    // Simple intensity stereo
    var pan = (azimuth / 180).clip(-1, 1); // -1 = left, 1 = right

    // Distance attenuation
    var amp = 1.0 / (distance.max(0.5).squared);

    source.layer.set(\pan, pan, \amp, amp);

    "Stereo: pan=% amp=%".format(
      pan.round(0.01), amp.round(0.01)
    ).postln;
  }

  export { |path|
    "Exporting stereo to %".format(path).postln;
    // Use server.render or NRT
  }
}

// ===== BINAURAL DECODER =====
QBinauralDecoder {
  var <hrtf;               // HRTF dataset

  *new {
    ^super.new.init;
  }

  init {
    // Load HRTF (Head-Related Transfer Function)
    hrtf = QHRTF.load(\default);
    "Loaded HRTF dataset".postln;
  }

  decode { |source, scene|
    var azimuth = source.azimuth;
    var elevation = source.elevation;
    var distance = source.distance;

    // Get HRTF filters for this position
    var leftFilter = hrtf.getFilter(azimuth, elevation, \left);
    var rightFilter = hrtf.getFilter(azimuth, elevation, \right);

    // Distance attenuation
    var amp = 1.0 / (distance.max(0.5).squared);

    // Apply HRTF convolution
    source.layer.addFX(\binaural, (
      leftFilter: leftFilter,
      rightFilter: rightFilter,
      amp: amp
    ));

    "Binaural: az=°% el=°% dist=%m".format(
      azimuth.round(1), elevation.round(1), distance.round(0.1)
    ).postln;
  }

  export { |path|
    "Exporting binaural to %".format(path).postln;
  }
}

// ===== HRTF DATABASE =====
QHRTF {
  classvar <datasets;

  *initClass {
    datasets = IdentityDictionary[
      \default -> (
        name: "MIT KEMAR",
        elevations: (-40, -30, -20, -10, 0, 10, 20, 30, 40, 50, 60, 70, 80, 90),
        azimuths: Array.fill(37, { |i| i * 10 - 180 })
        // HRTF IR buffers would be loaded here
      )
    ];
  }

  *load { |name=\default|
    ^datasets[name];
  }

  getFilter { |azimuth, elevation, ear|
    // TODO: Interpolate between nearest HRTF measurements
    // For now, return placeholder
    ^Buffer.alloc(Server.default, 128);
  }
}

// ===== SURROUND DECODER =====
QSurroundDecoder {
  var <format;
  var <speakers;           // Speaker positions

  *new { |format=\surround_51|
    ^super.newCopyArgs(format).init;
  }

  init {
    speakers = switch(format,
      \surround_51, {
        [
          (\name: \L,    \azimuth: -30,  \elevation: 0),
          (\name: \R,    \azimuth: 30,   \elevation: 0),
          (\name: \C,    \azimuth: 0,    \elevation: 0),
          (\name: \LFE,  \azimuth: 0,    \elevation: -90),
          (\name: \Ls,   \azimuth: -110, \elevation: 0),
          (\name: \Rs,   \azimuth: 110,  \elevation: 0)
        ]
      },
      \surround_71, {
        [
          (\name: \L,    \azimuth: -30,  \elevation: 0),
          (\name: \R,    \azimuth: 30,   \elevation: 0),
          (\name: \C,    \azimuth: 0,    \elevation: 0),
          (\name: \LFE,  \azimuth: 0,    \elevation: -90),
          (\name: \Lss,  \azimuth: -90,  \elevation: 0),
          (\name: \Rss,  \azimuth: 90,   \elevation: 0),
          (\name: \Lsr,  \azimuth: -150, \elevation: 0),
          (\name: \Rsr,  \azimuth: 150,  \elevation: 0)
        ]
      },
      \atmos_714, {
        [
          // Bed layer
          (\name: \L,    \azimuth: -30,  \elevation: 0),
          (\name: \R,    \azimuth: 30,   \elevation: 0),
          (\name: \C,    \azimuth: 0,    \elevation: 0),
          (\name: \LFE,  \azimuth: 0,    \elevation: -90),
          (\name: \Lss,  \azimuth: -90,  \elevation: 0),
          (\name: \Rss,  \azimuth: 90,   \elevation: 0),
          (\name: \Lsr,  \azimuth: -150, \elevation: 0),
          (\name: \Rsr,  \azimuth: 150,  \elevation: 0),
          // Height layer
          (\name: \Ltf,  \azimuth: -30,  \elevation: 45),
          (\name: \Rtf,  \azimuth: 30,   \elevation: 45),
          (\name: \Ltr,  \azimuth: -150, \elevation: 45),
          (\name: \Rtr,  \azimuth: 150,  \elevation: 45)
        ]
      }
    );

    "Initialized % with % speakers".format(format, speakers.size).postln;
  }

  decode { |source, scene|
    var azimuth = source.azimuth;
    var elevation = source.elevation;
    var distance = source.distance;

    // VBAP-style panning to nearest speakers
    var gains = this.calculateVBAP(azimuth, elevation);

    // Distance attenuation
    var amp = 1.0 / (distance.max(0.5).squared);

    gains.keysValuesDo { |speaker, gain|
      "  % = %".format(speaker, (gain * amp).round(0.01)).postln;
    };

    source.layer.set(\surroundGains, gains, \amp, amp);
  }

  calculateVBAP { |azimuth, elevation|
    // Vector-Based Amplitude Panning
    // Find 2-3 nearest speakers and calculate gains

    var sourceVector = this.sphericalToCartesian(azimuth, elevation);
    var gains = IdentityDictionary();

    // Find nearest speakers (simplified)
    var nearest = speakers.sortBy { |spk|
      this.angularDistance(
        azimuth, elevation,
        spk.azimuth, spk.elevation
      );
    }.keep(3);

    // Calculate gains (simplified triplet VBAP)
    nearest.do { |spk|
      var dist = this.angularDistance(
        azimuth, elevation,
        spk.azimuth, spk.elevation
      );
      var gain = (1.0 - (dist / 180)).max(0).squared;
      gains[spk.name] = gain;
    };

    // Normalize
    var sum = gains.values.sum;
    if (sum > 0) {
      gains.keysValuesDo { |k, v| gains[k] = v / sum };
    };

    ^gains;
  }

  sphericalToCartesian { |azimuth, elevation|
    var az = azimuth.degrad;
    var el = elevation.degrad;
    ^[
      cos(el) * sin(az),
      cos(el) * cos(az),
      sin(el)
    ];
  }

  angularDistance { |az1, el1, az2, el2|
    // Great circle distance
    var v1 = this.sphericalToCartesian(az1, el1);
    var v2 = this.sphericalToCartesian(az2, el2);
    var dot = (v1[0] * v2[0]) + (v1[1] * v2[1]) + (v1[2] * v2[2]);
    ^acos(dot.clip(-1, 1)).raddeg;
  }

  export { |path|
    "Exporting % to %".format(format, path).postln;
  }
}

// ===== AMBISONICS DECODER =====
QAmbisonicsDecoder {
  var <order;              // 1st, 2nd, 3rd, 4th order
  var <numChannels;        // (order + 1)^2

  *new { |order=1|
    ^super.newCopyArgs(order).init;
  }

  init {
    numChannels = (order + 1).squared;
    "Ambisonics order % (%ch)".format(order, numChannels).postln;
  }

  decode { |source, scene|
    var azimuth = source.azimuth.degrad;
    var elevation = source.elevation.degrad;
    var distance = source.distance;

    // Encode to B-format
    var bFormat = this.encode(azimuth, elevation, distance);

    source.layer.set(\ambisonics, bFormat);

    "Ambisonics: %ch B-format".format(numChannels).postln;
  }

  encode { |azimuth, elevation, distance|
    var bFormat = Array.fill(numChannels, 0);

    // Distance attenuation
    var amp = 1.0 / (distance.max(0.5).squared);

    // Spherical harmonics
    // Order 0 (W)
    bFormat[0] = amp * 0.7071; // Omnidirectional

    if (order >= 1) {
      // Order 1 (X, Y, Z)
      bFormat[1] = amp * cos(elevation) * sin(azimuth);   // X (front-back)
      bFormat[2] = amp * cos(elevation) * cos(azimuth);   // Y (left-right)
      bFormat[3] = amp * sin(elevation);                  // Z (up-down)
    };

    // Higher orders would go here...
    // Order 2: 5 channels (R, S, T, U, V)
    // Order 3: 7 channels
    // Order 4: 9 channels

    ^bFormat;
  }

  export { |path|
    "Exporting Ambisonics order % to %".format(order, path).postln;
  }
}
```

---

## Integration Example

```supercollider
(
// ===== COMPOSITION =====
q = QProject(\immersive);
q.tempo = 100;

// Create layers
var kick = q.scene.addLayer(\kick, \909kick);
var bass = q.scene.addLayer(\bass, \subbass);
var lead = q.scene.addLayer(\lead, \sawlead);
var pad = q.scene.addLayer(\pad, \pad);

// ===== SPATIAL SETUP =====
// Use Dolby Atmos 7.1.4 format
var spatial = QSpatial(q, format: \atmos_714);

// Set room
spatial.scene.room = QRoom(\hall);

// ===== ADD SPATIAL SOURCES =====
// Kick: front center, static
var kickSource = spatial.addSource(kick, position: [0, 2, 0]);

// Bass: center, slightly back
var bassSource = spatial.addSource(bass, position: [0, 1, 0]);

// Lead: circular motion overhead
var leadSource = spatial.addSource(lead, position: [2, 2, 2]);
spatial.move(
  leadSource,
  QTrajectory.circular(
    center: [0, 2, 2],
    radius: 3,
    duration: 16,
    plane: \xy
  )
);

// Pad: wide stereo field
var padSourceL = spatial.addSource(pad, position: [-4, 2, 1]);
var padSourceR = spatial.addSource(pad, position: [4, 2, 1]);

// ===== ANIMATE =====
fork {
  var time = 0;
  loop {
    // Update trajectories
    spatial.sources.do { |source|
      source.updateTrajectory(time);
    };

    time = time + 0.1;
    0.1.wait;
  };
};

// ===== RENDER =====
spatial.render("~/immersive_atmos.wav");

// ===== ALSO RENDER BINAURAL VERSION =====
spatial.setFormat(\binaural);
spatial.render("~/immersive_binaural.wav");
)
```

---

## Use Cases

### VR/AR Applications
- Immersive game audio
- Virtual concerts
- 360° video soundtracks

### Dolby Atmos Content
- Film post-production
- Music mixing (streaming platforms)
- Immersive albums

### Installations
- Museum exhibits
- Art installations
- Spatial performances

### Binaural Content
- Headphone-based experiences
- ASMR/immersive podcasts
- Virtual reality audio

---

## Summary

| Feature | Formats | Notes |
|---------|---------|-------|
| **Stereo** | 2.0 | Intensity panning |
| **Binaural** | 2.0 (HRTF) | 3D for headphones |
| **Surround** | 5.1, 7.1, 7.1.4 | Standard formats |
| **Ambisonics** | 1st-4th order | Scene-based |
| **VBAP** | Any speaker array | Vector panning |
| **Movement** | Linear, circular, spiral | Trajectories |
| **Distance** | Attenuation, air absorption | Physics-based |
| **Room** | Early reflections, RT60 | Acoustic modeling |
| **LOC** | ~1,800 | — |
| **Classes** | 10 | — |

**Implementation**: 3 weeks (Weeks 59-61)

---

**QSpatial: From stereo to Dolby Atmos, with immersive 3D audio for every format.**
