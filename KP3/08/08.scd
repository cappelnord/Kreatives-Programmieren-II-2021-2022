// Verzerrungen
// Für mehr siehe Auch Tour of Ugens - Distortion

// Eine ganze menge an Distortions sind bereits in SuperCollider eingebaut.
// In der Regel ist ihr Ausgabebereich stets von -1 bis 1. Dementsprechend
// ist der Ausgabebereich stets sicher. Je nachdem wie "heiß" das Signal
// in die Verzerrung geht desto höher der Grad der Verzerrung.

Ndef(\dist, {(SinOsc.ar(440) * MouseX.kr(0, 30)).dup.distort * 0.5}).play

Ndef(\dist, {(SinOsc.ar(440) * MouseX.kr(0, 30)).dup.clip2 * 0.5}).play

Ndef(\dist, {(SinOsc.ar(440) * MouseX.kr(0, 30)).dup.softclip * 0.5}).play

Ndef(\dist, {(SinOsc.ar(440) * MouseX.kr(0, 30)).dup.tanh * 0.5}).play

// Wie man es auch bei Gitarrenverstärkern kennt nimmt man gerne zur
// Steuerung von Verzerrungen 2 Parameter, preamp und postamp.
// Der preAmp regelt wie laut das Signal in den Verzerrer geht (
// und steuert somit dann den Grad der Verzerrung). Der postAmp
// wird dann nach der Verzerrung angewandt und regelt die Lautstärke.

(
Ndef(\distFett, {
	var sig = Saw.ar(50 * [1.0, 1.005, 2, 2.001]).sum;
	var preAmp = MouseX.kr(1, 100, 1);
	var postAmp = 0.2;
	sig = RLPF.ar(sig, SinOsc.kr(0.1).range(100, 2000), 0.5);

	sig = (sig * preAmp).tanh * postAmp;

	sig.dup;
}).play
)

// sclang

// Operatoren
// Help: Operators


// Binäre Operatoren (2 Operanden)

// +, -, *, / ....

2 * 2

5 + 5

// Unäre Operatoren (1 Operand)

5.neg

5.sin

// sclang: Binäre Operationen haben keine Präzedenz
// Punkt vor Strich gilt nicht, Auswertung bon Links nach Rechts.
// Alles was in runden Klammern ist wird vorher ausgewertet

5 + 1 * 2

5 + (1 * 2)

2 + 2 * 4 + 4

(2 + 2) * (4 + 4)

// Auch vorsicht bei Vergleichen!

a = 3

a == 2 + 1 // geht nicht, da a == 2 false ist und dann false + 1 nicht klappt

a == (2 + 1)


// Achtung, das gleiche gilt auch auf der Syntheseseite!

(
Ndef(\operatoren, {
	SinOsc.ar(440).dup * 0.2 + SinOsc.ar(880) * 0.1;
	// entspricht:
	// (((SinOsc.ar(440).dup * 0.2) + SinOsc.ar(880)) * 0.1)
}).play;
)

(
Ndef(\operatoren, {
	// wahrscheinlich war eher dies gemeint
	(SinOsc.ar(440).dup * 0.2) + (SinOsc.ar(880) * 0.1);
}).play;
)

// Auch Präzedenz haben Unäre Operatoren bzw. Methodenaufrufe

2 + 5.neg // entspricht 2 + -5, nicht -7

// Allgemeine Form von Methodenaufrufen (hierzu nächste Sitzung mehr)
// [Empfänger].[Nachricht]([Parameter1], [Parameter2], ...)


// Whitespace wird von SuperCollider ignoriert und dient nur der
// besseren Lesbarkeit für uns!

{0.5 * 0.1 * SinOsc         .       ar(440, 0.5) .     dup}.play

{0.5*0.1*SinOsc.ar(440, 0.5).dup}.play


// Regeln:
// a) Klammern
// b) Methodenaufrufe mit . [Empfänger].[Nachricht]
// c) Von Links nach Rechts
// Zuweisungen sind noch mal ein Sonderfall

// Diese Infos zu den Operatoren und Methodenaufrufen ist noch unvollständig.
// Ein wichtiger Punkt wird nächste Sitzung noch dazukommen!
