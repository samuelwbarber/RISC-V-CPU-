#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vtop.h"
#include "vbuddy.cpp"
int main(int argc, char **argv, char **env) {
    int simcyc;     // simulation clock count
    int tick;       // each clk cycle has two ticks for two edges

    Verilated::commandArgs(argc, argv);
    // init top verilog instance
    Vtop* top = new Vtop;

    if (vbdOpen()!=1) return(-1);
    vbdHeader("PDF");

    // init trace dump
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("top.vcd");

    // initialize simulation input 
    top->iClk = 1;
    top->iRst = 0;

    // run simulation for MAX_SIM_CYC clock cycles
    for (simcyc=0; simcyc<9999999; simcyc++) 
    {
        // dump variables into VCD file and toggle clock
        for (tick=0; tick<2; tick++) 
        {
            tfp->dump (2*simcyc+tick);
            top->iClk = !top->iClk;
            top->eval ();
        }
        if(simcyc>450000){
            vbdPlot(int(top->oRega0), 0, 255);
            vbdCycle(simcyc);
        }

        if ((Verilated::gotFinish()) || (vbdGetkey()=='q')) exit(0);
    }
    vbdClose();
    tfp->close(); 
    printf("Exiting\n");
    exit(0);
}
