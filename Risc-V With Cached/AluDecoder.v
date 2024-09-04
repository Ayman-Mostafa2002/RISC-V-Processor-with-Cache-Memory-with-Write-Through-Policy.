module AluDecoder (
    input [1:0] aluOP,
    input OP_f7,
    input [2:0] funct3,
    output reg [3:0] ALU_control
);
    localparam ADD  = 4'd0;
    localparam SUB  = 4'd1;
    localparam SLL  = 4'd2;
    localparam SLT  = 4'd3;
    localparam SLTU = 4'd4;
    localparam XOR  = 4'd5;
    localparam SRL  = 4'd6;
    localparam SRA  = 4'd7;
    localparam OR   = 4'd8;
    localparam AND  = 4'd9;
    localparam NOP  = 4'd15;

    always @(*) begin
        case (aluOP)
            2'b00: ALU_control = ADD; // LW, SW, LUI, ALUI, JAL, JALR
            2'b01: begin              // Branch instructions
                case (funct3)
                    3'b000, 3'b001: ALU_control = SUB;  // EQ, NEQ
                    3'b100, 3'b101: ALU_control = SLT;  // BLT, BGT
                    3'b110, 3'b111: ALU_control = SLTU; // BLTU, BGTU
                    default:        ALU_control = NOP;
                endcase
            end
            2'b10: begin              // R-type and I-type instructions
                case (funct3)
                    3'b000: ALU_control = (OP_f7) ? SUB : ADD;
                    3'b001: ALU_control = SLL;
                    3'b010: ALU_control = SLT;
                    3'b011: ALU_control = SLTU;
                    3'b100: ALU_control = XOR;
                    3'b101: ALU_control = (OP_f7) ? SRA : SRL;
                    3'b110: ALU_control = OR;
                    3'b111: ALU_control = AND;
                    default: ALU_control = NOP;
                endcase
            end
            default: ALU_control = NOP; // Default case for undefined aluOP
        endcase
    end
endmodule
