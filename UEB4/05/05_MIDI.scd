// Hiermit connecten wir unsere Devices und überprüfen, ob alles angeschlossen ist und erkannt wird

MIDIClient.init;
MIDIIn.connectAll;

MIDIClient.sources;


// Einfache Synths mit ein paar Argumenten die wir über MIDI steuern wollen

(
SynthDef(\midi, { | freq = 100, gate = 1, amp = 1 |

	var snd, env;

	env = EnvGen.ar(Env.adsr, gate, doneAction: 2);
	snd = SinOscFB.ar(freq * [1, 1.01], 0.75) * env;
	snd = snd * 0.2;

	Out.ar(0, snd * amp);

}).add;


SynthDef(\control, { | freq = 100, gate = 1, amp = 1, ffreq = 2000 |

	var snd, env;

	freq = Lag2.kr(freq, 0.01);

	env = EnvGen.ar(Env.adsr, gate, doneAction: 2);
	snd = SinOscFB.ar(freq * [1, 1.01], 0.75) * env;
	snd = LPF.ar(snd, ffreq);

	snd = snd * 0.05;

	Out.ar(0, snd * amp);

}).add;
)

// Test test
~x = Synth(\midi);
~x.set(\gate, 0);


// MIDIdef enthält alle Fumktionalität die wir brauchen um MIDI zu empfangen
// Zusätzlich zur Superklasse MIDIFunc können wir unseren MIDIdef unter einem Key abspeichern
// Und bei erneuten ausführen ersetzen (wir kennen das ja schon von vielen anderen "defs" wie zum beispiel dem Pdef

// Da MIDIdefs innerhalb von sclang exisiteren, können wir hier auch auf bedingte Anweisungen oder andere Language spezifische Konstrukte zurückgreifen.
// Dadurch können wir die Daten damit auch erst einmal filtern und skalieren bevor wir sie auf Parameter in unserer Klangsynthese mappen

// Über verschiedene Convenience Methods können wir außerdem direkt bestimmte MIDI Events abgreifen


// Einfacher MIDIdef.noteOn um zu überprüfen, was wir an MIDI Daten empfangen

(
MIDIdef.noteOn(\note, { |...args|

	args.postln;

});
)


// EIn Möglicher Aufbau um Polyphon zu arbeiten:
// Da wir unsere Synths in einem Array unter ihrer note number ablegen
// Können wir beim noteOff immer den zugehörigen Synth releasen

~synths = Array.newClear(128);

(
MIDIdef.noteOn(\note, { |vel, nn|

	nn.postln;
	~synths[nn] = Synth(\midi, [

		\freq, nn.midicps,

	]);

});


MIDIdef.noteOff(\noteOff, { |vel, nn|

	~synths[nn].set(\gate, 0);

});
)


// Praktische Funktionen für einfachers Mapping sind linlin und explin
// Hier wird inMin und inMax linear auf outMin und outMax gemappt

(
MIDIdef.noteOn(\note, { |vel, nn|

	nn.postln;
	~synths[nn] = Synth(\midi, [

		\freq, nn.midicps,
		\amp, vel.linlin(0, 127, 0.01, 1);

	]);

});
)


// Das Gleiche mit exponentiellem output
// -> Ein Language reboot hat den Fehler, warum linexp in der Übung nicht funktioniert hat übrigens gelöst :)

(
MIDIdef.noteOn(\note, { |vel, nn|

	["raw" + vel].postln;
	vel.linexp(0, 127, 0.01, 1).postln;
	~synths[nn] = Synth(\midi, [

		\freq, nn.midicps

	]);

});

MIDIdef.noteOff(\noteOff, { |vel, nn|

	~synths[nn].set(\gate, 0);

});
)


// MIDIdef.cc für control values

(
MIDIdef.cc(\controlArgs, { | ...argd |

	args.postln;

});
)


// Mit weiteren Messages Funktionen wir fold, wrap, blend oder clip können wir das verhalten unserer potis entsprechend verändern:
// Ihr findet sie inder Help unter:
AbstractFunction


// fold
(
~x = Synth(\control);

MIDIdef.cc(\freq1, { | cv, cc |

	cv.postln;

	~x.set(\freq, cv.linexp(0, 127, 100, 2500).fold(150, 2000));

});
)


// clip ist bereits bekannt aus der Klangsynthese, funktioniert hier ebenso:

(
~x = Synth(\control);

MIDIdef.cc(\freq1, { | cv, cc |

	cv.postln;

	~x.set(\freq, cv.linexp(0, 127, 100, 2500).clip(300, 700));

});
)


//...Doch wollen wir unsere Parameter Mapping noch weiter modifizieren
// Können wir unseren MIDI Input als Index Benutzen um aus einer custom Env auszuwählen:


~myEnv = Env({2500.rand} ! 10, {1.7.rand} !9, 'sine');

~myEnv.plot;


// Gibt uns einen "level" Wert zu einem bestimmten "time" Wert:

~myEnv.at(0.5);
~myEnv.at(0.1);

(
~x = Synth(\control);

MIDIdef.cc(\freq1, { | cv, cc |

	["Raw: " ++ cv].postln;
	"Envelope: ".postln;

	~x.set(\freq, ~myEnv.at(cv.linlin(0, 127, 0, 1.7)).postln;);

});
)


// Über eine Liste können wir dann zusätzlich auch auf Vergangen Werte zugreifen
// Und Beispielsweise den Durchschnittswert daraus berechen

~histo = List.new;


// Am Ende erhalten wir dann doch sehr viel Kontrollmöglichkeiten aus einer ein Dimensionialen Poti Bewegung :)

(
~x = Synth(\control);

MIDIdef.cc(\freq1, { | cv, cc |

	~histo.addFirst(cv);

	["Raw: " ++ cv].postln;
	"Envelope: ".postln;
	~x.set(
		\freq, ~myEnv.at(cv.linlin(0, 127, 0, 1.7)).postln;
		\ffreq, ~hist[..10].mean.linlin(0, 127, 500, 2500)
	);

});
)

~histo.plotHisto(128, 0, 127);


