// Buffer und Trigger

trigger uGens
s.scope;

~buf = Buffer.read(s,"/Users/anselmweber/Desktop/sample6.wav" );
~buf.play;
~buf = Buffer.readChannel(s,"/Users/anselmweber/Desktop/sample6.wav", channels: 0 );

~wbuf = Buffer.alloc(s, 44100, 1);


// Einfache Granular Synthese in SC
// Wir schreiben einen Saw in einen 2ch Buffer und Lesen in mit GrainBuf aus

(
Ndef(\writeBuf, {

	BufWr.ar(Saw.ar([100, 101]).sum, ~wbuf, LFSaw.ar(1).range(0, 44100));

});
)

~wbuf.plot;

(
Ndef(\grainBuf, {

	var snd, trig, rate;

	trig = Dust2.kr(100);
	rate = MouseX.kr(0.1, 1.25);

	snd = GrainBuf.ar(2, trig, 1, ~wbuf, rate, 0.5, 0) * 0.05;

	//snd = CombC.ar(snd, decatime: 3, add: snd);

	snd;

}).play;
)




// Demand Ugens


// Demand Ugens sind vereinfacht gesagt ein Weg, Patterns in die Klangsynthese zu holen

// Bei Patterns die in der Language ausgeführt werden rufen wir immer eine neue Instanz unseres Synths mit verschiedenen Werten auf

s.plotTree;

(
SynthDef(\simple, { | freq = 440, gate = 1 |

	var snd, env;

	env = EnvGen.ar(Env.linen(0.01, 1, 0.01), gate, doneAction: 2) * 0.25;

	snd = SinOscFB.ar(freq * [1, 1.01], 1);
	snd = snd * env;

	Out.ar(0, snd);

}).add;
)

(
Pdef(\pattern, {
	Pbind(
		\instrument, \simple,
		\freq, Pseq([30, 42, 35, 38].midicps * 2, inf)
	)
}).play;
)



// Wollen wir uns nun die selbe Tonabfolge innerhalb einer Instanz zum Beispiel einem Ndef ausführen
// Dann können wir auf Demand Ugens zurückgreifen
// Demand.kr liefertund auf controlRate (wir befinden uns nun ausschließlich auf dem Server)
// die gewünschte Frequenz welche sich nach jedem Trigger ändert


(
Ndef(\demand, {

	var snd, freqs, demand, trig;

	trig = Impulse.kr(1);

	// Dseq ist unser demand rate Ugen entspricht Pseq in der "Pattern Welt"
	freqs = Dseq([30, 42, 35, 38].midicps * 2, inf);

	demand = Demand.kr(trig, 0, freqs);
	snd = SinOscFB.ar(demand * [1, 1.01], 1) * 0.25;

});

Ndef(\demand).play;
)


// Wollen wir mit Demand Ugens Rhythmisch arbeiten empfiehlt sich Duty

// Hier klingen die Synth Instanzen in einander da wir immer die sellbe Envelope nutzen
// Ein Effekt den wir mit nur einer Instanz natürlich nicht so einfach erzielen können

(
Pdef(\pattern, {
	Pbind(
		\instrument, \simple,
		\freq, Pseq([30, 42, 35, 38].midicps * 2, inf),
		\dur, Pseq([1,  1/ 3, 1/3, 1/3], inf)
	)
}).play;
)


(
Ndef(\duty, {

	var snd, freqs, demand, trig, durs;

	trig = Impulse.kr(1);

	// Dseq ist unser demand rate Ugen entspricht Pseq in der "Pattern Welt"
	freqs = Dseq([30, 42, 35, 38].midicps * 2, inf);
	durs = Dseq([1, 1/3, 1/3, 1/3], inf);

	demand = Duty.kr(durs, 0, freqs);
	snd = SinOscFB.ar(demand * [1, 1.01], 1) * 0.25;

});

Ndef(\duty).play;
)


// Ein Vorteil von Demand Ugens ist die Flexibilität
// Denn Trigger Signale können wir schnel anpassen und / oder modulieren

(
Ndef(\dseq, {

	var snd, trig, freqs, demand;

	trig = Impulse.kr(MouseY.kr(2, 16));
	freqs = Dseq([30, 42, 35, 38].midicps * 2, inf);

	demand = Demand.kr(trig, 0, freqs);

	snd = SinOscFB.ar(demand * [1, 1.01], 1) * 0.25;

});

Ndef(\dseq).play;
)


(
Ndef(\dseq, {

	var snd, trig, freqs, demand, lfo;

	lfo = LFNoise1.kr(1).range(0.1, 10);
	trig = Dust2.kr(lfo);
	freqs = Dseq([30, 42, 35, 38].midicps * 2, inf);

	demand = Demand.kr(trig, 0, freqs);

	snd = SinOscFB.ar(demand * [1, 1.01], 1) * 0.25;

});

Ndef(\dseq).play;
)


// GrainBuff mit demand
// Nun Können wir auch Demand nutzen um gezielte rates innerhalb unserer Granularsynthese anzusteuern

(
~wbuf = Buffer.alloc(s, 44100, 1);

Ndef(\writeBuf, {

	var phase, sig;

	phase = Phasor.ar(0, 1, 0, 44100);

	sig = Saw.ar([100, 100.1]);
	//sig = JPverb.ar(sig);

	BufWr.ar(sig.sum, ~wbuf, phase);

});
)

~wbuf.plot;

(
Ndef(\grainBuf, {

	var snd, trig, rates, trigger, freqs, demand;

	trigger = Impulse.kr([3, 8] * 0.05).sum;
	rates = Dseq([0.25, 0.5, 1, 0.5 / 3], inf);

	demand = Demand.kr(trigger, 0, rates);

	trig = Dust2.kr(100);
	snd = GrainBuf.ar(2, trig, 10, ~wbuf, demand, 0.5, 0) * 0.05;

	snd = LPF.ar(snd, 3500);

	snd = CombC.ar(snd, 0.5, LFNoise1.kr(0.1).range(0.1, 0.5), decaytime: 3, add: snd) * 0.25;

}).play;
)



