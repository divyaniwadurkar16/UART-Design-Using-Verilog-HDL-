module uart_top_tb;

// =====================================================
// Signals
// =====================================================
reg clk;
reg reset;
reg write_enb;
reg rdy_clr;
reg [7:0] data_in;

wire tx;
wire [7:0] data_out;
wire ready;
wire busy;

// =====================================================
// DUT (Device Under Test)
// =====================================================
uart_top dut(

.clk(clk),
.reset(reset),
.write_enb(write_enb),
.data_in(data_in),
.rdy_clr(rdy_clr),
.tx(tx),
.data_out(data_out),
.ready(ready),
.busy(busy)

);

// =====================================================
// Clock Generation
// 10 ns clock period
// =====================================================
always #10 clk = ~clk;

// =====================================================
// Reset Task
// =====================================================
task apply_reset;
begin
    reset = 1'b1;
    #20;
    reset = 1'b0;

    $display("RESET APPLIED");
end
endtask

// =====================================================
// Send Byte Task
// =====================================================
task send_byte(input [7:0] din);
begin
    @(negedge clk);

    data_in = din;
    write_enb = 1'b1;

    @(negedge clk);

    write_enb = 1'b0;

    $display("TRANSMITTED DATA = %h", din);
end
endtask

// =====================================================
// Clear Ready Task
// =====================================================
task clear_ready;
begin
    @(negedge clk);
    rdy_clr = 1'b1;

    @(negedge clk);
    rdy_clr = 1'b0;
end
endtask

// =====================================================
// Verification Task
// =====================================================
task check_data(input [7:0] expected_data);
begin

    wait(!busy);
    wait(ready);

    if(data_out == expected_data)
        $display("PASS : Expected = %h | Received = %h",
                  expected_data, data_out);
    else
        $display("FAIL : Expected = %h | Received = %h",
                  expected_data, data_out);

    clear_ready();

end
endtask

// =====================================================
// Test Sequence
// =====================================================
initial
begin

    // Initialize signals
    clk = 0;
    reset = 0;
    write_enb = 0;
    rdy_clr = 0;
    data_in = 8'h00;

    // Apply reset
    apply_reset();

    // ==========================================
    // Test Case 1 : 0x41 ('A')
    // ==========================================
    send_byte(8'h41);
    check_data(8'h41);

    // ==========================================
    // Test Case 2 : 0x55
    // ==========================================
    send_byte(8'h55);
    check_data(8'h55);

    // ==========================================
    // Test Case 3 : 0xAA
    // ==========================================
    send_byte(8'hAA);
    check_data(8'hAA);

    // ==========================================
    // Test Case 4 : 0xFF
    // ==========================================
    send_byte(8'hFF);
    check_data(8'hFF);

    // ==========================================
    // Finish Simulation
    // ==========================================
    #500;

    $display("SIMULATION COMPLETED");
    $finish;

end

endmodule
