#!/usr/bin/env python
"""Wav File to hex converter."""

# Base Python
from scipy.io import wavfile
import os
import matplotlib as plt
import argparse
import sys


""" --- FUNCTION: display_data() -- checking data contents (mono vs stereo) --- """ 
#works both mono & stereo
def display_data(audiofile, showgraphs = False):
    fs_in, data_in = wavfile.read(audiofile)
    print(f".Wav Contents = {data_in}")
    print(f".Wav Samples Length = {data_in.shape[0]}")
    print(f".Wav Channel(s) = {len(data_in.shape)}")
    length = data_in.shape[0] / fs_in
    print(f".Wav Length = {length}s")
    print(f"Sampling Rate= {fs_in} Hz")
    print(f"bit depth= {type(data_in[0])}")
    print(f"sampling rate = {fs_in} Hz, length = {data_in.shape[0]} samples => {data_in.shape[0]/fs_in} s, channels = {len(data_in.shape)}")

    # if showgraphs == True:
    #     plt.figure();
    #     plt.plot(data_in);
    #     plt.title(str(audiofile));
    #     plt.xlabel("Samples");
    #     plt.ylabel("Amplitude");
    print("-------------")

def twos_comp(val):
    """compute the 2's complement of int value val"""
    if val < 0:
        return 2**16 + val
    return val

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input',
                        help="input file name of human readable assembly")
    parser.add_argument('-o', '--output',
                        help="output file name of hex values in text that can be read from SystemVerilog's readmemh")
    parser.add_argument('-v', '--verbose', action="store_true",
                        help="increases verbosity of the script")
    parser.add_argument('-l', '--length', action="store",
                        help="number of entries to read from data file")
    args = parser.parse_args()
    if not os.path.exists(args.input):
        raise Exception(f"input file {args.input} does not exist.")
 
    samplerate, data = wavfile.read(args.input)

    if args.verbose:
        print(f"Parsed {len(data)} instructions. Label table:")
        print(f"Sample rate: {samplerate}")
    if args.output:
        with open(args.output, 'w+') as file:
            # file.write(format(samplerate, 'x') + '\n')
            print(args.length)
            print(len(data))
            # import pdb; pdb.set_trace()
            for value in data[0:(int(args.length) if args.length else None)]:
                file.write(f"{(twos_comp(value)):04x}\n")
    sys.exit(0)
    
    

    # display_data(filename, showgraphs=True)


if __name__ == "__main__":
    main()