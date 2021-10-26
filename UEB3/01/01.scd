// CMD + Enter für Zeile an Code
// CMD + . Zum Stoppen  !

// Das kennt ihr bestimmt auch schon aus Python:

// Typen

"Hello" // string

'hello'  // Symbol
\hello // Symbol mit anderer schreibweise
7 // Integer

// Symbols werden als key für verschiedene Objecte Benutzt --> Bereits bekannt aus Dictonary

// Variablen: Jede Anweisung oder Zuweisung wird bei SuperCollider mithilfe des ";"  abgeschlossen:
// Interpreter variablen:

a = 7;
b = 3;

// Einfache mathemathische Operatoren
a + b;
a / b;
a * b;
a ** b;
a % b;

// Wichtig hierbei: SuperCollider kennt keine operatorenpräzedenz !
// So gilt hier kein Punkt vor Strich:
c = 2;
a + b * c;

// Falls wir das wollen, müssen wir mit Klammern arbeiten:
a + (b * c);

// Vergleichsoperatoren:

a == b;
a > b;
a != b;

// Nachrichten:
// Da alles in SuperCollider als Objekt ein Objekt ist, können wir mithilfe von Messages (Siehe Help: Messages -> Reference)
// auf dem Objekt eigene Methoden zugreifen.
// Messages können über unterschiedliche Syntax an einen Empfänger (Das Objekt) gesendet werden.
// SuperCollider typisch ist diese schreibweise:

7.dump; // Nützliche Message für Objektinfos

// Wir auch unterschiedliche Nachrichten verketten:

7.sin.pow(2);

// Nachrichten wie pow verlangen nach Argumenten, bei anderen bleiben sie optional:
7.135.round;
7.135.round(0.01);

// Wir senden eine Message an eine Funktion. Funktionen in SuperCollider erstellen wir innerhalb der geschweiften Klammern "{}"
// Funktionen haben wie in anderen Sprachen auch argumente welche wir über die value Message verändern können;
x = { arg a = 1, b = 2;  a + b };

//Alternative Schreibweise:
x = { | a = 3, b = 1 |  a + b };

// Wir lassen die Argumente unverändert
x.value;

// Wir setzten neue Argumente für a und b
x.value(9, 3);


// Code Blocks

// Mehrere Zeilen können wir mit "()" zusammenfassen, wobei immer die letzte Zeile ausgegeben wird
// Innerhalb von Code Blocks können auch Lokale Variablen mit var definiert werden. Sie sind allerdings nur in ihrem jeweiligen Bereich gültig
(
var input1 = 1;
var input2 = 2;
input1 + input2;
input1 - input2;
)

input1 + input2; // --> 'not defined' da außerhalb des Geltungsbereichs

// Mit der postln Message können wir uns auch Zwischenschritte ausgeben lassen, daher ist es auch nützlich zum Debuggen
(
var input1 = 1;
var input2 = 2;
(input1 + input2).postln;
input1 - input2;
)


// currentEnvironment / Namespace

currentEnvironment;

~myNumber = 3;

//...Ist eigentlich ein ShortCut hierfür:

currentEnvironment.put(\myNumber, 6);

// Hier wird der Wert unter einem Symbol als Key im Dictonary currentEvironment abgelegt
~myNumber;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Sound !!

// Zunächstt müssen wir den Server starten
// Der Server ist Zuständig für die Echt Zeit Audioverarbeitung und führt sogennante
// Unit Generatoren -> Ugens in AudioRate oder ControlRate aus. (.ar, .kr)

s.boot; // oder kürzer mit CMD + B

ServerOptions // Help File über Server Einstellungen wie SampleRate
// So können wir unsere SampleRate anpassen:

o = Server.default.options;
o.sampleRate = 48000;

// Die Änderungen treten erst nach einem reboot in Kraft
s.reboot;

// VORSICHT: Standartmäßig ist die Amplitude aller Soundgeneratoren auf 1 gesetzt, was sehr Laut werden kann !!!!
// Das Kann vor allem mit Kopfhörern schnell sehr Laut sein !!!!

// Daher Multiplizieren wir die Amplitude mit einem Wert < 1:
SinOsc.ar(440) * 0.1;
{[SinOsc.ar(440) * 1, SinOsc.ar(440) * 0.1]}.plot;


// Abspielen können wir UGens auf AudioRate wenn wir sie innerhalb Funktion schreiben und über .play starten
{SinOsc.ar(440) * 0.1}.play;
// Hier passiert eigentlich noch etwas mehr doch da kommen wir später nochmal drauf zurück


// Zugriff auf verschiedene Parameter über Keyword Arguments. Siehe Help File SinOsc:
{SinOsc.ar(440, mul: 0.1)}.play;
// Ist das selbe wie:
{SinOsc.ar(440) * 0.1}.play;

// Mit .dup oder !2 erweitern wir unser Signal auf 2 Kanäle
{SinOsc.ar(440, mul: 0.1).dup}.play;
{SinOsc.ar(440, mul: 0.1) ! 2}.play;

//  .ar  steht für AudioRate: Das heißt wir erzeugen 44.100 Werte pro Sekunde (Oder mehr je nach SampleRate)
// In der Welt der Ugens können wir andere UGens benutzen um Ugens zu steuern
// Das Ganze kann man sich so vorstellen wie bei einem ModularSynth: Der Output eines Ugens (oder Moduls) steuert ein anderes Ugens (oder Moduls:

// XLine steurt in diesem Fall unsere Frequenz in dem es diese über eine Zeitspanne exponentiell ansteigen lässt:
{SinOsc.ar(XLine.kr(220, 880, 5, doneAction: 2), mul: SinOsc.kr(2)) * 0.25}.play;

// .kr steht für ControlRate: Dort werden weniger Werte pro Sekunde erzeugt:
// Wenn wir Signale auf AudioRate steuern wollen müssen wir diese nicht zwingend auch auf AudioRate machen.
// .kr spart CPU und hat zudem noch ein paar zusätzliche Methoden gegenüber .ar

// Noch besser funktioniert dieses Prinzip mithilfe von Ndefs:
// Ndefs sind eine von sehr viele "def" strukturen in SuperCollider. Diese legen wir dann unter einem Symbol als Key ab. So können wir sie jederzeit abrufen / abspielen und verändern:

Ndef(\sine, {SinOsc.ar(120, mul: 0.25)}).stop
Ndef(\sine, {SinOsc.ar(120, mul: 0.25)}).stop;

Ndef(\modsine, {SinOsc.ar(220, mul: 0.25) * LFPulse.kr(2)});  //  --> Vergleiche LFPulse und Pulse in der Help

// Indem wir fadeTime setzten können wir Ndefs während wir sie verändern ineinander faden
Ndef(\modsine).fadeTime = 5;
Ndef(\modsine).play;

Ndef(\modsine, {SinOsc.ar(440, mul: 0.25) * LFPulse.kr(2)});  //  --> Vergleiche LFPulse und Pulse in der Help
Ndef(\modsine).stop;

Ndef(\modsine).clear;

// Wir können auch Ndefs innerhalb Ndefs verwenden !

Ndef(\mod, {SinOsc.ar(5)});

// Additiv +  AM
// Hier setzten wir auch ein Argument dass wir im
Ndef(\x, { SinOsc.ar(440) + SinOsc.ar(440) * 0.1 * Ndef(\mod) !2  }).play;

// Simpel FM
Ndef(\cheapFM, {SinOsc.ar(440 + SinOsc.kr(XLine.kr(1, 600, 20), mul: XLine.kr(2, 200, 20)) )}).play;

// Nützlich: Bei Ndefs haben wir noch ein Mixer GUI zu verfügung:
NdefMixer(s);

// Hier setzten wir auch ein Argument dass wir im NdefMixer verändern können
// Was ich übersehen hatte:
// Hierzu müssen wir ganz rechts neben unseren Mixer auf das "ed" klicken, dann erweitert sich das Fenster !

(
Ndef(\x, {| freq = 220 |
	SinOsc.ar(freq) + SinOsc.ar(440)  * Ndef(\mod) !2 * 0.1
}).play;
)


