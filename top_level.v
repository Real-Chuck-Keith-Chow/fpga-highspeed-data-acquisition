module top_level(
    input wire clk_100MHz,       // Main clock input
    input wire reset_n,           // Active-low reset
    // ADC Interface
    output wire adc_cs_n,         // ADC chip select
    output wire adc_sclk,         // ADC serial clock
    input wire adc_dout,          // ADC data out
    // UART Interface
    output wire uart_tx,          // UART transmit
    input wire uart_rx,           // UART receive
    // Wireless Interface
    output wire nrf_ce,           // nRF24L01+ chip enable
    output wire nrf_csn,          // nRF24L01+ chip select
    output wire nrf_sck,          // nRF24L01+ serial clock
    output wire nrf_mosi,         // nRF24L01+ master out slave in
    input wire nrf_miso,          // nRF24L01+ master in slave out
    input wire nrf_irq            // nRF24L01+ interrupt
);
