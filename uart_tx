module uart_tx(
    input wire clk,
    input wire reset_n,
    input wire [7:0] tx_data,
    input wire tx_valid,
    output reg tx_out,
    output wire tx_ready
);
    
    parameter CLK_FREQ = 100_000_000;
    parameter BAUD_RATE = 1_000_000;
    
    localparam BIT_TICKS = CLK_FREQ / BAUD_RATE;
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    
    reg [1:0] state;
    reg [7:0] data_reg;
    reg [15:0] counter;
    reg [2:0] bit_index;
    
    assign tx_ready = (state == IDLE);
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            tx_out <= 1'b1;
        end else begin
            case (state)
                IDLE: begin
                    tx_out <= 1'b1;
                    if (tx_valid) begin
                        state <= START;
                        data_reg <= tx_data;
                        counter <= 0;
                    end
                end
                
                START: begin
                    tx_out <= 1'b0;
                    if (counter == BIT_TICKS - 1) begin
                        state <= DATA;
                        counter <= 0;
                        bit_index <= 0;
                    end else begin
                        counter <= counter + 1;
                    end
                end
                
                DATA: begin
                    tx_out <= data_reg[bit_index];
                    if (counter == BIT_TICKS - 1) begin
                        counter <= 0;
                        if (bit_index == 7) begin
                            state <= STOP;
                        end else begin
                            bit_index <= bit_index + 1;
                        end
                    end else begin
                        counter <= counter + 1;
                    end
                end
                
                STOP: begin
                    tx_out <= 1'b1;
                    if (counter == BIT_TICKS - 1) begin
                        state <= IDLE;
                    end else begin
                        counter <= counter + 1;
                    end
                end
            endcase
        end
    end
endmodule
