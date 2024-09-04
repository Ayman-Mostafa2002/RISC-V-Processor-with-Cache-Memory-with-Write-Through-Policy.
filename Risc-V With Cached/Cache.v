module Cache
 (
    input wire clk,
    input wire rst_n,                   // Active-low reset
    input wire MemRead,                 // Processor's read request
    input wire MemWrite,                // Processor's write request
    input wire [9:0] WordAddress,       // Address from the processor
    input wire [31:0] DataIn,           // Data to be written by the processor
    output wire [31:0] DataOut,         // Data output to the processor
    output wire Stall                   // Stall signal to the processor
);

    // Internal signals
    wire [127:0] MainMemOut;            // Data block from main memory
    wire [127:0] BlockIn;               // Data block input to cache
    wire [31:0] CacheOut;               // Data output from cache
    wire Hit;                           // Cache hit indicator
    wire ready;                         // Ready signal from main memory
    wire ready_after;
    wire fill;                          // Fill signal from cache controller
    wire CacheRead;                     // Cache read control signal
    wire CacheWrite;                    // Cache write control signal
    wire MemReadMain;                   // Main memory read control signal
    wire MemWriteMain;                  // Main memory write control signal

    // Instantiate CacheMemory
    CacheMemory cache_mem (
        .clk(clk),
        .rst_n(rst_n),
        .CacheWrite(CacheWrite),
        .CacheRead(CacheRead),
        .Tag(WordAddress),
        .DataIn(DataIn),
        .BlockIn(MainMemOut),
        .fill(fill),
        .DataOut(CacheOut),
        .Hit(Hit)
    );

    // Instantiate MainMemory
    MainMemory main_mem (
        .clk(clk),
        .rst_n(rst_n),
        .MemWrite(MemWriteMain),
        .MemRead(MemReadMain),
        .WordAddress(WordAddress),
        .DataIn(DataIn),
        .BlockOut(MainMemOut),
        .ready(ready),
        .ready_after(ready_after)
    );

    // Instantiate CacheController
    CacheController cache_ctrl (
        .clk(clk),
        .rst_n(rst_n),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .WordAddress(WordAddress),
        .DataIn(DataIn),
        .MainMemOut(MainMemOut),
        .CacheOut(CacheOut),
        .Hit(Hit),
        .ready(ready),
        .ready_after(ready_after),
        .fill(fill),
        .CacheRead(CacheRead),
        .CacheWrite(CacheWrite),
        .Stall(Stall),
        .MemReadMain(MemReadMain),
        .MemWriteMain(MemWriteMain)
    );

    // DataOut assignment: Data from cache is sent to the processor
    assign DataOut = CacheOut;

endmodule
