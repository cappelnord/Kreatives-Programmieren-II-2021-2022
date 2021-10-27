// Kreatives Programmieren 3
// SuperCollider II
// 27.10.2021

s.boot;

// Exkurs: Ein beliebter Testsound unter SuperCollider Usern
().play;

// () ist ein leeres Event, ein mit dem Dictionary verwandtes Objekt
// Help: Event

// Wir können ein Event auch weiter parametrisieren, z.B.
// eine musikalische Stufe, Skala, Oktave bestimmen:

(degree: 0, octave: 5).play;

(degree: 0, octave: 4).play;

(degree: 0, scale: Scale.minor).play;
(degree: 1, scale: Scale.minor).play;
(degree: 2, scale: Scale.minor).play;
(degree: 3, scale: Scale.minor).play;


// wir können auch direkt die Frequenz angeben
(freq: 200).play;


// Wiederholung Ndefs
// Help: Ndef

// Ndefs erlauben uns Klangsyntheseprozesse über einen Namen anzusprechen.
// Zudem haben Ndefs noch ein paar mehr Fähigkeiten als nackte Syntheseprozesse
// in Funktionsklammern.

// Führt man diese beiden Anweisungen aus erklingen 2 Sinustöne gleichzeitig.

{SinOsc.ar(550) * 0.1}.play;
{SinOsc.ar(440) * 0.1}.play;

// Wenn wir den gleichen Synthesecode in einen Ndef packen
// dann wird der bereits erklingende Klang durch den neuen ersetzt.

Ndef(\apfel, {SinOsc.ar(550) * 0.1}).play;
Ndef(\apfel, {SinOsc.ar(440) * 0.1}).play;

// Da der Syntheseprozess nun auch einen Namen hat können wir ihn gezielt stoppen.

Ndef(\apfel).stop;

// Wir können die fadeTime eines Ndefs setzen. Bei der Ersetzung des Klangs
// findet dann ein Crossfade statt.

Ndef(\apfel).fadeTime = 3;

Ndef(\apfel, {Saw.ar(100) * 0.1}).play;
Ndef(\apfel, {Saw.ar(200) * 0.1});
Ndef(\apfel, {Saw.ar(400) * 0.1});

Ndef(\apfel).stop;

// Ndefs können auch Parameter haben. Hierrüber können wir z.B.
// eine Frequenz steuern.

Ndef(\apfel, {| freq = 200| SinOsc.ar(freq) * 0.1}).play;
Ndef(\apfel).set(\freq, 600);
Ndef(\apfel).set(\freq, 400);
Ndef(\apfel, {| freq = 200| Saw.ar(freq) * 0.1});


Ndef(\apfel).stop;

// Wir werden im Laufe des Seminars/der Übung noch mehr über Ndefs erfahren!




// Arrays in SuperCollider ...

// Help: Collection
// Help: SequencableCollection
// Help: Array

// ... ähneln erstmal sehr denen von Python:
// Wir können Objekte jeglichen Typs dort ablegen:

x = [50, "Apfel", {}, SinOsc];

// Oftmals ist es aber sinnvoller Objekte des gleichen Typs in einem Array zu fassen.

x = [100, 200, 300, 400];

// Wir können auf Elemente per Index zugreifen ...

x[0];

// ... und einzelne Werte des Arrays verändern

x[0] = 1000;

x;

// Es gibt eine Vielzahl an Methoden die bereits in der SuperCollider
// Standardbibliothek implementiert sind.

x.sum // Summe
x.scramble // Eine durchmischte Kopie zurückgeben
x.size //  wie viele Elemente hat der Array?


// Arithmetische Operationen (und auch einige mathematischen Funktionen)
// werden für jedes Element des Arrays ausgeführt.

x = [1, 2, 3, 4];

x * 10;
x + 100;

x.sin; // Sinus für jedes Element des Arrays


// Wir können auch 2 Arrays miteinander verrechnen.
//

x = [1, 2, 3, 4];
y = [1, 10, 100, 1000];

x * y;

// Wir sehen: Die Elemente im Array werden
// miteinander verrechnet.


// Was passiert wenn Arrays nicht die
// gleiche Länge haben?

x = [1, 2, 3, 4];
y = [1, 10, 100];

x * y;

// Beim kürzeren Array wird einfach wieder von vorne angefangen.


// Exkurs: for-Schleife in SuperCollider.
// .do wird in SuperCollider fast immer als "for" bzw. "foreach"
// Schleife genutzt.

(
// Zählschleife
100.do {|i|
	i.postln;
};
)

(
// Iteriere über einen Array
[10, 20, 30].do {|value|
	value.postln;
}
)


// Auf der Klangsyntheseseite steht ein Array für
// ein mehrkanaliges Signal. Für Stereosound brauchen
// wir z.B. 2 Kanäle.


// 50 Hz Links, 400 Hz Rechts
Ndef(\stereo, { [Saw.ar(50), Saw.ar(400)] * 0.1}).play;



// Über Multichannel Expansion werden immer, wenn als
// Argument für ein UGen ein Array genutzt wird mehrere
// Instanzen des UGens erzeugt.

// Help: Multichannel Expansion


// Effektiv das selbe wie oben aber kürzer.
Ndef(\stereo, { Saw.ar([50, 400]) * 0.1}).play;


// Wir können beliebig viele Audiosignale paralell führen.
// Dies ist auch sehr gängig in der Klangsynthese. Mit .sum
// können wir mehrkanalige Signale dann wieder zusammenmischen.
// mit .dup duplizieren wir das Signal. Dadurch erhalten wir
// wieder ein Stereo Signal (beide Seiten gleich).

Ndef(\stereo, { Saw.ar([50, 400, 800, 1200]).sum.dup * 0.1}).play;

// Eine Alternative ist Splay (Stereo-Play oder Spread-Play).
// Hierbei werden alle Kanäle im Stereofeld verteilt.
// Von Links nach Rechts.

Ndef(\stereo, { Splay.ar(Saw.ar([50, 400, 800, 1200])) * 0.1}).play;


// Alle regeln (Operationen auf Arrays, Operationen mit Arrays) von
// oben gelten auch auf der Klangsyntheseseite. Dies ist ein Beispiel
// additiver Synthese bei der wir sinusartige Obertöne (ganzzahlige vielfache
// einer Grundfrequenz) mit einer jeweilgen Amplitude multiplizieren und
// zusammen mischen.

Ndef(\additiv, { (SinOsc.ar([1, 3, 5, 7, 9] * 300) * [1, 0.6, 0.25, 1, 0.25]).sum.dup * 0.1}).play


// Etwas übersichtlicher: Wir nutzen Variablen um Frequenzen und Amplituden zu speichern.
// Der ganze Codeblock wird nun zusammen ausgeführt. Mehr zur Nutzung von Variablen bald!

(
Ndef(\additiv, {
	var freqs = [1, 3, 5, 7, 9] * 300;
	var amps = [1, 0.6, 0.25, 1, 0.25];
	(SinOsc.ar(freqs) * amps).sum.dup * 0.1;
}).play;
)


// Multichannel Expansion Bonus:

// Wir haben oben kurz das Event gesehen. Auch hier funktioniert Multichannel-Expansion

(degree: [0, 2, 4], scale: Scale.minor).play;

(degree: [0, 2, 4], scale: Scale.major).play;

