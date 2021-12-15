# Building a I2S transmitter in SystemVerilog
ENGR3410 Computer Architecture | Fall 2021

Annie Chu & Manu Patil

## Project Overview
In this project, we set to build a I2S transmitter in SystemVerilog to play music out of a speaker. Our MVP was to play an input .wav file and play it through an external speaker. Our stretch goal was replace a .wav file with a MIDI input.

I2S (Inter-Integrated Circuit Sound) is an serial bus interface standard used to connect digital audio devices, commonly used to communicate PCM audio data between ICs in an electronic device. The I2S bus typically has 3 wires:
1. SCK (Serial Clock)
2. WS (Word Select) -- used to flag Left or Right channel
3. SD (Serial Data) -- serial data to be communicated

This is shown in the figure below (Source: Hackaday)

<img src="https://hackaday.com/wp-content/uploads/2019/04/i2s-timing-themed.png" alt="drawing" width="600"/>

## Project Execution
We chose a 3 second .wav recording of Cantina Band sourced from [UIC](https://www2.cs.uic.edu/~i101/SoundFiles/) to transmit. Using the Python script wav2hex.py, we first extracted the PCM audio data array and sampling frequency (fs) from the .wav file and then converted all data from integers to hex. This hex file serves as the memory file we loaded into our SystemVerilog program. 

### Hardware

#### Materials
- [Xilinx Cmod A7 (FPGA)](https://digilent.com/reference/programmable-logic/cmod-a7/start)
- [Adafruit I2S 3W Class D Amplifier Breakout](https://www.adafruit.com/product/3006)
  - [Board Pinouts](https://learn.adafruit.com/adafruit-max98357-i2s-class-d-mono-amp/pinouts)
- [Mini Metal Speaker w/ Wires - 8 ohm 0.5W](https://www.adafruit.com/product/1890)
- Breadboard
- Wires

#### Set Up

<img src="https://github.com/anniejchu/i2scontroller/blob/main/images/hardwaresetup.jpg" alt="drawing" width="600"/>

In the drawing above, we connected the FPGA to the I2S breakout board directly to the speaker. The I2S board has set pinouts describes in [this link](https://learn.adafruit.com/adafruit-max98357-i2s-class-d-mono-amp/pinouts). 

Given the following options for the configurable settings GAIN and SD/Mode, we chose:

_GAIN_
- 15dB if a 100K resistor is connected between GAIN and GND
- 12dB if GAIN is connected directly to GND
- **9dB if GAIN is not connected to anything (this is the default)**
- 6dB if GAIN is conneted directly to Vin
- 3dB if a 100K resistor is connected between GAIN and Vin

_SD/MODE_
- If SD is connected to ground directly (voltage is under 0.16V) then the amp is shut down
- **If the voltage on SD is between 0.16V and 0.77V then the output is (Left + Right)/2, that is the stereo average.** 
- If the voltage on SD is between 0.77V and 1.4V then the output is just the Right channel
- If the voltage on SD is higher than 1.4V then the output is the Left channel.

### Reference Material
[I2S Bus Specification](https://www.sparkfun.com/datasheets/BreakoutBoards/I2SBUS.pdf)

