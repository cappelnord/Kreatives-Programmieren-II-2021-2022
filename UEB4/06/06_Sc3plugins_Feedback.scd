
// Sc3-plugins

// Moog Filter

		SinOscFB.ar(100, 3, 0.2) !2,
		MouseX.kr(50, 3500),
		MouseY.kr(0, 4));

});
)

Ndef(\moog).play;

// Klingt gut mit LFO Wobbles :)

(
Ndef(\moog2, {

	MoogFF.ar( SinOscFB.ar(100, 1.5, 0.2) ,
		SinOsc.kr([3, 8] * LFNoise0.kr(1)).range(50, 2500),
		3.5);

}).play;
)


// Das Beispiel aus der Help klingt auch sehr fein

(
x = {
    MoogFF.ar(
        Pulse.ar([40,121], [0.3,0.7]),
        SinOsc.kr(LFNoise0.kr(0.42).range(0.001, 2.2)).range(30, 4200),
        0.83 * 4) * 0.5}.play
)
x.free;

(
{
  MoogVCF.ar(
       Pulse.ar([40,121],[0.3,0.7]),
     SinOsc.kr(LFNoise0.kr(0.42).range(0.001,2.2)).range(30,4200),0.8
) * 0.5 }.play(s);
)

(
{

	MoogLadder.ar(Mix(LFSaw.ar([120, 180], 0, 0.33)), LinExp.kr(LFCub.kr(0.1, 0.5*pi), -1, 1, 180, 8500), 0.75).dup

}.play
)

// Hier das Beispiel wie wir die Window Klasse nutzen können, damit unser Scope alwaysOnTop ist
// Leider habe mich nicht herausgefunden wie man die Größe da dynamisch anpassen kann
// Evtl geht es irgendwie mit ScopeView...

(
w = Window.new("my own scope", Rect(400, 400, 400, 400));
w.view.decorator = FlowLayout(w.view.bounds);
w.alwaysOnTop = true;
c = Stethoscope.new(s, view:w.view, bufsize: 4096);
//c = ScopeView.new(w.view, w.view.bounds.insetAll(10, 10, 10 ,10));

w.onClose = { c.free }; // don't forget this

w.front;
)


//////////////////////////////////////////////////////////////////////////// Feedback Experiments ////////////////////////////////////////////////////////////////////

// Wenn wir mit Feedback arbeiten sind LeakDC und Limiter Empfehlenswert um unseren Output etwas zu bändigen

s.meter(0, 2);

// Achtung, das hier ist trotzdem ziemlich Laut !

{ Limiter.ar(PinkNoise.ar(2), 0.5, 0.001) }.play;

// Oder wir nutzen Safety

Safety(s).enable;
Safety(s).setLimit(0.4);

s.plotTree;

{ PinkNoise.ar(2) }.play;

Safety(s).disable;


// Was auch immer geht ist natürlich clip
// Achtung trotz der * 0.5 noch Laut

(
{
	SinOscFB.ar(200, 1, mul: 4).clip ! 2 * 0.5;
}.play;
)


// Limiter im Vergleich

(
{
	Limiter.ar(
	SinOscFB.ar(
		200, 1, mul: 4),
		0.99,
		0.001) * 0.5 !2;
}.play;
)


// Alternativ können wir etwas weicher und / oder analoger mit tanh verzerren

// Im Scope kann man hier gut den unterschied zu clip sehen

s.scope;

(
{
	[Saw.ar(100, 1, mul: 20).tanh  * 0.5, Saw.ar(101, 1, mul:20).clip];
}.play;
)


// Bei .clip sollten wir außerdem noch minmax Argumente setzen
// Sonst erhalten wir ein DC offset...oder wir arbeiten mit LeakDC

(
{
	Saw.ar([100, 101], 1, mul: 20).clip(-0.8, 0.8)  * 0.5;
}.play;
)

(
{
	var snd;

	snd = Saw.ar([100, 101], 1, mul: 20).clip * 0.5;
	snd = LeakDC.ar(snd);

}.play;
)


// InFeedback ist gut dokumentiert und hat ein paar Beispiele für Setups mit Feedback

InFeedback

// Und hier das Ergebnis unserer bastelei mit InFeedback :)

~grainbuf = Buffer.alloc(s, 44100, 1);

(
SynthDef(\Feedb, { arg out=0, in=0;

	var input, sound, delay;

	// Hier können wir unser Feedback beeinflussen
	 // Am besten mal mit MouseX etwas ausprobieren
	input = InFeedback.ar(in, 1) * LFNoise1.kr(1).range(0.1, MouseX.kr(0.2, 1.05));

	delay = DelayC.ar(input, 0.5, [0.1, 0.25, 0.4]).sum;

	sound = Trig.ar(Impulse.ar(LFNoise1.kr([1, 1.1]).range(4, 12)), 0.001) * SinOscFB.ar(800, 1);
	sound = sound + delay;

	sound = JPverb.ar(sound) + sound * 0.75;

	BufWr.ar(sound.sum, ~grainbuf, Phasor.ar(0, BufRateScale.kr(~grainbuf), 0, 44100));

	Out.ar(out, sound.tanh * 0.5);

}).add;
)

~x = Synth(\Feedb);


// Feedback freeeeeze

(
Ndef(\grainfreeze, {

	GrainBuf.ar(1, Dust2.kr(100), 1, ~grainbuf, MouseY.kr(0.1, [1, 0.99]), 0.5) * 0.25;

});
)


Ndef(\grainfreeze).play;

~x.free;
~grainbuf.plot;















