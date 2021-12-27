
(
SynthDef(\kick, { |freq = 200, release = 2|

	var snd, env;

	env = EnvGen.ar(Env.perc(0.01, release), doneAction: 2);

	// Guter Trick für simple Kick Sounds: Schnelle XLines als Frequenz !
	snd = SinOsc.ar(XLine.kr(freq, 50, 0.01)) * env;

	snd = HPF.ar(NHHall.ar(snd.dup, release)) * 0.25 + snd;

	Out.ar(0, snd * 0.2);

}).add
)

Synth(\kick, [\freq, 500, \release, 3]);


(
SynthDef(\snare, { |ffreq = 800, release = 0.5|

	var snd, env;

	env = EnvGen.ar(Env.perc(0.01, release), doneAction: 2);

	// Snares können wir gut mit einem WhiteNoise synthethisieren
	snd = RLPF.ar(WhiteNoise.ar(1), ffreq, rq: 0.5);

	snd = NHHall.ar(snd.dup, release * 2) * 0.25 + snd;
	snd = snd * env;

	Out.ar(0, snd * 0.1);

}).add
)


// Mit dem Filter können wir unseren Snare Sound noch etwas stimmen

Synth(\snare, [\ffreq, 500]);
Synth(\snare, [\ffreq, 1500]);


// PATTERNS

// Nun brauchen wir nur noch eine Methode um Drum Sounds abspielen zu lassen
// Eine einfach Möglichkeit dazu wäre fork
// fork sequenziert unseren Code innerhalb der Funktionsklammern
// mit .wait können wir die Wartezeit zwischen den dadurch enstehend Teilabschnitten festlegen

(
{
	"first".postln;

	1.wait;

	"second".postln;
}.fork;
)

// Was wir damit sequenzieren wollen, bleibt uns überlassen
// So klingt das ganze mit unserem Drum Sounds

(
{
	Synth(\kick);

	0.5.wait;

	Synth(\snare);

	0.5.wait;
}.fork;
)


// Wir haben uns ja schon einmal .do angeschaut
// Das können wir auch innerhalb von fork verwenden

(
{
	4.do{
		Synth(\kick);

		0.25.wait;

		Synth(\snare);

		0.25.wait;
	}
}.fork;
)

// fork eignet sich also gut um Code zu sequenzieren
// Wollen wir damit allerdings halbwegs komplexe Rhythmen abspielen, stößt fork schnell an seine Grenzen

(
{
	inf.do{

		Synth(\kick);

		0.5.wait;

		Synth(\snare);

		0.75.wait;

		Synth(\kick);

		0.25.wait;

		Synth(\snare);

		0.5.wait;
	}
}.fork;
)


// Doch es gibt in Supercollider auch noch Sturkturen, mit denen wir unsere Drum Sounds abspielen können:
// Pattern

// Wollen wir beispielsweise über Zahlen in einer Reiher iterieren, eigent sich dafür Pseq:
// Pseq iteriert über eine Liste und das so oft wir das möchten:

// 2 Iterationen
~seq = Pseq([1,2,3], 2);

// 15 Iterationen
~seq = Pseq([1,2,3], 15);


// Damit wir von unserem Pseq nun einzelne Werte abfragen können müssen wir in zunächst in einen Stream umwandeln
// Auf Streams werden wir an dieser Stelle erst einmal nicht so genau eingehen. Mehr dazu in der Help under "Pattern versus Stream"

~seq = ~seq.asStream;


// Nun können wir mit .next einzelne Werte abfragen:

~seq.next;


// Das ganze geht so lange bis "nil" ausgegeben wird, die Anzahl der repeats also aufgebraucht ist

~seq = Pseq([1,2,3], 2);
~seq= ~seq.asStream;

10.do{ ~seq.next.postln; };


// Mit inf können wir aber auch unendlich oft über unsere Pseqs iterieren

~seq = Pseq([1,2,3], inf);
~seq= ~seq.asStream;

100.do{ ~seq.next.postln; };


// Mit verschiedenen Pattern und deren kombination können wir uns mit relativ wenig Code komplexe Outputs erzeugen
// Eine gute Übersicht findet ihr in der Help unter Patterns -> Examples
// Diese können wir wiederum nutzen um Instanzen von unserem Synth mit Argumenten aus unserem Pattern auszustatten


//Pseq
~freqs =  Pseq([3000, 550, 100], inf).asStream;

(
{
	inf.do{

		Synth(\kick, [\freq, ~freqs.next]);

		0.2.wait;

	}
}.fork;
)


// Patterns in Patterns: Pwhite + Pdup

~freqs = Pdup(3, Pwhite(500, 3000)).asStream;

(
{
	inf.do{

		Synth(\kick, [\freq, ~freqs.next]);

		0.2.wait;

	}
}.fork;
)


// Patterns in Patterns Pwhite + Pduü + Pseq

~freqs = Pseq( [Pdup(1, Pwhite(500, 3000, 4)), 1000, 3000], inf ).asStream;

(
{
	inf.do{

		Synth(\snare, [\ffreq, ~freqs.next]);

		0.15.wait;

	}
}.fork;
)


// Wie ihr vielleicht merkt funktioniert das zwar ganz gut mit einem Argument.
// Doch was wenn wir mehrere gleichzeitig beeinflussen wollen ?
// Dafür gibt es eine mächtige Struktur in SuperCollider: Pbinds

// In Pbind bilden wir immer Paare aus einem Key und einem Pattern
// Die Keys sind zum einen die Parameter, welche wir in unserem SynthDef festlegen

// Weitere parktische keys wie \dur,  oder \instrument mit dem wir unseren Synth auswählen, kommen von Event
// Dieses bestimmt welche Aktionen als Antwort auf die uns bereits bekannt .play message ausgeführt werden sollen
// Pbind kombiniert also die Parameter unseres Synth und weitere nützliche Parameter aus Event zu einer Art Sequencer für unsere Synths bzw. Instrumente

(
Pbind(

	\instrument, \kick,
	\freq, Pseq([500, 3000], inf)

).play;
)


// Wie man sehen kann brauchen wir hier auch keine waits mehr
// Doch mit dem \dur aus Event können wir die Wartezeit bis zu unserem nächsten Schritt in unserer mit PBind erzeugten Sequenz festlegen

(
Pbind(

	\instrument, \kick,
	\freq, Pseq([500, 3000], inf),
	\dur, 1

).play;
)

// Zwei Pseqs mit unterschiedlichen Längen: Falls wir eine Länge an repeats angeben welche nicht "inf" ist
// Wird der Pbind beendet, sobald der erste Pseq beendet ist

(
Pbind(

	\instrument, \kick,
	\freq, Pseq([500, 3000], inf),
	\dur, Pseq([1/2, 1/4, 1/4], inf)

).play;
)

// ...Mit Patterns und Pbinds gibt es noch einiges ,was wir dieses Mal noch nicht geschafft haben, doch mehr dazu nächstes Mal !

// *** Jingle Bells FM Weihnachts Special ***

(
SynthDef(\bells, { |freq = 280|

	var snd, env, mod, car;

	env = EnvGen.ar(Env.perc(0.002, 5), doneAction: 2);
	mod = SinOsc.ar(280, mul: 190);
	car = SinOsc.ar(freq + mod);

	snd = car * env * 0.1;

	Out.ar(0, snd.dup)

}).add;
)

Synth(\bells);


(
~melody = [
	64, 64, 64,
	64, 64, 64,
	64, 67, 60, 62, 64
].midicps;
)

(
~durs = [
	1/4, 1/4, 1/2,
	1/4, 1/4, 1/2,
	1/4, 1/4, 1/4, 1/4, 1
]
)

(
Pbind(

	\instrument, \bells,
	\freq, Pseq(~melody, inf),
	\dur, Pseq(~durs, inf)

).play;
)














