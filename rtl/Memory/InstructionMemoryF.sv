module InstructionMemoryF #(
  parameter DATA_WIDTH = 32
)(
   /* verilator lint_off UNUSED */
  input  logic [31:0]           iPC,
   /* verilator lint_on UNUSED */
  output logic [DATA_WIDTH-1:0] oInstruction
);

//////////////////////////////////////////////
////     Instruction ROM Array 32 x 4095  ////
//////////////////////////////////////////////

  //ROM Array - Address space is large enough to cover the memory space shown in memory map
  logic [DATA_WIDTH - 1 : 0] rom_array [0 : 2**12  - 1];


//////////////////////////////////////////////
////     Load Instructions Into ROM       ////
//////////////////////////////////////////////

  initial begin
          $display("Loading ROM");
          $readmemh("pdf.hex", rom_array);
  end;


//////////////////////////////////////////////
////   Read Instruction Word From ROM     ////
//////////////////////////////////////////////

  //Load LS Byte of 4 consecutive memory cells into instruction word - since byte addressable instructions
  always_comb begin
    oInstruction = {rom_array[iPC + 32'd3][7:0], rom_array[iPC + 32'd2][7:0], rom_array[iPC + 32'd1][7:0], rom_array[iPC][7:0] };
  end


endmodule
