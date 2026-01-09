/*
DnB SynthDefs for Quasar Phase 0 Demo

Modern Drum and Bass synthesis suite:
- Kick, Snare, Hats
- Reese Bass
- Sub Bass
- Pads and atmospheres

Load with: load("resources/SynthDefs/dnb_synthdefs.scd");
*/

(
// ====================================
// DRUMS
// ====================================

// Kick - Deep, punchy DnB kick
SynthDef(\dnbKick, {
    |out=0, amp=0.6, pan=0, freq=50, decay=0.4, click=0.02|
    var sig, env, clickEnv;

    // Main body
    env = EnvGen.kr(Env.perc(0.001, decay, curve: -4), doneAction: 2);
    sig = SinOsc.ar(
        XLine.kr(freq * 2, freq, 0.05)
    ) * env;

    // Click layer
    clickEnv = EnvGen.kr(Env.perc(0.001, click));
    sig = sig + (WhiteNoise.ar * clickEnv * 0.1);

    // Saturation
    sig = (sig * 2).tanh;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// Snare - Crisp DnB snare
SynthDef(\dnbSnare, {
    |out=0, amp=0.3, pan=0, tune=0, decay=0.15|
    var sig, env, noise, tone;

    env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);

    // Noise component
    noise = WhiteNoise.ar * env;
    noise = BPF.ar(noise, 2000 + tune, 0.5) * 2;

    // Tonal component
    tone = SinOsc.ar([180, 280] + tune) * env * 0.3;

    sig = (noise + tone.sum) * 0.5;
    sig = (sig * 1.5).tanh;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// Hi-Hat Closed
SynthDef(\dnbHatClosed, {
    |out=0, amp=0.15, pan=0, decay=0.05, freq=8000|
    var sig, env;

    env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);
    sig = WhiteNoise.ar * env;
    sig = BPF.ar(sig, freq, 0.3) * 3;
    sig = (sig * 1.2).tanh;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// Hi-Hat Open
SynthDef(\dnbHatOpen, {
    |out=0, amp=0.2, pan=0, decay=0.2, freq=8000|
    var sig, env;

    env = EnvGen.kr(Env.perc(0.001, decay), doneAction: 2);
    sig = WhiteNoise.ar * env;
    sig = BPF.ar(sig, freq, 0.5) * 2;
    sig = HPF.ar(sig, 6000);

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// ====================================
// BASS
// ====================================

// Reese Bass - Classic DnB bass
SynthDef(\reeseBass, {
    |out=0, amp=0.4, pan=0, freq=55, gate=1, detune=2, cutoff=800, res=0.3|
    var sig, env, filterEnv;

    env = EnvGen.kr(Env.adsr(0.01, 0.3, 0.7, 0.5), gate, doneAction: 2);
    filterEnv = EnvGen.kr(Env.adsr(0.02, 0.2, 0.3, 0.3), gate);

    // Detuned sawtooth oscillators
    sig = Mix.fill(4, { |i|
        Saw.ar(freq * (1 + (i * detune * 0.001))) * 0.25
    });

    // Filter
    sig = RLPF.ar(sig,
        (cutoff * (1 + (filterEnv * 3))).clip(50, 18000),
        res.linlin(0, 1, 0.9, 0.1)
    );

    // Saturation
    sig = (sig * 2).tanh;

    sig = Pan2.ar(sig, pan, amp * env);
    Out.ar(out, sig);
}).add;

// Sub Bass - Deep sub foundation
SynthDef(\subBass, {
    |out=0, amp=0.5, pan=0, freq=55, gate=1|
    var sig, env;

    env = EnvGen.kr(Env.adsr(0.01, 0.1, 1.0, 0.3), gate, doneAction: 2);

    sig = SinOsc.ar(freq) * env;
    sig = (sig * 1.5).tanh;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// ====================================
// ATMOSPHERE
// ====================================

// Pad - Lush atmospheric pad
SynthDef(\dnbPad, {
    |out=0, amp=0.2, pan=0, freq=440, gate=1, cutoff=2000|
    var sig, env;

    env = EnvGen.kr(Env.adsr(1.0, 0.5, 0.7, 2.0), gate, doneAction: 2);

    sig = Mix.fill(8, { |i|
        Saw.ar(freq * (1 + (i * 0.01))) * 0.125
    });

    sig = RLPF.ar(sig, cutoff, 0.5);
    sig = sig * env;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// Arp - Melodic arpeggiator
SynthDef(\dnbArp, {
    |out=0, amp=0.3, pan=0, freq=440|
    var sig, env;

    env = EnvGen.kr(Env.perc(0.01, 0.3), doneAction: 2);

    sig = Pulse.ar(freq, 0.5);
    sig = RLPF.ar(sig, freq * 4, 0.3);
    sig = sig * env;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// Vocal Stab - Processed vocal hit
SynthDef(\vocalStab, {
    |out=0, amp=0.4, pan=0, freq=200, formant=500|
    var sig, env;

    env = EnvGen.kr(Env.perc(0.01, 0.5), doneAction: 2);

    sig = Pulse.ar(freq, 0.5);
    sig = sig + Pulse.ar(freq * 2, 0.3);

    // Formant filter
    sig = BPF.ar(sig, formant, 0.1, 3);
    sig = sig + BPF.ar(sig, formant * 2, 0.1, 2);

    sig = sig * env;
    sig = (sig * 1.5).tanh;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

"DnB SynthDefs loaded successfully!".postln;
"Available synths:".postln;
"  Drums: \\dnbKick, \\dnbSnare, \\dnbHatClosed, \\dnbHatOpen".postln;
"  Bass: \\reeseBass, \\subBass".postln;
"  Atmosphere: \\dnbPad, \\dnbArp, \\vocalStab".postln;
)
