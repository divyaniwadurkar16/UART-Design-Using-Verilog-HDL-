module uart_receiver #(

parameter DATA_WIDTH = 8,
parameter OVERSAMPLE = 16

)(

input clk,
input reset,
input clk_enb,
input rx,
input rdy_clr,

output reg [DATA_WIDTH-1:0] data_out,
output reg ready

);

// =====================================================
// State Encoding
// =====================================================
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

// =====================================================
// Constants
// =====================================================
localparam MID_SAMPLE = OVERSAMPLE/2;

// =====================================================
// Registers
// =====================================================
reg [1:0] state;
reg [3:0] sample_count;
reg [2:0] bit_index;
reg [DATA_WIDTH-1:0] temp_reg;

// =====================================================
// UART Receiver Logic
// =====================================================
always @(posedge clk or posedge reset)
begin

    if(reset)
    begin
        state        <= IDLE;
        sample_count <= 0;
        bit_index    <= 0;
        temp_reg     <= 0;
        data_out     <= 0;
        ready        <= 0;
    end

    else
    begin

        // Clear ready flag externally
        if(rdy_clr)
            ready <= 1'b0;

        // Run UART logic only on rx enable
        if(clk_enb)
        begin

            case(state)

                // ======================================
                // IDLE STATE
                // Wait for start bit
                // ======================================
                IDLE:
                begin
                    sample_count <= 0;

                    if(rx == 1'b0)
                        state <= START;
                end

                // ======================================
                // START BIT VALIDATION
                // ======================================
                START:
                begin
                    sample_count <= sample_count + 1'b1;

                    // Sample at middle of start bit
                    if(sample_count == MID_SAMPLE)
                    begin
                        if(rx == 1'b0)
                        begin
                            bit_index <= 0;
                            temp_reg <= 0;
                        end
                        else
                        begin
                            state <= IDLE;
                        end
                    end

                    // Move to DATA state
                    if(sample_count == OVERSAMPLE-1)
                    begin
                        sample_count <= 0;
                        state <= DATA;
                    end
                end

                // ======================================
                // DATA RECEIVE
                // ======================================
                DATA:
                begin
                    sample_count <= sample_count + 1'b1;

                    // Sample at middle of bit
                    if(sample_count == MID_SAMPLE)
                    begin
                        temp_reg[bit_index] <= rx;
                    end

                    // End of bit duration
                    if(sample_count == OVERSAMPLE-1)
                    begin
                        sample_count <= 0;

                        if(bit_index == DATA_WIDTH-1)
                        begin
                            state <= STOP;
                        end
                        else
                        begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                end

                // ======================================
                // STOP BIT CHECK
                // ======================================
                STOP:
                begin
                    sample_count <= sample_count + 1'b1;

                    if(sample_count == MID_SAMPLE)
                    begin
                        // Stop bit must be HIGH
                        if(rx == 1'b1)
                        begin
                            data_out <= temp_reg;
                            ready <= 1'b1;
                        end
                    end

                    if(sample_count == OVERSAMPLE-1)
                    begin
                        sample_count <= 0;
                        state <= IDLE;
                    end
                end

                // ======================================
                // SAFETY STATE
                // ======================================
                default:
                begin
                    state <= IDLE;
                end

            endcase

        end

    end

end

endmodule
