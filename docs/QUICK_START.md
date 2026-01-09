# Quasar Quick Start Guide

**Phase**: Zero (Skeleton)
**Status**: Foundation ready, awaiting implementation

---

## Installation

### 1. Clone Repository

```bash
cd ~/path/to/your/projects
git clone https://github.com/yourusername/quasar.git
cd quasar
```

### 2. Install to SuperCollider

```bash
make install
```

Or manually:

```bash
ln -s $(pwd) ~/Library/Application\ Support/SuperCollider/Extensions/Quasar
```

### 3. Recompile SuperCollider

In SuperCollider:
- Press `Cmd+Shift+L` (macOS) or `Ctrl+Shift+L` (Linux/Windows)
- Or menu: `Language > Recompile Class Library`

### 4. Verify Installation

```supercollider
// Boot server
s.boot;

// Create a project
q = QProject.new;

// Display info
q.postInfo;
Quasar.postInfo;
```

You should see Quasar version info and project details!

---

## Your First Project

### Hello Quasar

```supercollider
(
s.waitForBoot({
    // Create project
    q = QProject.new(tempo: 120, seed: 42);
    q.title = "My First Composition";
    q.author = "Your Name";

    // Set musical parameters
    q.keySignature = \dMinor;
    q.timeSignature = [4, 4];

    // Display info
    q.postInfo;
});
)
```

### Explore Theory Subsystems

```supercollider
(
// Access theory modules
q = QProject.new;

// These will be functional after Phase 2
q.theory.harmony;
q.theory.melody;
q.theory.rhythm;
q.theory.counterpoint;
q.theory.form;

// Display theory info
q.theory.postInfo;
)
```

---

## Next Steps

### Current Phase: Zero (Skeleton Only)

Right now, Quasar has the **structure** but not yet the **functionality**. You can:

1. ✅ Create projects
2. ✅ Set metadata (tempo, key, title, etc.)
3. ✅ Access theory subsystems
4. ❌ Generate music (coming in Phase 0-7)
5. ❌ Render audio (coming in Phase 8)

### Coming in Phase 0 (Weeks 1-2)

- Playback engine
- Audio scene system
- Timeline sequencing
- Basic routing

### Coming in Phase 2 (Weeks 6-8)

- Harmony generation
- Melody generation
- Rhythm patterns
- Counterpoint

### Coming in Phase 5 (Weeks 15-17)

- Form archetypes
- Complete compositions

---

## Example Workflow (Future)

Once Phase 0-7 is complete, you'll be able to:

```supercollider
(
// Create from template
q = QProject.fromTemplate(\baroque);
q.keySignature = \dMinor;

// Define fugue subject
q.theory.form.exposition.subject = [0, 2, 4, 5];

// Generate structure
q.theory.form.generate;

// Play!
q.play;

// Or render offline
q.render("~/my_fugue.wav");
)
```

---

## Documentation

### Essential Reading

1. **README.md** - Project overview
2. **INSTALL.md** - Detailed installation
3. **PHASE_ZERO_COMPLETE.md** - Current status
4. **docs/architecture/ARCHITECTURE.md** - Design philosophy

### Architecture Docs

See `docs/architecture/` for complete design specs:

- ARCHITECTURE.md - Genre-agnostic design
- OBJECT_MODEL.md - Class hierarchy
- IMPLEMENTATION_TRACKER_UPDATED.md - Roadmap
- COMPLETE_FRAMEWORK_SUMMARY.md - All 19 frameworks
- [16 framework-specific documents]

### Examples

See `examples/`:

- 00_hello_quasar.scd - Getting started
- 01_project_creation.scd - Project API
- 02_theory_exploration.scd - Theory subsystems

---

## Getting Help

### Resources

- **Documentation**: `docs/`
- **Examples**: `examples/`
- **Tests**: `tests/` (see how things work)
- **Source**: `src/` (skeleton classes)

### Community

- **Forum**: [scsynth.org](https://scsynth.org/)
- **Issues**: GitHub Issues
- **Discord**: TBD

### Common Issues

**Q: Classes not found after installation?**
A: Make sure you recompiled the class library (`Cmd+Shift+L`)

**Q: When will music generation work?**
A: Phase 2 (Weeks 6-8) will add harmony, melody, rhythm generation

**Q: Can I use Quasar now?**
A: Phase Zero provides the skeleton structure. Actual composition features coming in Phase 0-7.

---

## Development

### Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md)

### Running Tests

```bash
make test
```

Or in SuperCollider:

```supercollider
UnitTest.runAll;
```

### Project Status

```bash
make status
```

Shows:
- Current version
- Number of classes
- Number of tests
- Number of examples

---

## Roadmap

| Phase | Timeline | Features |
|-------|----------|----------|
| **Zero** | **Complete** | **Project foundation** |
| 0 | Weeks 1-2 | Core engine |
| 1-2 | Weeks 3-8 | Unit database, theory foundation |
| 3-7 | Weeks 9-22 | Gestures, texture, form, selection |
| 8 | Weeks 23-34 | Production tools (QMix, QPose, QMess) |
| 9 | Weeks 35-37 | Klotho integration |
| 10-18 | Weeks 38-66 | All 19 frameworks |
| 20 | Weeks 69-78 | Complete UX/UI |
| 23 | Weeks 85-88 | Release v2.0 |

**Total**: 88 weeks (22 months) to complete ecosystem

---

## What's Next?

### For Developers

Start implementing Phase 0:
1. Core playback engine
2. Scene system
3. Timeline sequencer

See `docs/architecture/IMPLEMENTATION_TRACKER_UPDATED.md`

### For Users

- Explore the skeleton structure
- Try example files
- Read documentation
- Join the community
- Follow development progress

---

**Welcome to Quasar!**

*From macro-composition to Dolby Atmos masters, with AI assistance and live performance.*

**Current Status**: Phase Zero Complete ✅
**Next Milestone**: Phase 0 (Core Engine)
**Full Release**: 88 weeks

---

Questions? See [CONTRIBUTING.md](../CONTRIBUTING.md) or open an issue!
