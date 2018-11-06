# State-Machine-with-Audio-Output
A finite state machine to control an audio codec on an FPGA using VHDL
The frequency of the square wave is controlled through the internal signal tone_terminal_count. This count will be assigned to 4 possible values, called COUNT_C5, COUNT_E5, COUNT_G5, and COUNT_C6. These are the four notes of a simple tune, each note should be played for one second.
