// Acquisition Control FSM
// Coordinates ADC sampling, UART, and nRF24L01+ at 10 MS/s
module acquisition_control_fsm (
    input wire clk_100MHz,       // System clock
    input wire reset_n,          // Active-low reset
    // Status inputs
    input wire adc_data_valid,   // ADC data ready
    input wire uart_ready,       // UART ready for new data
    input wire nrf_ready,        // Wireless module ready
    // Control outputs
    output reg adc_start,        // Triggers ADC conversion
    output reg proc_data_valid,  // Data valid for downstream
    // Mode selection
    input wire [1:0] mode        // 00=ADC only, 01=UART, 10=Wireless, 11=Both
);

    // =============================================
    // FSM States
    // =============================================
    typedef enum {
        IDLE,
        START_ADC,
        WAIT_ADC,
        PROCESS_DATA,
        SEND_UART,
        SEND_WIRELESS,
        WAIT_COMPLETION
    } state_t;
    
    state_t current_state, next_state;

    // =============================================
    // State Transition Logic
    // =============================================
    always @(posedge clk_100MHz or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // =============================================
    // Next State Decoding
    // =============================================
    always @(*) begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (uart_ready || nrf_ready) begin
                    next_state = START_ADC;
                end
            end
            
            START_ADC: begin
                next_state = WAIT_ADC;
            end
            
            WAIT_ADC: begin
                if (adc_data_valid) begin
                    next_state = PROCESS_DATA;
                end
            end
            
            PROCESS_DATA: begin
                next_state = (mode[1:0] == 2'b00) ? IDLE : 
                            (mode[0]) ? SEND_UART :
                            (mode[1]) ? SEND_WIRELESS : WAIT_COMPLETION;
            end
            
            SEND_UART: begin
                if (!uart_ready) begin  // Wait until UART accepts data
                    next_state = (mode[1]) ? SEND_WIRELESS : IDLE;
                end
            end
            
            SEND_WIRELESS: begin
                if (!nrf_ready) begin  // Wait until wireless accepts data
                    next_state = IDLE;
                end
            end
            
            WAIT_COMPLETION: begin
                if (!uart_ready && !nrf_ready) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    // =============================================
    // Output Logic
    // =============================================
    always @(posedge clk_100MHz or negedge reset_n) begin
        if (!reset_n) begin
            adc_start <= 1'b0;
            proc_data_valid <= 1'b0;
        end else begin
            // Default outputs
            adc_start <= 1'b0;
            proc_data_valid <= 1'b0;
            
            case (current_state)
                START_ADC: begin
                    adc_start <= 1'b1;  // Pulse ADC start
                end
                
                PROCESS_DATA: begin
                    proc_data_valid <= 1'b1;  // Validate processed data
                end
                
                default: ;  // No action for other states
            endcase
        end
    end

    // =============================================
    // Performance Monitoring (optional)
    // =============================================
    reg [31:0] cycle_counter;
    always @(posedge clk_100MHz or negedge reset_n) begin
        if (!reset_n) begin
            cycle_counter <= 32'b0;
        end else if (current_state != next_state) begin
            cycle_counter <= cycle_counter + 1;
        end
    end

endmodule
