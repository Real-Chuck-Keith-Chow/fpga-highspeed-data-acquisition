module spi_adc_controller(
    input wire clk,
    input wire reset_n,
    input wire start_conversion,
    input wire miso,
    output reg cs_n,
    output reg sclk,
    output reg [17:0] adc_data,
    output reg data_valid
);

    // States for FSM
    typedef enum {IDLE, INIT_CONV, SAMPLE_DATA, COMPLETE} state_t;
    state_t current_state, next_state;
    
    // Clock divider for 10MHz SPI clock (from 100MHz system clock)
    reg [3:0] clk_div;
    wire spi_clk = clk_div[3];  // 100MHz / 10 = 10MHz
    
    // Shift register for data
    reg [17:0] shift_reg;
    reg [4:0] bit_counter;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            clk_div <= 0;
            cs_n <= 1'b1;
            sclk <= 1'b0;
        end else begin
            current_state <= next_state;
            clk_div <= clk_div + 1;
            
            case (current_state)
                INIT_CONV: begin
                    cs_n <= 1'b0;
                    sclk <= 1'b0;
                end
                SAMPLE_DATA: begin
                    if (clk_div == 4'd0) sclk <= ~sclk;
                    if (clk_div == 4'd8 && sclk) begin
                        shift_reg <= {shift_reg[16:0], miso};
                        bit_counter <= bit_counter + 1;
                    end
                end
                COMPLETE: begin
                    cs_n <= 1'b1;
                    adc_data <= shift_reg;
                    data_valid <= 1'b1;
                end
                default: begin
                    data_valid <= 1'b0;
                end
            endcase
        end
    end
    
    // FSM next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: if (start_conversion) next_state = INIT_CONV;
            INIT_CONV: if (clk_div == 4'd15) next_state = SAMPLE_DATA;
            SAMPLE_DATA: if (bit_counter == 18) next_state = COMPLETE;
            COMPLETE: next_state = IDLE;
        endcase
    end
endmodule
