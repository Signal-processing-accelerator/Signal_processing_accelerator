#!/bin/bash

topModule="tb_FIR_HPF"
subModule="usin_rom.v FIR_HPF.v addr_gen.v func_gen.v tb_FIR_HPF.v"
iverilog -s $topModule -o FIR_LPF $subModule
vvp ./FIR_LPF