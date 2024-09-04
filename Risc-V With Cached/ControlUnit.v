module ControlUnit (
    input [6:0] opcode,
    input [2:0] funct3,
    input OP_f7,
    input zero,
    output memWrite,
    output memRead,  
    output aluSrcB, 
    output regWrite,
    output [1:0] resultSrc, 
    output [1:0] aluSrcA,
    output [2:0] immSrc,
    output [3:0] ALU_control,
    output reg [1:0] PC_src,
    output reg [1:0] store,
    output reg [2:0] load
);  
    localparam LOAD    = 7'b0000011;
    localparam STORE   = 7'b0100011;
    localparam LW      = 3'b000;
    localparam LH      = 3'b001;
    localparam LB      = 3'b010;
    localparam LHU     = 3'b011;
    localparam LBU     = 3'b100;
    localparam SW      = 2'b00;
    localparam SH      = 2'b01;
    localparam SB      = 2'b10;

    wire branch, jump;
    wire [1:0] aluOP;

    // main_decoder
    MainDecoder MAIN_DECODER (
    .opcode(opcode),
    .aluOP(aluOP),
    .branch(branch),
    .resultSrc(resultSrc), 
    .memWrite(memWrite),
    .memRead(memRead),
    .aluSrcA(aluSrcA), 
    .aluSrcB(aluSrcB),
    .regWrite(regWrite), 
    .jump(jump), 
    .immSrc(immSrc)
    );

    // ALU_decoder
    AluDecoder ALU_DECODER (
    .aluOP(aluOP), 
    .OP_f7(OP_f7), 
    .funct3(funct3), 
    .ALU_control(ALU_control)
    );

    // PC_src
    always @(*) begin
        PC_src[1] = jump;
        case (funct3)
            3'b000, 3'b101, 3'b111: PC_src[0] = (branch &  zero);  // BEQ, BGE, BGEU
            3'b001, 3'b100, 3'b110: PC_src[0] = (branch & ~zero);  // BNE, BLT, BLTU
            default:                PC_src[0] = 0;
        endcase
    end


    // LOAD
    always @(*) begin
        if (opcode == LOAD) begin
            case (funct3)
                3'b000 : load = LB;  
                3'b001 : load = LH;
                3'b100 : load = LBU;   
                3'b101 : load = LHU;   
                3'b001 : load = LB;   
                3'b001 : load = LB;   
                3'b001 : load = LB;   
                default: load = LW;
            endcase 
        end
        else
            load = LW;
    end

    // STORE
    always @(*) begin
        if (opcode == STORE) begin
            case (funct3)
                3'b000 : store = SB;  
                3'b001 : store = SH;
                default: store = SW;
            endcase 
        end
        else
            store = SW;
    end

endmodule