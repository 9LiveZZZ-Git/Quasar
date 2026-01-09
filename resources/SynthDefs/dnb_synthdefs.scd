/*
PROFESSIONAL DnB SynthDefs for Quasar
Industry-standard modern Drum and Bass synthesis

Features:
- Deep, punchy kicks with proper sub presence
- Layered snares with body and crack
- Bright, present hi-hats
- Authentic Reese bass with movement
- Powerful sub bass with harmonics
- Lush, evolving pads

Version: 2.0 (Professional)
Load with: load("resources/SynthDefs/dnb_synthdefs_professional.scd");
*/

(
"Loading professional DnB SynthDefs...".postln;

// ====================================
// DRUMS - PROFESSIONAL
// ====================================

// ===== KICK - Deep, Punchy, Layered =====
SynthDef(\dnbKick, {
    |out=0, amp=0.8, pan=0, freq=40, decay=0.35, pitchDecay=0.05, click=0.003|
    var sig, env, sub, body, clickLayer, pitchEnv, mid;

    // Main envelope
    env = EnvGen.kr(Env.perc(0.001, decay, curve: -8), doneAction: 2);

    // Pitch envelope (2 octaves down for punch)
    pitchEnv = EnvGen.kr(Env.perc(0, pitchDecay, curve: -4));

    // SUB layer (30-40Hz) - The weight
    sub = SinOsc.ar(
        freq * (1 + (pitchEnv * 2))  // Pitch sweep
    );
    sub = sub * env * 0.6;

    // BODY layer (60-100Hz) - The punch
    body = SinOsc.ar(
        (freq * 1.5) * (1 + (pitchEnv * 1.5))
    );
    body = body + (SinOsc.ar((freq * 2)) * 0.3);  // Harmonic
    body = body * env * 0.4;

    // CLICK layer (2-8kHz) - The attack
    clickLayer = WhiteNoise.ar;
    clickLayer = BPF.ar(clickLayer, 3000, 0.5);
    clickLayer = clickLayer * EnvGen.kr(Env.perc(0, click));
    clickLayer = clickLayer * 0.15;

    // MID layer (150-300Hz) - The presence
    mid = SinOsc.ar((freq * 4) * (1 + (pitchEnv * 0.5))) * env * 0.2;

    // Combine layers
    sig = sub + body + clickLayer + mid;

    // Saturation for harmonics and punch
    sig = (sig * 2).tanh;

    // High-pass to clean up rumble
    sig = HPF.ar(sig, 25);

    // Subtle compression (make it punchier)
    sig = Compander.ar(sig, sig,
        thresh: 0.4,
        slopeBelow: 1,
        slopeAbove: 0.5,
        clampTime: 0.001,
        relaxTime: 0.01
    );

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// ===== SNARE - Layered, Punchy, Modern =====
SynthDef(\dnbSnare, {
    |out=0, amp=0.5, pan=0, tune=0, decay=0.15, bodyDecay=0.1, noiseDecay=0.12|
    var sig, env, bodyEnv, noiseEnv, crackEnv, noiseStereo;
    var body, crack, noise;

    // BODY layer (180-220Hz fundamental)
    bodyEnv = EnvGen.kr(Env.perc(0.001, bodyDecay, curve: -4));
    body = SinOsc.ar(200 + tune);  // Fundamental
    body = body + (SinOsc.ar(180 + tune) * 0.5);  // Slight detune
    // Add FM for character
    body = body * (1 + (SinOsc.ar(350) * 0.3));
    body = body * bodyEnv * 0.4;

    // CRACK layer (ring modulation 800-1200Hz)
    crackEnv = EnvGen.kr(Env.perc(0.001, 0.05));
    crack = SinOsc.ar(240 + tune) * SinOsc.ar(900);  // Ring mod
    crack = crack + (SinOsc.ar(280 + tune) * SinOsc.ar(1100) * 0.7);
    crack = BPF.ar(crack, 1000, 0.5, 3);
    crack = crack * crackEnv * 0.3;

    // NOISE layer (filtered white noise 1.5-8kHz)
    noiseEnv = EnvGen.kr(Env.perc(0.001, noiseDecay, curve: -2), doneAction: 2);
    noise = WhiteNoise.ar + PinkNoise.ar;
    // Multi-stage filtering for character
    noise = BPF.ar(noise, 2000 + tune, 0.5, 2);
    noise = noise + BPF.ar(noise, 4000, 0.3, 1);
    noise = HPF.ar(noise, 1500);
    noise = noise * noiseEnv * 0.4;

    // Combine layers
    sig = body + crack + noise;

    // Saturation/distortion for grit
    sig = (sig * 2.5).tanh;

    // Slight stereo widening on noise component
    noiseStereo = noise * [1, 1.02];  // Subtle width
    sig = sig + (noiseStereo * 0.1);

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// ===== HI-HAT CLOSED - Bright, Present, Crisp =====
SynthDef(\dnbHatClosed, {
    |out=0, amp=0.5, pan=0, decay=0.05, tone=1.0|
    var sig, env, noise;

    env = EnvGen.kr(Env.perc(0.001, decay, curve: -4), doneAction: 2);

    // Multiple noise sources
    noise = (WhiteNoise.ar * 0.7) + (PinkNoise.ar * 0.3);

    // Multiple resonant peaks for metallic character
    sig = BPF.ar(noise, 6000 * tone, 0.3, 2);
    sig = sig + BPF.ar(noise, 8500 * tone, 0.25, 1.5);
    sig = sig + BPF.ar(noise, 11000 * tone, 0.2, 1);

    // High-pass for brightness
    sig = HPF.ar(sig, 5000);

    sig = sig * env;

    // Subtle saturation
    sig = (sig * 1.3).tanh;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// ===== HI-HAT OPEN - Long Decay, Resonant =====
SynthDef(\dnbHatOpen, {
    |out=0, amp=0.6, pan=0, decay=0.25, tone=1.0|
    var sig, env, noise, pitchMod;

    env = EnvGen.kr(Env.perc(0.001, decay, curve: -2), doneAction: 2);

    // Richer noise mix
    noise = (WhiteNoise.ar * 0.6) + (PinkNoise.ar * 0.4);

    // More resonance, wider spread
    sig = BPF.ar(noise, 7000 * tone, 0.5, 2.5);
    sig = sig + BPF.ar(noise, 9000 * tone, 0.4, 2);
    sig = sig + BPF.ar(noise, 12000 * tone, 0.3, 1.5);

    // Subtle pitch modulation for shimmer
    pitchMod = LFNoise2.kr(100) * 500;
    sig = sig + (BPF.ar(noise, 8000 + pitchMod, 0.35) * 0.3);

    // High-pass
    sig = HPF.ar(sig, 6000);

    sig = sig * env;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// ====================================
// BASS - PROFESSIONAL
// ====================================

// ===== REESE BASS - Thick, Moving, Authentic =====
SynthDef(\reeseBass, {
    |out=0, amp=0.6, pan=0, freq=55, gate=1,
     detune=5, cutoff=800, res=0.6, drive=2|
    var sig, env, filterEnv, pwmEnv;
    var oscs, filter1, filter2;
    var chorusMod, vowelFreq, notchFreq, filtered;
    var low, mid, high, phaseMod, lowMono, highStereo;

    // Envelopes
    env = EnvGen.kr(Env.adsr(0.005, 0.2, 0.8, 0.4), gate, doneAction: 2);
    filterEnv = EnvGen.kr(Env.adsr(0.01, 0.3, 0.4, 0.3), gate);
    pwmEnv = EnvGen.kr(Env.adsr(0.05, 0.5, 0.5, 0.2), gate);

    // 8 detuned oscillators (saws + squares for richness)
    oscs = Mix.fill(8, { |i|
        var detuneAmount = (i - 3.5) * detune * 0.01;
        var sawOsc = Saw.ar(freq * (1 + detuneAmount));
        var squareOsc = Pulse.ar(
            freq * (1 + detuneAmount),
            0.5 + (pwmEnv * 0.3)  // PWM for movement
        );
        (sawOsc * 0.7) + (squareOsc * 0.3)
    }) * 0.125;

    // Chorus/ensemble effect (internal)
    chorusMod = SinOsc.kr(0.5) * 0.003;
    oscs = oscs + DelayC.ar(oscs, 0.02, 0.01 + chorusMod);

    // Multi-stage filtering
    // Stage 1: Main lowpass with envelope
    filter1 = RLPF.ar(oscs,
        (cutoff * (1 + (filterEnv * 4))).clip(50, 8000),
        res.linlin(0, 1, 0.9, 0.1)
    );

    // Stage 2: Bandpass for vowel character
    vowelFreq = LFNoise1.kr(0.3).range(300, 1200);
    filter2 = BPF.ar(oscs, vowelFreq, 0.5, 0.3);

    // Stage 3: Notch filter for movement
    notchFreq = LFNoise1.kr(0.4).range(400, 2000);
    filtered = BRF.ar(filter1 + filter2, notchFreq, 0.3);

    sig = filtered;

    // Multiband saturation
    low = LPF.ar(sig, 200);
    mid = BPF.ar(sig, 600, 1);
    high = HPF.ar(sig, 1200);

    low = (low * drive).tanh;
    mid = (mid * (drive * 0.7)).tanh;
    high = (high * (drive * 0.5)).softclip;

    sig = low + mid + high;

    // Subtle phasing
    phaseMod = SinOsc.kr(0.3) * 0.002;
    sig = sig + AllpassN.ar(sig, 0.02, phaseMod);

    // Apply envelope
    sig = sig * env;

    // Stereo widening above 150Hz (keep low mono!)
    lowMono = LPF.ar(sig, 150);
    highStereo = HPF.ar(sig, 150);
    highStereo = highStereo * [1, 1.01];  // Subtle stereo

    sig = lowMono + highStereo.sum;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// ===== SUB BASS - Powerful, Felt, Clean =====
SynthDef(\subBass, {
    |out=0, amp=0.7, freq=55, gate=1, harmonics=0.08|
    var sig, env, sub, harm, pitchEnv;

    // Tight envelope
    env = EnvGen.kr(Env.adsr(0.003, 0.05, 1.0, 0.15), gate, doneAction: 2);

    // Subtle pitch envelope for attack
    pitchEnv = EnvGen.kr(Env.perc(0, 0.02, curve: -8));

    // Pure sub (30-80Hz)
    sub = SinOsc.ar(freq * (1 + (pitchEnv * 0.1)));

    // Subtle 2nd and 3rd harmonics for audibility
    harm = SinOsc.ar(freq * 2) * harmonics * 0.5;
    harm = harm + (SinOsc.ar(freq * 3) * harmonics * 0.25);

    sig = sub + harm;

    // Subtle saturation for warmth
    sig = (sig * 1.3).tanh;

    // MONO output (critical for sub!)
    sig = sig * env * amp;
    Out.ar(out, sig ! 2);  // Duplicate to stereo but same signal
}).add;

// ====================================
// ATMOSPHERE - PROFESSIONAL
// ====================================

// ===== PAD - Lush, Evolving, Wide =====
SynthDef(\dnbPad, {
    |out=0, amp=0.3, pan=0, freq=440, gate=1, cutoff=2500, detune=0.02|
    var sig, env, filterEnv;
    var oscs, filtered;
    var filterMod, ampMod, chorusL, chorusR;

    // Long, smooth envelope
    env = EnvGen.kr(Env.adsr(2.0, 1.0, 0.7, 3.0), gate, doneAction: 2);
    filterEnv = EnvGen.kr(Env.adsr(1.0, 2.0, 0.5, 2.0), gate);

    // 16 detuned oscillators for richness
    oscs = Mix.fill(16, { |i|
        var detuneAmt = (i - 7.5) * detune;
        var saw = Saw.ar(freq * (1 + detuneAmt));
        var square = Pulse.ar(freq * (1 + detuneAmt), 0.5);
        var tri = LFTri.ar(freq * (1 + detuneAmt));
        (saw * 0.5) + (square * 0.3) + (tri * 0.2)
    }) * 0.0625;

    // Slow filter modulation
    filterMod = LFNoise1.kr(0.2).range(0.5, 1.5);
    filtered = RLPF.ar(oscs,
        (cutoff * filterMod * (1 + filterEnv)).clip(200, 8000),
        0.5
    );

    // High-pass to remove mud
    filtered = HPF.ar(filtered, 200);

    // Slow amplitude modulation
    ampMod = LFNoise1.kr(0.1).range(0.9, 1.0);
    filtered = filtered * ampMod;

    // Stereo chorus effect
    chorusL = filtered + DelayC.ar(filtered, 0.05,
        LFNoise1.kr(0.3).range(0.01, 0.03));
    chorusR = filtered + DelayC.ar(filtered, 0.05,
        LFNoise1.kr(0.4).range(0.01, 0.03));

    sig = [chorusL, chorusR];

    // Subtle phasing
    sig = sig + AllpassN.ar(sig, 0.05, LFNoise1.kr(0.15).range(0.01, 0.04));

    sig = sig * env;

    // Wide stereo image
    sig = Balance2.ar(sig[0], sig[1], pan, amp);
    Out.ar(out, sig);
}).add;

// ===== ARP - Plucky, Defined =====
SynthDef(\dnbArp, {
    |out=0, amp=0.4, pan=0, freq=440, cutoff=2000|
    var sig, env, filterEnv;

    env = EnvGen.kr(Env.perc(0.005, 0.25, curve: -4), doneAction: 2);
    filterEnv = EnvGen.kr(Env.perc(0.01, 0.15, curve: -6));

    // Richer oscillator mix
    sig = Pulse.ar(freq, 0.5) + (Saw.ar(freq) * 0.4);

    // Resonant filter for pluck character
    sig = RLPF.ar(sig,
        (cutoff * (1 + (filterEnv * 3))).clip(freq, 8000),
        0.3
    );

    sig = sig * env;

    // Saturation
    sig = (sig * 1.5).tanh;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

// ===== VOCAL STAB - Formant-Rich =====
SynthDef(\vocalStab, {
    |out=0, amp=0.5, pan=0, freq=200, formant=500, vowel=0.5|
    var sig, env, formantEnv, formant1, formant2, formant3;

    env = EnvGen.kr(Env.perc(0.01, 0.4, curve: -4), doneAction: 2);
    formantEnv = EnvGen.kr(Env.perc(0.02, 0.3, curve: -2));

    // Rich oscillator source
    sig = Pulse.ar(freq, 0.5);
    sig = sig + Pulse.ar(freq * 2, 0.3);
    sig = sig + (Saw.ar(freq) * 0.3);

    // Multiple formant filters for vowel sound
    formant1 = BPF.ar(sig, formant * (1 + (formantEnv * 0.5)), 0.1, 3);
    formant2 = BPF.ar(sig, formant * 2.2, 0.15, 2);
    formant3 = BPF.ar(sig, formant * 3.5, 0.2, 1.5);

    // Mix formants based on vowel parameter
    sig = (formant1 * (1 - vowel)) + (formant2 * vowel) + formant3;

    sig = sig * env;

    // Heavy saturation for character
    sig = (sig * 2.5).tanh;

    sig = Pan2.ar(sig, pan, amp);
    Out.ar(out, sig);
}).add;

"".postln;
"✅ Professional DnB SynthDefs loaded successfully!".postln;
"".postln;
"Available professional synths:".postln;
"  🥁 Drums: \\dnbKick, \\dnbSnare, \\dnbHatClosed, \\dnbHatOpen".postln;
"  🎸 Bass: \\reeseBass, \\subBass".postln;
"  🎹 Atmosphere: \\dnbPad, \\dnbArp, \\vocalStab".postln;
"".postln;
"Improvements:".postln;
"  • Kick: Layered (sub+body+click), 30-40Hz fundamental".postln;
"  • Snare: 3-layer design (body+crack+noise)".postln;
"  • Hats: Brighter, louder, more present".postln;
"  • Reese: 8 oscs, chorus, phasing, vowel filter".postln;
"  • Sub: Harmonics for audibility, mono output".postln;
"  • Pad: 16 oscs, LFO modulation, stereo chorus".postln;
"".postln;
)
