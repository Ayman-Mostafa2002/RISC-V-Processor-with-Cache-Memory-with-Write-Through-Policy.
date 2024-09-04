module Cache_tb;

    // Testbench signals
    reg clk;
    reg rst_n;
    reg MemRead;
    reg MemWrite;
    reg [9:0] WordAddress;
    reg [31:0] DataIn;
    wire [31:0] DataOut;
    wire Stall;

    // Instantiate the Top module
    Cache DUT (
        .clk(clk),
        .rst_n(rst_n),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .WordAddress(WordAddress),
        .DataIn(DataIn),
        .DataOut(DataOut),
        .Stall(Stall)
    );

    // Clock generation
    always #1 clk = ~clk;  // 2ns period clock

    // Test sequence
    initial begin
        // Initialize signals
        clk         = 0;
        rst_n       = 0;
        MemRead     = 0;
        MemWrite    = 0;
        WordAddress = 0;
        DataIn      = 0;
        #10;

        // Reset the system
        rst_n = 1;
        #10;

        // Test Case 1: Store Word (SW) to address 0x004
        @(posedge clk);
        WordAddress = 10'h004;
        DataIn      = 32'hAABBCCDD;
        MemWrite    = 1;
        MemRead     = 0;
        @(negedge Stall);


        // Test Case 2: Load Word (LW) from address 0x004 (Cache Miss)
        @(posedge clk);
        MemWrite    = 0;
        WordAddress = 10'h004;
        DataIn      = 0;
        MemRead     = 1;
        @(negedge Stall);
        $display("Time: %0t | DataOut after LW (should be AABBCCDD): %0h", $time, DataOut);

        // Test Case 3: Store Word (SW) to address 0x001
        @(posedge clk);
        MemRead     = 0;
        WordAddress = 10'h001;
        DataIn      = 32'h11223344;
        MemWrite    = 1;
        @(negedge Stall);

        // Test Case 4: Load Word (LW) from address 0x001(Cache Miss)
        @(posedge clk);
        MemWrite    = 0;
        WordAddress = 10'h001;
        DataIn      = 0;
        MemRead     = 1;
        @(negedge Stall);
        $display("Time: %0t | DataOut after LW (should be 11223344): %0h", $time, DataOut);

        // Test Case 5: Load Word (LW) from address 0x004 (Cache Hit)
        @(posedge clk);
        WordAddress = 10'h004;
        DataIn      = 0;
        MemWrite    = 0;
        MemRead     = 1;
        repeat(2) @(negedge clk);
        $display("Time: %0t | DataOut after LW (Cache Hit, should be AABBCCDD): %0h", $time, DataOut);


        // Test Case 6: Load Word (LW) from address 0x001 (Cache Hit)
        @(posedge clk);
        WordAddress = 10'h001;
        DataIn      = 0;
        MemWrite    = 0;
        MemRead     = 1;
        repeat(2) @(negedge clk);
        $display("Time: %0t | DataOut after LW (Cache Hit, should be 11223344): %0h", $time, DataOut);

        // Test Case 7: Load Word (LW) from address 0x003 (Cache Hit)
        @(posedge clk);
        WordAddress = 10'h003;
        DataIn      = 0;
        MemWrite    = 0;
        MemRead     = 1;
        repeat(2) @(negedge clk);
        $display("Time: %0t | DataOut after LW (Cache Hit, should be 00000000): %0h", $time, DataOut);

        // Test Case 8: Store Word (SW) to address 0x003
        @(posedge clk);
        MemRead     = 0;
        WordAddress = 10'h003;
        DataIn      = 32'hFFFFFFFF;
        MemWrite    = 1;
        @(negedge Stall);

        // Test Case 9: Load Word (LW) from address 0x003 (Cache Hit)
        @(posedge clk);
        WordAddress = 10'h003;
        DataIn      = 0;
        MemWrite    = 0;
        MemRead     = 1;
        repeat(2) @(negedge clk);
        $display("Time: %0t | DataOut after LW (Cache Hit, should be FFFFFFFF): %0h", $time, DataOut);

        // Test Case 10: Store Word (SW) to address 0x081
        @(posedge clk);
        MemRead     = 0;
        WordAddress = 10'h081;
        DataIn      = 32'hFFFF0000;
        MemWrite    = 1;
        @(negedge Stall);

        // Test Case 11: Load Word (LW) from address 0x081 (Cache miss)
        @(posedge clk);
        WordAddress = 10'h081;
        DataIn      = 0;
        MemWrite    = 0;
        MemRead     = 1;
        @(negedge Stall);
        $display("Time: %0t | DataOut after LW (should be FFFF0000): %0h", $time, DataOut);

        // End of simulation
        @(posedge clk);
        WordAddress = 0;
        DataIn      = 0;
        MemWrite    = 0;
        MemRead     = 0;
        #10;
        $stop;
    end

endmodule
