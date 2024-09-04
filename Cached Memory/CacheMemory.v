module CacheMemory (
    input wire clk,
    input wire rst_n,                   // Active-low reset
    input wire CacheWrite,
    input wire CacheRead,
    input wire [9:0] Tag,               // Tag from WordAddress
    input wire [31:0] DataIn,           // Data to be written
    input wire [127:0] BlockIn,         // Block from memory (4 words, 32 bits each) (3,2,1,0)
    input wire fill,
    output wire [31:0] DataOut,          // Data output from cache
    output wire Hit                     // Cache hit indicator
);

    // 512 Bytes Cache Memory (128 words of 32 bits each)
    reg [31:0] CacheData [0:127];
    // Cache tag array
    reg [9:0]  CacheTag [0:127];  
    // Valid bit for each cache line   
    reg CacheValid [0:127];   

    integer i;

    //wire
    wire [6:0] Index;
    wire [6:0] Index_FirstWord_Block;
    wire [1:0] Offset;
    wire [9:0] Tag_FirstWord_Block;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all cache lines to invalid state
            for (i = 0; i < 128; i = i + 1) begin
                CacheValid[i] <= 1'b0;
                CacheTag[i]   <= 10'b0;
                CacheData[i]  <= 32'b0;
            end
        end
        else begin
            if (CacheWrite) begin
                if (fill) begin
                    CacheData[Index_FirstWord_Block]    <= BlockIn[31:0]   ;
                    CacheData[Index_FirstWord_Block+ 1] <= BlockIn[63:32]  ;
                    CacheData[Index_FirstWord_Block+ 2] <= BlockIn[95:64]  ;
                    CacheData[Index_FirstWord_Block+ 3] <= BlockIn[127:96] ;
                    CacheTag[Index_FirstWord_Block]     <= Tag_FirstWord_Block ;
                    CacheTag[Index_FirstWord_Block+1]   <= Tag_FirstWord_Block+1 ;
                    CacheTag[Index_FirstWord_Block+2]   <= Tag_FirstWord_Block+2 ;
                    CacheTag[Index_FirstWord_Block+3]   <= Tag_FirstWord_Block+3 ;
                    CacheValid[Index_FirstWord_Block]   <= 1'b1;
                    CacheValid[Index_FirstWord_Block+1] <= 1'b1;
                    CacheValid[Index_FirstWord_Block+2] <= 1'b1;
                    CacheValid[Index_FirstWord_Block+3] <= 1'b1;
                end
                else if (CacheValid[Index] && CacheTag[Index] == Tag) begin
                    CacheData[Index]  <= DataIn;
                    CacheTag[Index]   <= Tag;
                    CacheValid[Index] <= 1'b1;
                end
            end
        end
    end

    assign Index = Tag[6:0];
    assign Index_FirstWord_Block = {Index[6:2], 2'b00};
    assign Tag_FirstWord_Block = {Tag[9:2], 2'b00};
    assign Hit = CacheValid[Index] && CacheTag[Index] == Tag;
    assign Offset = Index[1:0];

    // Combinational Cache Read Operation
    assign DataOut = fill ? (
                        (Offset == 2'b00) ? BlockIn[31:0]  :
                        (Offset == 2'b01) ? BlockIn[63:32] :
                        (Offset == 2'b10) ? BlockIn[95:64] :
                        (Offset == 2'b11) ? BlockIn[127:96] :
                                            32'hAAAAAAAA
                    ) : 
                    ((CacheRead && CacheValid[Index] && CacheTag[Index] == Tag) ? CacheData[Index] : 32'b0);

endmodule
