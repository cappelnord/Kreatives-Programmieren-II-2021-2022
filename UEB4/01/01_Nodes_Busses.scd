
// Kleines Recap zu der Verwendung von Ndefs in Ndefs
// Diesmal mit Select


Ndef(\x, {SinOsc.ar([100, 101] * 6) * 0.1});
Ndef(\y, {SinOsc.ar([300, 301]) * 0.1});
Ndef(\z, {Pulse.ar([50, 51]) * 0.1});


// Mit Select kann zwischen verschiedenen Inputs ausgewählt werden
// Die Auswahl bestimmt der Index der in diesem Beispiel mit einem Sinus moduliert wird

(
Ndef(\mix, {

	var snd = Select.ar(SinOsc.kr(0.5).range(0,3), [Ndef(\x), Ndef(\y), Ndef(\z)], LFNoise1.kr(10).range(0.1, 3));
	snd;

}).play;

Ndef(\mix).quant = 1;
)

// SelectX kann zwischen unseren Quellen Crossfaden

(
Ndef(\mixFocus, {

	var snd = SelectX.ar(SinOsc.kr(0.5).range(0,3), [Ndef(\x), Ndef(\y), Ndef(\z)]);
	snd;

}).play;
)

// Und SelextXFocus zusätzlich die stärke des CrossFades beeinflussen:
// Je kleiner der Focus, desto "fuzzy" die Auswahl

(
Ndef(\mixFocus, {

	var snd = SelectXFocus.ar(SinOsc.kr(0.5).range(0,3), [Ndef(\x), Ndef(\y), Ndef(\z)], focus: 0.5);
	snd = CombC.ar(snd, decaytime: 3.0, add: snd * 0.5);
	snd;

}).play;
)

// LFNoise1 moduliert den Focus

(
Ndef(\mixFocus, {

	var snd = SelectXFocus.ar(SinOsc.kr(0.5).range(0,3), [Ndef(\x), Ndef(\y), Ndef(\z)], LFNoise1.kr(10).range(0.1, 3));

	snd;

}).play;
)

Ndef(\mixFocus).fadeTime = 4;
Ndef(\mixFocus).free;

// Sobald wir unseren mix Ndef quantisiert haben können wir diesen dann auch mit Synths und Pdef synchronisieren:

(
SynthDef(\kick, {

	var env = EnvGen.ar(Env.perc(0.001, 0.5), doneAction: 2);
	var snd = SinOsc.ar(XLine.kr(300, 50, 0.05)) * 0.1 * env;

	Out.ar(0, snd.dup);

}).add;
)

(
Pdef(\k,
	Pbind(
		\instrument, \kick,
		\dur, 0.5
	)
)
)

Pdef(\k).quant = 1;
Pdef(\k).play

Ndef(\mixFocus).quant = 1;
Ndef(\mixFocus).play;


// Busse und Ausführeihenfolge auf dem Server:



s.plotTree;
s.queryAllNodes;

// Language vs Server

(
SynthDef(\sine, { |freq = 100, start = 100, end = 500|

	var snd = SinOsc.ar(XLine.kr(start, end, 10)) * 0.1;
	Out.ar(0, snd.dup);
}).add;
)

Synth(\sine, [\freq, XLine.kr(100, 500, 5)]);

Synth(\sine, [\start, 100, \end, 500]);

// Kleines Beispiel zur sc-synth | sc-lang Kommuikation:
// Nicht möglich da der UGen "Bauplan" (SynthDef) des Synths bereits abgeschlossen ist. Dort ist kein XLine enthalten.
(
SynthDef(\line, { |freq|
	var snd = SinOsc.ar(freq);
	Out.ar(0, snd *0.5);
}).add;
)

Synth(\line, [\freq, XLine.kr(1,10,2)]);

// Eine Lösung: Nun ist unser XLine mit dabei und wir können es über Argumente ansteuern
(
SynthDef(\line, { |start, end, dur |
	var snd = SinOsc.ar(XLine.kr(start, end, dur));
	Out.ar(0, snd * 0.5);
}).add;
)

(
x = Synth(\line, [
	\start, 50,
	\end, 500,
	\dur, 5	]);
)


// Bus und die Ausführreihenfolge des Servers

// Ein Bus ist ein kleiner Bereich im Speicher an dem samples abgelegt werden können.

/*
/              1-Block (64-samples)          \
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||  AudioRate :  64 Werte
                             1 Value                    ControlRate: 1 Wert
*/

// Diese Buse sind per Default für die Systemhardware vorgesehen

// Default Options
o = Server.default.options;

// Output Channesl Ansehen und Verändern
o.numOutputBusChannels;
o.numOutputBusChannels = 2; // 0 L, 1R

// Input Bus
o.numInputBusChannels ;

o.numInputBusChannels;


// Alle weiteren Buse stehen frei für internes Routing, das keinen direkten Input / Output mit der SystemHardware hat.

~busAudio = Bus.audio(s, 1); // Audio Bus mit einem Kanal
~busControl = Bus.control(s); // Control Rate Bus

// 2Channel Audio Bus
~busAudio = Bus.audio(s);


// Jeder Bus erhält einem Index unter dem er auf unserem Server addressierbar ist

~busAudio.index;

// Innerhalb der Language braucht uns dieser Index erst einmal nicht zu kümmern
// Denn wir können einfach den Namen verwenden unter dem wir den Bus erstellt haben
~busAudio;

// Dieser Name existiert jedoch nicht auf dem Sever sondern nur in unserer Language
// Wollten wir also zusammen einen Server für die Klangsynthese nutzen, und auf dem selben Bus zugreifen
// Wäre hier also der Index gefragt

(
SynthDef(\input, { |freq = 2, start = 100, end = 500|

	var snd = SinOsc.ar(LFNoise1.kr(freq).range(100, 800)) * 0.1;
	Out.ar(~fxBus, snd.dup);
	//Out.kr(~fxBus, snd.dup);

}).add;
)

(
SynthDef(\fx, { |freq = 100, start = 100, end = 500|

	var in = In.ar(~fxBus, 2);
	var snd = Clip.ar(in * 50) * 0.1;
	Out.ar(0, snd);

}).add;
)

~fxBus.get({|val| val.postln;});


// Wir wir hören, hören wir nichts...
(
Synth(\input);
Synth(\fx);
)

// Den Node Tree haben wir uns bereits ein paar mal angeschaut:
//  Er bestimmt in welcher Reihenfolge sich Supercollider durch die synth nodes arbeitet
//  Die Synth die wir verwenden repräsentieren eine Synth Node auf dem Server
// SynthDef und Synth sind dabei einfach Funktionlitäten aus der Language
// Um zunächst den Bauplan eines Synths unseren Server zu übergeben
// --> SynthDef({...}).add;
// Und diesen dann als Synth Node auf dem Server zu adden und abzuspielen
// --> Synth([\freq, 440])

// Hier sehen wir die tatsächliche reihenfolge

s.plotTree;


// Konkret gilt für diese Reihenfolger: Synth_fx welcher Synth_input als input hat, muss nach Synth_input ausgeführt werden !
// Die Anordnugn der Synth Nodes können wir aber auch beeinflussen
// Und zwar mit addActions

// Die doneActions kennen wir bereits von den Envelopes:

{PinkNoise.ar(0.5) * Line.kr(1,0,2,doneAction: Done.freeSelf)}.play.onFree {"done".postln};

// Die addActions sind quasi das Pendant dazu
// Dh sie bestimmen nicht was passiert wenn ein Vorgang abgeschlossen ist
// Sondern das wenn er beginnt, bzw wenn der Synth als Node auf unserem Server geaddet wird
// Standartmäßig wird einen neuer Synth immer oben in unsere Ausführeihenfolge eingefügt
// Daher kommt es auch, dass diese Reihenfolge nicht immer ganz unseren Vortellungen entsprechen mag:

(
Synth(\input, [\freq, 4], addAction: 'addToHead');
Synth(\fx, addAction: 'addToHead');

s.plotTree;
)

// Mit der addAction addToTail können wir die Synth Nodes nacheinander anhängen

(
Synth(\input, [\freq, 4], addAction: 'addToTail');
Synth(\fx, addAction: 'addToTail');

s.plotTree;
)

// Mit Gruppen lässt sich dann auch für mehrere Synth bzw. Nodes sicherstellen,
// dass sie vor einer bestimmten anderen Gruppe von Synths ausgeführt wird

~synthgroup = Group.new(s);
~fxgroup =  Group.tail;

Synth(\input, [\freq, 0.1], ~synthgroup);
Synth(\fx, target: ~fxgroup);

Synth(\input, [\freq, 1], ~synthgroup);


// Übrigens:
// Überlicherweise werden alle Nodes, die nicht weiter spezifiziert ist in der Default Group ausgeführt.
// Dadurch ist sichergestellt das Funktionen wie s.record oder s.scope an der richtigen Stelle ausgeführt wird
// Also immer nach der default Group
// Mehr dazu siehe Doku => Default Group

s.plotTree;
s.scope;
s.freqscope;



