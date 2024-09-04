module DataPath (
    input clk, rstn,
    input memWrite, aluSrcB, regWrite,
    input Stall,
    input [2:0] immSrc, load,
    input [3:0] aluControl,
    input [1:0] resultSrc, aluSrcA, PCSrc, store, 
    input [31:0] mem_RD, instr,
    output reg [31:0] mem_WD,
    output [31:0] PC, aluResult,
    output zero
);  
    localparam LW      = 3'b000;
    localparam LH      = 3'b001;
    localparam LB      = 3'b010;
    localparam LHU     = 3'b011;
    localparam LBU     = 3'b100;
    localparam SW      = 2'b00;
    localparam SH      = 2'b01;
    localparam SB      = 2'b10;

    // Internal Signals
    wire zero_flag;
    wire [4:0] reg_RA1, reg_RA2, reg_WA;
    wire [31:0] reg_RD1, reg_RD2, alu_result, imm_extend, alu_A, alu_B;
    reg [31:0] PC_reg, reg_WD;

    // Register File
    assign reg_RA1 = instr[19:15];
    assign reg_RA2 = instr[24:20];
    assign reg_WA  = instr[11:7];


    always @(*) begin
    case (resultSrc)
        2'b10  : reg_WD = (PC_reg + 32'd4);
        2'b01  : begin
            case (load)
                LB:  reg_WD = {{24{mem_RD[7]}}, mem_RD[7:0]};
                LH:  reg_WD = {{16{mem_RD[15]}}, mem_RD[15:0]};
                LBU: reg_WD = {24'd0, mem_RD[7:0]};
                LHU: reg_WD = {16'd0, mem_RD[15:0]};
                default: reg_WD = mem_RD;
            endcase
        end
        2'b00  : reg_WD = alu_result;
        default: reg_WD = 0;
        endcase
    end


    RegisterFile #(.DATA(32), .ADDR(5)) reg_file 
    (
    .clk(clk), 
    .rstn(rstn), 
    .WE(regWrite), 
    .WD(reg_WD),
    .RA1(reg_RA1), 
    .RA2(reg_RA2), 
    .WA(reg_WA), 
    .RD1(reg_RD1), 
    .RD2(reg_RD2)
    );

    // Sign Extend
    SignExtendation SIGN_EXTEND 
    (
    .instr(instr),
    .sel(immSrc), 
    .out(imm_extend)
    );

    // ALU
    assign alu_A = (aluSrcA == 2'b00) ? reg_RD1 :
                   (aluSrcA == 2'b10) ? PC_reg  : 32'd0;
    assign alu_B = (aluSrcB) ? imm_extend : reg_RD2;
    Alu ALU 
    (
    .A(alu_A), 
    .B(alu_B), 
    .opcode(aluControl), 
    .ALU_out(alu_result), 
    .zero_flag(zero_flag)
    ); 

    // PC
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            PC_reg <= 0;
        else if (!Stall) begin
            case (PCSrc)
            2'b10,2'b11: PC_reg <= alu_result;
            2'b01      : PC_reg <= PC_reg + imm_extend;
            2'b00      : PC_reg <= PC_reg + 32'd4;
            default    : PC_reg <= 0;
            endcase
        end
    end


    // OUTPUT
    always @(*) begin
        case (store)
            SB: mem_WD = {{24{reg_RD2[7]}}, reg_RD2[7:0]};
            SH: mem_WD = {{16{reg_RD2[15]}}, reg_RD2[15:0]};
            default: mem_WD = reg_RD2;
        endcase
    end


    assign aluResult = alu_result;
    assign PC = PC_reg;
    assign zero = zero_flag;
endmodule