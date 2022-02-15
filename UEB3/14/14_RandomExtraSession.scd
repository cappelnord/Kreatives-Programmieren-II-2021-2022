
// LFNoise für Random auf ar / kr direkt in der Klangsynthese
(
{
	SinOsc.ar(440 + LFNoise1.ar(XLine.kr(1, 1000, 10)).range(30, 1000)) * 0.1 !2
}.play;
)


// Random Trigger Synth

// Hier nutzen wir einen control Bus um trigger auf control Rate von einem Synth zum anderen zu schicken

(
~bus1 = Bus.control(s, 2);

SynthDef(\triggerSend, { | freq = 1, outbus|

	var snd, gate;


	snd = Dust.kr(freq * [1, 1.1]);

	// Wir kennen Out breits um an den Hardwaroutput zu senden
	// Hier nutzen wir statt dem Hardwarebus (0) unseren controlBus
	Out.kr(outbus, snd);

}).add;

SynthDef(\triggerReceive, { |gatefreq = 1, triggerbus|

	var env, snd, gate;

	// So wie wir mit "Out" Signale aus unseren Synth senden, können wir diese mit "In" wieder abgreifen
	gate = In.kr(triggerbus, 2);

	// In EnvGen nutzen wir das gate um die Envelope zu triggern
	env = EnvGen.ar(Env.perc(0.01, 1), gate, doneAction: 0);
	snd = WhiteNoise.ar(0.1).dup * env;

	// Diesmal senden wir an unseren Hardware Output
	Out.ar(0, snd);

}).add;
)


// Nun müssen wir nur noch unseren control Bus also Output des Senders und als Input des Empfängers angeben

// ACHTUNG: Bei Bussen gilt es immer die Ausführreihenfolge zu beachten
// Denn obwohl wir eine Synth Instanz eine Zeile später adden, wird diese standartmäßig am Anfang der Reihenfolge eingefügt.
// In diesem Fall wollen wir aber das der Empfänger logischerweise NACH dem Sender ausgeführt wird
// Daher ändern wir seine addAction auf \addToTail
// Standartmäßig ist diese auf \addToHead also jeder neue Synth wird oben bzw. am Anfang der Reihenfolge eingefügt
// Am besten ihr beobachten den Unterschied im plotTree:
s.plotTree;

(
Synth(\triggerSend, [\outbus, ~bus1]);

Synth(\trigger, [\triggerbus, ~bus1], addAction: \addToTail);
)


// Random Arrays für Klangsynthese und / oder Patterns

10.collect{ |i| i.postln;  i.rand};

{10.rand} ! 10;

{rrand(0.1, 0.9)} ! 10;

{SinOsc.ar( 100 * {rrand(1, 50)} ! 10).sum.dup  * 0.01} .play;

(
Pdef(\k,

	Pbind(
		\dur, 0.5,
		\degree, Pseq({rrand(0, 10)} ! 10, inf)
	)

).play;
)

// Hier wird jede sekunde (1.wait) neu aus einer Liste aus Arrays gewählt
// Bei Tdef können wir ähnlich wie bei Pdef Dinge unter einem Key ablegen
// Nur sind es diesmal keine Pattern sondern Tasks (sehr ähnlich zu Routinen )

(
Tdef(\x, {
	loop{

		~chooseList = [[3, 2, 5, 6],[2,5,7], [1, 2, 3]].choose;

		Pdef(\k,
			Pbind(
				\dur, 0.25,
				\degree, Pseq(~chooseList, inf)
			)
		);

		1.wait;
	}
}).play;

Pdef(\k).play;
)

// Stoppen wir den Tdef stoppt der loop des auswählens und der Pdef wiederholt die selbe Liste endlos
Tdef(\x).stop;

Pdef(\k).stop;


// Aus der Help: Nach jedem durchlauf von Pseq wird random transponiert

(
Pbind(
    \degree, Pn(Pseq((0..7)), inf, \step),
    \mtranspose, Pgate(Pwhite(0,5), inf, \step),
    \dur, 0.2
).play
)
