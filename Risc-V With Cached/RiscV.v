module RiscV (
    input clk,
    input rstn,
    input WE,
    input [31:0] WD
);
    // Internal Signals
    wire memWrite, memRead, aluSrcB, regWrite, zero;
    wire [2:0] funct3, immSrc, load;
    wire [3:0] ALU_control;
    wire [1:0] resultSrc, aluSrcA, PCSrc, store;
    wire [31:0] instr, mem_RD, aluResult, PC, mem_WD;
    wire [6:0] opcode;
    wire Stall;
    wire OP_f7;

    // INSTR
    assign opcode  = instr[6:0];
    assign funct3  = instr [14:12];
    assign OP_f7   = instr[30];
   
    // Data Path
    DataPath DATA_PATH (
    .clk(clk),
    .rstn(rstn),
    .PCSrc(PCSrc),
    .resultSrc(resultSrc),
    .memWrite(memWrite),
    .aluSrcA(aluSrcA),
    .aluSrcB(aluSrcB),
    .regWrite(regWrite),
    .aluControl(ALU_control),
    .immSrc(immSrc),
    .instr(instr),
    .load(load),
    .store(store),
    .mem_RD(mem_RD),
    .aluResult(aluResult),
    .PC(PC),
    .Stall(Stall),
    .mem_WD(mem_WD),
    .zero(zero)
    );

    // Control Unit
    ControlUnit CONTROL_UNIT (
     .opcode(opcode),
     .funct3(funct3),
     .OP_f7(OP_f7),
     .zero(zero),
     .PC_src(PCSrc), 
     .resultSrc(resultSrc),
     .memWrite(memWrite),
     .memRead(memRead),
     .aluSrcA(aluSrcA),
     .aluSrcB(aluSrcB),
     .regWrite(regWrite),
     .immSrc(immSrc), 
     .load(load),
     .store(store),
     .ALU_control(ALU_control)
     );

    // Instruction Memory
    InstructionsMemory #(.DATA(32), .ADDR(32), .MEM_DEPTH(256)) INSTR_MEM (
    .clk(clk),
    .WE(WE),
    .WD(WD),
    .PC(PC),
    .RD(instr)
    );

    // Data Memory
    Cache Cache_Unit (
    .clk(clk),
    .rst_n(rstn),
    .MemRead(memRead),
    .MemWrite(memWrite),
    .WordAddress(aluResult[9:0]),
    .DataIn(mem_WD),
    .DataOut(mem_RD),
    .Stall(Stall)
    );
endmodule
