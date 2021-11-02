// Wiederholung Amplitudenmodulation

(
Ndef(\mod, { |freq = 440|
	var snd = SinOsc.ar(freq) * 0.1 * SinOsc.kr(40);
	snd;

});
Ndef(\mod).play;
)


// Wollen wir einen bereits ausgeführten Ndef von Mono in Stereo umwandeln, müssen wir ihn zunächst clearen da dessen Referenz noch in Mono vorliegt
// Im Postwindow: "Ndef('mod'): wrapped channels from 2 to 1 channels"

Ndef(\mod).clear

(
Ndef(\mod, { |freq = 440|

	var snd = SinOsc.ar(freq) * 0.1 * SinOsc.kr(40);
	snd.dup;
});

Ndef(\mod).play;
)

Ndef(\mod).fadeTime = 4;
Ndef(\mod).set(\freq, 250);


// Wiederholung Multichannel Expansion:
// Multichannel Expansion tritt auch dann ein wenn wir dem modulator ein Array an argumenten Übergeben:

(
Ndef(\modStereo, { |freq = 440|

	var snd = SinOsc.ar(freq) * 0.1 * SinOsc.ar([1, 1.5]);
	snd;

});

Ndef(\modStereo).fadeTime = 2;
Ndef(\modStereo).play;
)


// Hier noch einmal ein Mixdown mit längerem Array und .sum
// Hier bitter auch darauf achten das sich natürlich auch die Lautstärker addiert
// Daher sollten wir die Amplitude stets mit sehr niedrigen Werten multiplizieren !
// Man kann hier deutlich hören, wann sich die Amplituden synchronisieren und addieren:

(
Ndef(\modSum, { |freq = 440|
	(SinOsc.ar(freq) * 0.04 * SinOsc.ar([1, 1.5, 2, 2.5, 3, 3.5])).sum.dup;
});

Ndef(\modSum).fadeTime = 2;
Ndef(\modSum).play;
)

s.meter;


// Alternativ

(
Ndef(\modSum, { |freq = 440|

	Mix.ar(SinOsc.ar(freq) * 0.05 * SinOsc.ar([1, 1.5, 2, 2.5, 3, 3.5])).dup;
});

Ndef(\modSum).play;
)


// Mit Pan2 können wir Mono Signale in unserem Stereobild plazieren

(
Ndef(\modMulti, {

	var snd = SinOsc.ar(440) * 0.05 * SinOsc.kr([1, 1.5, 2, 2.5, 3, 4.5, 5]);
	Pan2.ar(snd.sum, pos: -1);

}).play;
)

(
Ndef(\modMulti, {

	var snd = SinOsc.ar(440) * 0.05 * SinOsc.kr([1, 1.5, 2, 2.5, 3, 4.5, 5]);
	Pan2.ar(snd.sum, pos: 1);

}).play;
)

// Das Ganze geht dann natürlich auch mit einen LFO
// Denn dieser erzeugt und Werte abhängig zu seiner Amplitude,
// also standartmäßig von -1 bis  +1. Das können wir uns zu Nutze machen,
// indem wir die Amplitude durch multiplikation beeinflussen
// So bewirkt  * 0.5 das auch unsere Autopan eingeschränkt wird die Positionen zwischen -0.5 und +0.5 abbildet
// -1 ist hier immer ganz Links und +1 ganz Rechts

(
Ndef(\modMulti, {

	var snd = SinOsc.ar(440) * 0.05 * SinOsc.kr([1, 1.5, 2, 2.5, 3, 4.5, 5]);
	Pan2.ar(snd.sum, SinOsc.kr(0.5, mul: 0.5));

}).play;
)

// Mehr zu Arrays:

// Arrays können wir uns auch mit einigen nützlichen Funktionen erstellen lassen
// Wir erstellen ein Array der Größe zehn dessen inhalt mit stepsize: 1 von start: 0 hochzählt

Array.series(10,start: 0, stepsize: 1);


// Mit dieser Funktion könnten wir unseren modSum Ndef also auch einfach so schreiben:

(
Ndef(\modSum, { |freq = 440|

	SinOsc.ar(freq) * 0.01 * SinOsc.ar(Array.series(6, 1, 0.5)).sum.dup;
});

Ndef(\modSum).play;
)

// Dadurch können wir mit relativ wenig Code eine große Klangfülle erreichen
(
~clustersize = 30;

Ndef(\sum, {

	var snd, mod;

	mod = SinOsc.ar(Array.series(~clustersize, 60, 1/3));
	snd = SinOsc.ar(Array.series(~clustersize, 60, 50)) * mod;

	snd.sum.dup * 0.002;
});

Ndef(\sum).play;
)

// Wollen wir bei bei unserer Klangsynthese mit Akkorden arbeiten können wir auch .midicps verwenden
// um eine MidiNoteNumber in ihre Frequenz umzurechnen

69.midicps;
32.midicps;


// Hier einzelne MidiNotenumbers verändern für dramtische Crossfades :)

Ndef(\chord).fadeTime = 4;
Ndef(\chord, { Saw.ar([64.midicps, 67.midicps, 70.midicps]).sum.dup } * 0.1).play;


// Aus unserem Frequenz Cluster können wir nun mit .midicps einen Halbton Cluster
// erstellen, welcher sich gleichmäßiger über das (Hör)Spektrum verteilt

(
~clustersize = 30;

Ndef(\sum, {

	var mod = SinOsc.ar(Array.series(~clustersize, 60, 1/3));
	var snd = SinOsc.ar(Array.series(~clustersize, 56, 1).midicps);

	(snd * mod).sum.dup * 0.002;
});
)

Ndef(\sum).play;


// zum Vergleich nochmal das selbe aber diesmal mit Splay

(
Ndef(\sPlay, {

	var mod = SinOsc.ar(Array.series(~clustersize, 60, 1/3));
	var snd = SinOsc.ar(Array.series(~clustersize, 56, 1).midicps);

	Splay.ar((snd * mod).sum) * 0.002;
});

Ndef(\sPlay).play;
)


// Mit zusätzlicher Frequenzmodulation:

(
~clustersize = 60;

Ndef(\sPlay, {

	var snd, mod, car;

	mod = SinOsc.ar(XLine.kr(Array.series(~clustersize, 110, 10), 1600, 10), mul: 100);
	car = SinOsc.ar(Array.series(~clustersize, 56, 1).midicps + mod);

	snd = Splay.ar(car * 0.05);
	snd;
});

Ndef(\sPlay).play;
)


// Mit etwas fadeTime und weniger Oszillatoren
// Mit dem freqscope können wir den Verlauf der XLine visuell beobachten:
s.freqscope;

(
~clustersize = 20;

Ndef(\sPlay, {

	var snd, mod, car;

	mod = SinOsc.ar(XLine.kr(Array.series(~clustersize, 110, 10), 1600, 10), mul: 100);
	car = SinOsc.ar(Array.series(~clustersize, 56, 1).midicps + mod);

	snd = Splay.ar(car * 0.05) ;
	snd;
});
)

Ndef(\sPlay).fadeTime = 2;
Ndef(\sPlay).play;


// Weiter nützliche Array Funktionen:

Array.fill(4, {|i|; i + 1});
Array.geom(10, 1, 2);
Array.interpolation(50, start: 0.0, end: 1.0);
Array.rand(8, 1, 100);
Array.fib(10, 0, 1);


// Haben wir uns erst einmal ein Array erstellt können wir es auch im nachhinein noch verändern:

~myArr = Array.rand(10, 1, 100);
~myArr.rotate;
~myArr.reverse;
~myArr.dup;


// mit .do können wir auch über Arrays iterrieren
(
['a', 'b', 'c'].do({ |item, i |
	[i, item].postln;
});
)


// Übergeben wir .do einen positiven Integer, iterrieren wir immer von 0 bis zu ihrem Wert:

10.do{ |i| i.postln;};

10.do { |i|  ~myArr.rotate(i).postln; };


// 2 Mal .do mit unterschiedlichen Iterationsvariablen
(
2.do{ |iter1|
	['a', 'b', 'c'].do({ |item, iter2| [iter1, item, iter2].postln; });
};
)