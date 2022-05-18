s.options.blockSize = 1;

(
// Fedback + Delay eines einfachen Impulses

Ndef(\impulse, {
	var sig = Impulse.ar(8).dup;
	var delayTime = MouseX.kr(0, 0.05);
	var fb = Ndef(\impulse).ar;

	sig = sig + (DelayC.ar(fb, 0.05, delayTime) * -0.99);

	sig;
});
)

Ndef(\impulse).play


(
// Feedback-Delay mit Sound-Input; Kopfhörer!
Ndef(\fb, {
	var sig = SoundIn.ar(0);
	var fb = Ndef(\fb).ar;

	sig = sig + (DelayC.ar(fb, 0.25, 0.25) * 0.75);

	sig;
});
)

Ndef(\fb).play


// Feedback-Quark

// Installieren via:
Quarks.gui;

// Die Hilfe ist noch in einem alten Hilfsformat, hierfür am besten:

// File > Open user support Directory
// Im Finder/Explorer: downloaded-quarks/Feedback ansteuern
// Dort gibt es dann .html Dateien die ihr im Browser öffnen könnt.

(
Ndef(\impulseQuark, {
	var sig = Impulse.ar(8).dup;
	var delayTime = MouseX.kr(0, 0.05);
	sig = sig + FbC({|fb| sig + fb * -0.99}, 0.05, delayTime);

	sig;
});
)

Ndef(\impulseQuark).play

