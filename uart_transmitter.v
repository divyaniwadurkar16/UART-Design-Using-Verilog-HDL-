
module uart_transmitter #(

parameter DATA_WIDTH = 8

)(

input clk,
input reset,
input tx_enb,
input write_enb,
input [DATA_WIDTH-1:0] data_in,

output reg tx,
output busy

);

// State encoding
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

// Registers
reg [1:0] state;
reg [DATA_WIDTH-1:0] data;
reg [2:0] index;

// Busy signal
assign busy = (state != IDLE);

// Sequential logic
always @(posedge clk or posedge reset)
begin

    if(reset)
    begin
        tx <= 1'b1;
        state <= IDLE;
        index <= 3'd0;
        data <= 0;
    end

    else
    begin

        case(state)

            // IDLE state
            IDLE:
            begin
                tx <= 1'b1;

                if(write_enb)
                begin
                    data <= data_in;
                    index <= 3'd0;
                    state <= START;
                end
            end

            // START bit
            START:
            begin
                if(tx_enb)
                begin
                    tx <= 1'b0;
                    state <= DATA;
                end
            end

            // DATA transmission
            DATA:
            begin
                if(tx_enb)
                begin
                    tx <= data[index];

                    if(index == DATA_WIDTH-1)
                        state <= STOP;
                    else
                        index <= index + 1'b1;
                end
            end

            // STOP bit
            STOP:
            begin
                if(tx_enb)
                begin
                    tx <= 1'b1;
                    state <= IDLE;
                end
            end

            // Safety state
            default:
            begin
                tx <= 1'b1;
                state <= IDLE;
            end

        endcase

    end

end

endmodule
