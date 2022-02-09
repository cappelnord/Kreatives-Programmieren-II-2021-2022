// Zufall I - 02.02.2022

// Help: Randomness

// Nur Ganzzahlen
5.rand;

// Gleitkommazahlen
5.0.rand;

// Gleitkommazahl zwischen -5.0 und 5.0
5.0.rand2

// Unterschiedliche Verteilungen:

// Wahrscheinlichkeit nimmt linear ab
1.0.linrand;

// Gauss-ähnliche Verteilung
1.0.sum3rand

// Normalverteilung (mit Standardabweichung)
0.gauss(1)

// Ein kleines Testbett um verschiedene Verteilungen zu hören.
(
{
	200.do {
		var note = 60;
		// note = note + 12.rand2;
		// note = note + 12.bilinrand;
		// note = note.gauss(2).round;
		// note = note + 3.rand2;
		(midinote: note, dur: 0.025).play;
		0.1.wait;
	}
}.fork;
)


// Zufall II - 09.02.2022

(
{
	thisThread.randSeed = 6002;
	6.do {
		6.rand.postln;
		1.wait;
	}
}.fork;
)



// Siehe auch: RandID
(
{
	RandSeed.kr(1, 6002);
	SinOsc.ar(LFNoise0.kr(0.5).range(220, 880)) * 0.1;
}.play
)



