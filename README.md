# FightPGA

A simple 2-player fighting game written from scratch in Verilog (targeting Cyclone V/DE1-SoC).

## Project Setup

First you need to import the project into Quartus using the qpf file in the quartus folder. The sof file for direct upload to a DE1-SoC is also available in that folder. For anyone wishing to remap the pins, the pin assignments for the DE1 top-level module are:
|Signal           |Location|Explanation                 |Relevant Input on Board|
|-----------------|--------|----------------------------|-----------------------|
|clk_out          |PIN_A11 |VGA DAC Clock output        |                       |
|display_en       |PIN_F10 |VGA DAC enable output       |                       |
|hsync            |PIN_B11 |VGA DAC hsync               |                       |
|vga_sync         |PIN_C10 |VGA DAC sync output         |                       |
|vsync            |PIN_D11 |VGA DAC vsync output        |                       |
|p1_inputs\[0\]     |PIN_AG25|Player 1 walk forward input |GPIO bank 1 pin 9      |
|p1_inputs\[1\]     |PIN_AF25|Player 1 walk backward input|GPIO bank 1 pin 7      |
|p1_inputs\[2\]     |PIN_AC23|Player 1 grab input         |GPIO bank 1 pin 5      |
|p1_inputs\[3\]     |PIN_AE23|Player 1 block input        |GPIO bank 1 pin 3      |
|p1_inputs\[4\]     |PIN_AA21|Player 1 kick input         |GPIO bank 1 pin 1      |
|p2_inputs\[0\]     |PIN_AC22|Player 2 walk forward input |GPIO bank 1 pin 35     |
|p2_inputs\[1\]     |PIN_AD21|Player 2 walk backward input|GPIO bank 1 pin 33     |
|p2_inputs\[2\]     |PIN_AG22|Player 2 grab input         |GPIO bank 1 pin 29     |
|p2_inputs\[3\]     |PIN_AF23|Player 2 block input        |GPIO bank 1 pin 31     |
|p2_inputs\[4\]     |PIN_AJ22|Player 2 kick input         |GPIO bank 1 pin 27     |
|palette_select\[0\]|PIN_AB12|Palette swap bit 0 input    |Slide switch 0         |
|palette_select\[1\]|PIN_AC12|Palette swap bit 1 input    |Slide switch 1         |
|pll_locked       |PIN_V16 |PLL lock success LED output |LED 0                  |
|ref_clk          |PIN_AF14|50 MHz onboard clock input  |                       |
|reset            |PIN_AA14|Global reset input          |Keybutton 0            |
|vga_b\[0\]         |PIN_B13 |VGA DAC blue bit 0 output   |                       |
|vga_b\[1\]         |PIN_G13 |VGA DAC blue bit 1 output   |                       |
|vga_b\[2\]         |PIN_H13 |VGA DAC blue bit 2 output   |                       |
|vga_b\[3\]         |PIN_F14 |VGA DAC blue bit 3 output   |                       |
|vga_b\[4\]         |PIN_H14 |VGA DAC blue bit 4 output   |                       |
|vga_b\[5\]         |PIN_F15 |VGA DAC blue bit 5 output   |                       |
|vga_b\[6\]         |PIN_G15 |VGA DAC blue bit 6 output   |                       |
|vga_b\[7\]         |PIN_J14 |VGA DAC blue bit 7 output   |                       |
|vga_g\[0\]         |PIN_J9  |VGA DAC green bit 0 output  |                       |
|vga_g\[1\]         |PIN_J10 |VGA DAC green bit 1 output  |                       |
|vga_g\[2\]         |PIN_H12 |VGA DAC green bit 2 output  |                       |
|vga_g\[3\]         |PIN_G10 |VGA DAC green bit 3 output  |                       |
|vga_g\[4\]         |PIN_G11 |VGA DAC green bit 4 output  |                       |
|vga_g\[5\]         |PIN_G12 |VGA DAC green bit 5 output  |                       |
|vga_g\[6\]         |PIN_F11 |VGA DAC green bit 6 output  |                       |
|vga_g\[7\]         |PIN_E11 |VGA DAC green bit 7 output  |                       |
|vga_r\[0\]         |PIN_A13 |VGA DAC red bit 0 output    |                       |
|vga_r\[1\]         |PIN_C13 |VGA DAC red bit 1 output    |                       |
|vga_r\[2\]         |PIN_E13 |VGA DAC red bit 2 output    |                       |
|vga_r\[3\]         |PIN_B12 |VGA DAC red bit 3 output    |                       |
|vga_r\[4\]         |PIN_C12 |VGA DAC red bit 4 output    |                       |
|vga_r\[5\]         |PIN_D12 |VGA DAC red bit 5 output    |                       |
|vga_r\[6\]         |PIN_E12 |VGA DAC red bit 6 output    |                       |
|vga_r\[7\]         |PIN_F13 |VGA DAC red bit 7 output    |                       |


If you are planning to remap the input buttons or use the controller on a different board, you will need to keep in mind where the pins for the inputs are located. The GPIO bank pin numbers are given assuming the notch on the header is on the left side, and pins are numbered left to right, top to bottom (pin 0 is at the top left) like so:

|                 |        |
|-----------------|--------|
|0                |1       |
|2                |3       |
|4                |5       |
|6                |7       |
|8                |9       |
|5V               |GND     |
|...              |...     |

This is on the DE1-SoC.