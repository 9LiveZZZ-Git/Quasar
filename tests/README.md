# Quasar Test Suite

This directory contains unit and integration tests for Quasar.

## Test Organization

```
tests/
├── Unit/           # Unit tests for individual classes
│   ├── TestQProject.sc
│   ├── TestQTheory.sc
│   ├── TestQTimeline.sc
│   └── ...
├── Integration/    # Integration tests for complete workflows
│   └── ...
└── Fixtures/       # Test data and fixtures
    └── ...
```

## Running Tests

### Run All Tests

```bash
make test
```

Or directly with SuperCollider:

```supercollider
// In SuperCollider
UnitTest.runAll;
```

### Run Specific Test Class

```supercollider
TestQProject.run;
```

### Run Specific Test Method

```supercollider
TestQProject.new.test_new_project_creation;
```

## Writing Tests

### Test File Structure

All test classes should:
1. Inherit from `UnitTest`
2. Be named with `TestQ` prefix (e.g., `TestQHarmony`)
3. Have test methods named with `test_` prefix

### Example Test

```supercollider
TestQMyClass : UnitTest {

    test_basic_functionality {
        var obj;

        obj = QMyClass.new;

        this.assertNotNil(obj,
            "Object should not be nil");

        this.assertEquals(obj.someValue, 42,
            "Value should be 42");
    }

    test_error_handling {
        var obj;

        obj = QMyClass.new;

        this.assertException({
            obj.invalidMethod;
        }, Error, "Should throw error for invalid method");
    }
}
```

## Available Assertions

- `assertNotNil(value, message)`
- `assertEquals(actual, expected, message)`
- `assert(condition, message)`
- `assertFloatEquals(actual, expected, message, precision)`
- `assertException(function, errorClass, message)`
- `assertNoException(function, message)`
- `assertArrayFloatEquals(actual, expected, message, precision)`

See SuperCollider's UnitTest documentation for complete list.

## Test Coverage Goals

- **Unit Tests**: All public methods should have tests
- **Coverage Target**: > 75%
- **Edge Cases**: Test boundary conditions and error cases
- **Reproducibility**: Tests should pass consistently with same seed

## Current Test Status

### Phase Zero (Skeleton)
- ✅ Basic project creation tests
- ✅ Theory subsystem initialization tests
- ✅ Timeline creation tests

### Coming in Phase 0-7
- Core engine functionality
- Music theory generation
- Unit selection
- Gesture behaviors
- Form generation

### Coming in Phase 8+
- Production frameworks (QMix, QPose, QMess)
- Klotho integration
- Spatial audio
- Adaptive music
- Live performance

## Test Data

Test fixtures are stored in `tests/Fixtures/`:
- Audio samples
- MIDI files
- Chord progressions
- Test scores

## Continuous Integration

Tests should be run:
1. Before committing changes
2. In pull request CI
3. Before releases

## Debugging Failed Tests

If tests fail:

1. **Check the error message**: Read the assertion failure message
2. **Run in isolation**: Run just the failing test
3. **Add debug output**: Use `.postln` to inspect values
4. **Check dependencies**: Ensure server is booted if needed

Example:

```supercollider
// Add debug output
test_my_feature {
    var result;

    result = myObject.calculate;
    result.postln; // Debug: see what we got

    this.assertEquals(result, expected);
}
```

## Contributing Tests

When contributing code:
1. Add tests for new functionality
2. Update existing tests if behavior changes
3. Ensure all tests pass before submitting PR
4. Document any special test requirements

---

**Current Status**: Phase Zero - Basic skeleton tests
**Goal**: > 75% coverage by Phase 7
