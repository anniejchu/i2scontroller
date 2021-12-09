"""Wav File to hex converter."""

# Base Python
from scipy.io import wavfile
import os
import matplotlib as plt


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


def main():
    filename = os.path.join(os.getcwd(), 'CantinaBand3.wav')
    samplerate, data = wavfile.read(filename)

    display_data(filename, showgraphs=True)
    with open("CantinaBand3.hex", 'w+') as file:
        file.write(hex(samplerate) + '\n')
        for value in data[:]:
            file.write(hex(value) + '\n')

if __name__ == "__main__":
    main()