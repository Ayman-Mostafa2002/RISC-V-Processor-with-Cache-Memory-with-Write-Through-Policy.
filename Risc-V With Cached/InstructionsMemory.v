module InstructionsMemory #(parameter DATA = 32, ADDR = 32, MEM_DEPTH = 256)(
    input clk,
    input WE,
    input [DATA - 1 : 0] WD,
    input [ADDR - 1 : 0] PC,
    output [DATA - 1 : 0] RD
);
    wire [ADDR - 1 : 0] Address;
    reg [DATA - 1 : 0] I_MEM [0 : MEM_DEPTH - 1];

    always @(posedge clk) begin
        if (WE)
            I_MEM[Address] <= WD;
    end

    assign Address = PC>>2 ;
    assign RD = I_MEM[Address];
endmodule