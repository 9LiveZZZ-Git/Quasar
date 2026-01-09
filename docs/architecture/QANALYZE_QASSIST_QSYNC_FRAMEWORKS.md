# QAnalyze, QAssist & QSync: Analysis, AI Assistant, and Media Sync Frameworks

**Status**: Design Complete ✅
**Phases**: 14 (Analysis/AI, Weeks 69-72), 15 (Sync, Weeks 73-74)
**LOC Estimate**: ~2,800 lines combined
**Classes**: ~16 classes

---

## Part 1: QAnalyze - Musical Analysis Framework

### Philosophy

**Problem**: Understanding existing music (MIDI, audio, scores) is difficult. Composers need tools to learn from examples, auto-tag compositions, and extract musical features.

**Solution**: **QAnalyze** provides comprehensive musical analysis:
- Key/chord detection
- Form analysis (detect sections)
- Motif extraction
- Style classification
- Tempo/meter detection

---

### QAnalyze Architecture

```supercollider
// ===== MAIN ENGINE =====
QAnalyze {
  var <source;             // Audio buffer or MIDI data
  var <results;            // Analysis results

  *new { |source|
    ^super.newCopyArgs(source).init;
  }

  init {
    results = IdentityDictionary();
  }

  // Run full analysis
  analyzeAll {
    this.detectKey;
    this.detectChords;
    this.detectTempo;
    this.detectForm;
    this.extractMotifs;
    this.classifyStyle;

    ^results;
  }

  // Key detection
  detectKey {
    var keyProfile = this.buildKeyProfile;
    var bestMatch = this.matchKeyProfile(keyProfile);

    results[\key] = bestMatch;
    "Detected key: %".format(bestMatch).postln;
    ^bestMatch;
  }

  buildKeyProfile {
    // Krumhansl-Schmuckler algorithm
    var pitchClasses = Array.fill(12, 0);

    source.notes.do { |note|
      var pc = note.midinote % 12;
      pitchClasses[pc] = pitchClasses[pc] + note.dur;
    };

    ^pitchClasses.normalizeSum;
  }

  matchKeyProfile { |profile|
    var majorProfile = [6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88].normalizeSum;
    var minorProfile = [6.33, 2.68, 3.52, 5.38, 2.60, 3.53, 2.54, 4.75, 3.98, 2.69, 3.34, 3.17].normalizeSum;

    var bestKey = nil;
    var bestScore = -inf;

    // Try all 24 keys
    12.do { |root|
      [\major, \minor].do { |mode|
        var template = if (mode == \major) { majorProfile } { minorProfile };
        var rotated = template.rotate(root);
        var score = profile.correlate(rotated);

        if (score > bestScore) {
          bestScore = score;
          bestKey = (root: root, mode: mode);
        };
      };
    };

    ^bestKey;
  }

  // Chord detection
  detectChords {
    var chords = [];
    var windowSize = 1.0; // 1 beat windows

    (source.duration / windowSize).ceil.do { |i|
      var window = source.getWindow(i * windowSize, windowSize);
      var chord = this.identifyChord(window);
      chords = chords.add(chord);
    };

    results[\chords] = chords;
    "Detected % chords".format(chords.size).postln;
    ^chords;
  }

  identifyChord { |window|
    var pitchClasses = window.notes.collect { |n| n.midinote % 12 }.as(Set);

    // Simple chord matching
    var chordDatabase = [
      ([0, 4, 7], \major),
      ([0, 3, 7], \minor),
      ([0, 4, 7, 10], \dominant7),
      ([0, 4, 7, 11], \major7),
      ([0, 3, 7, 10], \minor7)
      // ... more chords
    ];

    chordDatabase.do { |entry|
      var template = entry[0].as(Set);
      12.do { |root|
        var rotated = (template + root) % 12;
        if (rotated == pitchClasses) {
          ^(root: root, type: entry[1]);
        };
      };
    };

    ^(root: nil, type: \unknown);
  }

  // Tempo detection
  detectTempo {
    var onsets = this.detectOnsets;
    var intervals = onsets.doAdjacentPairs { |a, b| b - a };
    var histogram = this.buildIOIHistogram(intervals);
    var tempo = this.findDominantPeriod(histogram);

    results[\tempo] = tempo;
    "Detected tempo: % BPM".format(tempo.round(1)).postln;
    ^tempo;
  }

  detectOnsets {
    // Spectral flux onset detection
    // Placeholder: return array of onset times
    ^[];
  }

  // Form analysis
  detectForm {
    var sections = this.segmentByNovelty;
    var labels = this.labelSections(sections);

    results[\form] = labels;
    "Detected form: %".format(labels.join("-")).postln;
    ^labels;
  }

  segmentByNovelty {
    // Novelty-based segmentation
    // Compare adjacent windows for change
    var segments = [];
    var threshold = 0.5;

    // TODO: Implement full novelty curve
    ^segments;
  }

  labelSections { |sections|
    // Label sections as A, B, C, etc.
    var labels = [];
    var currentLabel = $A.ascii;

    sections.do { |section|
      var similar = sections.detect { |s|
        this.sectionSimilarity(section, s) > 0.8
      };

      if (similar.notNil) {
        labels = labels.add(similar.label);
      } {
        labels = labels.add(currentLabel.asAscii);
        currentLabel = currentLabel + 1;
      };
    };

    ^labels;
  }

  // Motif extraction
  extractMotifs {
    var motifs = [];
    var windowSize = 4; // 4-note windows

    source.notes.slide(windowSize).do { |window|
      var motif = window.collect { |n| (pitch: n.midinote, dur: n.dur) };
      motifs = motifs.add(motif);
    };

    // Find repeated motifs
    var repeated = this.findRepeatedMotifs(motifs);

    results[\motifs] = repeated;
    "Found % repeated motifs".format(repeated.size).postln;
    ^repeated;
  }

  findRepeatedMotifs { |motifs|
    var counts = IdentityDictionary();

    motifs.do { |motif|
      var key = motif.asString; // Simplification
      counts[key] = (counts[key] ? 0) + 1;
    };

    ^counts.select { |count| count > 1 }.keys;
  }

  // Style classification
  classifyStyle {
    var features = this.extractStyleFeatures;
    var style = this.matchStyle(features);

    results[\style] = style;
    "Classified style: %".format(style).postln;
    ^style;
  }

  extractStyleFeatures {
    ^(
      avgTempo: results[\tempo],
      keyMode: results[\key].mode,
      chordComplexity: this.calculateChordComplexity,
      rhythmicDensity: this.calculateRhythmicDensity,
      melodicRange: this.calculateMelodicRange
    );
  }

  matchStyle { |features|
    // Simple heuristic matching
    if (features.avgTempo > 140) { ^\edm };
    if (features.avgTempo < 80 and: { features.chordComplexity > 0.7 }) { ^\jazz };
    if (features.keyMode == \minor and: { features.melodicRange < 12 }) { ^\ambient };

    ^\unknown;
  }
}
```

---

## Part 2: QAssist - AI Composition Assistant

### Philosophy

**Problem**: Writer's block, indecision, and lack of experience slow down composition. Composers need intelligent suggestions.

**Solution**: **QAssist** provides AI-powered assistance:
- Smart completion (finish phrases)
- Chord suggestions
- Conflict detection
- "Make it better" improvements

---

### QAssist Architecture

```supercollider
// ===== MAIN ENGINE =====
QAssist {
  var <project;
  var <analyzer;           // QAnalyze instance
  var <memory;             // Past suggestions

  *new { |project|
    ^super.newCopyArgs(project).init;
  }

  init {
    analyzer = QAnalyze(project);
    memory = [];
  }

  // Complete a phrase
  completePhrase { |partialMelody|
    var analysis = analyzer.analyze(partialMelody);
    var key = analysis.key;
    var lastInterval = this.getLastInterval(partialMelody);
    var candidates = this.generateCandidates(partialMelody, key);

    var best = this.rankCandidates(candidates, partialMelody);

    "Suggested completion: %".format(best).postln;
    ^best;
  }

  generateCandidates { |melody, key|
    var candidates = [];
    var lastNote = melody.notes.last.midinote;

    // Generate possible next notes
    [-2, -1, 0, 1, 2, 3, 4, 5, 7].do { |interval|
      var nextNote = lastNote + interval;

      // Check if in scale
      if (this.isInScale(nextNote, key)) {
        candidates = candidates.add(nextNote);
      };
    };

    ^candidates;
  }

  rankCandidates { |candidates, melody|
    var scores = candidates.collect { |candidate|
      var score = 0;

      // Prefer stepwise motion
      var lastNote = melody.notes.last.midinote;
      var interval = (candidate - lastNote).abs;
      if (interval <= 2) { score = score + 5 };

      // Prefer downward resolution if previous was upward
      var prevInterval = this.getLastInterval(melody);
      if (prevInterval > 0 and: { (candidate - lastNote) < 0 }) {
        score = score + 3; // Contour balance
      };

      // Prefer chord tones
      if (this.isChordTone(candidate, melody.harmony)) {
        score = score + 2;
      };

      (candidate: candidate, score: score);
    };

    ^scores.maxItem { |x| x.score }.candidate;
  }

  // Suggest chords for melody
  suggestChords { |melody|
    var key = analyzer.detectKey(melody);
    var chords = [];

    // Analyze each bar
    melody.bars.do { |bar|
      var prominentNotes = this.getProminentNotes(bar);
      var chord = this.findMatchingChord(prominentNotes, key);
      chords = chords.add(chord);
    };

    "Suggested % chords".format(chords.size).postln;
    ^chords;
  }

  findMatchingChord { |notes, key|
    var pitchClasses = notes.collect { |n| n % 12 }.as(Set);

    // Try diatonic chords
    var diatonicChords = QHarmony.diatonicChords(key);

    diatonicChords.do { |chord|
      var chordPCs = chord.notes.collect { |n| n % 12 }.as(Set);

      if (pitchClasses.isSubsetOf(chordPCs)) {
        ^chord;
      };
    };

    ^nil; // No match
  }

  // Check for issues
  checkForIssues { |composition|
    var issues = [];

    // Parallel fifths/octaves
    issues = issues ++ this.checkParallelMotion(composition);

    // Voice crossing
    issues = issues ++ this.checkVoiceCrossing(composition);

    // Range violations
    issues = issues ++ this.checkRangeViolations(composition);

    "Found % issues".format(issues.size).postln;
    ^issues;
  }

  // Improve composition
  improve { |composition, aspect=\overall|
    switch(aspect,
      \overall, {
        composition = this.improveVoiceLeading(composition);
        composition = this.improveRhythm(composition);
        composition = this.improveHarmony(composition);
      },
      \voice_leading, {
        composition = this.improveVoiceLeading(composition);
      },
      \rhythm, {
        composition = this.improveRhythm(composition);
      },
      \harmony, {
        composition = this.improveHarmony(composition);
      }
    );

    "Improved %".format(aspect).postln;
    ^composition;
  }

  improveVoiceLeading { |comp|
    // Minimize voice movement
    comp.voices.doAdjacentPairs { |chord1, chord2|
      chord2.notes = this.reorderForSmooth VoiceLeading(chord1.notes, chord2.notes);
    };
    ^comp;
  }

  improveRhythm { |comp|
    // Add variation, avoid monotony
    if (this.isRhythmicallyMonotonous(comp)) {
      comp = this.addRhythmicVariation(comp);
    };
    ^comp;
  }

  improveHarmony { |comp|
    // Add passing chords, substitutions
    comp = this.addPassingChords(comp);
    ^comp;
  }
}
```

---

## Part 3: QSync - Media Synchronization Framework

### Philosophy

**Problem**: Music for film, video, and games must sync precisely to timecode, hit points, and video frames.

**Solution**: **QSync** provides frame-accurate synchronization:
- SMPTE timecode support
- Hit point alignment
- Tempo mapping to duration
- Frame-accurate rendering

---

### QSync Architecture

```supercollider
// ===== MAIN ENGINE =====
QSync {
  var <project;
  var <timecode;           // QTimecode
  var <hitPoints;          // Array of QHitPoint
  var <videoFrameRate = 24; // fps

  *new { |project, frameRate=24|
    ^super.newCopyArgs(project, nil, [], frameRate).init;
  }

  init {
    timecode = QTimecode(videoFrameRate);
    "QSync initialized: % fps".format(videoFrameRate).postln;
  }

  // Add hit point
  addHitPoint { |time, description, intensity=0.5|
    var hitPoint = QHitPoint(time, description, intensity);
    hitPoints = hitPoints.add(hitPoint);
    hitPoints = hitPoints.sort { |a, b| a.time < b.time };

    "Hit point added: % at %".format(description, time).postln;
    ^hitPoint;
  }

  // Fit composition to duration
  fitToDuration { |targetDuration|
    var currentDuration = project.duration;
    var ratio = targetDuration / currentDuration;

    // Adjust tempo
    project.tempo = project.tempo * ratio;

    "Fitted composition: %s → %s (tempo: % BPM)".format(
      currentDuration.round(0.1),
      targetDuration.round(0.1),
      project.tempo.round(1)
    ).postln;
  }

  // Align section to hit point
  alignToHitPoint { |section, hitPointIndex|
    var hitPoint = hitPoints[hitPointIndex];
    var sectionStart = section.startTime;
    var offset = hitPoint.time - sectionStart;

    // Shift section
    section.startTime = hitPoint.time;

    "Aligned % to hit point at %".format(
      section.name, hitPoint.time
    ).postln;
  }

  // Generate click track for conductor
  generateClickTrack {
    var clicks = [];
    var beatDuration = 60.0 / project.tempo;
    var numBeats = (project.duration / beatDuration).ceil;

    numBeats.do { |i|
      clicks = clicks.add((
        time: i * beatDuration,
        frame: (i * beatDuration * videoFrameRate).round,
        beat: i
      ));
    };

    "Generated click track: % beats".format(clicks.size).postln;
    ^clicks;
  }

  // Render with timecode burn-in
  renderWithTimecode { |outputPath|
    "Rendering with SMPTE timecode...".postln;

    // TODO: Add timecode to audio metadata
    project.render(outputPath);
  }
}

// ===== TIMECODE =====
QTimecode {
  var <frameRate;

  *new { |frameRate=24| ^super.newCopyArgs(frameRate) }

  // Convert seconds to SMPTE (HH:MM:SS:FF)
  secondsToSMPTE { |seconds|
    var totalFrames = (seconds * frameRate).round;
    var hours = (totalFrames / (frameRate * 3600)).floor;
    var minutes = ((totalFrames % (frameRate * 3600)) / (frameRate * 60)).floor;
    var secs = ((totalFrames % (frameRate * 60)) / frameRate).floor;
    var frames = totalFrames % frameRate;

    ^"%:%:%:%".format(
      hours.asString.padLeft(2, "0"),
      minutes.asString.padLeft(2, "0"),
      secs.asString.padLeft(2, "0"),
      frames.asString.padLeft(2, "0")
    );
  }

  // Convert SMPTE to seconds
  smpteToSeconds { |smpte|
    var parts = smpte.split($:);
    var hours = parts[0].asInteger;
    var minutes = parts[1].asInteger;
    var secs = parts[2].asInteger;
    var frames = parts[3].asInteger;

    ^(hours * 3600) + (minutes * 60) + secs + (frames / frameRate);
  }
}

// ===== HIT POINT =====
QHitPoint {
  var <time;               // Seconds
  var <description;        // "Door slam", "Explosion", etc.
  var <intensity;          // 0-1

  *new { |time, description, intensity=0.5|
    ^super.newCopyArgs(time, description, intensity);
  }

  smpte { |frameRate=24|
    ^QTimecode(frameRate).secondsToSMPTE(time);
  }
}
```

---

## Integration Examples

### Example 1: Analyze Existing Composition

```supercollider
(
// Load MIDI file
var midi = QMIDIFile.load("~/my_composition.mid");

// Analyze
var analyze = QAnalyze(midi);
var results = analyze.analyzeAll;

"=== ANALYSIS RESULTS ===".postln;
"Key: %".format(results[\key]).postln;
"Tempo: % BPM".format(results[\tempo]).postln;
"Form: %".format(results[\form]).postln;
"Style: %".format(results[\style]).postln;
"Chords: % detected".format(results[\chords].size).postln;
)
```

### Example 2: AI-Assisted Composition

```supercollider
(
q = QProject(\assisted);
var assist = QAssist(q);

// Start melody
var melody = QMelody([60, 62, 64, 65].collect { |n| (midinote: n, dur: 0.5) });

// Ask AI to complete it
var completion = assist.completePhrase(melody);
melody.notes = melody.notes ++ completion;

// Suggest chords
var chords = assist.suggestChords(melody);

// Check for issues
var issues = assist.checkForIssues(q);
issues.do { |issue| issue.postln };

// Improve if needed
if (issues.notEmpty) {
  q = assist.improve(q, aspect: \voice_leading);
};
)
```

### Example 3: Film Scoring with Sync

```supercollider
(
q = QProject(\film_score);
var sync = QSync(q, frameRate: 24);

// Add hit points from spotting session
sync.addHitPoint(12.5, "Door opens", intensity: 0.3);
sync.addHitPoint(34.8, "Car crash", intensity: 0.9);
sync.addHitPoint(67.2, "Kiss", intensity: 0.6);
sync.addHitPoint(90.0, "End credits", intensity: 0.4);

// Compose sections
q.timeline.add(\intro, 12.bars);
q.timeline.add(\action, 16.bars);
q.timeline.add(\romance, 12.bars);
q.timeline.add(\credits, 8.bars);

// Align sections to hit points
sync.alignToHitPoint(q.timeline[\intro], 0);
sync.alignToHitPoint(q.timeline[\action], 1);
sync.alignToHitPoint(q.timeline[\romance], 2);
sync.alignToHitPoint(q.timeline[\credits], 3);

// Fit to total video duration (2 minutes)
sync.fitToDuration(120.0);

// Render with timecode
sync.renderWithTimecode("~/film_score_synced.wav");
)
```

---

## Summary

| Framework | LOC | Classes | Weeks |
|-----------|-----|---------|-------|
| **QAnalyze** | ~1,200 | 6 | 2 |
| **QAssist** | ~1,000 | 5 | 2 |
| **QSync** | ~600 | 5 | 2 |
| **TOTAL** | **~2,800** | **16** | **6** |

---

**QAnalyze: Understand music • QAssist: Compose smarter • QSync: Perfect timing**
