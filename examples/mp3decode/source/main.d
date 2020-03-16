module main;

import std.stdio;
import std.file;

import audioformats;

/// Usage: mp3decode source.mp3 output.wav
void main(string[] args)
{
    if (args.length != 3)
        throw new Exception("usage: mp3decode input.mp3 output.wav");

    string inputPath = args[1];
    string outputPath = args[2];

    AudioStream input, output;

    input.openFromFile(args[1]);

    float sampleRate = input.getSamplerate();
    int channels = input.getNumChannels();
    long lengthFrames = input.getLengthInFrames();

    writefln("Opening %s:", inputPath);
    writefln("  * format     = %s", convertAudioFileFormatToString(input.getFormat()) );
    writefln("  * samplerate = %s Hz", sampleRate);
    writefln("  * channels   = %s", channels);
    double seconds = lengthFrames / cast(double) sampleRate;
    writefln("  * length     = %.3g seconds (%s samples)", seconds, lengthFrames);

    float[] buf = new float[1024 * channels];

    output.openToFile(outputPath, AudioFileFormat.wav, sampleRate, channels);

    // Chunked encode/decode
    int totalFrames = 0;
    int framesRead;
    do
    {
        framesRead = input.readSamplesFloat(buf);
        output.writeSamplesFloat(buf[0..framesRead*channels]);
        totalFrames += framesRead;
    } while(framesRead > 0);

    output.destroy();

    writefln("=> %s frames decoded and written to %s", totalFrames, outputPath);
}