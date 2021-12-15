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


// .dump ist eine praktische Nachricht um mehr über ein Objekt zu erfahren
5.dump;
SinOsc.dump;
SinOsc.ar.dump;

// [Empfänger].[Nachricht]([Argument1], [Argument2], ...)
// Wenn wir kein Argument haben können wir die runden Klammern auch weglassen.

5.sin();
5.sin;

5.cos();
5.cos;

-1.abs();
-1.abs;

2.sqrt();
2.sqrt;

// Es können auch mehrere Nachrichten/Methodenaufrufe nachaneinder jeweils
// auf das Ergebnis des davorherigen Aufrufs angewandt werden.
// (Method Chaining)

2.sqrt.neg;
SinOsc.ar(440).abs;


// Argumente können in einem Methodenaufruf entweder über die
// Reihenfolge angegeben werden

SinOsc.ar(440, pi, 0.5)

// Wir können die Reihenfolge auch überspringen indem wir den Namen
// des Arguments davor setzten. name: Wert, name: Wert
// (pi ist hierbei auch ein Wert/Konstante)

// Die Reihenfolge ist dann komplett egal

SinOsc.ar(phase: pi, freq: 440)

// Man kann Reihenfolge und benannte Argumente auch mischen

SinOsc.ar(440, add: 0.5);

// Was aber nicht geht ist erst ein benanntes Argument zu nehmen und
// dann noch eines ohne Namen.

SinOsc.ar(phase: pi, 440)

// Manchal ist es auch einfach interessant die Reihenfolge beizubehalte
// aber durch die Namen der Parameter den Code klarer zu strukturieren

SinOsc.ar(freq: 440, phase: pi)


// Alternative Schreibweise für Methodenaufrufe
// ... erinnert dann mehr an die Schreibweise von Funktionen in
// Python/C oder Mathematik

5.sin
sin(5)

5.neg
neg(5)

2.pow(10)
pow(2, 10)

// [Empfänger].[Nachricht](Argument1, Argument2, ...)
// [Nachricht](Empfänger, Argument1, Argument2)

// Das ganze ist allgemeing gültig
SinOsc.ar(440)
ar(SinOsc, 440)

// Auch das funktioniert - auch wenn man Code sehr selten so sieht
RLPF.ar(SoundIn.ar, SinOsc.kr(0.1).range(100, 2000), 0.5);
ar(RLPF, ar(SoundIn), range(kr(SinOsc, 0.1), 100, 2000), 0.5);

// Für Methodenaufrufe mit nur einem Argument gibt es auch
// eine Nachricht die an eine binäre Operation erinnert

// [Empfänger] [Nachricht]: [Argument]
5.pow(2)
pow(5, 2)
5 pow: 2

SinOsc.ar(220)
ar(SinOsc, 220)
SinOsc ar: 220

// ACHTUNG! Hier wird dann wieder alles von-links-nach-rechts ausgewertet

// ungültig
1 + SinOsc ar: 220

// 2 + 2 wird als erstes ausgewertet
2 + 2 pow: 10
4 pow: 10

2 + (2 pow: 10)

// Tatsächlich sind binäre Operationen in SuperCollider auch Methodenaufrufe.
// Der erste Operand ist hierbei der Empfänger, der zweite Operand das Argument.
// Allerdings fällt hier dann der Doppelpunkt weg.

// +, -, *, /,

4 + 4

// Integer markieren und Cmd+I bzw. Strg+I ruft den Code der
// Integer Klasse auf. Hier sieht man auch die Definition der
// Methoden für die arithmetischen Operationen
Integer


// Auch viele grundlegende Kontrollstrukturen in SuperCollider
// sind eigentlich nichts weiteres als Methodenaufrufe, so
// auch .if

(
a = 2;
(a > 5).if({
	"Wahr".postln;
}, {
	"Falsch".postln;
});
)

// Durch die Funktions-Schreibweise und ein bisschen
// syntactic Sugar, der in bestimmten Fällen das Weglassen
// von Klammern erlaubt kann man in SuperCollider einige
// Sachen auch wie in C oder ähnlichen Programmiersprachen
// schreiben. (Ich persönlich bevorzuge die obere Schreibweise,
// da hier klarer ist was eigentlich passiert)

(
a = 10;

if(a > 5) {
	postln("Wahr");
}
)

// Help: Syntactic Shortcuts


// Auch Konstruktoren sind syntactic Sugar. Eigentlich wird
// die .new Methode einer Klasse aufgerufen.

Ndef(\bla, {SinOsc.ar(440)})
Ndef.new(\bla, {SinOsc.ar(440)})
new(Ndef, \bla, {ar(SinOsc, 440)})

// seltsam ...
Ndef new: \bla



// Funktionen sind in SuperCollider stets anonym (ohne Namen). Aber
// wir können einer Funktion dann einen Namen geben indem wir sie
// einer Variable zuordnen.

/*
def x(a, b):
   return a * b

x(5, 10)
*/

(
x = {arg a, b;
	a * b;
};

x.value(5, 10);
// value(x, 5, 10);
)

(
x = {|a, b|
	a * b;
};
// Kurzschreibweise für Funktionsaufruf
x.(5, 10);
)

// Wir können bei den Funktionsargumenten auch Standardwerte
// angeben. Genauso können wir Argumente auch per Namen übergeben.


(
x = {|a=2, b=10|
	a * b;
};

// x.value;
// x.value(5);
x.value(b: 100)
)

// Help: Writing Classes
// (für diejenigen die es interessiert)


// Next: Bedingte Anweisungen, Schleifen, Scope, ...