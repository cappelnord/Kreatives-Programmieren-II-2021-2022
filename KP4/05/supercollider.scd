a = 100

a.postln;

(
{
	var f = MouseX.kr(220, 440);
	f.postln; // .poll
	SinOsc.ar(f);
}.play
)

// Interpretervariablen a-z

a = 1000;

a * 20

// Umgebungsvariablen
~a = 1000;
~apfel = 1000;
~apfel * 20;

~apfel

Environment.push(Environment.new())

~apfel = 5000
~apfel * 20

Environment.pop()


~apfel

// Stack - Last In First Out - LIFO
// Stack Overflow
// Queue - First In First Out - FIFO


// Help: ProxySpace

(
var apfel = 1000;
apfel * 20;
)

apfel.postln;

~birne.postln;
