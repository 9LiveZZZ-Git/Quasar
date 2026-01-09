/*
QCounterpoint - Contrapuntal system for Quasar

Manages species counterpoint, imitation, canon, and fugue generation.

EXAMPLES::
cp = QCounterpoint(\firstSpecies);
counter = cp.generate(cantusFirmus, voice: \above);
::

Version: 0.0.1 (Phase Zero - Skeleton)
*/

QCounterpoint {
    var <theory;
    var <species;

    *new { |theory, species|
        ^super.new.init(theory, species);
    }

    init { |argTheory, argSpecies|
        theory = argTheory;
        species = argSpecies;
    }

    generate { |cantusFirmus, voice = \above|
        // Generate counterpoint
        // Implementation: Phase 2
        "QCounterpoint.generate() - not yet implemented".postln;
        ^[];
    }

    answer { |subject, type = \tonal|
        // Generate fugue answer
        // Implementation: Phase 2
        "QCounterpoint.answer() - not yet implemented".postln;
        ^[];
    }
}
