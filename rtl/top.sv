`include "include/ControlTypeDefs.svh"
module top(
    input  logic         iClk,         // Clock input
    input  logic         iRst,         // Reset Signal

    output logic [31:0]  oRega0        // Output Register a0
);

////////////////////////////////
////      PC Register       ////
////////////////////////////////



    logic [31:0] pc_f; //pc from fetch stage
    logic [31:0] target_pc_d;
    logic [31:0] instruction_f; //instruction out of fetch
    logic [31:0] jb_target;
 
    logic        take_jb_f;
    logic        stall_f;

    PCRegisterF PCRegister(
        .iClk(iClk),
        .iRst(iRst),
        .iPCSrcD(pc_src_d),
        .iPCSrcF(take_jb_f),
        .iTargetPC(target_pc_d),
        .iBranchTarget(jb_target),
        .iStallF(stall_f),
        .iRecoverPC(recover_pc_d),
        .oPC(pc_f)
    );

    InstructionMemoryF InstructionROM(
        .iPC(pc_f),
        .oInstruction(instruction_f)
    );

    //if we have a branch instruciton that branches backward then take the branch (static branch prediction)
    JumpBranchHandlerF JumpBranchHandlerF(
        .iInstructionF(instruction_f),
        .iPCF(pc_f),
        .oTakeJBF(take_jb_f),
        .oJBTarget(jb_target)
    );

    FPipelineRegisterD PipelineRegister1(
        .iClk(iClk),
        .iStallD(stall_d),
        .iFlushD(flush_d),
        .iInstructionF(instruction_f),
        .iPCF(pc_f),
        .iTakeJBF(take_jb_f),
        .iRecoverPCD(recover_pc_d),
        .oInstructionD(instruction_d),
        .oPCD(pc_d),
        .oRecoverPC(recover_pc_e),
        .oTakeJBD(take_branch_d)
    );


//--------DECODE PIPELINE REGISTER---------------------
    
    InstructionTypes    instruction_type_d;
    InstructionSubTypes instruction_sub_type_d;
    logic [31:0] instruction_d;
    logic [31:0] pc_d;
    logic [31:0] reg_data_out1_d;
    logic [31:0] reg_data_out2_d;
    logic [31:0] reg_jump_offset_d;
    logic [31:0] imm_ext_d;  

    logic [4:0]  rs1_d;
    logic [4:0]  rs2_d;
    logic [4:0]  rd_d;

    logic [31:0] reg_data_in_w;

    logic [2:0]  result_src_d;    
    logic [3:0]  alu_control_d;
    logic        alu_src_d;

    logic        mem_write_en_d;
    logic        reg_write_en_d;

    logic        flush_d;
    logic        stall_d;

    logic        pc_src_d;
    logic        take_branch_d;
    logic        recover_pc_d;

    logic        comparator_op1_select;
    logic        comparator_op2_select;
    logic [31:0] comparator_op1_d;
    logic [31:0] comparator_op2_d;
    logic        forward_reg_offset;

    OperandForwarderD OperandForwarderD(
        .iRegData1D(reg_data_out1_d),
        .iRegData2D(reg_data_out2_d),
        .iAluResultOutM(alu_result_m),
        .iCompOp1Select(comparator_op1_select),
        .iCompOp2Select(comparator_op2_select),
        .iForwardRegOffset(forward_reg_offset),
        .oCompOp1(comparator_op1_d),
        .oCompOp2(comparator_op2_d),
        .oRegOffset(reg_jump_offset_d)
    );

    ComparatorD RegComparator(
        .iInstructionTypeD(instruction_type_d),
        .iJBTypeD(instruction_sub_type_d),
        .iRegData1D(comparator_op1_d),
        .iRegData2D(comparator_op2_d),
        .iTakeJBD(take_branch_d),
        .oRecoverPC(recover_pc_d),
        .oFlushD(flush_d),
        .oPCSrcD(pc_src_d)
    );

//////////////////////////////////////////////////////////
//// Control Unit : Control Path + Instruction Memory ////
//////////////////////////////////////////////////////////


    ControlPathD ControlPath(
        .iInstruction(instruction_d),
        .oImmExt(imm_ext_d),
        .oRegWrite(reg_write_en_d),
        .oMemWrite(mem_write_en_d),
        .oAluControl(alu_control_d),
        .oAluSrc(alu_src_d),
        .oResultSrc(result_src_d),
        .oRs1(rs1_d),
        .oRs2(rs2_d),
        .oRd(rd_d),
        .oInstructionType(instruction_type_d),
        .oInstructionSubType(instruction_sub_type_d)
    );


///////////////////////////////////////////
////  PC Adder : Target PC Calculator  ////
///////////////////////////////////////////


    PCAdderD TargetPCAdder(
        .iPCD(pc_d),
        .iImmExt(imm_ext_d),

        .iInstructionType(instruction_type_d),
        .iInstructionSubType(instruction_sub_type_d),

        .iRegOffset(reg_jump_offset_d),
        .iRecoverPCD(recover_pc_d | recover_pc_e),
        .oPCTarget(target_pc_d)
    );


/////////////////////////////////
////      Register File      ////
/////////////////////////////////


    RegisterFileD RegisterFile(
        .iClk(iClk),

        .iReadAddress1(rs1_d),
        .iReadAddress2(rs2_d),
        .iWriteAddress(rd_w),

        .iDataIn(reg_data_in_w),
        .iWriteEn(reg_write_en_w),

        .oRegData1(reg_data_out1_d),
        .oRegData2(reg_data_out2_d),
        .oRega0(oRega0)
    );

    HazardUnit HazardControl(
        .iInstructionTypeD(instruction_type_d),
        .iInstructionSubTypeD(instruction_sub_type_d),
        .iInstructionTypeE(instruction_type_e),
        .iInstructionTypeM(instruction_type_m),

        .iDestRegE(rd_e),
        .iDestRegM(rd_m),
        .iDestRegW(rd_w),
        .iRegWriteEnE(reg_write_en_e),
        .iRegWriteEnM(reg_write_en_m),
        .iRegWriteEnW(reg_write_en_w),

        .iSrcReg1D(rs1_d),
        .iSrcReg2D(rs2_d),
        .iSrcReg1E(rs1_e),
        .iSrcReg2E(rs2_e),

        .oForwardAluOp1E(alu_op1_select),
        .oForwardAluOp2E(alu_op2_select),

        .oForwardCompOp1D(comparator_op1_select),
        .oForwardCompOp2D(comparator_op2_select),

        .oForwardRegOffsetD(forward_reg_offset),

        .oStallF(stall_f),
        .oStallD(stall_d),
        .oFlushE(flush_e)
    );



//--------EXECUTION STAGE PIPELINE REGISTER---------------------

    DPipelineRegisterE PipelineRegister2(
        .iClk(iClk),
        .iFlushE(flush_e),
        .iInstructionTypeD(instruction_type_d),
        .iInstructionSubTypeD(instruction_sub_type_d),
        .iPCD(pc_d), 
        .iImmExtD(imm_ext_d),

        .iResultSrcD(result_src_d),  
        .iAluControlD(alu_control_d),
        .iAluSrcD(alu_src_d),
        .iRegDataOut1D(reg_data_out1_d),
        .iRegDataOut2D(reg_data_out2_d),
        .iRs1D(rs1_d),
        .iRs2D(rs2_d),
        .iRdD(rd_d),
        .iRegWriteEnD(reg_write_en_d),
        .iMemWriteEnD(mem_write_en_d),

        .oInstructionTypeE(instruction_type_e),
        .oInstructionSubTypeE(instruction_sub_type_e),
        .oPCE(pc_e),  
        .oImmExtE(imm_ext_e),

        .oResultSrcE(result_src_e),  
        .oAluControlE(alu_control_e),
        .oAluSrcE(alu_src_e),
        .oRegDataOut1E(reg_data_out1_e),
        .oRegDataOut2E(reg_data_out2_e),
        .oRs1E(rs1_e),
        .oRs2E(rs2_e),
        .oRdE(rd_e),
        .oRegWriteEnE(reg_write_en_e),
        .oMemWriteEnE(mem_write_en_e)
    );

    InstructionTypes    instruction_type_e;
    InstructionSubTypes instruction_sub_type_e;
    logic [31:0] pc_e;
    logic [31:0] imm_ext_e;  

    logic [31:0] reg_data_out1_e;
    logic [31:0] reg_data_out2_e;
    logic [4:0]  rs1_e;
    logic [4:0]  rs2_e;
    logic [4:0]  rd_e;    
    logic        reg_write_en_e;

    logic [31:0] alu_result_e;
    logic [3:0]  alu_control_e;    
    logic [2:0]  result_src_e;
    logic        alu_src_e;    
    logic        recover_pc_e;
    logic [31:0] mem_data_in_e;
    logic        mem_write_en_e;

    logic [31:0] alu_op1_e;
    logic [31:0] alu_op2_e;

    logic [ 1:0] alu_op1_select;
    logic [ 1:0] alu_op2_select;
/* verilator lint_off UNUSED */
    logic        zero_e;
/* verilator lint_off UNUSED */
    logic        flush_e;


/////////////////////////////////
////  Arithmetic Logic Unit  ////
/////////////////////////////////

    AluOpForwarderE AluOpForwarder(
        .iForwardAluOp1(alu_op1_select),
        .iForwardAluOp2(alu_op2_select),
        .iResultDataW(reg_data_in_w),
        .iAluResultOutM(alu_result_m),
        .iInstructionTypeM(instruction_type_m),
        .iUpperImmM(imm_ext_m),
        .iUpperImmW(imm_ext_w),
        .iRegData1E(reg_data_out1_e),
        .iRegData2E(reg_data_out2_e),
        .oAluOp1(alu_op1_e),
        .oAluOp2(mem_data_in_e)
    );

    always_comb begin
        alu_op2_e = alu_src_e ? imm_ext_e : mem_data_in_e ; //Pick between immediate or register operand
    end
    
    AluE Alu(
        .iAluControl(alu_control_e),
        .iAluOp1(alu_op1_e),
        .iAluOp2(alu_op2_e),
        .oAluResult(alu_result_e),
        .oZero(zero_e)
    );    



//--------MEMORY STAGE PIPELINE REGISTER---------------------

    EPipelineRegisterM PipelineRegister3(
        .iClk(iClk),
        //.iFlushE(flush_e),
        .iInstructionTypeE(instruction_type_e),
        .iInstructionSubTypeE(instruction_sub_type_e),
        .iPCE(pc_e),
        .iImmExtE(imm_ext_e),  
        .iAluOutE(alu_result_e),
        .iMemDataInE(mem_data_in_e),
        .iDestRegE(rd_e),
        .iResultSrcE(result_src_e),
        .iRegWriteEnE(reg_write_en_e),
        .iMemWriteEnE(mem_write_en_e),
        .oInstructionTypeM(instruction_type_m),
        .oInstructionSubTypeM(instruction_sub_type_m),
        .oPCM(pc_m),  
        .oImmExtM(imm_ext_m),  
        .oAluOutM(alu_result_m),
        .oMemDataInM(mem_data_in_m),
        .oDestRegM(rd_m),
        .oResultSrcM(result_src_m),
        .oRegWriteEnM(reg_write_en_m),
        .oMemWriteEnM(mem_write_en_m)
    );

    InstructionTypes    instruction_type_m;
    InstructionSubTypes instruction_sub_type_m;
    logic [31:0] pc_m;
    logic [31:0] imm_ext_m;

    logic [31:0] alu_result_m;
    logic [ 2:0] result_src_m;

    logic [ 4:0] rd_m;
    logic        reg_write_en_m;

    logic [31:0] mem_data_in_m;
    logic [31:0] mem_data_out_m;
    logic        mem_write_en_m;


/////////////////////////////////
////      Data Memory        ////
/////////////////////////////////


    NewMem NewMem(
        .iClk(iClk),
        .iWriteEn(mem_write_en_m),
        .iInstructionType(instruction_type_m),
        .iMemoryInstructionType(instruction_sub_type_m), 
        .iAddress(alu_result_m),
        .iMemData(mem_data_in_m),
        .ooMemData(mem_data_out_m)
    );



//--------WRITE STAGE PIPELINE REGISTER---------------------


    MPipelineRegisterW PipelineRegister4(
        .iClk(iClk),
        .iPCM(pc_m),
        .iImmExtM(imm_ext_m),
        .iMemDataOutM(mem_data_out_m),
        .iAluOutM(alu_result_m),
        .iDestRegM(rd_m),
        .iResultSrcM(result_src_m),
        .iRegWriteEnM(reg_write_en_m),
        .oPCW(pc_w),
        .oImmExtW(imm_ext_w),
        .oMemDataOutW(mem_data_out_w),
        .oAluOutW(alu_result_w),
        .oDestRegW(rd_w),
        .oResultSrcW(result_src_w),
        .oRegWriteEnW(reg_write_en_w)
    );


    logic [31:0] pc_w;
    logic [31:0] imm_ext_w;
    logic [31:0] mem_data_out_w;
    logic [31:0] alu_result_w;
    logic [ 4:0] rd_w;
    logic [ 2:0] result_src_w;
    logic        reg_write_en_w;


//////////////////////////////////////////////////////////////////////////////////////
////  Write Back Result Selector : Choses What Is Written Back To Register File  /////
//////////////////////////////////////////////////////////////////////////////////////

    ResultMuxW ResultSelector(
        .iResultSrcW(result_src_w),
        .iMemDataOutW(mem_data_out_w),
        .iAluResultW(alu_result_w),
        .iPCW(pc_w),
        .iUpperImmW(imm_ext_w),
        .oRegDataInW(reg_data_in_w)
    );  

endmodule
