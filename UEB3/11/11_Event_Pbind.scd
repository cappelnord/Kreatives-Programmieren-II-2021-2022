// Pbind und Event:


// Pbind und Event

// Wiederholung Streams

x = Pwhite(1, 10, inf).asStream;

x.next;
x.nextN(10);


// Ein Pbind weißt den .next Wert seiner Pattern einen Key zu

// Das heißt wenn wir einen Pbind stream nach seinem
// nächsten Wert abfragen würde kein einzelner Wert,
// sondern ein Wertepaar wie in einem Dictonary ausgegeben werden.

// Diese Wertepaar ist ein Objekt namens Event
// Event erbt von seiner Superklasse Dictionary

// Nehmen wir das Event getrennt von Pbind,
// haben wir eine sammlung an (key : value) Paaren wie in einem DIctionary

e = (freq: 440, dur: 1);

// auf Values über den Key zugreifen

e.at(\freq);
e[\freq];
e.freq;

// Values verändern und hinzufügen

e.put(\freq, 220);
e.freq;

e.put(\amp, 0.1);
e.amp;


// Events haben sog. Event prototypes

// Meistens nutzen wir hierbei den default event prototype (Event.default)
// Im default Event prototype sind wiederum verschiedene event types definiert

// Von dort (nicht von Pbind !) kommen dann auch nützliche Parameter die wir bereits kennen wir \dur
// Wenn wir also mit dem \dur Parameter innerhalb unseres Pbind arbeiten,
//  überschreiben wir den default Parameter in Event.default:

(
~testEvent = Pbind(

	\dur, 0.5

).asStream;
)

~testEvent.next((Event.new));


// Output von Pbinds

// Pbinds holen sich den nächsten Wert ihrer Pattern
// Und machten aus ihnen mit ihrem jeweiligen key (\degree, \dur) ein Event
// Wenn alle Paare im Pbind abgearbeitet sind ist das Event komplett

x = Pseq([1, 2, 3, 4], inf).asStream;

x.next;

(
~testbind = Pbind(

	\someValue, Pseq([1, 2, 3, 4], inf),
	\dur, Pseq([0.5, 1], inf),

).asStream;
)

~testbind.next((Event.new));


// Wenn wir nun ~texbind.next mehrmals Ausführen bekommen wir je nach Pattern unterschiedlich Wertepaare

// Doch was ist nun der Unterschied  zwischen einem Event und einem Dictionary ?
// Kurze Antwort: Wir können Events abspielen.
// --> Events haben eine Funktion aus event Prototype die auf eine .play
// message antwortet und in der festgelegt ist, was daraufhin geschehen soll:

( 'degree': 0, 'dur': 0.5 ).play;

( 'degree': 2, 'dur': 2).play;


// Dem Pbind ist es grundsätzlich erst einmal egal wie wir unsere Parameter nennen, seine Aufgabe besteht darin,
// Werte unter einem Key als ein Event auszugeben
// Das Event wiederum reagiert auf .play und überschreibt entsprechende keys in Event.default

// Wenn wir einen Pbind abspielen erhalten wir einen EventStreamPlayer, eine Reihe an Events
// auf denen die .play Methode angewandt wird

(
Pbind(

	\dur, 0.5,
	\freq, Pwhite(120, 120 * 8)

).play
)


// Event.default


// Spielen wir einen leeren Pbind ab, merken wir auch, dass wir Sound hören,
// ohne einen Instrument / Synth unter dem \instrument Key anzugeben

Pbind().play;


// Das liegt daran, dass wir mit dem \insturment Parameter den default Synth welcher in Event.sc festgelegt ist überschreiben
// Übergeben wir also keinen Synth unter \instrument, erzeugt der Pbind ein EventStreamPlayer aus Events,
// welche auf die .play Methode den default Synth mit seinen default Werten abspielen
// Der sieht übrigens so aus:

(
SynthDef(\default, { arg out=0, freq=440, amp=0.1, pan=0, gate=1;
	var z;
	z = LPF.ar(
		Mix.new(VarSaw.ar(freq + [0, Rand(-0.4,0.0), Rand(0.0,0.4)], 0, 0.3)),
		XLine.kr(Rand(4000,5000), Rand(2500,3200), 1)
	) * Linen.kr(gate, 0.01, 0.7, 0.3, 2);
	OffsetOut.ar(out, Pan2.ar(z, pan, amp));
}, [\ir]);
)

Synth(\default);


// Der Output passt allerdings noch nicht so ganz zum dem was wir hören,
// Wenn wir den Pbind abspielen

Pbind().play;


// Das liegt daran dass das default Event dem Synth noch weitere Parameter übrgibt,
// Die hier noch nicht berücksichtig sind

// Hier der Beweis dass es sich um den selben Synth handelt

Pbind(\instrument, \default).play;

// Zwei wichtige Komponenten sind hierbei Zeit und Tonhöhe / Pitch !



// PITCH

// Im default Event ist multilevel Modell, das pitch model implementiert
// Im low-level Bereich, steuern wir die Frequenz des Synths direkt:

(
Pbind(

    \dur, 0.25,
    \freq, Pseq([300, 400, 500, 700, 900], inf)

).play;
)


// Wir haben auch schonmal etwas mit \detune gemacht
// detune arbeiten auf dem selben level wie \freq doch zu einem späteren Zeitpunkt
// Nachdem wir freq gesetzt haben wird der \detune Wert auf die Frequenz addiert:

(
Pbind(

    \dur, 0.25,
    \freq, Pseq([300, 400, 500, 700, 900], inf),
	\detune, 20

).play;
)

(
Pbind(

    \dur, 0.25,
    \freq, Pseq([300, 400, 500, 700, 900], inf),
	\detune, -50

).play;
)

// Im nächsten Level befindet sich \midinote
// Dass default binding für freq, ist wiederum eine Funktion welche diese midinote + transpose value in eine Frequenz umrechnet:

~freq = {
	(~midinote.value + ~ctranspose).midicps;
};

(
Pbind(

    \dur, 0.25,
	\midinote, Pseq([60, 61, 62, 67, 68], inf),

).play;
)

// Dieser wiederum berechnet sich wie folgt:

~midinote = {
	(~note.value + ~gtranspose + (~octave * divs) + ~root)
	* 12.0 / ~stepsPerOctave;
};


// Die \note values berufen wie sich dabei immer auf die Tonschritte einer gleichstufigen Stimmung

// Dabei müssen wir die Oktave alerdings nicht zwingend in 12 Tonschritte unterteilen
// Denn stepsPerOctave erlaubt es uns, eigene Tonabstände innerhalb eine Oktave zu definieren:

(
Pbind(

    \dur, 0.5,
	\octave, Pseq([3,4, 5], inf),
	\note, Pseq([1, 2, 6], inf),
	\stepsPerOctave, 9

).play;
)

// \note wiederum setzt sich wie folgt zusammen:

~note = {
	var divs;
	divs = ~stepsPerOctave;
	(~degree + ~mtranspose).degreeToKey(~scale, divs);
};


(
Pbind(

    \dur, 0.5,
	\degree, Pseq([1,2, 3], inf)

).play;
)

// degree bezieht sich also schon auf eine Stufe innerhalb einer Tonleiter (\scale)
// bei einer diatonischen Dur Tonleiter wäre \scale also [0, 2, 4, 5, 7, 9, 11]
// Wir können die \scale aber auch neu definieren:

(
Pbind(

    \dur, 0.5,
	\degree, Pseq([0,2, 3], inf),
	\scale, [0, 2, 4, 1]

).play;
)

// DURATION

// Zusätzlich zur bereits bekannten Dauer unter \dur

(
Pbind(

	\dur, Pseq([0.5, 1, 0.25, 0.25], inf),
	\midinote, Pseq([42, 50, 51, 45], inf)

).play;
)


// können wir notenlängen einen \legato Wert übergeben
// dieser wird mit der notenlänge mutipliziert um der Aushaltedauer \sustain zu erhalten

(
Pbind(

   \dur, Pseq([0.5, 1, 0.25, 0.25], inf),
	\legato, Pseq([0.1, 1, 0.5, 0.1], inf),
	\midinote, Pseq([42, 50, 51, 45], inf)

).play;
)


// Vorteile der verschiedenen Abstraktionsebenen ist, dass egal welchen Parameter wir verändern,
// am Ende wird einfach nur der \freq Parameter gesetzt und jeder Synth mit einen freq Argument
// kann also aauf keys wie \midinote oder \degree entsprechend abgespielt werden

// Wenn wir unserem wenn wir unserem Pbind nun einen eigenen Synth übergeben,
// macht es also Sinn, sich an bestimmte Namenskonventionen zu halten.
// Vor allem wenn wir wollen, dass Parameter wie \midinote auch auf unseren eignen Synth anwendbar sind

(
SynthDef(\stSine,{ | freq = 440, amp = 0.2 |

	var snd, env;

	env = EnvGen.ar(Env.perc(0.01, 1), doneAction: 2);
	snd = SinOsc.ar([freq, freq * 1.01])  * env;

	Out.ar(0, snd * amp);

}).add;
)


// Dadurch dass wir ein freq argument gesetzt haben und \midinote letzten Endes in \freq umgerechnet wird
// Können wir dem Pbind \midinote übergeben
// Event.default berechnet uns daraus den Frequenzwert
// Und überschreibt das freq Argument in unserem Synth

(
Pbind(

	\instrument, \stSine,
	\midinote, Pseq([60, 64, 65, 64], inf),
	\dur, 0.25,

).play;
)


// Wollen wir nun auch \legato benutzen, sollten wir unsere envelope in unserem Synth darauf anpassen

// Dazu brauchen wir zwei Parameter gate und sustain
// --> Wir erinner uns das der \sustain wert aus legato berechnet wird

// Hierzu eignet sich Linen ein linearer envelope generator dessen asr Envelope über ein gate getriggert wird

(
SynthDef(\stSine,{ | freq = 440, amp = 0.2, sustain = 1, gate = 1 |

	var snd, env;

	env = Linen.kr(gate, 0.01, sustain, 0.5, doneAction:2);
	snd = SinOsc.ar([freq, freq * 1.01])  * env;

	Out.ar(0, snd * amp);

}).add;
)

(
Pbind(

	\instrument, \stSine,
	\midinote, Pseq([60, 64, 65, 64], inf),
	\dur, 0.25,
	\legato, Pseq([0.1, 1, 0.5, 0.1], inf)

).play;
)


// Weitere Keys und deren Zusammenhang zu Event sind in der Help unter
Event  //--> Useful keys for notes

// Schaut auch mal in
Understanding Streams, Patterns and Events // Insbesondere hierzu Part 5 - Event.default










