// Envelopes 2.0


// Letztes Mal haben wir uns damit beschäftigt, Envelopes zu erstellen:

~env = Env([0, 1, 0.5, 0], [0.1, 1, 2]);

~env.plot;

{ WhiteNoise.ar(0.1) * EnvGen.ar(~env, doneAction: 2) !2 }.play;


// In unserem Env Objekt können wir auch schon direkt mit multichannel Expansion arbeiten !
// So können wir beispielsweise jedem Kanal eine eigene releaseTime geben
// Wir sehen nun im plot auch zwei Hüllkurven

~env = Env([0, [1, 3], 0.5, 0], [0.5, 1, 2]);

~env.plot;

~env = Env([0, 1, 0.5, 0], [0.5, 1, [2, 5]]);

~env.plot;


// Das ganze dann in einem Ndef

(
Ndef(\envtest, {

	var snd, env;

	env = EnvGen.ar(~env, doneAction: 2);

	snd = Saw.ar([220, 440]) * env * 0.1;

	snd;

});
)


// Das macht allerdings noch nicht so wirklich Sinn, da die doneAction:2 des ersten EnvGens den gesamten Ndef beendet
// Doch wir können aber auch hier mit multichannel Expansion arbeiten:

(
~env = Env([0, 1, 0.5, 0], [0.5, 1, [2, 5]]);

Ndef(\envtest, {

	var snd, env;

	env = EnvGen.ar(~env, doneAction: [0, 2]);

	snd = Saw.ar([220, 440]) * env * 0.1;

	snd;

});
)

// Nun sollte erst wenn der EnvGen auf Kanal 2 fertig ist der umschließende Synth bzw. Ndef beendet werden.

Ndef(\envtest).play;



// Innerhalb von EnvGen können wir auch mit trigger arbeitern:
// Als Trigger Signal eignet sich Impulse

~env = Env([0, 1, 0.5, 0], [0.5, 1, [2, 4]] * 0.2)
~env.plot;


Ndef(\envtest).play;

(
Ndef(\envtest, {

	var snd, env, trigger;

	trigger = Impulse.kr(XLine.kr(4, 0.5, 10, doneAction: 2));

	env = EnvGen.ar(~env, doneAction: 0, gate: trigger);

	snd = Saw.ar([220, 440]) * env * 0.1;

	snd;

});
)

s.plotTree;


// Über Envelope Creation Methods --> siehe Help zu Env können wir uns bestimmte Shapes direkt erstellen lassen

~tri = Env.triangle(dur: 3, level: 1);

~tri.plot;

{ WhiteNoise.ar(0.1) * EnvGen.ar(~tri, doneAction: 2) !2 }.play;

~sine = Env.sine(dur: 3, level: 1);

~sine.plot;

{ WhiteNoise.ar(0.1) * EnvGen.ar(~sine, doneAction: 2) !2 }.play;


// Das kennt ihr vielleicht schon von Synthesizern: adsr Envelopes (attack-decay-sustain-release)

~adsr = Env.adsr(attackTime: 0.01, decayTime: 0.5, sustainLevel: 0.5, releaseTime: 1);

~adsr.plot;

s.reboot;

{ WhiteNoise.ar(0.1) * EnvGen.ar(~adsr, doneAction: 2) }.play;


// Sustaining Envs wie .adsr oder auch .asr übergeben wir ein sustain level
// Das Sustain leveln wird ausgehalten (sustained) bis das gate des zugehörigen EnvGens auf 0 ist
// Danach "springt" EnvGen in das release Segment

(
SynthDef(\octave, { |gate, release = 1|

	var env, snd;

	env = EnvGen.kr(Env.adsr(releaseTime: release), gate: gate, doneAction: 2);
	snd = Pulse.ar([200, 400, 800]).sum * env * 0.1;

	Out.ar(0, snd.dup)

}).add;
)

~tave = Synth(\octave, [\gate, 1, \release, 3]);

~tave.set(\gate, 0);


// Das ganze mit einem Signal als trigger für unser gate

(
SynthDef(\octavegate, { |release = 1, density = 0.5|

	var env, snd, trigger;

	trigger = Dust.kr(density);
	env = EnvGen.kr(Env.adsr(releaseTime: release), gate: trigger, doneAction: 0);
	snd = Pulse.ar([200, 400, 800]).sum * env * 0.1;

	Out.ar(0, snd.dup)

}).add;
)

Synth(\octavegate, [\density, 10 , \release, 0.5]);


// Und noch eine nützliche Hüllkurve für Kurze / Perkussive Sounds

~perc = Env.perc(0.01, 0.5);

~perc.plot;

{ WhiteNoise.ar(0.1) * EnvGen.ar(~perc, doneAction: 2) !2 }.play;



// Lasst uns Env.perc nutzen um einen simplen Drum Synth zu bauen

(
SynthDef(\kick, { |freq = 200, release = 2|

	var snd, env;

	env = EnvGen.ar(Env.perc(0.01, release), doneAction: 2);

	// Guter Trick für simple Kick Sounds: Schnelle XLines als Frequenz ! Quelle: Patrick :]
	snd = SinOsc.ar(XLine.kr(freq, 50, 0.01)) * env;

	snd = HPF.ar(NHHall.ar(snd.dup, release)) * 0.25 + snd;

	Out.ar(0, snd * 0.2);

}).add
)

Synth(\kick, [\freq, 500, \release, 3]);


(
SynthDef(\snare, { |ffreq = 800, release = 0.4|

	var snd, env;

	env = EnvGen.ar(Env.perc(0.01, release), doneAction: 2);

	// Snares können wir mit einem WhiteNoise synthethisieren
	snd = RLPF.ar(WhiteNoise.ar(1), ffreq, rq: 0.5);

	snd = NHHall.ar(snd.dup, release * 2) * 0.25 + snd;
	snd = snd * env;

	Out.ar(0, snd * 0.1);

}).add
)


// Mit dem Filter können wir unseren Snare Sound noch etwas stimmen

Synth(\snare, [\ffreq, 500]);
Synth(\snare, [\ffreq, 1500]);









