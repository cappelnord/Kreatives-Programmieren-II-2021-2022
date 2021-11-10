```
 ___   _     _ _____ _____ ___   _____ ______ _____ 
|  _ \| \   / |_   _|  ___|  _ \|  ___|  __  |_   _|
| |_| |\ \_/ /  | | | |   | |_| | |   | |  | | | |  
|    /  \   /   | | | |___|    /| |___| |__| | | |  
|  _ \   | |    | | |  ___|  _ \|  ___|  __  | | |  
| |_| |  | |    | | | |___| |_| | |___| |  | | | |  
|____/   |_|    |_| |_____|____/|_____|_|  |_| |_|
```

## Fundamentals

- CHARS
  - https://en.wikipedia.org/wiki/Character_(computing)
  - https://en.wikipedia.org/wiki/C_(programming_language)#Character_set
  - unsigned (0...255) vs. signed (-127...128)

- INTEGER OVERFLOW
  - https://en.wikipedia.org/wiki/Integer_overflow

- LET'S SAW!
  - [bytebeat.c](bytebeat.c)
  - `t` counts up to 4.294.967.296 (32-bit!)

- ENCODING (requires [FFmpeg](https://ffmpeg.org/download.html))
  - `./bytebeat | head -c 40000 | ffmpeg -f u8 -ar 8000 -ac 1 -i - -c:a pcm_u8 -y bytebeat.wav` (5 sec. saw wave)

- FREQUENCY
  - sample rate / data type size (8000 / 255 = 31.3725490196 Hz)

- MATH
  - `*` or `/` ---> frequency control
  - `+` ---> phase shift
  - `-` ---> invert signal
  - `%` ---> wrapping `t` (results in frequency and amplitude change)

- BITWISE
  - `&` ---> square wave
  - `|`, `^`, `<<`, `>>` ---> ...

- RELATIONAL
  - `((t%8000)>4000)*t` ---> start 'n' stop (every 0.5 sec. for a sampling rate of 8kHz)

- SIERPINSKI
  - `t&t>>8`

## Literature & Links

- [HTML5 Bytebeat](https://greggman.com/downloads/examples/html5bytebeat/html5bytebeat.html)
- [Discovering novel computer music techniques by exploring the space of short computer programs](https://arxiv.org/abs/1112.1368)
- [Algorithmic symphonies from one line of code -- how and why?](http://viznut.fi/texts-en/bytebeat_algorithmic_symphonies.html)
- [Some deep analysis of one-line music programs.](http://viznut.fi/texts-en/bytebeat_deep_analysis.html)
- [Kragen](http://canonical.org/~kragen/bytebeat/)