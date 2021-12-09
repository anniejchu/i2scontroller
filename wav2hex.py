"""Wav File to hex converter."""

# Base Python
from scipy.io import wavfile
import os

filename = os.path.join(os.getcwd(), 'Carol of the Bells.wav')
samplerate, data = wavfile.read(filename)

from pprint import pprint
import pdb; pdb.set_trace()

with open("Carol of the Bells.hex", 'w+') as file:
    file.write(str(list(data)))



