// Ein paar Experimente mit CombN und DelayTimes als Resonatoren

// Bei sehr kurzen Delaytimes kommt es zu hörbaren Resonanzen der Frequenz 1 / delaytime
// Das können wir nutzen um mit Demand Ugens gezielte Tonhöhen resonieren zu lassen

(
Ndef(\delay2, {

	var snd, times, demand;

	times = [ 0.001, 0.002, 0.004];
	demand = Demand.kr(Impulse.kr(2), 0, Dseq(times, inf));

	snd = SinOsc.ar(440) * LFPulse.kr([3, 8] * 0.1) * 0.05;

	snd = CombN.ar(snd, 0.02, demand , 10);
	snd = LeakDC.ar(snd);

}).play;
)

// Hier ist eine kleine Funtion die uns aus frequenz die passende delaytime ausrechnet

~f  = { | x | 1 /  x };


(
Ndef(\delay2, {

	var snd, times, demand;

	times = ~f.value([1000, 500, 250]);
	demand = Demand.kr(Impulse.kr(2), 0, Dseq(times, inf));

	snd = SinOsc.ar(440) * LFPulse.kr([3, 8] * 0.1) * 0.1;

	snd = CombN.ar(snd, 0.02, demand , 10)  * 0.5;
	snd = LeakDC.ar(snd);

}).play;
)

s.meter;


// Unsere Annäherung an einen Flanger Effekt

(
Ndef(\flangerlike, {

	var snd, lfo, time;

	lfo = LFNoise1.kr(0.1).range(0.1, 1);
	time = LFCub.kr(0.1).range(0.01, 0.015) * lfo;

	snd = SinOscFB.ar(100 * [1, 1.01], 1.5)  * 0.1;

	snd = CombL.ar(snd, 0.15, time , 1.0).tanh * 0.25;

	// für eventuelle DC offset durch feedbacks
	snd = LeakDC.ar(snd);

});

Ndef(\flangerlike).play;
)


// Fades Fades Fades

// Mit Lag.kr und hohen Lagtimes können wir bereits in der Klangsynthese Übergange schaffen
// Die immer dann stattfinden wenn neue Parameter gesetzt werden

(
SynthDef(\a, { |out = 0, freq = 440|

	var ramp;
	ramp = Lag.kr(freq, 30);

	Out.ar(out, SinOsc.ar(ramp) * 0.1 !2);

}).add;
)

~x = Synth(\a);
~x.set(\freq, 880);

(
SynthDef(\b, { |out = 0|

	Out.ar(out, SinOsc.ar(440 * 2) * 0.1 !2);

}).add;
)


// Ein Aufbau um zwischen mehreren Sources zu CrossFaden

(
Ndef(\c, {

	SinOsc.ar(440) * 0.1 !2;

});
)

(
Ndef(\d, {

	SinOsc.ar(440 * 0.5) * 0.1 !2;

});
)

Ndef(\d).fadeTime = 4;

(
Ndef(\mix, {

	XFade2.ar(Ndef(\c), Ndef(\d), SinOsc.kr(1));

});
)

Ndef(\mix).play;


// Oder wir verwenden gleich SelectXFocus für ein Array aus belibieg vielen Sources
// Beide könnten wir natürlich auch mit Synths verwenden
// Müssten dann allerdings auf Busse und In.ar zurückgreifen

// So können wir unsere Quellen dynmisch verändern während der mix zwischen ihnen Crossfadet

(
Ndef(\c, {

	SinOsc.ar(440) * 0.1 !2;

});

Ndef(\d, {

	SinOsc.ar(440 * 0.5) * 0.1 !2;

});

Ndef(\e, {

	PinkNoise.ar(0.1)  !2;

});

Ndef(\mix, {

	SelectXFocus.ar(

		which: SinOsc.kr(0.5).range(0, 2), // Index für unser Source Array
		array:  [Ndef(\c), Ndef(\d), Ndef(\e)],

	);

});

Ndef(\mix).play;
)



// Über Source Patterns können wir mit einem Pbind die Source eines Ndefs dynamisch austauschen
// Falls euch das verwirrt schaut mal in der Help unter:

ProxyRoles

// Wir können dazu auch gerne auch mal eine NodeProxy bzw Ndef "in Depth" Session machen

(
Ndef(\x,

    \setsrc -> Pbind(\source,
        Pseq([
            { LFTri.ar(280 * Line.kr(1.1, 0.4, rrand(2, 3)) + [0,1]) * 0.1 },
            { Pulse.ar(40 + [0,1]) * 0.1 },
            { LFTri.ar(LFTri.kr(1).round(1.0.rand) + 1 * 180 + [0,1], 0.04) * 0.3 },
        ], inf),
        \dur, Pseq([3, 2, 4], inf)
    )
).play;
)


// Nun können wir über eine fadeTime zwischen Sources faden

(

Ndef(\x).fadeTime = 4;

Ndef(\x,

    \setsrc -> Pbind(\source,
        Pseq([
            { LFTri.ar(280 * Line.kr(1.1, 0.4, rrand(2, 3)) + [0,1]) * 0.1 },
            { Pulse.ar(40 + [0,1]) * 0.1 },
            { LFTri.ar(LFTri.kr(1).round(1.0.rand) + 1 * 180 + [0,1], 0.04) * 0.3 },
        ], inf),
        \dur, Pseq([3, 2, 4], inf)
    )
).play;
)


// Tdefs als "Fades" oder Rampen in der Language
// Mit Tdefs können wir einzelne Tasks kapseln und wie bei Pdefs unter einem Key ablegen

(
Tdef(\x, {
	~x = 0;
	loop{

		if(~x < 1, {~x = ~x + 0.001});
		~x.postln;
		0.01.wait;
	}
});
)

Tdef(\x).play;

Tdef(\x).stop;

(
{

	"hello".postln;

	0.5.wait;

	"first".postln;

	Tdef(\x).play;

	1.wait;

	Tdef(\x).stop;

	0.25.wait;

	"second".postln;

	Tdef(\x).play;

	1.wait;

	Tdef(\x).stop;

	"bye".postln;

}.fork;
)


