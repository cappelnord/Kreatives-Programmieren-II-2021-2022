// Mit LeakDC kann man Gleichspannungsanteile entfernen ...
// ... ähnlich würde es auch mit HPF gehen (z.B. HPF mit 20 Hz)

(
{
	var sig = SinOsc.ar(0.1);
	LeakDC.ar(sig);
}.play
)

// Immer gut:

// Video-Feedback mit Kamera und Screen: machen!
// Oder auch mit digitalem Video, z.B. mit Hydra
// https://hydra.ojack.xyz/



// Ein Versuch einer Amplitudenmodulation mit Feedback

(
Ndef(\fb, {
	var ctrl = MouseX.kr(0, 1);
	SinOsc.ar(50) * ((1-ctrl) + (ctrl * DelayC.ar(Ndef.ar(\fb), 0.1, MouseY.kr(0, 0.1)) * 4)) * 0.75;
})
)

// Anstatt Ndef(\fb) direkt zu spielen gebe ich ihn über einen weiteren Ndef aus
// der dann wiederrum mit .tanh in seinem Umfang begenzt wird.

(
Ndef(\fbOut, {
	// hier wäre auch noch mal ein guter Ort einen Reverb o.ä. hinzuzufügen
	LeakDC.ar(Ndef(\fb).ar.tanh) * 0.5
})
)

Ndef(\fbOut).play;


// Manchmal kommt der \fb Ndef in einen Zustand bei dem der Feedbackloop dann keinen Klang mehr
// generiert. Hier hilft dann den Ndef zu clearen und wieder neu auszuwerten.

Ndef(\fb).clear


// Weitere Ideen:
// Feedback mit Frequenzmodulation
// Pitch, Amplitude
