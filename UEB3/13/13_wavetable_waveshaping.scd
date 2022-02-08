// Wavetable Synthesis

// Osc und VOsc

// Eigentlich haben wir Wavtable Synthese schon die ganze Zeit betrieben

// Ugens wie SinOsc greifen auf  fixe Lookup Tables zurück, in denen die Shape ihres Signals festgeschrieben steht

// Das können wir auch bei den einzelnen Ugens nachsehen
SinOsc

// Solch ein Signal können wir mit dem Signal Objekt auch selbst erstellen
// Dazu können wir beispielsweise Signal.sineFill nutzen

(
~sig = Signal.sineFill(512, [1], [0]);
~sig.plot;
)

// Wir können Osc dazu verwenden unsere Signal auszulesen
// Doch zuert müssen wir unseren Sinus (momentan in der Form einer Colleciton)
// In das Wavetable Format bringen.

~sig.asWavetable;

// Wavetableformat übernimmt die Interpolation zwischen einzelnen Samplewerten bereits im vorraus
// Die Rechenlast für die Interpolation ist nicht daher auf dem Server


// Dann benötigen wir nur noch einen Buffer aus dem Osc lesen kann
// Ein Buffer ist erstmal nur eine Stelle im Speicher an der wir Werte ablegen können
// So können wir Buffer mit samplenwerten von Audiofiles von unsere Festplatte befüllen...

b = Buffer.read(s, "pathToSoundFile");

// ...Oder über .loadCollection mit den Samplewerten eines von uns erstellten Signals

(
b = Buffer.alloc(s, 2048);

~sig = Signal.sineFill(1024, [1], [0]);
~sig.plot;
~wt = ~sig.asWavetable;

b.loadCollection(~wt);
)


// Nun können wir diesen Buffer mit Osc auslesen

{ Osc.ar(b, 440) !2 * 0.1  }.play;
// --> SinOsc nutzt auch Osc nutzt allerdings mit einem vorgefertigtem Sinus Table aus 8192 samples


// Mit sineFill können wir beginnend mit dem Grundton (1) auch Obertöne angeben
// um unser Signal komplexer zu gestalten
(
b = Buffer.alloc(s, 2048);

~sig = Signal.sineFill(1024, [1, 1/4, 1/6, 1/2], [0]);
~sig.plot;
~wt = ~sig.asWavetable;

b.loadCollection(~wt);
)

{ Osc.ar(b, 440) !2 * 0.1  }.play;
// --> SinOsc nutzt auch Osc nutzt allerdings mit einem vorgefertigtem Sinus Table aus 8192 samples


(
~amps = Array.fill(20, {|i| i.sin;});
~sig = Signal.sineFill(1024,
	[1, 1/4, 1/6, 1/2],
	[0]);
~sig.plot;
~wt = ~sig.asWavetable;
b.loadCollection(~wt);
)

{ Osc.ar(b, MouseY.kr(50, 500)) !2 * 0.1 }.play;

// Natürlich können wir uns auch ähnliche Klänge mit additive Synthese zusammenbasteln
// Der Vorteil ist hier aber, dass wir deutlich weniger Ugens benötigen

// mit .sine3 können wir unseren Buffer auch direkt mit Frequenzen befüllen

b.sine3([1], [1], [0], asWavetable: false).plot;

b.sine3([1], [1], [0], asWavetable: true);

{ Osc.ar(b, MouseY.kr(50, 500)) !2 * 0.1 }.play;


// Enden wir nicht mit dem selben Sample Wert springt der Oszillator wieder zurück
// Da wir durch wrapping das Ende gleich den Anfang setzten
// --> wir erhalten eine Saw-like Wavetable

b.sine3([1.25], [1], [0], asWavetable: false).plot;

(
b.sine3([1.25], [1], [0], asWavetable: true);


{ Osc.ar(b, MouseY.kr(50, 500) ) !2 * 0.1 }.play;
)


// Sehr schön: Wie können Wavetables auch dynamisch verändern während Osc daraus ausliest:

{ Osc.ar(b, MouseY.kr(50, 500)  ) !2  * 0.1 }.play;

(
{
	10.do{
		b.sine3(
			({exprand(0.5, 30)} !20).sort, // Gib uns exp rand zwischen 0.5 und 30 und das 20 mal
			({exprand(0.01, 0.95)} ! 20).sort.reverse,
			{rrand(0, 2pi)} !20
		);

		1.wait;
	};
}.fork;
)

// Hinweis: !20 Funktioniert hier genauso wie wir es kennen von multiChannel Expansion
// Also wir erhalten ein Array mit 20 evluationen von der jeweiligen Funktion:

{exprand(0.5, 30)} !20;

{exprand(0.5, 30)}.dup;

{exprand(0.5, 30)}.dup(20);


// Zusammen mit Multichannel Expansion für mehr "Voices" und etwas detune klingt das ganze doch schon recht gut

{ Osc.ar(b, MouseY.kr(50, 100) * [1, 1.01, 2, 2.01]  ).sum.dup  * 0.05 }.play;


// random Wavetables: (Laufzeit ausführen):
(
b.sine3(
	({exprand(0.5, 30)} !20).sort,
	({exprand(0.01, 0.95)} ! 20).sort.reverse,
	{rrand(0, 2pi)} !20
);
)


// Wir können auch die guten alten Envelopes Nutzen um einen Wavetable Buffer zu befüllen



~buf = Buffer.alloc(s, 2048);


~env = Env([0, 0.6, -0.9, 0.3, 0], [4, 3, 2, 1], \lin);
~env.plot;

~sig = ~env.asSignal(1024);
~wt = ~sig.asWavetable;

~buf.loadCollection(~wt);


{ Osc.ar(~buf, MouseY.kr(50, 500) * [1, 1.01, 2, 2.01]  ).sum.dup  * 0.1 }.play;


// Nun haben wir genug Grundwissen um unseren eigenen Wavetable Synth zu bauen
// Hinweis: Oft haben wir wenn wir mit  wellenformen experimentieren DC offset
// Das können wir mit LeakDC eindämmen

(
SynthDef(\wave, { |buf = 0, freq = 200, amp = 0.1, gate = 1|

	var snd, env;
	env = Linen.kr(gate, 0.1, 1, 1, doneAction:2);
	snd = Osc.ar(buf, freq * [1, 2.01, 1.01, 2]).sum * 0.1 * env;
	snd = LeakDC.ar(snd);

	Out.ar(0, snd !2 * amp);

}).add;
)

(
~b1 = Buffer.alloc(s, 2048);

~b1.sine3(
	({exprand(0.5, 30)} !20).sort,
	({exprand(0.01, 0.95)} ! 20).sort.reverse,
	{rrand(0, 2pi)} !20
);


~b2 = Buffer.alloc(s, 2048);

~b2.sine3(
	({exprand(0.5, 30)} !20).sort,
	({exprand(0.01, 0.95)} ! 20).sort.reverse,
	{rrand(0, 2pi)} !20
);
)


// Dem Synth übergeben wir den aktuellen Buffer als Parameter
Synth(\wave, [\buf, ~b1]);


// cheesy Pdef der unseren buffer und die octave wechselt...

(
Pdef(\wt,
	Pbind(
		\instrument, \wave,
		\degree, Pn(Pseq([2, 4, 5, 7, 6]) * 1, inf, \octi),
		\dur, Pseq([1, 1, 1, 0.75, 0.25], inf) * 0.5,
		\buf, Pseq([~b2, ~b1, ~b1, ~b1 ], inf),
		\legato, 0.75,
		\octave, Pgate(Pwhite(3, 6), inf, \octi)
	)
);

Pdef(\wt).play;
)


// 80s vibing...

(
Pdef(\wt,
	Pbind(
		\instrument, \wave,
		\degree, Pn(Pseq([2, 4, 5, 7, 6]) * 1, inf, \octi),
		\dur, Pseq([1, 1, 1, 0.75, 0.25], inf) * 0.5,
		\buf, Pseq([~b2, ~b1, ~b1, ~b1 ], inf),
		\legato, 0.75,
		\octave, Pgate(Pwhite(3, 6), inf, \octi)
	)
);

Pdef(\wt).play;

Pdef(\wtb,
	Pbind(
		\instrument, \wave,
		\degree, Pn(Pseq([2]) * 1, inf, \octi),
		\dur, Pseq([1, 1, 1, 0.75, 0.25], inf) * 0.5,
		\buf, ~b2,
		\legato, 0.01,
		\octave, Pseq([3, 4], inf)
	)
);

Pdef(\wtb).play;
)


// VOsc können wir nutzen um zwischen mehreren Buffern zu interpolieren

(
SynthDef(\vosc, { |buf = 0, freq = 200, amp = 0.1, gate = 1|

	var snd, env, bufpos;
	bufpos = buf + MouseX.kr(0, 1);
	env = Linen.kr(gate, 0.1, 1, 2, doneAction:2);
	snd = VOsc.ar(bufpos, freq) * 1 * env;

	Out.ar(0, snd !2 * amp);

}).add;
)

(
~b1 = Buffer.alloc(s, 2048);

~b1.sine3(
	({exprand(0.5, 30)} !20).sort,
	({exprand(0.01, 0.95)} ! 20).sort.reverse,
	{rrand(0, 2pi)} !20
);


~b2 = Buffer.alloc(s, 2048);

~b2.sine3(
	({exprand(0.5, 30)} !20).sort,
	({exprand(0.01, 0.95)} ! 20).sort.reverse,
	{rrand(0, 2pi)} !20
);
)

Synth(\vosc, [\buf, ~b1.bufnum]);

// Problem: Wenn wir mehrere Buffer verwenden wollen
// Verlieren wir schnell den Überblick welcher Buffer wo genau welche bufnum besitzt

// Mit  Buffer.allocConsecut() können wir uns belibig viele Buffer mit direkt aufeinanderfolgenden bufnums generieren

~bufs = Buffer.allocConsecutive(4, s, 2048);

(
~bufs.do({ |buf, i|
	buf.sine3(
		({exprand(0.5, 30)} !20).sort,
		({exprand(0.01, 0.95)} ! 20).sort.reverse,
		{rrand(0, 2pi)} !20

	)
})
)

~bufs[3].plot;

(
SynthDef(\vosc, { |buf = 0, numBufs = 2, freq = 200, amp = 0.1, gate = 1|

	var snd, env, bufpos;
	bufpos = buf + LFNoise1.kr(0.5).range(0, numBufs - 1).poll;
	env = Linen.kr(gate, 0.1, 1, 2, doneAction:2);
	snd = VOsc.ar(bufpos, freq) * 1 * env;

	Out.ar(0, snd !2 * amp);

}).add;
)

Synth(\vosc, [\buf, ~bufs[0].bufnum, \numBufs, 4]);


// Shaper + Transfer Funcntions

// Für den Shaper wird unser Wavetable als Transferfunktion ausgelesen
// Die Transferfunktion bestimmt, wie das Input Signal Sample für Sample verändert wird

//  Bei der Transferfunktion geben wir die Zeitachse auf um einen "Input-Output Graph" zu erhalten
// Wobei die X-Achse dem Input und die Y-Achse dem Output entspricht

// Schauen wir uns zunächste die "identity" Transfer Funktion an
// Hier passiert noch nichts dh Input entspricht genau dem Output

(
~tf = Env([-1, 1], [1], [0]).asSignal(1025);
~tf.plot;
~tf = ~tf.asWavetableNoWrap;
~ctf = Buffer.loadCollection(s, ~tf);
)


// Bei Transfer Functions müssen wir berücksichtigen das wir hier kein Signal abbilden
// Sondern nur das verhältnis, wie wir das Input Signal verändern wollen
// Daher macht auch hier wrapping keinen Sinn bzw. wir wollen es in den meisten Fällen nicht
// Kurz gesagt: Das Ende wird nicht der Anfang sein, denn Anfang und Ende beziehen sich auf unterschiedliche Amplitudenwerte in unserem Input Signal

//  Um das zu erreichen verlängern wir das Signal um einen Wert
// Das heißt die letzte Interpolation in der Wavetable ist dann nicht zwischen dem letzten Wert und den Anfangswert 1024 und 0 (So würde die Transfer Function nämlich verzerren)
// Sonder zwischen dem vorletzten und dem letzten wert 1024 und 1025

// Zusätzlich geben wir asWaveNoWrap an da wir nicht über die Transfer function oszillieren wollen

{ Shaper.ar(~btf, SinOsc.ar(440)) !2 * 0.05 }.play;

// Krümmen wir diese Input == Output transfer Function verzerren wir das Input Signal

Env([-0.8, 0, 0.8], [1, 1], [8, -8]).asSignal(1025).plot;

(
~tf = Env([-0.8, 0, 0.8], [1, 1], [8, -8]).asSignal(1025);
~tf = ~tf.asWavetableNoWrap;
~btf = Buffer.loadCollection(s, ~tf);
)

{ Shaper.ar(~btf, SinOsc.ar(440)) * 0.05 !2 }.play;


// Ohne Verzerrung
(
Ndef(\shapeDry, {

	var sig, snd;

	sig = SinOsc.ar([50, 100, 700]).sum  / 4;
	snd = Shaper.ar(~ctf, sig) * 0.1;
	snd.dup * 0.05;

}).play;
)

// Mit Verzerrung
(
Ndef(\shape, {

	var sig, snd;

	sig = SinOsc.ar([50, 100, 700]).sum  / 4;
	snd = Shaper.ar(~btf, sig);
	snd.dup * 0.05;

}).play;
)


// Natürlich können wir auch hier komplexer Shapes verwenden
// Beispielsweise können wir von der identity Transfer function ausgehen
// Und sie mit einem Signal addieren

(
~size = 1025;
~tf = Env([-1,1], [1], [0]).asSignal(~size);

~tf = ~tf +  Signal.sineFill( ~size,
	{rrand(0, 1) } !8,
	{rrand(0,2pi) } !8
);


~tf = ~tf.asWavetableNoWrap;
~btf = Buffer.loadCollection(s, ~tf);
)


(
Ndef(\shape, {

	var sig, snd;

	sig = SinOsc.ar([50, 100, 700]).sum  / 4;
	snd = Shaper.ar(~btf, sig);
	snd.dup * 0.05;

}).play;
)

// Sehr schöner Effekt
// Verändern wir die Amplitude unseres Inputs "wandert" unser Input Signal durch die Transfer Function

(
Ndef(\shape, {

	var sig, snd;

	sig = SinOsc.ar([50, 100, 700]).sum  / 4 * Line.kr(0, 1, 3);
	snd = Shaper.ar(~btf, sig);
	snd.dup * 0.05;

}).play;
)

(
Ndef(\shape, {

	var sig, snd;

	sig = SinOsc.ar([50, 100, 700]).sum  / 4 * LFTri.kr(0.5).range(0, 1);
	snd = Shaper.ar(~btf, sig);
	snd.dup * 0.05;

}).play;
)

(
Ndef(\shape, {
	var sig, snd, env;

	env = EnvGen.ar(Env.perc(0.01, 5));
	sig = SinOsc.ar([50, 100, 700]).sum  / 4 * 1 * env;

	snd = Shaper.ar(~btf, sig);
	snd.dup * 0.05;

}).play;
)