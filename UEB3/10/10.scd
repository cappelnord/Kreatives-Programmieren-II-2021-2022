//  Starten wir mit einem einfachen Synth

(
SynthDef(\blip, { | freq = 220 |

	var snd, env;

	env = EnvGen.ar(Env.perc(0.01, 1), doneAction: 2);
	snd = Blip.ar(freq, 13) * env * 0.1;

	Out.ar(0, snd.dup)

}).add;
)

Synth(\blip, [\freq, 100]);


// Und spielen diesen über Pbind ab

(
Pbind(

	\instrument, \blip,
	\freq, Pseq([110, 120, 240], inf),
	\dur, 1/4

).play;
)


// Wollen wir Werte verändern, während wir das Pattern abspielen, fällt uns auf das immer eine neue Instanz ensteht:

s.plotTree;

(
Pbind(

	\instrument, \blip,
	\freq, Pseq([110, 120, 240], inf),
	\dur, 1/2

).play;
)


// Doch ähnlich wie wir das von Ndefs gewohnt sind, können wir auch Pattern unter einem Key ablegen
// Dazu gibt es Pdef

// Führen wir das Pattern nun mehrmals aus, adressieren wir immer die selbe Instanz

Pdef(\blips).play;
(
Pdef(\blips,
	Pbind(

		\instrument, \blip,
		\freq, Pseq([110, 120, 240], inf),
		\dur, 1/4

	)
);
)


// Bei Ndefs haben wir auf NodeProxy zurückgegriffen (Proxy == Platzhalter) um uns eine ProxyNode zu erstellen welche wir zur Laufzeit verändern und überschreiben können
// Pdef nutzt dazu EventPatternProxy

// Einige Konzepte die wir bereits bei Ndefs kennelernten können wir nun auch bei Pdefs anwenden

// Zum Beispiel können wir Patterns ineinander crossfaden:

Pdef(\blips).play;

Pdef(\blips).fadeTime = 4;

(
Pdef(\blips,
	Pbind(

		\instrument, \blip,
		\freq, Pseq([110, 120, 240], inf),
		\dur, 1/8

	)
);
)


// Ändern wir nun etwas in unserem Pattern und führen es aus, geschieht dies ab sofort mit fadeTime

(
Pdef(\blips,

	Pbind(
		\instrument, \blip,
		\freq, Pseq([110, 120, 240, 110], inf),
		\dur, 1/4
	)
);
)

// Side Note: Mit dieser einfachen Rechnung können wir übrigens die duration, welche in Sekunden angegeben wird, in BPM umrechnen
// So erhalten wir Viertel auf 150 BPM

(
Pdef(\blips,

	Pbind(
		\instrument, \blip,
		\freq, Pseq([110, 120, 240, 110], inf),
		\dur, 1/4 * ( 4 * 60 / 150)
	)

);
)


// Außerdem können Pdefs auch kopieren und untereinander synchronisieren

Pdef(\blips).quant = 1;
Pdef(\blips).play;

Pdef(\blips).copy(\blips2);


// detune wird immer auf die frequenz unseres synths addiert
// So also stimmen wir unser instrument im Pdef(\blips2) um 50 nach unten

Pdef(\blips2).set(\detune, -50);
Pdef(\blips2).play;

Pdef(\blips2).stop;
Pdef(\blips1).stop;


// .clear kennt ihr bereits schon

Pdef(\blips).clear;

// Mit Pdef.clear alle aktiven Pdefs clearen

Pdef.clear;


// .clear entfernt allerdings nicht unsere Pattern sondern setzt lediglich ihre source auf "silent"
// spielen wir den Pdef erneut ab stellen wir fest dass dieser immernoch detuned ist

Pdef(\blips).play;

Pdef(\blips).set(\detune, 30);

Pdef(\blips).clear;

(
Pdef(\blips,

	Pbind(
		\instrument, \blip,
		\freq, Pseq([110, 120, 240, 110], inf),
		\dur, 1/4 * ( 4 * 60 / 150)
	)

);

Pdef(\blips).play;
)


// Wollen wir den Pdef komplett entfernen können wir .remove nutzen

Pdef(\blips).play;

Pdef(\blips).set(\detune, 30);

Pdef(\blips).remove;


// Nun starten wir Pdef(\blips) als eine neue Instanz welche auch nicht mehr detuned ist

(
Pdef(\blips,

	Pbind(
		\instrument, \blip,
		\freq, Pseq([110, 120, 240, 110], inf),
		\dur, 1/4 * ( 4 * 60 / 150)
	)

);

Pdef(\blips).play;
)

Pdef(\blips).pause;
Pdef(\blips).play;


// Mit Pdef.removeAll können wir alle Instanzen löschen

Pdef.removeAll;


// PdefAllGui() gibt uns außerdem einen visuellen Überblick über unsere Pdefs
// Praktisch: hier können wir Pattern auch starten und stop (equivalent zu .play und .stop)

PdefAllGui()


// Zu guter Letzt noch 2 neue Pattern Objekte Pn in kombination mit Pgate

(
SynthDef(\blip, { |freq = 110, tune = 1|

	var snd, env;

	env = EnvGen.ar(Env.perc(0.01, 1), doneAction:2);
	snd = Blip.ar( freq * tune, XLine.kr(5, 50, 0.5)) * env * 0.1;

	Out.ar(0, snd.dup)

}).add;
)


// Sobald das Pattern in Pn neu gestartet wird der angegebene key (\tune) auf true gesetzt
// Sobald dies geschieht (und nur dann) fordert Pgate den nächsten Wert aus Pwhite an
// Somit klingt jeder durchlauf der in Pseq gesetzten Frequenzen etwas unterschiedlich detuned
// Innerhalb eines durchlaufs bleibt \tune jedoch immer konstant

(
Pdef(\gate,
	Pbind(

		\instrument, \blip,

		\freq, Pn(Pseq([120, 240, 50, 480]), inf, \nextTune),
		\tune, Pgate(Pwhite(0.5, 4), inf, \nextTune),

		\dur, 0.5

	)
).play;
)











