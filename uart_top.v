module uart_top(

input clk,
input reset,
input write_enb,
input [7:0] data_in,
input rdy_clr,

output tx,
output [7:0] data_out,
output ready,
output busy

);

// =====================================================
// Internal Wires
// =====================================================
wire tx_enb;
wire rx_enb;
wire tx_line;

// =====================================================
// Baud Generator
// =====================================================
baud_generator baud_inst(

.clk(clk),
.reset(reset),
.tx_enb(tx_enb),
.rx_enb(rx_enb)

);

// =====================================================
// UART Transmitter
// =====================================================
uart_transmitter tx_inst(

.clk(clk),
.reset(reset),
.tx_enb(tx_enb),
.write_enb(write_enb),
.data_in(data_in),
.tx(tx_line),
.busy(busy)

);

// =====================================================
// UART Receiver
// =====================================================
uart_receiver rx_inst(

.clk(clk),
.reset(reset),
.clk_enb(rx_enb),
.rx(tx_line),
.rdy_clr(rdy_clr),
.data_out(data_out),
.ready(ready)

);

// =====================================================
// External TX Output
// =====================================================
assign tx = tx_line;

endmodule


