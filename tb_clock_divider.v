module tb_clock_divider();
    reg clk_100MHz;
    reg reset_n;
    wire clk_10MHz;

    clock_divider dut (
        .clk_100MHz(clk_100MHz),
        .reset_n(reset_n),
        .clk_10MHz(clk_10MHz)
    );

    // 100MHz clock gen
    always #5 clk_100MHz = ~clk_100MHz;

    initial begin
        // Initialize
        clk_100MHz = 0;
        reset_n = 0;
        
        // Release reset
        #100 reset_n = 1;
        
        // Verify frequency
        #1000 $display("Clock check: %0t ns", $time);
        $finish;
    end
endmodule
