// Control Signals, LFOs und Phasenmodulation

// Wir haben ja schon die Frequenz und die Amplitude moduliert
// Eng verwandt mit der Frequnzmodulation ist auch die Phasenmodulation
// Wenn wir die Frequenz oder die Amplitude setzen können wir änderungen an diesen Parametern unmittelbar hören
// Bei der Phase verhält sich das etwas anders: Da wir hier quasi das ganze Signal verschieben, hören wie nur Änderungen über Zeit (Modulation)
// ...oder die Verschiebung im Vergleich zu anderen Signalen:

s.scope;

// Gleiche Phase
{SinOsc.ar(440, 0) + SinOsc.ar(440, 0) * 0.1}.play;

// Umgedrehte Phase: Auslöschung
{SinOsc.ar(440, 0) + SinOsc.ar(440, pi) * 0.1}.play;

// Modulation zwischen Gleicher Phase und Auslöschung
{SinOsc.ar(440, 0) + SinOsc.ar(440, SinOsc.kr(0.5).range(0, 2pi)) * 0.1}.play;


// Modulation der Phase mit unterschiedlichen Control Signalen

(
Ndef(\sin, { |control|
	var snd = SinOsc.ar(440, control) * 0.1;
	snd.dup;
})
)

Ndef(\par, {LFPar.ar(MouseX.kr(1, 100), 2, 8pi)});
Ndef(\pulse, {LFPulse.ar(MouseX.kr(1, 100), mul: 8pi)});
Ndef(\tri, {LFTri.ar(MouseX.kr(1, 100), mul: 8pi)});

Ndef(\sin).fadeTime = 4;
Ndef(\sin).play;
Ndef(\sin).set(\control, Ndef(\par));
Ndef(\sin).set(\control, Ndef(\pulse));
Ndef(\sin).set(\control, Ndef(\tri));

Ndef(\sin).clear;


// Low Frequency Ugens sind nicht Band limitiert
// Das beudeted allerdings auch dass es bei hohen Frequenzen zu Aliasing kommen kann:

{ LFSaw.ar(1000) * 0.1 }.play
{ Saw.ar(1000) * 0.1 }.play


// Was wir im Spektrum des LFSaw zusätzlich hören, sind Obertöne des LFSaw welche oberhalb der Nyquist Frequency liegen
// und wieder in das hörbare Spektrum zurückgespiegelt werden

{ Saw.ar(MouseX.kr(500, 5000)) * 0.1 }.play
{ LFSaw.ar(MouseX.kr(500, 5000)) * 0.1 }.play


// Das funktionert demnach auch nur bei Klanggeneratoren mit Obertonreichen Spektren:

{ SinOsc.ar(MouseX.kr(500, 5000)) * 0.1 }.play
{ LFCub.ar(MouseX.kr(500, 5000)) * 0.1 }.play

// Alles was wir hier hören können, ist Aliasing

{ LFSaw.ar(23000) * 0.1 }.play;


// Verschiedene Oszillatoren unterscheiden sich darüber hinaus auch durch weiter eigenschaften:

{ LFPulse.ar() }.plot;
{ Pulse.ar() }.plot;

{ Saw.ar() }.plot;
{ LFSaw.ar() }.plot;

{ SinOsc.ar(440 + Pulse.ar(MouseX.kr(0.1, 5), mul: 200)) * 0.1}.play
{ SinOsc.ar(440 + LFPulse.ar(MouseX.kr(0.001, 5), mul: 200)) * 0.1}.play

{ SinOsc.ar(440 + Saw.ar(MouseX.kr(0.1, 5), mul: 200)) * 0.1}.play
{ SinOsc.ar(440 + LFSaw.ar(MouseX.kr(0.001, 5), mul: 200)) * 0.1}.play


// Delay

// Wir nehmen unseren Klank vom letzten Mal

(
Ndef(\filterbank, {

	var snd, freqs, amps, ringtimes;

	snd = Impulse.ar(1);

	freqs = [220, 440, 441, 880, 1200];
	amps = [0.1, 0.05, 0.1, 0.1, 0.05];
	ringtimes = [3, 1, 2, 1, 1] * 2.0;

	snd = DynKlank.ar(`[freqs, amps, ringtimes], snd, freqscale: 1.0);
	snd.dup * 0.1;

});

Ndef(\filterbank).play;
)


// Und nun mit einem einfachen Delay ohne Feedback:

(
Ndef(\filterbank, {

	var snd, freqs, amps, ringtimes;

	snd = Impulse.ar(1);

	freqs = [220, 440, 441, 880, 1200];
	amps = [0.1, 0.05, 0.1, 0.1, 0.05];
	ringtimes = [3, 1, 2, 1, 1] * 0.5;

	snd = DynKlank.ar(`[freqs, amps, ringtimes], snd, freqscale: 1.0);
	snd = DelayN.ar(snd, 1, [0.1, 0.125, 0.75, 0.1, 0.15, 0.33, 0.66]) + snd;
	snd = Splay.ar(snd) * 0.1;

});

Ndef(\filterbank).play;
)


// Delay N nutzt keine Interpolation. Dort kann es allerdings auch zu Artefakten kommen, wenn wir die Delaytime modulieren wollen
// Für modulierende Delaytimes können wir DelayL (linear interpolation) oder DelayC (cubic interpolation) verwenden

(
Ndef(\filterbank, {

	var snd, freqs, amps, ringtimes, delaytime;

	snd = Impulse.ar(0.5);

	freqs = [220, 440, 441, 880, 1200];
	amps = [0.1, 0.05, 0.1, 0.1, 0.05];
	ringtimes = [3, 1, 2, 1, 1] * 0.5;

	delaytime = LFTri.kr([0.5, 1, 3, 5], [0, 0.5pi, pi, 0.25pi]).range(0.1, 1);

	snd = DynKlank.ar(`[freqs, amps, ringtimes], snd, freqscale: 1.0);

	// Simples Delay ohne Feedback mit modulierten Phasen
	snd = DelayL.ar(snd, 1, delaytime) + snd;

	Splay.ar(snd) * 0.1;
});

Ndef(\filterbank).play
)


// CombN bzw. CombL / CombC haben wir  zusätzliches Feedback in unserer Delayschleife

(
Ndef(\filterbank, {

	var snd, freqs, amps, ringtimes;

	snd = Impulse.ar(1);

	freqs = [220, 440, 441, 880, 1200];
	amps = [0.1, 0.05, 0.1, 0.1, 0.05];
	ringtimes = [3, 1, 2, 1, 1];

	snd = DynKlank.ar(`[freqs, amps, ringtimes], snd, freqscale: Array.series(10, 1, 0.5) * 1);

	// Delay mit Feedback und Decay Time
	snd = CombC.ar(snd,1.5, Array.series(10, 0.1, 0.125), decay: 5) + snd;

	snd = Splay.ar(snd) * 0.1;

});
)

Ndef(\filterbank).fadeTime = 3;
Ndef(\filterbank).play;


// Wir Kombinieren beides für elektronische Jungle Sounds

(
Ndef(\fC, {

	var snd, freqs, amps, ringtimes, delaytime;

	snd = Impulse.ar(MouseX.kr(0.2, 2));

	freqs = [220, 440, 441, 880, 1200];
	amps = [0.1, 0.05, 0.1, 0.1, 0.05];
	ringtimes = [3, 1, 2, 1, 1] * 0.5;

	delaytime = LFTri.kr([0.5, 1, 3, 5], [0, 0.5pi, pi, 0.25pi]).range(0.1, 2);

	snd = DynKlank.ar(`[freqs, amps, ringtimes], snd, freqscale: LFNoise1.kr(1.5).range(1,3));
	snd = CombN.ar(snd, 2, delaytime, decaytime: 2) + snd;

	snd = JPverb.ar(snd * 0.5, 1) + snd;

	Splay.ar(snd) * 0.2;
});

Ndef(\fC).play;
)


// Bei "exception in real time: alloc failed, increase server's memory allocation (e.g. via ServerOptions)":
// Die Server Memory Size zu erhöhen damit wir auch längere delaytimes Einstellen können

o = Server.default.options;
o.memSize = 4096 * 2;

// reboot nicht vergessen
s.reboot;


