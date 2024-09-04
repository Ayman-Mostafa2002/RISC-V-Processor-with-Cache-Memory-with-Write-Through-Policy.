module CacheController (
    input wire clk,
    input wire rst_n,
    input wire MemRead,
    input wire MemWrite,
    input wire [9:0] WordAddress,
    input wire [31:0] DataIn,
    input wire [127:0] MainMemOut,  // 4-word block from MainMemory
    input wire [31:0] CacheOut,
    input wire Hit,
    input wire ready,
    input wire ready_after,
    output reg fill,
    output reg CacheRead,
    output reg CacheWrite,
    output reg Stall,
    output reg MemReadMain,
    output reg MemWriteMain
);

    reg [1:0] cs, ns;

    localparam IDLE   = 2'b00,
               READ   = 2'b01,
               WRITE  = 2'b10;

    // Always block for current state
    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cs <= IDLE;
        end else begin
            cs <= ns;
        end
    end

    // Always block for next state
    always @(*) begin
        ns = IDLE;
        case (cs)
            IDLE: begin
                if (MemRead) begin
                    if(Hit)begin
                        ns = IDLE;
                    end
                    else begin
                        ns = READ;
                    end
                end
                else if (MemWrite) begin
                    ns = WRITE;
                end
                else begin
                    ns = IDLE;
                end
            end
            READ: begin
                if (ready_after) begin
                    ns = IDLE;
               end
                else begin
                    ns = READ;
                end    
            end    
            WRITE: begin
                if (ready) begin
                    ns = IDLE;
                end
                else begin
                    ns = WRITE;
                end
            end
        endcase
    end


    // Always block for output logic
    always @(*) begin
        // Default output values
        Stall        = 1'b0;
        MemReadMain  = 1'b0;
        MemWriteMain = 1'b0;
        CacheRead    = 1'b0;
        CacheWrite   = 1'b0;
        fill         = 1'b0;

        case (cs)
            IDLE: begin
                MemReadMain  = 1'b0;
                MemWriteMain = 1'b0;
                CacheWrite   = 1'b0;
                fill         = 1'b0;
                Stall        = 1'b0;
                if(Hit)begin
                    CacheRead= 1'b1;
                end
                else begin
                    CacheRead= 1'b0;
                end
            end
            READ: begin
                MemWriteMain = 1'b0;
                MemReadMain  = 1'b1;
                CacheRead    = 1'b0;
                Stall        = 1'b1;
                if (ready) begin
                    MemReadMain  = 1'b0;
                    fill         = 1'b1;
                    CacheWrite   = 1'b1;
                end
                else begin
                    MemReadMain  = 1'b1;
                    fill         = 1'b0;
                    CacheWrite   = 1'b0;
                end
            end
            WRITE: begin
                MemReadMain  = 1'b0;
                MemWriteMain = 1'b1;
                CacheRead    = 1'b0;
                CacheWrite   = 1'b1;
                fill         = 1'b0;
                Stall        = 1'b1;
            end
        endcase
    end




endmodule
