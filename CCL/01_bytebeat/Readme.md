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

  - signedness: signed (0...255) vs. unsigned (-127...128)

- INTEGER OVERFLOW
  - https://en.wikipedia.org/wiki/Integer_overflow

- Let's saw!
  - [bytebeat.c](bytebeat.c)
  - `t` counts up to 4.294.967.296 (32-bit!)

- ENCODING (requires [FFmpeg](https://ffmpeg.org/download.html))
 - `./bytebeat | head -c 40000 | ffmpeg -f u8 -ar 8000 -ac 1 -i - -c:a pcm_u8 -y bytebeat.wav`

- FREQUENCY
 - sample rate / data type size (8000 / 255 = 31.3725490196 Hz)

## Literature & Links

- [Discovering novel computer music techniques by exploring the space of short computer programs](https://arxiv.org/abs/1112.1368)
- [Algorithmic symphonies from one line of code -- how and why?](http://viznut.fi/texts-en/bytebeat_algorithmic_symphonies.html)
- [Some deep analysis of one-line music programs.](http://viznut.fi/texts-en/bytebeat_deep_analysis.html)
- [Kragen](http://canonical.org/~kragen/bytebeat/)