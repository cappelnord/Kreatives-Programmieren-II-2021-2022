//////////////////////////////////////////////////////////////////// Clocks + Quant ///////////////////////////////////////////////////////////////////

// Einfache Drum Synths zur Demo

(
SynthDef(\kick,{
	var snd = SinOsc.ar(XLine.kr(500,50,0.1));
	var env = EnvGen.ar(Env.perc(0.01, 1), doneAction: 2) * 0.1;
	Out.ar(0, snd!2 * env);
}).add;


SynthDef(\snare,{|ffreq = 4000|
	var snd = RLPF.ar(WhiteNoise.ar(0.5), ffreq, 1);
	var env = EnvGen.ar(Env.perc(0.01, 0.1), doneAction:2) * 0.1;
	Out.ar(0, snd!2 * env);
}).add;
)


// AppClock
// SystemClock
// TempoClock

// Mit der System Clock können wir Events abhängig zur Zeit (in sek) planen und abspielen

(
SystemClock.sched(1,{
	Synth(\kick);
});
)


// TempoClock funktioniert ähnlich wie SystemClock, allerdings nicht relativ zur Zeit sondern zum jeweiligem tempo:
(
TempoClock.sched(1,{
	Synth(\snare);
});
)


// Der Unterschied liegt hier wie der Abstand (delta) angegebend wird
// So bezieht sich die SystemClock immer auf Zeit in Sekunden

// Die TempoClock allerdings auf Beats abhängig zu ihrem aktuellen tempo

(
t = TempoClock.new(120 / 60);

t.sched(2,{
	Synth(\snare);
});
)

(
t = TempoClock.new(300 / 60);

t.sched(2,{
	Synth(\snare);
});
)


// Unsere kick wird immer zum nächsten  ganzen beat (t.beats.ceil) abghängig von tempo abgespielt
(
t = TempoClock(1);
t.schedAbs(t.beats.ceil, { Synth(\kick); 1});
)

t.tempo = 90 / 60;
t.tempo = 4;
t.tempo = 0.5;
t.tempo = 1;


// Es gibt auch noch die AppClock, diese braucht uns allerdings erst einmal noch nicht zu interessieren
// Sie ist weniger genau als die TempoClock oder die SystemClock und kommt daher weniger beim
// audio timing zum Einsatz sonder vielmehr für GUI Elemente


// Vieles das ihr bereits kennt nutzt die Beats der bereits voreingestellten default TempoClock
// Um unsere Pattern oder Ndefs zu synchronisieren haben wir bisher immer .quant genutzt
// .quant nutzt auch die beats der default TempoClock

(

Pbind(\instrument, \snare,
	\dur, Pseq([1, 0.5, 0.25, 0.25], inf),
	\ffreq, Pwhite(3500, 3550,inf);
).play(quant: 1);
)

t = TempoClock.default;

// Die default Clock können wir auch nachträglich noch beeinflussen

t.tempo = 180 / 60;
t.tempo = 120 / 60;


// Doch reicht uns eine Clock ? Natürlich nicht ;)
// Wir können in der .play Methode auch eine eigene TempoClock angeben
// Somit sind wir nicht mehr an die default TempoClock gebunden und können auch mit mehreren clocks arbeiten:

(
// Beim Erstellen können wir der Clock direkt ein Tempo in bpm übergeben
~myclock = TempoClock.new(140/60);

Pbind(

	\instrument, \snare,
	\dur, Pseq([1, 0.5, 0.25, 0.25], inf),
	\ffreq, Pwhite(3500, 3550,inf);

).play(quant: 1, clock: ~myclock);
)

~myclock.tempo = 80 / 60;
~myclock.tempo = 190 / 60;

// Wenn wir mehrere Patterns mit unterschiedlichen Clocks synchronisieren wollen
// Müssen wir allerdings darauf achten, dass wir die Clocks zum selben Zeitpunkt starten !

(
~fast =  TempoClock.new(120 / 60);
~slow = TempoClock.new(120 / 60);
)


(
Pbind(

	\instrument, \snare,
	\dur, Pseq([1, 0.5, 0.25, 0.25], inf),
	\ffreq, Pwhite(3500, 3550,inf);

).play(quant: 1, clock: ~fast);
)

(
Pbind(

	\instrument, \snare,
	\dur, Pseq([1, 0.5, 0.25, 0.25], inf),
	\ffreq, Pwhite(1500, 2550,inf);

).play(quant: 1, clock: ~slow);
)

// Polyrythmic Fun  :)

~slow.tempo = 90 / 60;
~fast.tempo = 150 / 60;
~slow.tempo = 120 / 60;


// Pdef und argClock

// Bei Pdef müssen wir angeben, dass wir die clock des substreams verändern wollen
// Das geht dann mit argClock in .play oder einfach mit Pdef.clock

(
~fast =  TempoClock.new(120 / 60);
~slow = TempoClock.new(120 / 60);
)

(
Pdef(\s,
	Pbind(

		\instrument, \snare,
		\dur, Pseq([1, 0.5, 0.25, 0.25], inf),
		\ffreq, Pwhite(1500, 2550,inf);

	);
);
)

Pdef(\s).quant = 1;
Pdef(\s).play(argClock: ~fast);
~fast.tempo = 170 / 60;

Pdef(\s).stop;
Pdef(\s).clock(~slow);
Pdef(\s).play;

Pdef(\s).copy(\s2);
Pdef(\s2).play(argClock: ~fast);


