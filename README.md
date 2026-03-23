SHA-256 V2 
IMPLEMENTATION DETAILS
(25 Aug 2025)
Overview
This repository contains a Verilog implementation of the SHA-256 cryptographic hash algorithm in single-block mode (512-bit input → 256-bit digest). The project is designed for FPGA targets (tested on Xilinx Artix-7 XC7A200T) and verified using QuestaSim 2024.1.

Toolchain & Environment
•	Vivado: 2024.1.2 (64-bit)
•	Simulator: QuestaSim 2024.1 (Feb 2024 build)
•	Hardware (simulated): Artix-7 XC7A200T, 100–150 MHz
•	Host: Windows 11 Pro

The implementation includes:
•	Modularized RTL design (sha256_core, FSM controller, K-constants memory, and top wrapper).
•	Testbench for simulation and functional verification.
•	Waveform results demonstrates correct operation.
•	Documentation of design choices and test methodology.
 
Features
•	Algorithm: SHA-256 (FIPS 180-4 compliant)
•	Mode: Single-block (Example B.1 from FIPS 180-2) 
•	Digest Size: 256 bits
•	Design Language: Verilog-2001
•	Simulation Tool: QuestaSim 2024.1
