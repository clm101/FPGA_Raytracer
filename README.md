# FPGA_Raytracer
An implementation of ray-triangle intersection testing on a Basys 3 board written in VHDL

# Planning
## Phase 1 (Initial FPGA data storage work)
1. Create a basic shift register to eventually handle data reception(DONE)
2. Allow state of the shift register to be output at once(IN PROGRESS)
3. Figure out how to use the BRAM to store data
4. Verify writing and reading from the BRAM
## Phase 2 (Initial FPGA UART work)
1. Get FPGA to output data over a USB connection
2. Verify using puTTY
## Phase 3 (FPGA->Windows work)
- Create a Windows application that can read data being transmitted by FPGA over USB
## Phase 4 (Windows->FPGA work)
1. Implement data transfer from Windows to FPGA
2. Create FPGA circuit that receives data, manipulates it, and returns it
   - Test will likely be sending ASCII characters and receiving the character + 1('a' is sent, 'b' is received)
## Phase 5 (Initial Raytracing) and Beyond - TBD
