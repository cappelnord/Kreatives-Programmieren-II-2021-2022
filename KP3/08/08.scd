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


// Booleans und bedingte Anweisungen

/* Python

if alter > 16:
   print("Darf Wein kaufen")
elif alter == 16:
   print("Glück gehabt!")
else:
   print("Darf keinen Wein kaufen")


if(alter > 16) {

} else if(alter == 16) {

} else {

}
*/


// Boolesche Werte (Wahr oder Falsch)

true
false

// Vergleichsoperationen

5 == 5;
4 == 5;

5 > 5;
5 >= 5;

4 < 5;

5 != 5
4 != 5

// Äquivalenz und Identität

5 === 5

"Apfel" === "Apfel"
"Apfel" == "Apfel"

(
x = "Apfel";
y = x;
x === y
)

true.not // !true
false.not

(3 > 5).not

// or, and

// Und: &&
// Or: ||
// XOR: xor:

true && true;

false || true;
true || true;

true xor: false;
true xor: true;

(5 < 10) && (50 < 100)

// Es gibt auch viele Methoden in der sclang Standardbibliothek
// die einen Boolean-Wert zürckgeben

8.isPrime
3.isPrime

[1, 2, 3, 5].includes(5)


// Bedingte Anweisung ist im Grunde ein Methodenaufruf auf einen
// Boolean-Wert mit 2 Argumenten, einer Funktion die ausgeführt wird
// wenn der Wert wahr ist, und eine Funktion die ausgeführt wird wenn
// der Wert falsch ist!

(
x = 12;

(x >= 18).if({
	"Patrick darf Gin kaufen".postln;
}, {
	"Patrick darf keinen Gin kaufen".postln;
});
)

// Die if Methode gibt auch wieder das Ergebnis der Funktion zurück

(
x = 12;
y = (x >= 18).if({"Gin"}, {"Apfelsaft"});
y.postln;
)

// Da jedes Objekt auf die .value Methode hört (und sich dann selber
// zurückgibt) brauchen wir hier allerdings gar keine Funktion!

(
x = 12;
y = (x >= 18).if("Gin", "Apfelsaft");
y.postln;
)

// Wird ein Argument nicht gesetzt ist es automatisch nil. nil
// Bedeutet dass eine Variable kein Wert/Objekt zugewiesen ist.
// Es erfüllt die Funktion des Null-Zeigers anderer Programmiersprachen.

(
x = 12;
y = (x >= 18).if("Gin");
)

nil; // nichts
0; // Ganzzahl: 0


// sclang & scsynth

// Wichtig: Bedingte Anweisungen existieren nicht auf der Serverseite.
// Man kann zwar bedingte Anweisungen nutzen aber diese werden dann
// bereits bei der Erstellung des Synthesegraphen ausgeführt.

(
x = 18;
Ndef(\ok, {
	(x >= 18).if({
		Saw.ar(300);
	}, {
		SinOsc.ar(300);
	});
}).play;
)



(
// geht so nicht.
Ndef(\ok, {
	var lfo = SinOsc.kr(0.5);
	(lfo >= 0).if({
		Saw.ar(300);
	}, {
		SinOsc.ar(300);
	});
}).play;
)

// Vergleichsoperatoren funktionieren allerdings! Sie geben
// ein Signal zurück das entweder 0 (falsch) oder 1 (wahr) ist.

(
// geht so!
Ndef(\ok, {
	var lfo = SinOsc.kr(0.5);
	var gate = lfo >= 0;
	(Saw.ar(440) * gate) + (SinOsc.ar(440) * (1.0 - gate));
}).play;
)


(
// geht so!
Ndef(\ok, {
	var gate = MouseX.kr(0, 1) >= 0.5;
	(Saw.ar(440) * gate) + (SinOsc.ar(440) * (1.0 - gate));
}).play;
)

// Mit Select haben wir eine weitere Möglichkeit unser Signal
// zu verzweigen. Es repräsentiert hierbei viel weniger eine
// bedingte Anweisung sondern den Index-Operator bei Arrays.

// Select
(
Ndef(\ok, {
	var sigs = [SinOsc.ar(220), Saw.ar(220), Saw.ar(220/4)];
	Select.ar(SinOsc.kr(1).range(0,3), sigs);
}).play;
)



// Select
(
Ndef(\ok, {
	var sigs = [SinOsc.ar(220), Saw.ar(220), Saw.ar(220/4)];
	Select.ar(MouseX.kr(0, 3), sigs);
}).play;
)


// Select
(
Ndef(\ok, {
	var sigs = [SinOsc.ar(220), Saw.ar(220), Saw.ar(220/4)];
	Select.ar(LFSaw.ar(XLine.kr(0.05, 10, 10)).range(0, 3), sigs);
}).play;
)


// SelectXFocus um zu überblenden
(
Ndef(\ok, {
	var sigs = [SinOsc.ar(220), Saw.ar(220), Saw.ar(220/4)];
	SelectXFocus.ar(LFSaw.ar(XLine.kr(0.05, 10, 10)).range(0, 3), sigs, wrap: true);
}).play;
)


// Schleifen

// while Schleife als bedingte Schleife. Bedingung steht stehts in einer Funktion
// und muss true oder false zurückgeben. Der eigentliche Schleifenrumpf wird als
// Argument übergeben und wird solange aufgerufen bis die Bedingung false wird.

(
var i = 0;
{ i < 10 }.while({
	i.postln;
	i = i + 1;
});
)


/*
import random

wurf = 0
while wurf != 6:
   wurf = random.randint(1, 6)
   print(wurf)

*/

(
var wurf = 0;
{ wurf != 6 }.while({
	wurf = 6.rand + 1;
	wurf.postln;
});
)

// wirft mittlerweile einen Fehler! Früher wäre dies eine Endlosschleife.
(
var wurf = 0;
( wurf != 6 ).while({
	wurf = 6.rand + 1;
	wurf.postln;
});
)


// Es gibt in SuperCollider eine for-Schleife. Diese wird aber relativ
// selten benutzt, da die .do Methode viel mehr kann!

/*
for i in range(0, 6):
   print(i)
*/

(
0.for(5, {|i|
	i.postln;
})
)


// .do eignet sich perfekt als Ersatz für eine for-Schleifem, z.B.
// hier als einfache Zählschleife.

(
5.do({|i|
	i.postln;
});
)

// Wird die .do Methode auf einen Array aufgerufen dann wird über
// jedes Element des Arrays iteriert.

(
["Apfel", "Birne", "Kiwi"].do({|value, i|
	i.postln;
	value.postln;
});
)

// Über diesen Syntax können wir einfache Zahlenreihen erstellen.
// Über diese können wir dann auch mit .do iterieren!

(100..150);
(100, 102..150);


// Let's make some sound!


(
SynthDef(\pling, {|freq=440|
	var env = EnvGen.ar(Env.perc(0.01, 1), doneAction: 2);
	var sig = SinOsc.ar(freq).dup * env * 0.08;
	Out.ar(0, sig);
}).add;
)


// Alles zusammen ausgeführt.

(
((1..4) * 220).do ({|freq|
	freq.postln;
	Synth(\pling, [\freq, freq]);
});
)

// Mit .wait können wir die Ausführung um eine bestimmte Zeit unterbrechen um
// unserem Code z.B. eine zeitliche Struktur zu geben. Allerdings können wir nicht
// im Haupt-Thread warten und müssen unseren Code in einer Routine laufen lassen.

// Help: Routine

// {}.fork ist ein praktischer Weg um aus einer Funktion eine Routine zu erzeugen
// und diese abzuspielen. Dadurch können wir mehrere paralelle Codestränge laufen lassen.


(
x = {
	((1..16) * 220).do ({|freq|
		freq.postln;
		Synth(\pling, [\freq, freq]);
		0.25.wait;
	})
}.fork;
)

// Wichtig ist die Reihenfolge der Ausführung! In SuperCollider wird nie
// etwas wirklich paralell ausgeführt. Der aktuelle Thread bzw. die aktuelle
// Routine muss immer erst mit ihrer Ausführung abschliessen bevor die nächste
// Routine ans Werk darf. Somit wird bei .fork die Routine auch nicht sofort
// ausgeführt sondern erst wenn unser Code durchgelaufen ist.

(
"A".postln;
{
	"B".postln;
	inf.do ({
		Synth(\pling, [\freq, 60.midicps]);
		1.wait;
		Synth(\pling, [\freq, (60 + 12.rand).midicps]);
		1.wait;
	});
}.fork;
"C".postln;
)

// Natürlich können wir auch Schleifen in Schleifen setzen ...

(
{
	4.do {|i|
		var root = 60 + i;

		4.do ({
			Synth(\pling, [\freq, root.midicps]);
			1.wait;
			Synth(\pling, [\freq, (root + 12.rand).midicps]);
			1.wait;
		});

		2.wait;
	}
}.fork;
)

// Und genauso können wir innerhalb einer Routine weitere Routinen erzeugen!
// Ab irgendeinem Punkt wird es etwas undurchsichtig - aber dadurch lassen
// sich interessante muiskalische Strukturen erzeugen!

(
{
	12.do {|i|
		var root = 60 + i;
		("Start Root:" + root).postln;

		{
			8.do ({|e|
				("Start Schleife für Root:" + i + ", Schleifendurchlauf" + e).postln;
				Synth(\pling, [\freq, root.midicps]);
				1.wait;
				Synth(\pling, [\freq, (root + e.rand).midicps]);
				1.wait;
			});
		}.fork;

		2.25.wait;
	}
}.fork;
)


// Frohes Neues Jahr!

// Stream

// Wir können aus einem Pattern-Objekt einen Stream
// erzeuge und diesem Stream dann einen oder mehrere
// Werte entnehmen (mittels der .next Methode).

x = Pseq([10, 20, 30], 2);
y = x.asStream;

y.next;
y.nextN(3);

// Ein Stream endet sobald ein nil zurückgegeben wird.

// Genauso wie bei Funktionen (was hier auch noch mal
// demonstriert wird) können wir auch mehrere Streams
// oder Patternobjekte über Operationen miteinander verbinden.

a = {10.rand};
b = {[1, 10, 100, 1000].choose};
c = a * b;
c.value;

p = Pseq([1, 2, 3], inf) * Pseq([10, 100], inf);
x = p.asStream;
x.next;

z = x * 1000;
z.next;

// Wir können Streams in Form von Routinen selber definieren.
// Hierbei nutzen wir .yield um die Ausführung der Routine zu
// unterbrechen und einen Wert zurückzugeben.

(
r = Routine({
	1.yield;
	22.yield;
	333.yield;
	4444.yield;
});
)

r.next;

// Mit .embedInStream können Streams und Pattern in eine
// andere Routine bzw. Stream eingebettet werden. Es werden
// dann erst alle Werte aus dem Stream entnommen und
// zurückgegeben bevor der eigentliche Stream fortgesetzt wird.


(
v = Routine({
	2.do ({
		10.yield;
		100.yield;
	});
});
)

p = Pseq([20, 200], 2);

(
r = Routine({
	inf.do ({
		1.yield;
		22.yield;
		333.yield;
		4444.yield;
		v.embedInStream; // ist nach dem ersten Durchlauf aufgebraucht
		// v.reset.embedInStream;
		p.embedInStream;
	});
});
)


// Der Pbind ist auch ein Pattern welches in der Regel weitere
// Patternobjekte beinhaltet.

(
p = Pbind(
	\dur, Pseq([1, 2, 3], inf),
	\degree, Pseq([0, 2, 4, 7], inf),
)
)

x = p.asStream;

// Pbinds erzeugen Event-Streams, diese benötgen ein leeres Event als Argument.
// Dieses wird dann mit den Werten aus den jeweiligen Streams gefüllt.

x.next(())

p.play;

// Help: Understanding Streams, Patterns and Events - Part 1


// Scope (Gültigkeitsbereich)

// Interpretervariablen
// a-z

// Interpretervariablen sind global gültig, können allerdings nur
// die Buchstaben a bis z genutzt werden.

a = 200;
b = 100;
c = a * b;

s.boot;

// Alternativer Zugriff auf die Interpretervariablen über das
// Interpreter Objekt.
this.a;


// Umgebungsvariablen starten mit ~ und beziehen sich stets auf das
// aktuelle Environment "currentEnvironment". Im Grunde ist currentEnvironment
// ein Dictionary.

~apfel = 1000;
~birne = 200;

~apfel * 1000;

~f = {~apfel * ~birne}

~f.value

currentEnvironment;
currentEnvironment[\apfel] = 0

// pusht ein neues Environment auf den Environment Stack
Environment.push(Environment())

// ~apfel ist nun nil
~apfel;

// nimmt das oberste Environment vom Stapel; unser altes
// Environment ist nun wieder sichtbar.
Environment.pop


// (lokale) Variablen müssen deklariert werden. Auf die
// Variablen kann dann außerhalb des Gültigkeitsbereiches
// nicht mehr zugegriffen werden und Variablen mit gleichem
// Namen sind unabhängig voneinander.

(
var apfel = 10;
var birne = 20;

apfel * birne;
)

(
var apfel;
apfel * 100;
)


// Zeigen jedoch beide Variablen auf das selbe Objekt
// sind auch lokale Variablen wieder gewissermassen
// miteinander gekoppelt.

x = Pseq([1, 2, 3, 4], inf).asStream;

(
var apfel = x;
apfel.next
)

(
var birne = x;
birne.next;
)


