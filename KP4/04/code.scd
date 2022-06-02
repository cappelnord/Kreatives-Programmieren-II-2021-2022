// FM-Feedback

(
Ndef(\fb, {
	var modCtrl = 1000; // MouseY.kr(0, 1000); // modulationstiefe

	var ctrl = MouseX.kr(0, 1);

	var delayTime = MouseY.kr(0.0001, 0.002);

	var modRegular = SinOsc.ar(400) * (1.0 - ctrl);
	var modFeedback = DelayC.ar(Ndef(\fb).ar,1, delayTime)  * ctrl;

	var mod = (modRegular + modFeedback) * modCtrl;

	var sig = SinOsc.ar(200 + mod);
	sig;
});
)

(
Ndef(\fbOut, {
	LeakDC.ar(Ndef(\fb).ar(1)).dup * 0.5
});
)

Ndef(\fbOut).play



// Feedback mit Mikrofon, Pitch-Analyse und SinOsc Synthese

(
Ndef(\pitch, {
	var sig = SoundIn.ar;
	var pitch = Pitch.kr(sig);
	var freq = pitch[0];
	var hasFreq = pitch[1];
	pitch.poll;
	SinOsc.ar(pitch) * hasFreq * 0.4;
});
)

Ndef(\pitch).play



// Der Versuch ein akustisches Feedback mit Band-Reject-Filtern zu bändigen


(
Ndef(\pitchBRF, {
	var sig = SoundIn.ar.dup;
	var pitch = Pitch.kr(sig, maxFreq: 8000);
	var freq = pitch[0];
	var sig2 = BRF.ar(sig, freq, 0.1);
	var pitch2 = Pitch.kr(sig2, maxFreq: 8000);
	var freq2 = pitch2[0];
	var sig3 = BRF.ar(sig2, freq2, 0.1);
	var pitch3 = Pitch.kr(sig3, maxFreq: 8000);
	var freq3 = pitch3[0];
	BRF.ar(sig3, freq3, 0.1) * MouseX.kr(0, 1);
});
)

Ndef(\pitchBRF).play



(
Ndef(\fbSaw, {
	var ctrl = MouseX.kr(0, 1);
	var saw = Saw.ar(50) * (1.25 - ctrl);
	var fb = DelayC.ar(Ndef(\fbPitch).ar, 0.2, 0.2) * ctrl;
	var sig = saw + fb;
	var freq = Pitch.kr(sig)[0];
	BRF.ar(sig, freq, 0.1);
});
)



(
Ndef(\fbSawOut, {
	LeakDC.ar(Ndef(\fbSaw).ar(1)).dup * 0.5
});
)

Ndef(\fbSaw).play


// Das ist eher ein Unfall .. aber seht selbst :D


(
Ndef(\fbTrash, {
	var ctrl = MouseX.kr(0, 1);
	// weird und ungewollt aber OK.
	var saw = Saw.ar(50 + (Ndef(\fbPitch).ar * 50)) * (1.25 - ctrl);
	var fb = DelayC.ar(Ndef(\fbPitch).ar, 0.2, 0.2) * ctrl;
	var sig = saw + fb;
	var freq = Ndef(\fbPitch).kr;
	BRF.ar(sig, freq, 0.1);
});
)

(
Ndef(\fbFreq, {
	Pitch.kr(Ndef(\fbTrash))[0]
})
)



(
Ndef(\fbTrashOut, {
	LeakDC.ar(Ndef(\fbTrash).ar(1)).dup * 0.5
});
)

Ndef(\fbTrashOut).play


// Auch probieren: Amplitude

