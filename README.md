# Team05-RISCV-CPU

_Written by Lolézio Viora Marquet and Sam Barber_

This branch contains a fully working Pipelined CPU with Hazard Handling with Data Memory Cache in SystemVerilog.

A number of programs are available to use, including F1.s, which is the F1 Lights Program for the Pipelined CPU with Data Cache. These can be found in [Testing/Assembly](https://github.com/lolzio5/Team05-RISCV-Final/tree/b7c7e5eac61910712bd7877c136f52d1047438e9/Testing/Assembly).

<br>

However, if you want to assemble your own program, it is possible to assemble them and generate a hex file:

- Upload a .s file to the [Testing](https://github.com/lolzio5/Team05-RISCV-Final/tree/b7c7e5eac61910712bd7877c136f52d1047438e9/Testing) folder
- Open this folder with ``` cd Testing ```
- Run ``` make FileName.s```
- Move the generated .hex file to [rtl](https://github.com/lolzio5/Team05-RISCV-Final/tree/b7c7e5eac61910712bd7877c136f52d1047438e9/rtl)

> Before running, you will need to indicate the path to this file in [InstructionMemoryF.sv](https://github.com/lolzio5/Team05-RISCV-Final/blob/b7c7e5eac61910712bd7877c136f52d1047438e9/rtl/Memory/InstructionMemoryF.sv)  (see README.md on the Main Branch for more instructions).

To run the program on Vbuddy, and have the output be displayed on the screen, exit Testing and simply run
```
cd rtl
source ./buildCPU.sh
```

> Note that if you wish to upload your own data to data memory, you will need to provide the path to your file in [NewMem.sv](https://github.com/lolzio5/Team05-RISCV-Final/blob/b7c7e5eac61910712bd7877c136f52d1047438e9/rtl/Memory/DataMemoryM.sv) (see README.md on the Main Branch for more instructions).

If you wish to display on other parts of Vbuddy, you will need to edit [top_tb.cpp](https://github.com/lolzio5/Team05-RISCV-Final/blob/b7c7e5eac61910712bd7877c136f52d1047438e9/rtl/top_tb.cpp).

> Note you may need to change [vbuddy.cfg](https://github.com/lolzio5/Team05-RISCV-Final/blob/a81e108eafe1f65cbd0cc7d9f6f9b0cb6ed0ee6e/rtl/vbuddy.cfg) with the path to the USB Port Vbuddy is connected to





