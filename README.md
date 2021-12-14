# Building a I2S transmitter in SystemVerilog
ENGR3410 Computer Architecture | Fall 2021

Annie Chu & Manu Patil

### Project Overview
In this project, we set to build a I2C transmitter in SystemVerilog to play music out of a speaker. Our MVP was to play an input .wav file and play it through an external speaker. Our stretch goal was replace a .wav file with a MIDI input.

I2S (Inter-Integrated Circuit Sound) is an serial bus interface standard used to connect digital audio devices, commonly used to communicate PCM audio data between ICs in an electronic device. The I2S bus typically has 3 wires:
1. SCK (Serial Clock)
2. WS (Word Select) -- used to flag Left or Right channel
3. SD (Serial Data) -- serial data to be communicated

This is shown in the figure below (Source: Hackaday)
<!-- ![I2S Bus Lines](https://hackaday.com/wp-content/uploads/2019/04/i2s-timing-themed.png)  -->
<img src="https://hackaday.com/wp-content/uploads/2019/04/i2s-timing-themed.png" alt="drawing" width="200"/>


### Project Execution
We chose a .wav recording of Carol of the Bells to transmit. Using the Python script wav2hex.py, we first extracted the PCM audio data array and sampling frequency (fs) from the .wav file and then converted all the integers to hex. This hex file serves as the memory file we load into our SystemVerilog program. 

### Hardware
- Xilinx Vivado
- MAX98357A I2S AMP BREAKOUT BOARD
- SPEAKER 8OHM 500MW 

![setup](https://drive.google.com/file/d/1S1xXc8DI54SKvtSzNJcG32rneTbHYrcp/view) 


