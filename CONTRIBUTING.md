# Contributing to Quasar

Thank you for your interest in contributing to Quasar! This document provides guidelines and information for contributors.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Community Guidelines](#community-guidelines)

---

## Getting Started

### Areas Where Help is Needed

- **Core Development**: Implementing the 19 frameworks
- **Music Theory Algorithms**: Harmony, melody, counterpoint, form generation
- **SynthDef Library**: Creating high-quality SynthDefs for various instruments
- **Documentation**: Tutorials, examples, help files
- **Testing**: Unit tests, integration tests, real-world compositions
- **Example Compositions**: Demonstrating framework capabilities
- **Bug Reports**: Finding and reporting issues
- **Feature Requests**: Suggesting improvements

### Before You Start

1. Read the [README.md](README.md) to understand the project goals
2. Review the [ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md) to understand the design
3. Check the [IMPLEMENTATION_TRACKER_UPDATED.md](docs/architecture/IMPLEMENTATION_TRACKER_UPDATED.md) to see what's being worked on
4. Look for issues tagged `good first issue` or `help wanted`

---

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/your-username/quasar.git
cd quasar
```

### 2. Install Dependencies

```bash
# SuperCollider 3.13.0+
# For Klotho integration:
pip install -r Klotho/Klotho/requirements.txt
```

### 3. Set Up Development Environment

```bash
# Symlink to SuperCollider Extensions for testing
ln -s $(pwd) ~/Library/Application\ Support/SuperCollider/Extensions/Quasar-dev
```

### 4. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

---

## Project Structure

```
Quasar/
├── src/                    # Source code
│   ├── Core/              # Core 10 pillars
│   ├── Frameworks/        # 19 frameworks
│   ├── Utils/             # Utility classes
│   └── Extensions/        # SC extensions
├── tests/                 # Test suite
│   ├── Unit/             # Unit tests
│   └── Integration/      # Integration tests
├── docs/                  # Documentation
│   ├── architecture/     # Design docs
│   ├── tutorials/        # Tutorials
│   ├── api/             # API reference
│   └── guides/          # How-to guides
├── examples/             # Example compositions
├── resources/            # SynthDefs, samples, presets
└── scripts/              # Build and utility scripts
```

---

## Coding Standards

### SuperCollider Code Style

#### Naming Conventions

```supercollider
// Classes: PascalCase with Q prefix
QProject
QHarmony
QMixEngine

// Methods: camelCase
myMethod
generateProgression
autoMix

// Instance variables: camelCase with < accessor
var <tempo, <seed;

// Private methods: underscore prefix
prGenerateVoicing

// Constants: UPPER_CASE
const <DEFAULT_TEMPO = 120;
```

#### Code Organization

```supercollider
ClassName : SuperClass {
    // Class variables
    classvar <>globalSettings;

    // Instance variables (public)
    var <publicVar;

    // Instance variables (private)
    var privateVar;

    // Constructor
    *new { |args|
        ^super.new.init(args);
    }

    // Initialization
    init { |args|
        // Initialize here
    }

    // Public methods
    publicMethod {
        // Implementation
    }

    // Private methods
    prPrivateMethod {
        // Implementation
    }
}
```

#### Documentation Comments

Every class and public method should have documentation:

```supercollider
/*
QHarmony - Harmonic System

Manages scales, chords, progressions, and voice leading.

ARGUMENTS:
    key - The key signature (e.g., \cMajor, \dMinor)
    style - The style template (e.g., \baroque, \jazz)

EXAMPLES:
    h = QHarmony(\dMajor, \baroque);
    prog = h.progression(\authentic);
*/
QHarmony : Object {
    // ...
}
```

### General Guidelines

- Keep methods short and focused (< 50 lines)
- Use meaningful variable names
- Comment complex algorithms
- Avoid global variables
- Use seeded randomness for reproducibility
- Handle edge cases and errors gracefully

---

## Testing

### Writing Tests

Tests use SuperCollider's UnitTest framework:

```supercollider
TestQHarmony : UnitTest {

    test_progression_generation {
        var harmony, progression;

        harmony = QHarmony(\cMajor, \baroque);
        progression = harmony.progression(\authentic);

        // Test that progression is not nil
        this.assertNotNil(progression, "Progression should not be nil");

        // Test that progression ends on tonic
        this.assertEquals(progression.last.root, 0,
            "Authentic progression should end on tonic");
    }

    test_voice_leading {
        var harmony, voicing;

        harmony = QHarmony(\cMajor);
        voicing = harmony.voiceLead([0, 7, 0]); // I-V-I

        // Test smooth voice leading
        this.assert(voicing.isSmooth,
            "Voice leading should be smooth");
    }
}
```

### Running Tests

```supercollider
// Run all tests
UnitTest.runAll;

// Run specific test class
TestQHarmony.run;

// Run specific test method
TestQHarmony.new.test_progression_generation;
```

### Test Coverage Goals

- All public methods should have tests
- Test edge cases and error conditions
- Aim for > 75% code coverage

---

## Documentation

### Help Files

Every class needs a help file in HelpSource/:

```
HelpSource/Classes/QHarmony.schelp
```

Help file structure:

```
TITLE:: QHarmony
summary:: Harmonic system for Quasar
categories:: Quasar, Music Theory
related:: Classes/QMelody, Classes/QRhythm

DESCRIPTION::
QHarmony manages scales, chords, progressions, and voice leading.

CLASSMETHODS::

METHOD:: new
Create a new harmonic system.

ARGUMENT:: key
The key signature (e.g., \cMajor, \dMinor).

ARGUMENT:: style
The style template (e.g., \baroque, \jazz).

RETURNS::
A new QHarmony instance.

INSTANCEMETHODS::

METHOD:: progression
Generate a chord progression.

ARGUMENT:: type
The progression type (e.g., \authentic, \plagal).

RETURNS::
An array of chord objects.

EXAMPLES::

code::
// Create baroque harmony in D major
h = QHarmony(\dMajor, \baroque);

// Generate authentic cadence
prog = h.progression(\authentic);
prog.do(_.postln);
::
```

### Code Comments

- Use `//` for single-line comments
- Use `/* */` for multi-line comments
- Document complex algorithms with detailed comments
- Explain "why" not "what" when the code is clear

---

## Submitting Changes

### Commit Messages

Use clear, descriptive commit messages:

```
Format: <type>(<scope>): <subject>

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation only
- style: Code style (formatting, no logic change)
- refactor: Code refactoring
- test: Adding tests
- chore: Maintenance tasks

Examples:
feat(QHarmony): Add modal interchange support
fix(QRhythm): Fix syncopation algorithm edge case
docs(QMix): Update API documentation
test(QTheory): Add unit tests for voice leading
```

### Pull Request Process

1. **Update your branch**:
   ```bash
   git fetch upstream
   git rebase upstream/develop
   ```

2. **Run tests**:
   ```supercollider
   UnitTest.runAll;
   ```

3. **Create pull request**:
   - Write a clear title and description
   - Reference related issues
   - Include examples if applicable
   - Update documentation if needed

4. **Code review**:
   - Address reviewer feedback
   - Make requested changes
   - Keep discussion respectful and constructive

5. **Merge**:
   - Maintainer will merge after approval
   - Delete your branch after merge

---

## Community Guidelines

### Code of Conduct

We follow the SuperCollider Code of Conduct. Be respectful, inclusive, and constructive.

### Communication

- **GitHub Issues**: Bug reports, feature requests
- **GitHub Discussions**: General questions, ideas
- **Forum**: [scsynth.org](https://scsynth.org/)
- **Discord**: Real-time chat (link TBD)

### Getting Help

If you're stuck:
1. Check existing documentation
2. Search closed issues
3. Ask on GitHub Discussions
4. Join the forum or Discord

---

## Development Roadmap

See [IMPLEMENTATION_TRACKER_UPDATED.md](docs/architecture/IMPLEMENTATION_TRACKER_UPDATED.md) for:
- Current phase status
- Upcoming features
- Long-term goals

---

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Credited in release notes
- Acknowledged in documentation

---

## License

By contributing, you agree that your contributions will be licensed under the GPL-3.0 License.

---

## Questions?

Open an issue with the `question` label or ask on GitHub Discussions.

---

**Thank you for contributing to Quasar!**
