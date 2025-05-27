// Data Processing Pipeline
// Processes 18-bit ADC data @ 10 MS/s for UART/nRF24L01+
// Implements: Calibration, Threshold Detection, Data Packing
module data_processor (
    input wire clk_100MHz,       // System clock
    input wire reset_n,          // Active-low reset
    input wire [17:0] adc_data,  // Raw ADC input
    input wire data_valid,       // ADC data valid strobe
    output reg [31:0] processed_data, // Packed output
    output reg proc_data_valid   // Output data valid
);

    // Calibration Constants
    parameter OFFSET = 18'h08000;  // DC offset adjustment
    parameter GAIN = 18'h0CCCD;    // 1.05x gain (0xCCCD/0x10000)
    
    // Threshold Detection
    parameter THRESH_HIGH = 18'h2AAAA;  // 1.666V (for 3.3V full-scale)
    parameter THRESH_LOW = 18'h15555;   // 0.833V
    
    // Internal Signals
    reg [17:0] calibrated_data;
    reg threshold_flag;
    reg [13:0] sample_counter;  // 14-bit counter for timestamps
    
    // =============================================
    // Processing Pipeline (3-stage)
    // =============================================
    
    // Stage 1: Calibration (synchronous)
    always @(posedge clk_100MHz or negedge reset_n) begin
        if (!reset_n) begin
            calibrated_data <= 18'b0;
        end
        else if (data_valid) begin
            // Apply offset and gain: (data - OFFSET) * GAIN
            calibrated_data <= (adc_data - OFFSET) * GAIN;
        end
    end
    
    // Stage 2: Threshold Detection (combinational)
    always @(*) begin
        threshold_flag = (calibrated_data > THRESH_HIGH) || 
                         (calibrated_data < THRESH_LOW);
    end
    
    // Stage 3: Data Packing (synchronous)
    always @(posedge clk_100MHz or negedge reset_n) begin
        if (!reset_n) begin
            processed_data <= 32'b0;
            proc_data_valid <= 1'b0;
            sample_counter <= 14'b0;
        end
        else if (data_valid) begin
            // Pack into 32-bit format:
            // [31:30] = flags (threshold, reserved)
            // [29:16] = timestamp (14-bit)
            // [15:0]  = calibrated data (16 LSBs)
            processed_data <= {threshold_flag, 1'b0, 
                             sample_counter, 
                             calibrated_data[15:0]};
            
            proc_data_valid <= 1'b1;
            sample_counter <= sample_counter + 1;
        end
        else begin
            proc_data_valid <= 1'b0;
        end
    end

endmodule
