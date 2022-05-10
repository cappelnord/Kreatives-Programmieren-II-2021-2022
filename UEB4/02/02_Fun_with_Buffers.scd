
// Sound check
().play

s.scope;
// Ein Buffer ist die Server repräsentation von einem Array mit floats -> unsere Audio Sample

[0.1, -0.5, 0.35, -0, 0]

// Die Länge dieses Arrays ist folglich Channels * Samples


// Ein leerer Buffer in Stereo
~buf = Buffer.alloc(s, 10, 2);
~buf.plot;

// Mit Buffer.read können wir AudioSamples direkt aus einem SoundFile einlesen
// Die Größe des Buffers wird hierbei je nach Datei bzw von uns gewähltem Start und Endpunkt festgelegt

// Haben wir eine Datei gefunden können wir diese einfach in unseren Editor Draggen
// und erhalten den passenden Pfad

~buf = Buffer.read(s, "hierkommtderPfadzudeinemSampleperDragandDrop", startFrame: 2 * 44100);

~buf2 = Buffer.read(s, "hierkommtderPfadzudeinemSampleperDragandDrop");

~buf3 = Buffer.read(s,"/Users/anselmweber/Desktop/sample6.wav" );

// Wir können auch gezielt Channel in einen 1 Channel Buffer laden
~bufL = Buffer.readChannel(s, "/Users/anselmweber/Desktop/sample8.wav", channels: 0);

~bufL.plot;


// Den Buffer im Loop abspielen
(
Ndef(\playbuf1, {
	var snd = PlayBuf.ar(2, ~buf, 1, startPos: 0.0, loop: 1.0) * 0.2;
	snd;
}).play;
)

// Je nach abspielrate beinflussen wir dabei auch die Tonhöhe
// rate: 1 entspricht der SampleRate des Servers, das Sample wird mit 1:1 Geschwindigkeit abgespielt
// rate: 2 ist eine Oktave höher

(
Ndef(\playbuf1, {
	var snd = PlayBuf.ar(2, ~buf, rate: 2.0, startPos: 0.0, loop: 1.0) * 0.2;
	snd;
}).play;
)

// Negative rate spielt den Buffer rückwärts ab

(
Ndef(\playbuf1, {
	var snd = PlayBuf.ar(2, ~buf,rate: -1.0, startPos: 0.0, loop: 1.0) * 0.2;
	snd;
}).play;
)


// Ein Buffer mit negativer Rate und modulierter Abspielposition
// BufFrames.kr Gibt uns die aktuelle Anzahl der Frames, also die Größe des Buffers
(
Ndef(\playbuf1, {
	var snd = PlayBuf.ar(2, ~buf, -1, SinOsc.kr(0.1) * LFNoise1.kr(0.1) * BufFrames.kr(~buf), startPos: 0.0, loop: 1.0) * 0.2;
	snd;
}).play;
)


// Wir können mit BufRd unseren Buffer auch mit einem Signal auslesen
// Hier bietet sich ein Phasor Signal an
// Pro "Rampe" wird ein Teil des Buffers oder in diesem Beispiel der ganze Buffer abgespielt

(
Ndef(\bufrd, {
	var snd = BufRd.ar(2, ~buf3, Phasor.ar(1, BufRateScale.kr(~buf3) * 1, 0, BufFrames.kr(~buf3), 0));
	//snd = PitchShift.ar(snd, pitchRatio: 1.5);
	snd * 0.1;
}).play;
)


// Hier Lesen wir einen Buffer mit einem LFSaw aus und nutzen mutlichanne expansion
// Mit range kann dann  bestimmt werden, welche Samples ausgelesen werden

(
Ndef(\bufrd2, {
	var snd = BufRd.ar(2, ~buf3, LFSaw.ar([0.1, 0.5, 1, 3]).range(44100, 44100 * 3), loop: 1).sum ;
	snd.dup * 0.1;
}).play;
)


(
Ndef(\bufrd, {
	var snd = BufRd.ar(2, ~buf3, LFSaw.ar([0.1, 0.5]).range(44100, 44100 * 3), loop: 1);
	//snd = PitchShift.ar(snd, pitchRatio: [1, 1.5, 2, 1.25]);
	snd * 0.1;
}).play;
)


~buf.plot;

// Mit BufWr können wir in einen Buffer schreiben und ihn dann mit BufRd auszulesen
// Dabei können sich interessante Artefakte ergeben


// Wie allocaten einen Buffer der bei rate: 1 genau eine Sekunde dauert
~writebuf = Buffer.alloc(s, 44100, 2);


// Wir schreiben ein Sinus mithilfe eines LFCub in einen Buffer
(
Ndef(\BufSine, {
	var in;
	in = SinOsc.ar(100) * 0.1 !2;
	BufWr.ar(in, ~writebuf, LFCub.ar(1).range(0, 44100));
	0;
}).play;
)

// Und Lesen diesen mit einen Phasor mit halber rate wieder aus
(
Ndef(\BufRd, {

	var snd = BufRd.ar(2, ~writebuf, Phasor.ar(0, BufRateScale.kr(~writebuf) * 0.5, 0, 44100));
	snd.sum.dup;

}).play;
)


// Hier beschreiben wir die erste Hälfte des Buffers mit einem Saw
// Und die Zweite Hälfte mit einem Sinus
(
Ndef(\BufSaw, {
	var in;
	in = Saw.ar([100, 101]) * 0.1;
	BufWr.ar(in, ~writebuf, Phasor.ar(0, BufRateScale.kr(~writebuf) , 0, 44100 * 0.5));
	0;
}).play;

Ndef(\BufSine, {
	var in;
	in = SinOsc.ar([100, 101]) * 0.1;
	BufWr.ar(in, ~writebuf, LFCub.ar(1).range(44100 * 0.5, 44100));
	0;
}).play;
)


(
Ndef(\BufRd, {

	var snd = BufRd.ar(2, ~writebuf, Phasor.ar(0, BufRateScale.kr(~writebuf) * 0.5, 0, 44100));
	snd.sum.dup;

}).play;
)


// Beim auslesen kann man auch Kreativ werden :)
(
Ndef(\BufRd, {

	var snd = BufRd.ar(2, ~writebuf, Phasor.ar(0, BufRateScale.kr(~writebuf) * LFNoise1.kr([0.6, 0.2]).range(-3, 2), 0, 44100));
	snd;

}).play;
)

~writebuf.plot;

