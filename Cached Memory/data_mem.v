module data_mem #(parameter DATA = 32, ADDR = 32, MEM_DEPTH = 256)(
    input wire clk,
    input wire WE,
    input wire [ADDR - 1 : 0] A,
    input wire [DATA - 1 : 0] WD,
    output wire [DATA - 1 : 0] RD
);
    reg [DATA - 1 : 0] D_MEM [0 : MEM_DEPTH - 1];

    always @(posedge clk) begin
        if (WE)
            D_MEM[A] <= WD;
    end
    
   assign RD = D_MEM[A];
endmodule