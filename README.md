# FPGA_Raytracer
An implementation of ray-triangle intersection testing on a Basys 3 board written in VHDL.

The goal of this project is to implement a hardware accelerated ray-triangle intersection test that produces results identical(or within a low margin of error) to results produced by a software ray tracing algorithm. The tests will be implemented in hardware on a Basys 3 board. Development will occur in Vivado using VHDL. Communication between the board and PC is currently planned to use the RS-232 protocol over USB.  

# Planning
## Phase 1 (Initial FPGA data storage work)
1. Create a basic shift register to eventually handle data reception(DONE).
2. Allow state of the shift register to be output at once(DONE).
3. Figure out how to use the BRAM to store data(IN PROGRESS).
4. Verify writing and reading from the BRAM.
## Phase 2 (Initial FPGA UART work)
1. Get FPGA to output data over a USB connection.
2. Verify using puTTY.
## Phase 3 (FPGA->Windows work)
- Create a Windows application that can read data being transmitted by FPGA over USB.
## Phase 4 (Windows->FPGA work)
1. Implement data transfer from Windows to FPGA.
2. Create FPGA circuit that receives data, manipulates it, and returns it.
   - Test will likely be sending ASCII characters and receiving the character + 1('a' is sent, 'b' is received).
## Phase 5 (Initial Raytracing)
- Follow the [Ray Tracing in One Weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html) tutorial.
### **The remainder of this project is subject to how the raytracer is implemented**
## Phase 6 (Hardware Acceleration)
- Implement the circuit(s) that will perform the ray-triangle intersection testing.
## Phase 7 (Windows <-> FPGA)
1. Create the protocol that will be followed for data transmission.
   - Currently, the plan is to first send the number of tests to perform, then follow with the ray and scene information. The FPGA will perform the necessary computation and send back the intersection information. The process will likely be managed using a state machine.
2. Implement the protocol in hardware.
3. Implement the protocol in the Windows Application.
4. Test the intersection tests against the intersections performed by the software raytracer.
## Phase 8 (Completion)
1. Integrate the FPGA with the software ray tracer.
2. Test the performance hit.
## Alternate Completion
- Depending on the ray tracing guide, an alternate plan will eschew the integration with the Ray Tracing in One Weekend program. Instead, rays and triangles will be randomly generated on the PC, the intersection tests will be computed on both the FPGA and the PC, and the results will be compared. If the results are identical/within a margin of error, then that will be the final test. Future work would be creating a more flexible system.
## Post-Completion Tasks
- Implement BVH traversal
- Implement a method for detecting and performing different kinds of intersections
- Begin evaluating methods of accelerating other aspects of the computation on the FPGA
