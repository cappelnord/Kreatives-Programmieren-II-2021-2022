// New Stuff: SynthDefs !

// Mit Ndefs haben wir uns ja die letzte Zeit uns ausgibieg beschäftigt
// Ähnlich wie bei Ndefs legen wir bei SynthDefs ein Objekt oder besser gesagt Instrument unter einem Key ab

// Der größte Unterschied zu Ndefs ist allerdings, dass jeder Synth eine neue Instanz unseres Instruments repräsentiert

// Dies geschieht indem wir die Synths zunächst mithilfe von SynthDef als eine Art Bauplan für unser Instrument definieren

SynthDef(\empty, { }).add; // Mit .add übergeben wir unseren Bauplan dem Server


// Um uns daraufhin eine Instanz dieses Insturments aufzurufen

Synth(\empty);

s.plotTree;




// Im plotTree können wir beobachten dass beim mehrmaligen ausführen des Synths jedes mal eine neue Instanz angemeldet wird
// Im Gegensatz dazu wird die Source unseres Ndefs jedes mal ersetzt

Ndef(\empty, {});

Synth(\empty);

s.plotTree;



// Ähnlich wie bei Ndefs auch, können wir in unserem SynthDef nun festlegen, wie uns Instrument aufgebaut sein wird
// Das was wir eben noch leer gelassen haben ist der Body unseres Synths, die Unit Generator Graph Function.
// Dort wird festgelegt, wie die Ugens unseres Synths untereinander verknüpft sind.


// Zusätzlich können wir die Input und Output Busse unseres Synths festlegen
// Dies geschieht mit In.ar und Out.ar. Zunächst wollen wir uns nur Synths erstellen, welche Sound Output liefern.
// Daher brauchen wir erstmal nur Out.ar

In.ar();
Out.ar();


// Out.ar verlangt nach einem bus und einem channelsArray
// Als Bus übergeben wir ihm 0 dieser führt zu unserem Hardware Output zu sehen hier:

s.outputBus;


// Das channelsArray sind die Kanäle, welche wir diesem Bus übergeben wollen, also die 2 Kanäle aus unserem Splay

(
SynthDef(\fibo, { | freq = 60, numFibs = 10, amp = 1, spread = 1 |

	var snd, mod, lfo;

	lfo = SinOsc.kr(0.1).range(1, 20);
	mod = LFTri.ar( lfo, mul: 12pi);
	snd = SinOsc.ar(freq *  Array.fib(10, 0, 1 ), mod) * 0.02;

	snd = Splay.ar(snd, spread);

	Out.ar(0, snd * amp);

}).add;
)


// Führen wir den Synth nun mehrmals aus können wir hören wie sich mehrere Instanzen unseres Instruments überlagern
// Die Phasenmodulation für jeden einzelnen Synth startett unabhängig der bereits laufenden Synths immer wieder von 0

Synth(\fibo);



// Das ganze addiert sich allerdings sehr schnell in der Lautstärke und bis wir alles auf einmal beenden, tröten all Instanzen endlos vor sich hin....

// Doch wie können wir die Lautstärke unseres Synths über die Zeit genauer kontrollieren ?
// Dazu dienen uns Hüllkurven / Envelopes !

// Anstatt nun unsere Ampltiude wie gewohnt mit lfos über die Zeit zu steuern,
// wollen wir das nun mit einer Kurve machen

// In SuperCollider haben wir eine große Bandbreite an Möglichkeiten wie wir uns diese erstellen können

// Mit dem Env Objekt können wir uns mithilfe von zwei Arrays eine Custom Envelope erstellen
// Dabei geben wir in unserem ersten Array 'levels' die y-Werte unsere Kurve an.

// Im zweiten Array 'times' bestimmen wir wieviel Zeit zwischen diesen Werten vergehen soll.
// Hier haben wir nun eine Kurve mit 2 Segmenten: 1. Segment von 0 bis 1, 2. Segment von 1 bis 0

Env([0, 1, 0],[0.1, 3]).plot;


// Zusätzlich können wir mit dem curve Argument festlegen, wie der Form der Kurve innerhalb der Segmente aussehen wird
// bzw. wie wir zwischen einzelnen y-Werten Interpolieren wollen

Env([0, 1, 0],[0.1, 3], \linear).plot;

Env([0, 1, 0],[0.1, 3], \squared).plot;

Env([0, 1, 0],[0.1, 3], \sin).plot;




// Nun wollen wir mithilfe dieser Kurven die Lautstärker also die Amplitude unseres Synths steuern
// Ein Problem gibt es jedoch noch:
// Damit wir dies tun können müssen die Werte unsere Kurve auf Sample Ebene, zur Laufzeit mit unserem Signal multipliziert werden
// Genauso wie wir es auch mit lfos gewohnt sind:

{ SinOsc.ar(440) * SinOsc.kr(1) * 0.1 }.play;


// Hier steuern wie die Amplitude über Zeit mithilfe eines Sinus auf control rate

{ SinOsc.ar(440) * SinOsc.kr(1) * 0.1 }.play;


// Wollen wir das auch mit unserer Envelope machen, brauchen wir dazu EnvGen
// Dieses Ugen spielt unsere Hüllkurve auf audio / control Rate ab

~myEnv = Env([0, 1, 0],[0.1, 3], \linear);
{ EnvGen.ar(~myEnv).poll }.play;


// Nun können wir unserer Hüllkurve auf control Rate mit unserem Sinus multiplizieren

{ SinOsc.ar(440) * EnvGen.ar(~myEnv) * 0.1 }.play;



// Bauen wir das Ganze nun in unseren Synth ein

(
SynthDef(\fibo, { | freq = 60, numFibs = 10, amp = 1, spread = 1, attack |

	var mod = LFTri.ar( SinOsc.kr(0.1).range(1, 20), mul: 12pi);
	var snd = SinOsc.ar(freq *  Array.fib(10, 0, 1 ), mod) * 0.02;
	var levels = [0, 1, 0.75, 0];
	var times = [attack, 0.25, 0.5];

	var env = EnvGen.kr( Env(levels, times, \squared));

	snd = Splay.ar(snd, spread);

	snd = JPverb.ar(snd, 0.2) * 0.5 + snd;
	snd = snd * env;

	Out.ar(0, snd * amp);

}).add;
)

s.plotTree;
Synth(\fibo);


// Beobachter des plotTrees fällt allerdings schnell auf:
// Unsere Evenlope Erreicht ihren letzten Wert 0, wir hören also nichts
// Doch die Instanz unseres Synths besteht trotzdem weiter !
// Dieser Synth arbeitet zusätzlich mit Reverb welcher die CPU merklich belastet
// Es kann also durchaus passieren dass unser Server überlastet ohne das wir überhaupt etwas hören


// Abhilfe hierbei schaffen doneActions:
// Hier können wir festlegen was geschieht wenn ein Ugen zu ende abgespielt wurde
// Ein Integer wert bestimmt hierbei welche Aktion ausgeführt werden soll.
// Eine Überischt findet ihr unter der Help zu >> Done <<
// Wir werden in Zukunft dieses Thema noch genauer behandeln
// Momentan interessiert uns nur die doneAction: freeSelf mit dem Integerwert 2
// Dort steht: free the enclosing synth, also genau das was wir brauchen !


// Standartmäßig ist unsere doneAction auf 0 'do nothing when the UGen is finished'

s.plotTree;

~myEnv = Env([0, 1, 0],[0.1, 3], \linear);

{ EnvGen.ar(~myEnv, doneAction: 0).poll }.play;



// Unterschied sowohl im Post Window und im plotTree mit doneAction:2

~myEnv = Env([0, 1, 0],[0.1, 3], \linear);

{ EnvGen.ar(~myEnv, doneAction: 2).poll }.play;



// Nun zu unserem Synth:

(
SynthDef(\fibo, { | freq = 60, numFibs = 10, amp = 1, spread = 1, attack = 0.01, release = 0.5 |

	var mod = LFTri.ar( SinOsc.kr(0.1).range(1, 20), mul: 12pi);
	var snd = SinOsc.ar(freq *  Array.fib(10, 0, 1 ), mod) * 0.02;
	var levels = [0, 1, 0.75, 0];
	var times = [attack, 0.25, release];

	var env = EnvGen.kr( Env(levels, times, \squared), doneAction: 2);

	snd = Splay.ar(snd, spread);

	snd = JPverb.ar(snd, 0.2) * 0.5 + snd;
	snd = snd * env;

	Out.ar(0, snd * amp);

}).add;
)

s.plotTree;
Synth(\fibo);


// Dawir uns jedes mal unterschiedliche Instanzen eines Synths aufrufen,
// Macht es natürlich auch Sinn unterschiedliche Parameter zu setzen

// Bei Synth können wir aber auch Parameter direkt bei der erstellung der Instanz als Array von Wertepaaren übergeben

(
Synth(\fibo, [
	\freq, 550.rand,
	\numFibs, 5.rand,
	\attack, 0.2.rand
]);
)

// Wollen wir wie gewohnt die Parameter laufender Instanzen verändern, helfen uns hierbei Variablen:

(
~fibo1 = Synth(\fibo, [
	\freq, 550.rand,
	\numFibs, 5.rand,
	\attack, 0.2.rand,
	\release, 20
]);

~fibo2 = Synth(\fibo, [
	\freq, 550.rand,
	\numFibs, 5.rand,
	\attack, 0.2.rand,
	\release, 20
]);
)

~fibo1.set(\freq, 2000.rand);

~fibo2.set(\freq, 200.rand);















