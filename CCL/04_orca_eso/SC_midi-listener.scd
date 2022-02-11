MIDIIn.connect;
s.boot;
s.meter;

(
SynthDef("ping", { | freq = 440, gate = 0.0, amp = 0.5, out |
    var snd, env;

	snd = SinOsc.ar(freq) !2;
	env = EnvGen.kr(Env.perc, gate);
	snd = snd * env;

	Out.ar(out, snd * amp);
}).add;
)

x = Synth("ping");
y = Synth("ping");

x.free;
y.free;


(
~noteOn = {arg src, chan, num, vel;

	num.postln;
	vel.postln;

	if(chan == 0) {x.set(\freq, num.midicps); x.set(\gate, vel);};
	if(chan == 1) {y.set(\freq, num.midicps); y.set(\gate, vel);};

};
)

MIDIIn.addFuncTo(\noteOn, ~noteOn);


(
~noteOff = { arg src,chan,num,vel;

	if(chan == 0) {x.set(\gate, 0.0);};
	if(chan == 1) {y.set(\gate, 0.0);};
};
)

MIDIIn.addFuncTo(\noteOff, ~noteOff);


MIDIIn.removeFuncFrom(\noteOn, ~noteOn);
MIDIIn.removeFuncFrom(\noteOff, ~noteOff);