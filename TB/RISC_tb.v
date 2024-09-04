module RiscV_tb;
    reg clk;
    reg rstn;

    // Instantiate the TOP module
    RiscV DUT (
        .clk(clk),
        .rstn(rstn),
        .WE(1'b0),
        .WD(32'b0)
    );

    localparam CLK_PERIOD = 2;

    // Clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2);
        clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

    initial begin
        // Initialize signals
        rstn = 1'b0;
        clk  = 1'b0;

        // Load the instruction memory
        // $readmemh("test_instructions.dat", DUT.INSTR_MEM.I_MEM);
        $readmemh("Test.dat", DUT.INSTR_MEM.I_MEM);
        // Deassert reset after one clock cycle
        @(posedge clk);
        rstn = 1'b1;

        // Run simulation for a specific number of cycles
        repeat (100) @(posedge clk);

        // Stop the simulation
        $finish;
    end
endmodule
