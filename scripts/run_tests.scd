// Run all Quasar tests
// Usage: sclang scripts/run_tests.scd

(
// Boot server if not already running
if(Server.default.serverRunning.not, {
    "Booting server...".postln;
    Server.default.waitForBoot({
        ~runTests.();
    });
}, {
    ~runTests.();
});

~runTests = {
    var testClasses, results;

    "".postln;
    "===========================================".postln;
    "Running Quasar Test Suite".postln;
    "===========================================".postln;
    "".postln;

    // Find all test classes (classes starting with TestQ)
    testClasses = Class.allClasses.select({ |class|
        class.name.asString.beginsWith("TestQ")
    });

    if(testClasses.size == 0, {
        "WARNING: No test classes found!".postln;
        "".postln;
        "Test classes should be named TestQClassName".postln;
        "and placed in tests/Unit/ or tests/Integration/".postln;
        "".postln;
        0.exit;
    });

    "Found % test classes".format(testClasses.size).postln;
    "".postln;

    // Run all tests
    UnitTest.reset;
    testClasses.do({ |class|
        ("Running: " ++ class.name).postln;
        class.run;
    });

    "".postln;
    "===========================================".postln;
    "Test Results".postln;
    "===========================================".postln;
    UnitTest.report;
    "".postln;

    // Exit with appropriate code
    if(UnitTest.failures > 0 or: { UnitTest.errors > 0 }, {
        1.exit;
    }, {
        0.exit;
    });
};
)
