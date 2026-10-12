
module baud_generator #(

parameter CLOCK_FREQ = 50000000,
parameter BAUD_RATE  = 9600,
parameter OVERSAMPLE = 16

)(

input clk,
input reset,

output tx_enb,
output rx_enb

);

reg [15:0] tx_counter;
reg [15:0] rx_counter;

// Counter values
localparam TX_COUNT = CLOCK_FREQ / BAUD_RATE;
localparam RX_COUNT = CLOCK_FREQ / (BAUD_RATE * OVERSAMPLE);

always @(posedge clk or posedge reset)
begin

    if(reset)
    begin
        tx_counter <= 0;
        rx_counter <= 0;
    end

    else
    begin

        // TX counter
        if(tx_counter == TX_COUNT - 1)
            tx_counter <= 0;
        else
            tx_counter <= tx_counter + 1'b1;

        // RX counter
        if(rx_counter == RX_COUNT - 1)
            rx_counter <= 0;
        else
            rx_counter <= rx_counter + 1'b1;

    end

end

// Enable pulse generation
assign tx_enb = (tx_counter == 0);
assign rx_enb = (rx_counter == 0);

endmodule



