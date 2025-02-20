#include "verilated.h"
#include "verilated_vcd_c.h"
#include "VDataMemoryController.h"

int main(int argc, char **argv, char **env) {
    int simcyc;     // simulation clock count
    int tick;       // each clk cycle has two ticks for two edges

    Verilated::commandArgs(argc, argv);
    // init top verilog instance
    VDataMemoryController* top = new VDataMemoryController;

    // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("DataMemoryController.vcd");

    // initialize simulation input 
    top->iClk = 1;
    top->iWriteEn = 1;
    top->iAddress =0x00FF;
    top->iMemData =0x0444;
    top->iInstructionType=0x2;
    top->iMemoryInstructionType=0x2;
    // run simulation for MAX_SIM_CYC clock cycles
    for (simcyc=0; simcyc<3000; simcyc++) 
    {
        // dump variables into VCD file and toggle clock
        for (tick=0; tick<2; tick++) 
        {
            tfp->dump (2*simcyc+tick);
            top->iClk = !top->iClk;
            top->eval ();
        }
        if (simcyc==3)
        {
            top->iAddress =0x009F;
            //top->iMemoryInstructionType=0xB;
        }
        if (simcyc==5)
        {
            top->iAddress =0x00FF;
            top->iWriteEn=0;
            top->iInstructionType=0x1;
            //top->iMemoryInstructionType=0xB;
        }
        if (simcyc==6)
        {
            //top->iMemoryInstructionType=0xB;
        }
        if (Verilated::gotFinish()) exit(0);
    }

    tfp->close(); 
    printf("Exiting\n");
    exit(0);
}