// Kreatives Programmieren 3
// SuperCollider II
// 10.11.2021

s.boot;


// Aktuelle Nyquist-Frequenz
s.sampleRate / 2


// Demonstriert Aliasing bei Frequenzen über der Nyquist-Frequenz
Ndef(\sweep, {SinOsc.ar(XLine.ar(50, 80000, 30)).dup * 0.1}).play

// Bei bandlimitierten Oszillatoren wird darauf geachtet, dass keine Obertöne über
// der Nyquist-Frequenz (und somit Aliasing) entsteht.
Ndef(\oscis, {Saw.ar(600).dup * 0.2}).play
Ndef(\oscis, {Pulse.ar(600).dup * 0.1}).play

// Im direkten Vergleich (hört auf den rauen Klang oberhalb im Frequenzspektrum)

Ndef(\oscis, {Saw.ar(600).dup * 0.2}).play
Ndef(\oscis, {LFSaw.ar(600).dup * 0.1}).play

Ndef(\oscis, {Pulse.ar(600).dup * 0.1}).play
Ndef(\oscis, {LFPulse.ar(600).dup * 0.1}).play

// Bei hohen Frequenzen und mit noch einem Hochpassfilter wird es noch
// deutlicher.


Ndef(\oscis, {HPF.ar(Saw.ar(1000), 5000).dup * 0.2}).play
Ndef(\oscis, {HPF.ar(LFSaw.ar(1000), 5000).dup * 0.1}).play

Ndef(\oscis, {HPF.ar(Pulse.ar(1000), 5000).dup * 0.1}).play
Ndef(\oscis, {HPF.ar(LFPulse.ar(1000), 5000).dup * 0.1}).play

// Obertonspektrum von Saw und Pulse:
// https://de.wikipedia.org/wiki/Kippschwingung (alle harmonischen Obertöne)
// https://de.wikipedia.org/wiki/Rechteckschwingung (nur ungerade)


// Mit Maus/Trackpad und einem Filter können wir die Obertöne
// auch herausfiltern bzw. herausarbeiten und hören.


(
Ndef(\filter, {
	// falls 2 Monitore angeschlossen sind könnte MouseX unter 0 gehen!
	// daher hier mit max(50) den Wertebereich eingegrenzt, dass kein
	// Wert unter 50 gehen kann!
	var freq = MouseX.kr(50, 1000).max(50);
	BPF.ar(Saw.ar(80), freq, 0.005).dup * 5;
}).play
)


(
Ndef(\filter, {
	var freq = MouseX.kr(50, 1000).max(50);
	BPF.ar(Pulse.ar(80), freq, 0.005).dup * 3;
}).play
)



(
Ndef(\orgeldrone, {
	var freqs = Array.series(16, 50, 50);
	var amps = 1.0 / Array.series(16, 1, 1);
	var oscis = BPF.ar(WhiteNoise.ar, freqs, 0.0001) * amps;
	// sehr starke Verstärkung am Ende, da wir viel Energie aus dem Rauschen rausnehmen
	Splay.ar(oscis) * 600;
}).play;
)


// Schwebung/Beatings

// vollständige Auslöschung durch entgegengesetzte Phasen
(
Ndef(\phases, {
	(SinOsc.ar(440) + SinOsc.ar(440, pi)).dup * 0.1
}).play;
)

// Phase des 2. Oszillators mit Maus steuerbar
(
Ndef(\phases, {
	(SinOsc.ar(440) + SinOsc.ar(440, MouseX.kr(0, pi))).dup * 0.1
}).play;
)

// Bei einer Schwebung kommt es abwechselnd zu Verstärkung und
// Auslöschung, da die Phasenlage beider Töne zueinander ständig
// wechselt.
(
Ndef(\beatings, {
	(SinOsc.ar(440) + SinOsc.ar(441)).dup * 0.1
}).play;
)

// Die Frequenz dieser Modulation der Amplitude ist hierbei dann
// die Differenz der beiden Oszillatoren
(
Ndef(\beatings, {
	(SinOsc.ar(440) + SinOsc.ar(445)).dup * 0.1
}).play;
)


// Diese Schwebungen passieren auch bei Teiltönen von
// obertonreichen Oszillatoren. Eine praktische Anwendung
// hierfür das ist "fetter" machen von Synthie-Sounds indem
// man leicht zueinander verstimmte Oszillatoren nimmt.

(
Ndef(\fatsaw, {
	var sig = Saw.ar(50) + Saw.ar(50 + MouseY.kr(0, 1));
	RLPF.ar(sig, MouseX.kr(100, 2000), 0.5).dup * 0.2;
}).play
)

s.scope

// Help: Tour of UGens
// https://doc.sccode.org/Guides/Tour_of_UGens.html

// sc3-plugins
// https://github.com/supercollider/sc3-plugins

// Lieblings-Reverb in SuperCollider:

(
Ndef(\fatsaw, {
	var sig = Saw.ar(50) + Saw.ar(50 + MouseY.kr(0, 1));
	sig = RLPF.ar(sig, MouseX.kr(100, 2000), 0.2) * 0.2;
	JPverb.ar(sig, 5, 0.5) + sig;
}).play
)


// (Vorsicht: Feedback-Gefahr)
(
Ndef(\verb, {
	JPverb.ar(SoundIn.ar, 10, 0.8) * 0.3
}).play;
)

