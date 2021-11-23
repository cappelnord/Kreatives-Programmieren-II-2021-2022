s.scope;

s.freqscope;


Ndef(\a, { SinOsc.ar([120, 240]) * 0.1 } ).play;

Ndef(\b, { SinOsc.ar([120, 240] * 2) * 0.1 } ).play;


// Indem wir keinen Key angeben, könnwn wir alle Ndefs addressieren

Ndef.all;

Ndef.clear;

Ndef.all;


// Wiederholung: Filter mit MouseX und MouseY

(
Ndef(\saw, {

	var snd = Saw.ar(Array.series(20, 200, 50)).sum.dup  * 0.05;

	snd = RLPF.ar(snd, freq: MouseX.kr(300, 1500), rq: MouseY.kr(2, 0.1));
	snd;

} ).play;
)

Ndef(\saw).clear;


// Verkettung von LFO für (weirde) Tonfolgen

(
Ndef(\filter, {

	var rQ = MouseY.kr(1.0, 0.01);
	var freq = MouseX.kr(0, 1000).max(50);

	var steps = LFPulse.ar(2).range(40, 45).midicps;
	steps = steps * SinOsc.ar(0.1).range(1, 12);

	RLPF.ar(Pulse.ar(40.midicps + steps), freq, rQ).dup * 3 * 0.01;

}).play
)


// Ndefs Advanced

// Ein Ndef ist erbt Methoden aus der NodeProxy Klasse.
// Proxys in SuperCollider fungieren als Platzhalter und können ersetzt und verändert werden während sie abgespielt werden, wie wir es auch von Ndefs bisher gewohnt sind
// Da Ndefs von NodeProxy erbt, lohnt es sich ein paar Funktionen von NodeProxy genauer anzuschauen


// Das kennen wir bereits

Ndef(\v).play;

s.plotTree;

Ndef(\v, {SinOsc.ar(120) * 0.1});

Ndef(\v).fadeTime = 4;


// So würde das als NodeProxy aussehen:

a = NodeProxy(s);

a.play;

a.source = {SinOsc.ar(240)  * 0.1};

a.fadeTime = 4;

s.plotTree;


// Kopien von NodeProxies

a = NodeProxy(s);

a.source = { |freq = 444| Blip.ar(freq * [1, 1.03], 200) * 0.1 };

a.play;

a.set(\freq, 555);

b = a.copy;

b.play;

b.set(\freq, 222);


// Copies von Ndefs funktionieren ganz ähnlich
// Allerdings verlangen Ndefs auch immer nach einem Key
// Daher müssen wir hier den Key ders neuen Ndefs direkt als Argument übergeben

Ndef(\new, { | freq = 60, lffreq = 1 | Saw.ar(freq) * LFPulse.kr(lffreq) !2  * 0.1} ).quant = 1;

Ndef(\a).play;

Ndef(\a).copy(\b);

Ndef(\b).set(\lffreq, 1.1);

Ndef(\b).set(\freq, 240);

Ndef(\b).play;


// Synchrones ändern der Argumente != Synchronisierung von Ndefs untereinander

(

Ndef(\a).set(\lffreq, 3);

Ndef(\b).set(\lffreq, 6)

)


// In diesem Beispiel, laufen beide Kopien nicht synchron zueinander
// Denn beide Ndefs starten genau dann, wenn wir sie ausführen

// Das heißt um sie unteinander zu synchronisieren müssten wir unseren Code perfekt getimed ausführen...

// Oder wir nutzen quant !

// Mit quant können wir unserer Ndefs bzw. ihr Clocks untereinander synchronisieren
// Genauer gesagt wir "schedulen" damit wann der Ndef beginnt:

// Standartmäßig ist quant auf 0: Das bedeuted der Ndef beginnt sofort und wartet nicht auf den nächsten Beat der TempoClock

// --> zu Clocks werden wir in der Zukunft noch einiges Erfahren
// --> momentan reicht es aus zu wissen dass wir über die TempoClock einzelne Ndefs mit .quant synchronisieren können


// Standart: Der Ndef wird unmittelbar abgespielt

Ndef(\a).quant = 0;

Ndef(\a).play;


// Quantisieren wir auf 1, wird der Ndef nicht mehr direkt abgespielt, sondern auf den nächsten ganzen Schlag der TempoClock

Ndef(\a).quant = 1;

Ndef(\a).play;


// Nützliche Tools um über mehrere Ndefs und ihre Kopien den überblick zu behalten:


// Ndef GUI

Ndef(\a, { | freq = 60, lffreq = 1, amp = 1 | Saw.ar(60) * LFPulse.kr(lffreq) !2  * amp} ).gui;
Ndef(\a).play;


// Oder einfach über den Ndef Mixer über "ed"

NdefMixer(s);


// Mit .plotTree können wir uns alle aktiven Nodes anzeigen lassen

Ndef(\c, {SinOsc.ar(220) * 0.1 ! 2});

Ndef(\c).play;

s.plotTree;

Ndef(\c).stop;


// Oder für die Puristen: Alle Nodes im Post Window anzeigen lassen

Ndef(\c, {SinOsc.ar(220) * 0.1 ! 2});

Ndef(\c).play;

s.queryAllNodes;

Ndef(\c).stop;

Ndef(\b).play;

s.queryAllNodes;








