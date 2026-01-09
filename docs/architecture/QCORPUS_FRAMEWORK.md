# QCorpus: Corpus-Based Composition Framework

**Status**: Design Complete ✅
**Phase**: 18 (Weeks 64-66)
**LOC Estimate**: ~1,800 lines
**Classes**: ~9 classes

---

## Philosophy

**Problem**: Composers often want to work with existing musical material—analyzing corpora, extracting patterns, learning styles, generating variations based on real music. Traditional composition from scratch is slow compared to AI that learns from massive datasets.

**Solution**: **QCorpus** provides corpus-based composition capabilities:
- Analyze existing music (MIDI, audio, scores)
- Extract musical patterns and features
- Learn style models from corpora
- Generate new material in learned styles
- Concatenative composition (musical mosaicking)
- Style transfer from reference tracks
- Pattern mining and reuse

**Key Insight**: Give composers AI-like speed by letting them work FROM existing material, not just abstract rules.

---

## Core Capabilities

### 1. **Corpus Analysis**
- Import multiple pieces (MIDI files, audio files, MusicXML)
- Extract features (rhythmic patterns, melodic contours, harmonic progressions, timbral profiles)
- Build searchable databases
- Cluster similar materials

### 2. **Pattern Extraction & Mining**
- Find repeated motifs across corpus
- Extract common chord progressions
- Discover rhythmic patterns
- Mine voice leading patterns
- Identify structural templates

### 3. **Style Learning**
- Build statistical models from corpus
- Learn transition probabilities (Markov chains, n-grams)
- Capture harmonic language
- Model rhythmic vocabulary
- Profile timbral characteristics

### 4. **Generative Synthesis**
- Generate new material in corpus style
- Probabilistic composition based on learned models
- Constrained generation (stay in style but meet criteria)
- Hybrid generation (combine multiple corpus styles)

### 5. **Concatenative Composition**
- Musical mosaicking (target-based synthesis)
- Find corpus segments matching target features
- Smooth transitions between segments
- Timbral/rhythmic/harmonic matching

### 6. **Style Transfer**
- Apply rhythmic style of piece A to harmony of piece B
- Transfer orchestration from reference
- Apply formal structure from template
- Timbral profiling and application

---

## Architecture

```supercollider
// ===== MAIN ENGINE =====
QCorpus {
  var <name;
  var <pieces;             // Array of QCorpusPiece
  var <database;           // QCorpusDatabase
  var <analyzer;           // QCorpusAnalyzer
  var <generator;          // QCorpusGenerator
  var <matcher;            // QCorpusMatcher

  *new { |name="MyCorpus"|
    ^super.newCopyArgs(name).init;
  }

  init {
    pieces = [];
    database = QCorpusDatabase();
    analyzer = QCorpusAnalyzer();
    generator = QCorpusGenerator(this);
    matcher = QCorpusMatcher(this);

    "QCorpus initialized: %".format(name).postln;
  }

  // Add piece to corpus
  addPiece { |path, metadata|
    var piece = QCorpusPiece.load(path, metadata);
    pieces = pieces.add(piece);

    // Analyze
    analyzer.analyze(piece);

    // Add to database
    database.add(piece);

    "Added to corpus: % (%s, % notes)".format(
      piece.name,
      piece.duration.round(0.1),
      piece.notes.size
    ).postln;

    ^piece;
  }

  // Add entire folder
  addFolder { |folderPath, recursive=true|
    var files = this.scanFolder(folderPath, recursive);

    files.do { |path|
      this.addPiece(path);
    };

    "Added % pieces from folder".format(files.size).postln;
  }

  // Analyze entire corpus
  analyzeCorpus {
    "Analyzing corpus: % pieces...".format(pieces.size).postln;

    // Individual analysis
    pieces.do { |piece|
      analyzer.analyze(piece);
    };

    // Cross-corpus analysis
    this.analyzePatterns;
    this.analyzeStyles;
    this.buildStatisticalModels;

    "Corpus analysis complete".postln;
  }

  // Find patterns across corpus
  analyzePatterns {
    var patterns = analyzer.findRepeatedPatterns(pieces);

    "Found % repeated patterns".format(patterns.size).postln;

    database.patterns = patterns;
  }

  // Learn style models
  analyzeStyles {
    // Harmonic language
    var harmonicModel = analyzer.buildHarmonicModel(pieces);

    // Rhythmic vocabulary
    var rhythmicModel = analyzer.buildRhythmicModel(pieces);

    // Melodic contours
    var melodicModel = analyzer.buildMelodicModel(pieces);

    database.styleModel = (
      harmonic: harmonicModel,
      rhythmic: rhythmicModel,
      melodic: melodicModel
    );

    "Style models built".postln;
  }

  // Build statistical models
  buildStatisticalModels {
    // Markov chains for various parameters
    database.markovChains = (
      pitchClass: this.buildMarkovChain(\pitchClass, order: 2),
      rhythm: this.buildMarkovChain(\rhythm, order: 2),
      harmony: this.buildMarkovChain(\harmony, order: 1),
      dynamics: this.buildMarkovChain(\dynamics, order: 1)
    );

    "Statistical models built".postln;
  }

  buildMarkovChain { |parameter, order=1|
    var chain = QMarkovChain(order);

    pieces.do { |piece|
      var sequence = piece.extractParameter(parameter);
      chain.train(sequence);
    };

    ^chain;
  }

  // Generate new material based on corpus
  generate { |type=\melody, constraints|
    ^generator.generate(type, constraints);
  }

  // Find similar pieces
  findSimilar { |reference, metric=\harmonic, topN=5|
    ^database.findSimilar(reference, metric, topN);
  }

  // Search for specific patterns
  search { |query|
    ^database.search(query);
  }

  // Concatenative synthesis (musical mosaicking)
  mosaic { |target|
    ^matcher.synthesize(target);
  }
}

// ===== CORPUS PIECE =====
QCorpusPiece {
  var <name, <path, <metadata;
  var <notes;              // Array of note events
  var <duration;
  var <features;           // Extracted features
  var <analysis;           // Analysis results

  *load { |path, metadata|
    ^super.new.init(path, metadata);
  }

  init { |pth, meta|
    path = pth;
    metadata = meta ?? ();
    name = PathName(path).fileNameWithoutExtension;

    // Load based on file type
    if (path.endsWith(".mid")) {
      this.loadMIDI(path);
    };
    if (path.endsWith(".musicxml")) {
      this.loadMusicXML(path);
    };
    if (path.endsWith(".wav")) {
      this.loadAudio(path);
    };
  }

  loadMIDI { |path|
    // Load MIDI file
    var midiFile = SimpleMIDIFile.read(path);

    notes = midiFile.noteEvents;
    duration = midiFile.duration;

    "Loaded MIDI: % (% notes)".format(name, notes.size).postln;
  }

  loadMusicXML { |path|
    // Load MusicXML
    // TODO: Implement MusicXML parser
    "MusicXML loading not yet implemented".warn;
  }

  loadAudio { |path|
    // Load audio and analyze
    var buffer = Buffer.read(Server.default, path);

    // Use QAnalyze to extract MIDI from audio
    var analyzed = QAnalyze.fromAudio(buffer);
    notes = analyzed.notes;
    duration = buffer.duration;

    "Loaded audio: % (% seconds)".format(name, duration.round(0.1)).postln;
  }

  extractParameter { |param|
    ^switch(param,
      \pitchClass, { notes.collect { |n| n.midinote % 12 } },
      \rhythm, { notes.collect { |n| n.dur } },
      \dynamics, { notes.collect { |n| n.velocity } },
      \harmony, { this.extractChordSequence }
    );
  }

  extractChordSequence {
    // Chunk into bars, extract chords
    var chords = [];
    var barSize = 4.0; // Assume 4/4

    (duration / barSize).ceil.do { |i|
      var barNotes = notes.select { |n|
        (n.onset >= (i * barSize)) and: { n.onset < ((i+1) * barSize) }
      };

      var chord = this.identifyChord(barNotes);
      chords = chords.add(chord);
    };

    ^chords;
  }

  identifyChord { |barNotes|
    var pitchClasses = barNotes.collect { |n| n.midinote % 12 }.as(Set);

    // Simple chord identification
    // TODO: Use QAnalyze.identifyChord
    ^pitchClasses;
  }
}

// ===== CORPUS DATABASE =====
QCorpusDatabase {
  var <pieces;
  var <patterns;           // Repeated patterns found
  var <styleModel;         // Learned style characteristics
  var <markovChains;       // Statistical models
  var <featureIndex;       // KD-tree or similar for fast search

  *new {
    ^super.new.init;
  }

  init {
    pieces = [];
    patterns = [];
    styleModel = ();
    markovChains = ();
    featureIndex = QFeatureIndex();
  }

  add { |piece|
    pieces = pieces.add(piece);
    featureIndex.add(piece);
  }

  // Find similar pieces based on features
  findSimilar { |reference, metric=\harmonic, topN=5|
    var refFeatures = reference.features[metric];
    var similarities = [];

    pieces.do { |piece|
      if (piece != reference) {
        var pieceFeatures = piece.features[metric];
        var similarity = this.calculateSimilarity(refFeatures, pieceFeatures);

        similarities = similarities.add((
          piece: piece,
          similarity: similarity
        ));
      };
    };

    ^similarities.sort { |a, b| a.similarity > b.similarity }.keep(topN);
  }

  calculateSimilarity { |featuresA, featuresB|
    // Cosine similarity or Euclidean distance
    // Simplified placeholder
    ^rrand(0.0, 1.0);
  }

  // Search database for patterns
  search { |query|
    var results = [];

    // Search by various criteria
    if (query[\rhythmicPattern].notNil) {
      results = results ++ this.searchRhythm(query[\rhythmicPattern]);
    };

    if (query[\melodicContour].notNil) {
      results = results ++ this.searchMelody(query[\melodicContour]);
    };

    if (query[\harmonicProgression].notNil) {
      results = results ++ this.searchHarmony(query[\harmonicProgression]);
    };

    ^results;
  }

  searchRhythm { |pattern|
    // Find pieces with similar rhythmic patterns
    ^pieces.select { |piece|
      this.containsRhythm(piece, pattern);
    };
  }

  searchMelody { |contour|
    ^pieces.select { |piece|
      this.containsMelody(piece, contour);
    };
  }

  searchHarmony { |progression|
    ^pieces.select { |piece|
      this.containsHarmony(piece, progression);
    };
  }
}

// ===== CORPUS ANALYZER =====
QCorpusAnalyzer {
  analyze { |piece|
    piece.features = ();
    piece.analysis = ();

    // Extract features
    this.extractRhythmicFeatures(piece);
    this.extractMelodicFeatures(piece);
    this.extractHarmonicFeatures(piece);
    this.extractTimbralFeatures(piece);
    this.extractStructuralFeatures(piece);

    "Analyzed: %".format(piece.name).postln;
  }

  extractRhythmicFeatures { |piece|
    piece.features[\rhythmic] = (
      avgNoteDuration: piece.notes.collect(_.dur).mean,
      noteDensity: piece.notes.size / piece.duration,
      rhythmicComplexity: this.calculateRhythmicComplexity(piece),
      syncopationLevel: this.calculateSyncopation(piece),
      dominantDurations: this.findDominantDurations(piece)
    );
  }

  extractMelodicFeatures { |piece|
    var intervals = piece.notes.doAdjacentPairs { |a, b|
      b.midinote - a.midinote
    };

    piece.features[\melodic] = (
      avgInterval: intervals.mean,
      maxInterval: intervals.maxItem,
      melodicRange: piece.notes.collect(_.midinote).maxItem -
                    piece.notes.collect(_.midinote).minItem,
      contourType: this.identifyContour(piece),
      stepwiseMotion: intervals.count { |i| i.abs <= 2 } / intervals.size
    );
  }

  extractHarmonicFeatures { |piece|
    var chords = piece.extractChordSequence;

    piece.features[\harmonic] = (
      avgChordComplexity: this.calculateChordComplexity(chords),
      chromaticDensity: this.calculateChromaticism(piece),
      harmonicRhythm: chords.size / piece.duration,
      dominantChords: this.findDominantChords(chords),
      tonality: this.detectTonality(piece)
    );
  }

  extractTimbralFeatures { |piece|
    // If audio, extract spectral features
    piece.features[\timbral] = (
      spectralCentroid: nil, // Would come from audio analysis
      spectralFlux: nil,
      harmonicity: nil
    );
  }

  extractStructuralFeatures { |piece|
    piece.features[\structural] = (
      formType: this.detectForm(piece),
      sectionCount: this.countSections(piece),
      repetitionRate: this.calculateRepetition(piece)
    );
  }

  // Find patterns repeated across multiple pieces
  findRepeatedPatterns { |pieces|
    var patterns = [];
    var windowSize = 4; // 4-note patterns

    // Extract all patterns
    var allPatterns = [];

    pieces.do { |piece|
      piece.notes.slide(windowSize).do { |window|
        var pattern = this.normalizePattern(window);
        allPatterns = allPatterns.add((
          pattern: pattern,
          source: piece
        ));
      };
    };

    // Find repeated ones
    var patternCounts = IdentityDictionary();

    allPatterns.do { |entry|
      var key = entry.pattern.asString;
      patternCounts[key] = (patternCounts[key] ? 0) + 1;
    };

    // Filter to repeated patterns
    patternCounts.keysValuesDo { |key, count|
      if (count > 2) { // Appears at least 3 times
        patterns = patterns.add((
          pattern: key,
          occurrences: count
        ));
      };
    };

    ^patterns.sort { |a, b| a.occurrences > b.occurrences };
  }

  // Build style models
  buildHarmonicModel { |pieces|
    var allChords = [];

    pieces.do { |piece|
      allChords = allChords ++ piece.extractChordSequence;
    };

    // Calculate chord frequency
    var chordCounts = IdentityDictionary();

    allChords.do { |chord|
      var key = chord.asString;
      chordCounts[key] = (chordCounts[key] ? 0) + 1;
    };

    // Normalize to probabilities
    var total = chordCounts.values.sum;
    var chordProbs = IdentityDictionary();

    chordCounts.keysValuesDo { |key, count|
      chordProbs[key] = count / total;
    };

    ^chordProbs;
  }

  buildRhythmicModel { |pieces|
    var allRhythms = [];

    pieces.do { |piece|
      allRhythms = allRhythms ++ piece.extractParameter(\rhythm);
    };

    // Calculate rhythm frequency
    var rhythmCounts = IdentityDictionary();

    allRhythms.do { |dur|
      var quantized = dur.round(0.125); // Quantize to 32nd notes
      rhythmCounts[quantized] = (rhythmCounts[quantized] ? 0) + 1;
    };

    ^rhythmCounts;
  }

  buildMelodicModel { |pieces|
    var allIntervals = [];

    pieces.do { |piece|
      piece.notes.doAdjacentPairs { |a, b|
        var interval = b.midinote - a.midinote;
        allIntervals = allIntervals.add(interval);
      };
    };

    // Calculate interval frequency
    var intervalCounts = IdentityDictionary();

    allIntervals.do { |interval|
      intervalCounts[interval] = (intervalCounts[interval] ? 0) + 1;
    };

    ^intervalCounts;
  }
}

// ===== CORPUS GENERATOR =====
QCorpusGenerator {
  var <corpus;

  *new { |corpus| ^super.newCopyArgs(corpus) }

  // Generate new material based on corpus
  generate { |type=\melody, constraints|
    ^switch(type,
      \melody, { this.generateMelody(constraints) },
      \harmony, { this.generateHarmony(constraints) },
      \rhythm, { this.generateRhythm(constraints) },
      \piece, { this.generatePiece(constraints) }
    );
  }

  generateMelody { |constraints|
    var model = corpus.database.styleModel[\melodic];
    var markov = corpus.database.markovChains[\pitchClass];

    constraints = constraints ?? ();
    var length = constraints[\length] ? 16;
    var startPitch = constraints[\startPitch] ? 60;

    var melody = [];
    var currentPitch = startPitch;

    length.do {
      // Generate next pitch using Markov chain
      var interval = markov.generate;
      currentPitch = currentPitch + interval;

      // Keep in reasonable range
      currentPitch = currentPitch.clip(48, 84);

      melody = melody.add((
        midinote: currentPitch,
        dur: this.generateRhythmicValue
      ));
    };

    "Generated melody: % notes".format(length).postln;
    ^melody;
  }

  generateHarmony { |constraints|
    var model = corpus.database.styleModel[\harmonic];
    var markov = corpus.database.markovChains[\harmony];

    constraints = constraints ?? ();
    var length = constraints[\length] ? 8;

    var progression = [];

    length.do {
      var chord = markov.generate;
      progression = progression.add(chord);
    };

    "Generated harmony: % chords".format(length).postln;
    ^progression;
  }

  generateRhythm { |constraints|
    var model = corpus.database.styleModel[\rhythmic];
    var markov = corpus.database.markovChains[\rhythm];

    constraints = constraints ?? ();
    var length = constraints[\length] ? 16;

    var rhythm = Array.fill(length, { markov.generate });

    "Generated rhythm: % values".format(length).postln;
    ^rhythm;
  }

  generatePiece { |constraints|
    // Generate complete piece
    var melody = this.generateMelody(constraints);
    var harmony = this.generateHarmony(constraints);
    var rhythm = this.generateRhythm(constraints);

    var piece = QCorpusPiece.new;
    piece.notes = melody;
    piece.harmony = harmony;
    piece.rhythm = rhythm;

    "Generated complete piece".postln;
    ^piece;
  }

  generateRhythmicValue {
    var markov = corpus.database.markovChains[\rhythm];
    ^markov.generate ? 0.5;
  }
}

// ===== CORPUS MATCHER (for concatenative synthesis) =====
QCorpusMatcher {
  var <corpus;

  *new { |corpus| ^super.newCopyArgs(corpus) }

  // Concatenative synthesis - create target from corpus segments
  synthesize { |target|
    "Synthesizing target using corpus...".postln;

    var segments = this.findMatchingSegments(target);
    var result = this.assembleSegments(segments);

    ^result;
  }

  findMatchingSegments { |target|
    var segments = [];
    var windowSize = 0.5; // 0.5 second segments

    // For each segment of target, find best match in corpus
    (target.duration / windowSize).ceil.do { |i|
      var targetSegment = target.getSegment(i * windowSize, windowSize);
      var bestMatch = this.findBestMatch(targetSegment);

      segments = segments.add(bestMatch);
    };

    ^segments;
  }

  findBestMatch { |targetSegment|
    var bestMatch = nil;
    var bestScore = inf;

    corpus.pieces.do { |piece|
      piece.segments.do { |segment|
        var score = this.matchScore(targetSegment, segment);

        if (score < bestScore) {
          bestScore = score;
          bestMatch = segment;
        };
      };
    };

    ^bestMatch;
  }

  matchScore { |segmentA, segmentB|
    // Calculate distance between segments
    // Based on spectral, rhythmic, harmonic features

    var spectralDist = this.spectralDistance(segmentA, segmentB);
    var rhythmicDist = this.rhythmicDistance(segmentA, segmentB);
    var harmonicDist = this.harmonicDistance(segmentA, segmentB);

    ^(spectralDist * 0.4) + (rhythmicDist * 0.3) + (harmonicDist * 0.3);
  }

  assembleSegments { |segments|
    // Assemble segments with smooth transitions
    var result = QComposition();

    segments.do { |segment, i|
      // Add crossfade between segments
      if (i > 0) {
        result.addCrossfade(0.1);
      };

      result.addSegment(segment);
    };

    ^result;
  }
}

// ===== MARKOV CHAIN =====
QMarkovChain {
  var <order;
  var <chain;              // Transition probabilities

  *new { |order=1|
    ^super.newCopyArgs(order).init;
  }

  init {
    chain = IdentityDictionary();
  }

  // Train on sequence
  train { |sequence|
    sequence.slide(order + 1).do { |window|
      var state = window.keep(order);
      var next = window.last;

      var stateKey = state.asString;

      if (chain[stateKey].isNil) {
        chain[stateKey] = [];
      };

      chain[stateKey] = chain[stateKey].add(next);
    };

    "Trained Markov chain: % states".format(chain.size).postln;
  }

  // Generate next value given current state
  generate { |currentState|
    if (currentState.isNil) {
      // Random starting state
      currentState = chain.keys.choose;
    };

    var stateKey = currentState.asString;
    var possibleNext = chain[stateKey];

    if (possibleNext.isNil or: { possibleNext.isEmpty }) {
      ^nil;
    };

    ^possibleNext.choose;
  }
}
```

---

## Integration Example

```supercollider
(
// ===== CREATE CORPUS =====
var corpus = QCorpus("Bach Chorales");

// Add pieces from folder
corpus.addFolder("~/Music/BachChorales/");

// Analyze corpus
corpus.analyzeCorpus;

// ===== EXPLORE CORPUS =====
// Find similar pieces
var reference = corpus.pieces[0];
var similar = corpus.findSimilar(reference, metric: \harmonic, topN: 3);

similar.do { |result|
  "Similar (similarity=%): %".format(
    result.similarity.round(0.01),
    result.piece.name
  ).postln;
};

// Search for specific patterns
var results = corpus.search((
  harmonicProgression: [\I, \IV, \V, \I]
));

"Found % pieces with I-IV-V-I".format(results.size).postln;

// ===== GENERATE NEW MATERIAL =====
// Generate Bach-style melody
var newMelody = corpus.generate(\melody, (
  length: 16,
  startPitch: 60
));

// Generate Bach-style harmony
var newHarmony = corpus.generate(\harmony, (
  length: 8
));

// Generate complete Bach-style piece
var newPiece = corpus.generate(\piece, (
  length: 32,
  key: \Dminor
));

// ===== CONCATENATIVE SYNTHESIS =====
// Create target
var target = QMelody([60, 64, 67, 72]);

// Synthesize using corpus segments
var mosaic = corpus.mosaic(target);

mosaic.play;

// ===== STYLE TRANSFER =====
// Load reference for style
var popSong = QCorpusPiece.load("~/Music/pop_reference.mid");
corpus.addPiece(popSong);

// Transfer pop rhythm to Bach harmony
var hybrid = QProject();
hybrid.theory.harmony.progression = newHarmony;
hybrid.theory.rhythm.pattern = popSong.extractParameter(\rhythm);

hybrid.play;
)
```

---

## Use Cases

### Classical Composition Study
- Analyze Bach chorales to learn voice leading
- Extract counterpoint patterns
- Generate new chorales in Bach's style

### Film Scoring
- Build corpus of temp track
- Extract emotional/structural templates
- Generate variations matching temp track style

### Electronic Music Production
- Analyze favorite tracks
- Extract drum patterns, bass lines, synth progressions
- Generate new tracks in similar style

### Music Research
- Comparative analysis across composers/eras
- Pattern mining across large corpora
- Style evolution studies

### Live Performance
- Real-time concatenative synthesis
- Match incoming audio to corpus segments
- Generate accompaniment in learned style

---

## Summary

| Feature | Description | Use Case |
|---------|-------------|----------|
| **Corpus Import** | MIDI, audio, MusicXML | Build databases |
| **Pattern Mining** | Find repeated motifs | Learn vocabulary |
| **Style Learning** | Statistical models | Generate in style |
| **Markov Chains** | N-gram models | Probabilistic generation |
| **Concatenative Synthesis** | Musical mosaicking | Target-based composition |
| **Style Transfer** | Apply style of piece A to piece B | Hybrid creation |
| **Similarity Search** | Find similar pieces | Discover relationships |
| **Feature Extraction** | Rhythmic, melodic, harmonic, timbral | Analysis |

**LOC**: ~1,800 lines
**Classes**: 9 (QCorpus, QCorpusPiece, QCorpusDatabase, QCorpusAnalyzer, QCorpusGenerator, QCorpusMatcher, QMarkovChain, QFeatureIndex, QComposition)
**Implementation**: 3 weeks (Weeks 64-66)

---

**QCorpus: Learn from existing music, generate new material at AI speed with human control**
