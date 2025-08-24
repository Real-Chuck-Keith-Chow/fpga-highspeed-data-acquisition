// Clock Divider Module
// Divides 100MHz input clock to 10MHz (DIV=10)
// Synchronous reset, 50% duty cycle
module clock_divider (
    input wire clk_100MHz,  // 100MHz master clock
    input wire reset_n,      // Active-low reset
    output reg clk_10MHz     // Divided 10MHz output
);

    // Counter for division (0-4 for 10MHz from 100MHz)
    reg [2:0] counter;

    always @(posedge clk_100MHz or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 3'b0;
            clk_10MHz <= 1'b0;
        end
        else begin
            if (counter == 3'd4) begin  // Count 0-4 (5 cycles)
                counter <= 3'b0;
                clk_10MHz <= ~clk_10MHz;  // Toggle output
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
