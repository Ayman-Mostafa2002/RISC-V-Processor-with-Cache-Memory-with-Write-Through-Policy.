module MainMemory (
    input wire clk,
    input wire rst_n,              // Asynchronous active-low reset
    input wire MemWrite,
    input wire MemRead,
    input wire [9:0] WordAddress,  
    input wire [31:0] DataIn,      // Data to be written (4 words, 32 bits each) (3,2,1,0)
    output reg [127:0] BlockOut,   // Data output from memory (4 words, 32 bits each) (3,2,1,0)
    output reg ready,
    output reg ready_after
);

    // 4K memory (word-addressable)
    reg [31:0] memory [0:1023];  
    reg [2:0] cycle_counter;  
    wire [9:0] BlockAddress;

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 1024; i = i + 1) begin
                memory[i] <= 32'b0; 
            end
            cycle_counter <= 0;
            BlockOut <= 128'b0;
            ready <= 1'b0;
            ready_after <= 1'b0;        
        end
        else if (MemRead || MemWrite) begin
            if (cycle_counter != 3) begin
                cycle_counter <= cycle_counter + 1;
                ready <= 1'b0;
                ready_after <= 1'b0;        
            end
            else begin
                if (MemRead) begin
                    BlockOut[31:0]   <= memory[BlockAddress];           
                    BlockOut[63:32]  <= memory[BlockAddress+1];        
                    BlockOut[95:64]  <= memory[BlockAddress+2];         
                    BlockOut[127:96] <= memory[BlockAddress+3];
                end
                if (MemWrite) begin
                    memory[WordAddress] <= DataIn;
                end
                ready <= 1'b1;
                cycle_counter <= cycle_counter + 1;
            end
        end
        else begin
            ready <= 1'b0;  
            cycle_counter <= 0;  
            if (cycle_counter == 4) begin
                ready_after <= 1'b1;    
            end
            else begin
                ready_after <= 1'b0;    
            end    
        end
    end

    assign BlockAddress = {WordAddress[9:2], 2'b00};

endmodule
