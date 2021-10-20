# 20.10.2021; Kreatives Programmieren 3

## SuperCollider I - Über SuperCollider

### Wieso eine Programmiersprache nutzen um Musik und Klang zu erzeugen?

### SuperCollider

* [Download](https://supercollider.github.io/download)

### Aufbau

Das SuperCollider "Paket" beinhaltet 3 separate Komponenten. Jede dieser Komponente erfüllt einen gewissen Zweck, kann aber je nach Nutzung von SuperCollider ausgetauscht oder ausgelassen werden.

* Klangsyntheseserver: scsynth (bzw. supernova)
* Programmiersprache: sclang
* IDE: scide

* [Features](https://supercollider.github.io/)

sclang und scsynth kommunizieren über [Open Sound Control](http://opensoundcontrol.org/). Dadurch ist es auch möglich den Klangsyntheseserver scsynth über jegliche andere Programmiersprache relativ einfach anzusteuern. Viele Musikprogrammiersprachen nutzen scsynth als Klangsyntheseserver (z.B. [Sonic Pi](https://sonic-pi.net/), [Tidal Cycles](https://tidalcycles.org/), [FoxDot](https://foxdot.org/)). Man kann sclang auch ohne scsynth nutzen (um zum Beispiel Geräte per MIDI zu steuern). Es gibt auch viele alternative IDEs mit denen man mit SuperCollider arbeiten kann (Emacs, Vim, Atom, Visual Studio Code, ...). 

### Beispiele

* [Henry Vega - Sermon on wings and tergal lobes (Stimme: Anat Spiegel)](http://henryvega.net/music/wormsongs.php)
* [David Granström - Empty Room](https://hallowground.bandcamp.com/album/david-granstr-m-empty-room)
* [Jean-Philippe Drécourt - In​-​between, longing (seed 0262)](https://jpdrecourt.bandcamp.com/album/in-between-longing-seed-0262) [Infos](http://drecourt.com/writings/the-code-of-in-between-longing/)
* [SuperCollider Tweets (Beispiel: tengototen - Arvo Corman)](https://soundcloud.com/tengototen/arvo-corman?in=supercollider-showcase/sets/sc-tweets)
* [Eli Fieldsteel - Fracturs III for Flute and SuperCollider](https://www.youtube.com/watch?v=HjsQ8E1DNt0)
* [SuperCollider examples Ordner](https://github.com/supercollider/supercollider/tree/develop/examples)

### Tutorials

* [Getting Started with SuperCollider](https://doc.sccode.org/Tutorials/Getting-Started/00-Getting-Started-With-SC.html)
* [Eli Fieldsteel Tutorials auf YouTube](https://www.youtube.com/c/elifieldsteel/videos)
* [Weitere Tutorials](https://github.com/supercollider/supercollider/wiki/Tutorials)

### Kurzer Einblick in die IDE und Live Beispiele

[02_code_beispiele.scd](02_code_beispiele.scd)

### Ressourcen

* [SuperCollider Documentation](https://doc.sccode.org/)
* Wilson, S., Cottle, D., Collins, N. (eds) (2011). The SuperCollider Book. MIT Press.
* Valle, Andrea (2016). Introduction to SuperCollider. Logos Verlag Berlin.
* [SuperCollider Code Beispiele](https://sccode.org)
* [https://scsynth.org/](SuperCollider Forum)
* [https://www.facebook.com/groups/supercollider](SuperCollider Facebook Gruppe)