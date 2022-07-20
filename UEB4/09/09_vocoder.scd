// Kurzer Exkurs zu OSCdefs
s.scope;

().play;

OSCdef

NetAddr.langPort;

// OSC Basics

n = NetAddr("127.0.0.1", 57120); // local machine
(
OSCdef(\test, {|msg, time, addr, recvPort|

	msg.postln;


}, '/chat', n); // def style
)

n.sendMsg("/chat", "Hallo");



/////////////////////////////////////////////////////////////////////////// VOCODER ////////////////////////////////////////////////////////

// Unser Vocoder aus der Übung
// Dieser ist nachgebaut nach dem Schema aus dem deutschen Wikipedia Artikel zu Vocoder

~sample = Buffer.readChannel(s,"YourSamplePath", channels: [0]);

(
SynthDef(\vocoder, { |buffer, rq = 0.05, amp = 10, in = 0|

	var snd, carrier, voice, numBands, bands, voiceAmps, dry;


	voice = PlayBuf.ar(buffer.numChannels, buffer, BufRateScale.kr(buffer), loop: 1);


	// Je höher desto präzieser das tracking allerdings auf kosten der CPU auslastung
	numBands = 32;

	// Gibt uns ein Array von 1 bis numBands und mappt darauf exponentiell Frequenz mit denen wir filtern wollen
	bands = (1..numBands).linexp(1, numBands, 100, 8000);

	// Teilt die Voice in schmale Bänder auf und analysieren deren Peak Amplitude
	voice = BPF.ar(voice, bands,  rq);
	voiceAmps = Amplitude.kr(voice);


	carrier = Saw.ar(100 * [1, 1.01, 2, 2.01] * MouseY.kr(1, 4));

	// Der Carrier wird nach dem selben Prinzip gefiltert
	carrier = BPF.ar(carrier, bands, rq);
	snd = carrier * voiceAmps * amp;


	Out.ar(0, snd.sum.dup);

}).add
)

Synth(\vocoder, [\buffer, ~sample]);


// Für eine exaktere Wiedergabe hoher Transienten in der Stimme können wir mit diesem Trick arbeiten:

// Mit ZeroCrossing können wir über einen relativ sparsamen Algorithmus den Pitch unseres inputs analysieren
// Übersteigt dieser einen gewissen wert gibt uns der Vergleichsoperator true == 1 zurück
// Nehmen wir nur das Ergebnis dieses Vergleichs als index für SelectX
// Können wir je nach Pitch das Signal switchen:

(
{
	var index, input;

	input = SinOsc.ar(LFNoise1.kr(5).range(100, 500));

	index = ZeroCrossing.ar(input).poll > 250;

	SelectX.ar(index, [Saw.ar([100, 100.01]) * 0.25, PinkNoise.ar(0.25)]);

}.play;
)

// Das können wir uns zu nutze machen um transienten der Stimme wir "k", "t", "s"
// mit einem PinkNoise zu synthethisieren

// Dadurch wird die "Artikulation" unseres Vocoders gleich etwas deutlicher:

(
SynthDef(\vocTransient, { |buffer, rq = 0.05, amp = 10, in = 0|

	var snd, carrier, voice, numBands, bands, voiceAmps, dry;

	voice = PlayBuf.ar(buffer.numChannels, buffer, BufRateScale.kr(buffer), loop: 1);

	numBands = 32;

	bands = (1..numBands).linexp(1, numBands, 100, 8000);

	voice = BPF.ar(voice, bands,  rq);
	voiceAmps = Amplitude.kr(voice);


	carrier = Saw.ar(100 * [1, 1.01, 2, 2.01] * MouseY.kr(1, 4));

	// Tauscht unseren carrier ab 5000 Herz mit einem PinkNoise aus
	carrier = SelectX.ar((ZeroCrossing.ar(voice).lag(0.05) > 5000), [carrier, PinkNoise.ar]);

	carrier = BPF.ar(carrier, bands, rq);
	snd = carrier * voiceAmps * amp;

	Out.ar(0, snd.sum.dup);

}).add
)

Synth(\vocTransient, [\buffer, ~sample]);




// Und hier die häufigste Anwendung des Vocoders zusammen mit einem MIDI Synth als carrier


MIDIClient.init;
MIDIIn.connectAll;

(
~fxbus = Bus.audio(s, 2);

~sample2 = Buffer.readChannel(s,"AnotherSamplePath", channels: [0]);
~synths = Array.newClear(128);


SynthDef(\vocoderFX, { |buffer, rq = 0.05, amp = 10, in = 0|

	var snd, carrier, voice, numBands, bands, voiceAmps, dry;

	//voice = SoundIn.ar(0);
	voice = PlayBuf.ar(buffer.numChannels, buffer, BufRateScale.kr(buffer), loop: 1);

	numBands = 64;
	bands = (1..numBands).linexp(1, numBands, 100, 8000);

	voice = BPF.ar(voice, bands,  rq);
	voiceAmps = Amplitude.kr(voice);

	//carrier = Saw.ar(100 * [1, 1.01, 2, 2.04] * MouseY.kr(1, 4));
	carrier = In.ar(in, 2);

	carrier = BPF.ar(carrier, bands, rq);

	snd = carrier * voiceAmps * amp;

	//snd = snd + dry

	Out.ar(0, snd.sum.dup);

}).add;


SynthDef(\midi, { | freq = 100, gate = 1, amp = 1, out = 0 |

	var snd, env;

	env = EnvGen.ar(Env.adsr, gate, doneAction: 2);
	snd = Saw.ar(freq * [1, 1.01]) * env;
	snd = snd * 1;

	Out.ar(out, snd * amp);

}).add;
)


// Code aus 05_MIDI aus diesem Semester:

(
MIDIdef.noteOn(\note, { |vel, nn|

	nn.postln;
	~synths[nn] = Synth(\midi, [

		\freq, nn.midicps * 0.5,
		\out, ~fxbus

	]);

});


MIDIdef.noteOff(\noteOff, { |vel, nn|

	~synths[nn].set(\gate, 0);

});

Synth(\vocoderFX, [\buffer, ~sample2, \in, ~fxbus], addAction: \addToTail);
)



// Wollen wir nun den Hardware Input anstatt sample nutzen kann es sein, dass  numWireBufs des Servers dazu nicht ausreichen

Server.default.options.numWireBufs = 1024;
s.reboot;


// Same same nur mit SoundIn anstatt dem Sample

(
~fxbus = Bus.audio(s, 2);

~sample2 = Buffer.readChannel(s,"yourSample", channels: [0]);
~synths = Array.newClear(128);


SynthDef(\vocoderFX, { | rq = 0.05, amp = 10, in = 0|

	var snd, carrier, voice, numBands, bands, voiceAmps, dry;

	voice = SoundIn.ar(0);

	numBands = 64;
	bands = (1..numBands).linexp(1, numBands, 100, 8000);

	voice = BPF.ar(voice, bands,  rq);
	voiceAmps = Amplitude.kr(voice);

	//carrier = Saw.ar(100 * [1, 1.01, 2, 2.04] * MouseY.kr(1, 4));
	carrier = In.ar(in, 2);

	carrier = BPF.ar(carrier, bands, rq);

	snd = carrier * voiceAmps * amp;

	//snd = snd + dry

	Out.ar(0, snd.sum.dup);

}).add;


SynthDef(\midi, { | freq = 100, gate = 1, amp = 1, out = 0 |

	var snd, env;

	env = EnvGen.ar(Env.adsr, gate, doneAction: 2);
	snd = Saw.ar(freq * [1, 1.01]) * env;

	snd = snd * 1;

	Out.ar(out, snd * amp);

}).add;
)


// Code aus 05_MIDI von diesem Semester:

(
MIDIdef.noteOn(\note, { |vel, nn|

	nn.postln;
	~synths[nn] = Synth(\midi, [

		\freq, nn.midicps * 0.5,
		\out, ~fxbus

	]);

});


MIDIdef.noteOff(\noteOff, { |vel, nn|

	~synths[nn].set(\gate, 0);

});

Synth(\vocoderFX, [\in, ~fxbus], addAction: \addToTail);
)








