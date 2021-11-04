// Kreatives Programmieren 3
// SuperCollider II
// 03.11.2021

s.boot;



// 1) Einfache Stereo-Aufnahme in SuperCollider:

// startet die Aufnahme
s.record;

// stopt die Aufnahme
s.stopRecording;

// Hinweise:

// a) Audiodaten werden standardmäßig im 32-Bit Float Format gespeichert.
//    Das hat den Vorteil, dass auch Werte außerhalb des Bereichs -1 bis 1
//    Samples nicht geclippt werden sondern in der Nachbearbeitung wieder
//    in einen gültigen Bereich runterskaliert werden können.
//    Nachteil: Einige Audiosoftware (z.B. Logic) kommt damit nicht klar.
//    Patrick nutzt meistens Audacity um dann in 24 Bit umzuwandeln.

// b) Cmd/Strg . stoppt auch die Aufnahme!




// 2) .ar / .kr

// Controll Rate (.kr) ermöglicht es Signale mit niedrigerer zeitlicher
// Auflösung zu berechnen. Im Endeffekt handelt es sich hier wirklich
// nur eine Möglichkeit die Performance zu optimieren. In vielerlei Anwendung
// ist dies aber Heutzutage gar nicht mehr allzu relevant.

// Pro Audionblock (standardmäßig 64 Samples groß) wird jeweils ein .kr
// Sample berechnet. .kr Signale werden in der Regel dann bei der Anwendung
// im Zusammenhang mit .ar Signalen linear interpoliert.

// gibt die aktuelle Blockgröße aus
s.options.blockSize;

// s.options hält auch weitere interessante Optionen für scsynth bereit.
s.options.dump;


// UGens: K2A, A2K - mit diesen kann man auch explizit zwischen den
// beiden Auflösungen umwandeln.


(
Ndef(\krar, {
	K2A.ar(SinOsc.kr(100)).dup * 0.3
}).play;
)

// Die lineare Interpolation wird sichtbar im Scope:
s.scope;




// 3) Amplitudenmodulation / Ringmodulation


// Ringmodulation, Frequenz nimmt zu. Wir hören die
// Amplitudenmodulation erst als Tremolo-Effekt
// (wechselnd lauter/leiser), dann verschwimmt der Klang
// und schließlich hören wir die beiden Seitenbänder nach
// unten/oben wandern.

(
Ndef(\am, {
	(SinOsc.ar(440) * SinOsc.ar(XLine.ar(0.1, 220, 20))).dup * 0.1
}).play;
)

// Die Frequenz der Seitenbänder ist:
// Trägerfrequenz + Modulationsfrequenz und
// Trägerfrequenz - Modulationsfrequenz

// Wir können dies visuell auch in einem Frequenz-Analyzer betrachten:
s.freqscope;


// Der Klang dieser beiden Ndefs sollte gleich sein:

(
Ndef(\am, {
	(SinOsc.ar(440) * SinOsc.ar(300)).dup * 0.1;
}).play;
)

(
Ndef(\am, {
	(SinOsc.ar(440 - 300) + SinOsc.ar(440 + 300)).dup * 0.05;
}).play;
)


// Modulieren wir ein Signal mit mehreren Teiltönen (oder ein
// ganzes Spektrum) dann wird auch hier jeder Teilton versetzt.

(
Ndef(\am, {
	var carrier = SinOsc.ar(500) + SinOsc.ar(1000);
	var mod = SinOsc.ar(100);
	(carrier * mod).dup * 0.1;
}).play;
)

(
Ndef(\am, {
	SinOsc.ar([500-100, 500+100, 1000-100, 1000+100]).sum.dup * 0.05;
}).play;
)

// Wir können jegliche Quelle modulieren, z.B. auch underen
// Audio-Eingang (Vorsicht: Feedback Gefahr)

(
Ndef(\ringmod, {
	SoundIn.ar().dup * SinOsc.ar(400) * 0.3
}).play;
)


// Exkurs: MouseX, MouseY
// Help: MouseX
// Help: MouseY

// Mit MouseX und MouseY können wir einfach mit unserem Klang
// interagieren: Die Position des Mauscursors auf dem Screen
// wird in ein .kr Signal umgewandelt. Über die Parameter
// können wir das Signal skalieren.

// Interaktiver Ringmod:

(
Ndef(\ringmod, {
	SoundIn.ar().dup * SinOsc.ar(MouseX.kr(110, 2200)) * 0.3
}).play;
)



// Modulieren wir nicht mit einem Signal das von -1 bis 1 sondern
// von 0 bis 1 schwingt dann bleibt ein Teil des originalen
// Spektrums erhalten.

// Mit .range können wir bei den meisten UGens den Signalumfang
// bestimmen. (min, max)


(
Ndef(\am, {
	(SinOsc.ar(880) * SinOsc.ar(XLine.ar(1, 440, 20)).range(0, 1)).dup * 0.1
}).play;
)

// Modulationstiefe steuern mit MouseX

(
Ndef(\am, {
	SinOsc.ar(880).dup * SinOsc.ar(440).range(MouseX.kr(1, -1), 1) * 0.1
}).play;
)


// Läuft eines der Seitenbänder unter 0 (oder über die Nyquist-Frequenz)
// dann wird es gespiegelt.

(
Ndef(\am, {
	(SinOsc.ar(440) * SinOsc.ar(XLine.ar(1, 880, 20))).dup * 0.1
}).play;
)


// Amplitudenmodulation ist auch ein gutes Beispiel um Anwendung von
// .kr und .ar zu demonstrieren. Während der langsamen Modulation
// hört man praktisch keinen Unterschied. Sobald die Modulationsfrequenz
// höher wird hört man jedoch Artefakte.

(
Ndef(\am, {
	SinOsc.ar(440).dup * SinOsc.kr(XLine.ar(1, 220, 20)) * 0.1;
}).play;
)