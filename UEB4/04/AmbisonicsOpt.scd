// ------------------------------------------------------------
// boot server

s = Server.default;
s.record
s.reboot;

p = ServerOptions.new;
ServerOptions.memSize;
p.memSize = 8192 * 100;

p.numOutputBusChannels = 4;

// ------------------------------------------------------------
// define convenience function to verify number of server outputs
(
~checkMyServerOutputs = { arg server, decoder;
    server.serverRunning.if({
        (decoder.numOutputs > server.options.numOutputBusChannels).if({
            "Number of Server output bus channels is less than number required by Decoder!".warn;
            "Server Outputs: %\n".postf(server.options.numOutputBusChannels);
            "Decoder Outputs: %\n\n".postf(decoder.numOutputs);
            "Update number of Server outputs as illustrated here: ".post;
            "http://doc.sccode.org/Classes/ServerOptions.html#examples".postln;
        }, {
            "Server has an adequate number of output bus channels for use with this Decoder!".postln;
        })
    })
}
)


// ------------------------------------------------------------
// choose a decoder

// stereophonic / binaural
~decoder = FoaDecoderMatrix.newStereo((131/2).degrad, 0.5) // Cardioids at 131 deg
~decoder = FoaDecoderKernel.newUHJ                         // UHJ (kernel)
~decoder = FoaDecoderKernel.newSpherical                   // synthetic binaural (kernel)
~decoder = FoaDecoderKernel.newListen()                       // KEMAR binaural (kernel)


// pantophonic (2D)
~decoder = FoaDecoderMatrix.newQuad(k: 'dual')             // psycho optimised quad
~decoder = FoaDecoderMatrix.newQuad(pi/6, 'dual')          // psycho optimised narrow quad
~decoder = FoaDecoderMatrix.new5_0                         // 5.0
~decoder = FoaDecoderMatrix.newPanto(6, k: 'dual')         // psycho optimised hex


// periphonic (3D)
~decoder = FoaDecoderMatrix.newPeri(k: 'dual')
(// psycho optimised cube
~decoder = FoaDecoderMatrix.newDiametric(                  // psycho optimised bi-rectangle
    [[30, 0], [-30, 0], [90, 35.3], [-90, 35.3]].degrad,
    'dual'
);
)

~decoder = FoaDecoderMatrix.newDiametric;


// inspect
~decoder.kind
~checkMyServerOutputs.value(s, ~decoder);




// ------------------------------------------------------------
// define ~renderDecode
(
~renderDecode = { arg in, decoder;
    var kind;
    var fl, bl, br, fr;
    var fc, lo;
    var sl, sr;
    var flu, blu, bru, fru;
    var fld, bld, brd, frd;
    var slu, sru, sld, srd;


    kind = decoder.kind;

    case
        { decoder.numChannels == 2 }
            {
                // decode to stereo (or binaural)
                FoaDecode.ar(in, decoder)
            }
        { kind == 'quad' }
            {
                // decode (to quad)
                #fl, bl, br, fr = FoaDecode.ar(in, decoder);

                // reorder output to match speaker arrangement
                [fl, fr, bl, br]
            }
        { kind == '5.0' }
            {
                // decode (to 5.0)
                #fc, fl, bl, br, fr = FoaDecode.ar(in, decoder);
                lo = Silent.ar;

                // reorder output to match speaker arrangement
                [fl, fr, fc, lo, bl, br]
            }
        { kind == 'panto' }
            {
                // decode (to hex)
                #fl, sl, bl, br, sr, fr = FoaDecode.ar(in, decoder);

                // reorder output to match speaker arrangement
                [fl, fr, sl, sr, bl, br]
            }
        { kind == 'peri' }
            {
                // decode (to cube)
                #flu, blu, bru, fru, fld, bld, brd, frd = FoaDecode.ar(in, decoder);

                // reorder output to match speaker arrangement
                [flu, fru, blu, bru, fld, frd, bld, brd]
            }
        { kind == 'diametric' }
            {
                // decode (to bi-rectangle)
                #fl, fr, slu, sru, br, bl, srd, sld = FoaDecode.ar(in, decoder);

                // reorder output to match speaker arrangement
                [fl, fr, bl, br, slu, sru, sld, srd]
            };
}
)

// mono pink noise source
~encoder.free

// define encoder kernel
~encoder = FoaEncoderKernel.newDiffuse
~encoder = FoaEncoderMatrix.newOmni
~encoder = FoaEncoderMatrix.newDirection
//~encoder = FoaEncoderMatrix.newAtoB
//~encoder = FoaEncoderKernel.newSpread

~encoder = FoaEncoderMatrix.newDirections;

~encoder = FoaEncoderMatrix.newPeri;

// ------------------------------------------------------------
// B-format examples, natural soundfield with imaging transform
// B-format soundfile read from disk

// choose transformer
~transformer = 'zoomX'
~transformer = 'pushX'
~transformer = 'directO'

//Atk.userSoundsDir

// read a whole sound into memory
// remember to free the buffer later!
// (boot the server, if you haven't!)
~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "/b-format/Hodges-Purcell.wav")
~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "/b-format/Leonard-Orfeo_Trio.wav")
~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "/b-format/Courville-Dialogue.wav")
~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "/b-format/Leonard-Chinook.wav")
~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "/b-format/Leonard-Fireworks.wav")
~sndbuf = Buffer.read(s, Atk.userSoundsDir ++ "/b-format/Anderson-Nearfield.wav")


(
{
    var sig;                            // audio signal
    var angle;                          // angle control


    // display transformer & decoder
    "Ambisonic transforming via % transformer".format(~transformer).postln;
    "Ambisonic decoding via % decoder".format(~decoder.kind).postln;

    // gain ---> top            = 90 deg
    //           bottom         = 0 deg
    angle = MouseY.kr(2pi, 0);


    // ------------------------------------------------------------
    // test sig
    sig = PlayBuf.ar(~sndbuf.numChannels, ~sndbuf, BufRateScale.kr(~sndbuf), doneAction:2);   // soundfile

    // ------------------------------------------------------------
    // transform
    sig = FoaTransform.ar(sig, ~transformer, angle);


    // ------------------------------------------------------------
    // decode (via ~renderDecode)
    ~renderDecode.value(sig, ~decoder)

}.scope;
)

// free buffer
~sndbuf.free
























