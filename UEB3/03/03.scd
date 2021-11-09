// Eine Synthese Form hatten wir bisher noch nicht beachtet:
// Die Subtraktive Synthese !
// D.h. wir formen unseren Klang, indem wir von einem reichaltigem Spektrum etwas wegnehmen

// Dazu benötigen wir allem voran erst einmal Filter
// Filter

// Am einfachsten lassen sich Filter an einem weißen Rauschen demonstrieren:

// WARNHINWEIS: Bei allen Filtern in SuperCollider gibt es zu beachten,
// dass cutoff Frequency Werte nahe 0 extrem laute glitches erzeugen können !!!
// Daher bitte immer noch einmal extra das 'freq' Argument  überprüfen

// Mit dem Freqscope können wir beobachten welche Frequnzen von unserem Filter durchgelassen und welche heraussgefiltert werden

s.freqscope;

// Lowpass
(
Ndef(\filterNoise, {

	var snd = WhiteNoise.ar(0.1);
	snd = LPF.ar(snd, MouseX.kr(50, 2500));

	snd.dup;

});

Ndef(\filterNoise).play;
)

// Highpass
(
Ndef(\filterNoise, {

	var snd = WhiteNoise.ar(0.1);
	snd = HPF.ar(snd, MouseX.kr(50, 2500));

	snd.dup;

});

Ndef(\filterNoise).play;
)

// Bandpass
(
Ndef(\filterNoise, {

	var snd = WhiteNoise.ar(0.1);
	snd = HPF.ar(snd, MouseX.kr(50, 2500));

	snd.dup;

});

Ndef(\filterNoise).play;
)


// Der RLPF / RHPF mit zusätzlicher Resonanz auf der Filterfrequenz / cutoff Frequency
// Der Q-Faktor (berechnet aus Bandbreite / Filterfrequenz) bestimmt zum einem wie steil die Filterkurve abfällt,
// bei Resonanzfiltern verstärkt er jedoch zusätzlich die Resonanz auf der cutoff Frequency

// Bei RLPFs / RHPFs geben wir den Q-Faktor als 'reciprocal of Q' also 1 / Q an
// Daraus ergibt sich für uns um so kleiner der Wert -> um so steiler der Filter / deutlicher die Resonanz

(
Ndef(\filterNoise, {

	var snd, ffreq, rq;

	snd = WhiteNoise.ar(0.1);

	ffreq = MouseX.kr(50, 2500);
	rq = MouseY.kr(1, 0.01);

	snd = RLPF.ar(snd, ffreq, rq);
	snd.dup;

});

Ndef(\filterNoise).play;
)

// Wollen wir ein extrem dünnes Band herausfiltern können wir Resonz benutzen

(
Ndef(\filterNoise, {

	var snd, ffreq, bwr;

	snd = WhiteNoise.ar(0.1);

	ffreq = MouseX.kr(50, 2500);
	bwr = MouseY.kr(1, 0.01);

	snd = Resonz.ar(snd, ffreq, rq);
	snd.dup;

});

Ndef(\filterNoise).play;
)

// So klingt das ganze wenn wir einen Obertonreichen Klang filtern:
// Zunächst mal einen Saw Cluster den wir filtern wollen;

(
Ndef(\sawCluster, { | midinote = 40, amp = 0.01|

	var cluster, sig, snd, ffreq, bwr;

	cluster = Array.series(30, midinote).midicps;
	sig = Saw.ar(cluster).sum;
	sig.dup * amp;

})
)

Ndef(\sawCluster).fadeTime = 1;
Ndef(\sawCluster).play;


// Nun können wir diesen Ndef in einem Filter Ndef aufrufen

(
Ndef(\filter, {

	var snd, ffreq, rq;

	ffreq = MouseX.kr(50, 2500);
	rq = MouseY.kr(1, 0.01);

	snd = RLPF.ar(Ndef(\sawCluster), ffreq, rq);
	snd; // Kein .dup da gefilterter Ndef schon Stereo ist

});
)

Ndef(\filter).play;


// Mit Parametern

(
Ndef(\filter, { |ffreq = 440|

	var snd, rq;

	rq = MouseY.kr(1, 0.01);

	snd = RLPF.ar(Ndef(\sawCluster), ffreq, rq);
	snd; // Kein .dupm da gefilterter Ndef schon Stereo ist

});
)

Ndef(\filter).play;

Ndef(\filter).set(\ffreq, 300);
Ndef(\filter).set(\ffreq, 1200);


//Mit .map können wir auch einen weiteren Ndef zur filterkontrolle benutzen
Ndef(\lfo, { LFNoise0.kr(2).exprange(100, 2000) });

Ndef(\filter).play;
Ndef(\filter).map(\ffreq, Ndef(\lfo));


// Das  soeben benutzte LFNoise generiert uns random werte zwischen - 1, 1 mit einer Frequenz in audio / control Rate:

{ LFNoise0.kr(2).poll }.play;

{ LFNoise0.kr(30).poll }.play;


// mit exprange können wir die Range der values setzen und somit sinnvolle Values für unseren lfo erzeugen:
// in diesem Beispiel wollen wir random Frequnz Werte erhalten, welche im Hörbaren Bereich liegen:

{ LFNoise0.kr(2).exprange(100, 2000).poll }.play;


// Weiter LFNoise UGen können auch zwischen den werten interpolieren:

// Keine Interpolation
(
{ SinOsc.ar(
        LFNoise0.ar(4, 400, 450),
        0, 0.1
    )
}.play;
)

// Lineare Interpolation
(
{ SinOsc.ar(
        LFNoise1.ar(4, 400, 450),
        0, 0.1
    )
}.play;
)

// Erhöhen wir nun die Frequenz und die Range unseres LFNoise
// nähern wir uns immer mehr dem Spektrum eines Noise Generators

(
Ndef(\lfNoise, {

	var snd = SinOsc.ar(LFNoise0.kr(XLine.kr(1, 10000, 10)).exprange(100, 500)) * 0.1;
	snd.dup;

}).play;
)


// Wollen wir mehrere Resonatoren also eine Filterbank nutzen können wir das mit Dynklank machen

(
Ndef(\filterbank, {

	var snd, freqs, amps, ringtimes;

	snd = WhiteNoise.ar(0.1);

	freqs = [220, 440, 150, 880, 1200];
	amps = [0.1, 0.05, 0.1, 0.1, 0.05];
	ringtimes = [3, 1, 2, 1, 1]; // decay times der Resonatoren


	snd = DynKlank.ar(`[freqs, amps, ringtimes], snd, freqscale: 1.0);
	snd.dup * 0.1; // Kann sehr schnell sehr Laut werden

});
)

Ndef(\filterbank).fadeTime = 2;
Ndef(\filterbank).play;


// Es gibt auch Klank, aber ich verwende meistens Dynklank weil wir dort die Resonanzen auch noch während der Laufzeit
// verändern können. Klank hingegen nutzt fixe Resonatoren.

(
Ndef(\filterbank, {

	var snd, freqs, amps, ringtimes;

	snd = WhiteNoise.ar(0.1);

	freqs = [220, 440, 150, 880, 1200];
	amps = [0.1, 0.05, 0.1, 0.1, 0.05];
	ringtimes = [3, 1, 2, 1, 1]; // decay times der Resonatoren


	snd = DynKlank.ar(`[freqs, amps, ringtimes], snd, freqscale: MouseX.kr(1, 6));
	snd.dup * 0.1; // Kann sehr schnell sehr Laut werden

});
)

Ndef(\filterbank).fadeTime = 2;
Ndef(\filterbank).play;


// Dynklank funktioniert auch sehr gut mit kurzen Impulsen

(
Ndef(\filterbank, {

	var snd, freqs, amps, ringtimes;

	snd = Impulse.ar(MouseY.kr(1, 6));

	freqs = [220, 440, 441, 880, 1200];
	amps = [0.1, 0.05, 0.1, 0.1, 0.05];
	ringtimes = [3, 1, 2, 1, 1] * MouseX.kr(10, 0.05);  // Auch gerne mal sehr unterschiedliche Ringtimes ausprobieren


	DynKlank.ar(`[freqs, amps, ringtimes], snd, freqscale: MouseX.kr(1, 6)).dup * 0.1;
	//snd.dup * 0.1; // Kann sehr schnell sehr Laut werden

});
)

Ndef(\filterbank).fadeTime = 4;
Ndef(\filterbank).play;

Ndef(\filterbank).clear;


// DLC Content:

// Cheap Distortion mit Clip.ar:
// Clip.ar beschränkt die Amplitude unseres Signals zwischen 2 werten (standartmäßig 0 und 1);
// So können wir Verzerrung erzeugen in dem wir die Amplitude unseres Signals zunächst extrem laut clippen und danach wieder absenken

(
Ndef(\filterbank, {

	var snd, freqs, amps, ringtimes;

	snd = Impulse.ar(MouseY.kr(1, 24));

	freqs = [220, 440, 441, 880, 1200];
	amps = [0.1, 0.05, 0.1, 0.1, 0.05];
	ringtimes = [3, 1, 2, 1, 1] * MouseX.kr(5, 0.05);  // Auch gerne mal sehr unterschiedliche Ringtimes ausprobieren

	snd = DynKlank.ar(`[freqs, amps, ringtimes], snd, freqscale: MouseX.kr(0.1, 6));

	snd = Clip.ar(snd * 30) * 0.1;
	snd.dup * 0.1; // Kann sehr schnell sehr Laut werden

});

Ndef(\filterbank).play;
)


// Es gibt noch eine ganze Menge mehr Filter eine gute Übersicht könnt ihr hier finden:

14_Subtractive_synthesis

// Für nächstes Mal könnte ihr euch  gerne noch den BPeakEQ als Equalizer anschauen:
BPeakEQ.ar(in, freq: 1200.0, rq: 1.0, db: 0.0, mul: 1.0, add: 0.0




