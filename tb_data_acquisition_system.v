`timescale 1ns/1ps

module tb_data_acquisition_system();

    reg clk_100MHz;
    reg reset_n;
    
    // Instantiate DUT
    data_acquisition_system dut(.*);
    
    // Clock generation
    initial begin
        clk_100MHz = 0;
        forever #5 clk_100MHz = ~clk_100MHz;
    end
    
    // Reset generation
    initial begin
        reset_n = 0;
        #100 reset_n = 1;
    end
    
    // ADC model
    reg [17:0] adc_sample = 18'h3FFFF;
    always @(negedge dut.adc_cs_n) begin
        // Simulate ADC output
        for (int i = 17; i >= 0; i--) begin
            #50;  // 10MHz SPI clock period is 100ns (half period 50ns)
            adc_dout = adc_sample[i];
        end
    end
    
    // UART receiver model
    initial begin
        automatic bit [7:0] uart_byte;
        forever begin
            // Wait for start bit
            wait (dut.uart_tx === 0);
            #500;  // Sample at middle of start bit (1Mbps = 1µs/bit)
            
            // Sample data bits
            for (int i = 0; i < 8; i++) begin
                #1000;
                uart_byte[i] = dut.uart_tx;
            end
            
            // Call Python to process the received byte
            $system($sformatf("python process_uart_byte.py %h", uart_byte));
        end
    end
    
    // Main test sequence
    initial begin
        // Wait for reset
        #200;
        
        // Run for some time
        #1000000;
        
        // Generate report
        $system("python generate_test_report.py");
        $finish;
    end
endmodule
