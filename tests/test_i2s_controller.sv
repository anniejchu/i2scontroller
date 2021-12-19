`timescale 1ns / 100ps

`include "i2s_types.sv"

`define SIMULATION
module test_i2s_controller;

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ);
parameter I2S_CLK_HZ = 400_000; // Must be <= 400kHz
parameter DIVIDER_COUNT = CLK_HZ/I2S_CLK_HZ/2;  // Divide by two necessary since we toggle the signal
parameter MAX_CYCLES_PER_TX = 1000;
parameter MAX_CYCLES = 10000;

//Module I/O and parameters
logic clk, rst, ws_in;
wire sck;
wire ws_out;
wire sd; // Use another triststate to drive the i2c bus when reading data.

// i2c_transaction_t mode;
wire i_ready;
logic i_valid;
// logic [6:0] i_addr;
logic [7:0] i_data;
// logic o_ready;
wire o_valid;
// wire [7:0] o_data;

i2s_controller UUT(
  .clk(clk), .rst(rst), 
  .sck(sck), .sd(sd), .ws_in(ws_in), .ws_out(ws_out),
  .i_ready(i_ready), .i_valid(i_valid), .i_data(i_data)
);

// Run our main clock.
always #(CLK_PERIOD_NS/2) clk = ~clk;

initial begin
  // Collect waveforms
  $dumpfile("i2s_controller.fst");
  $dumpvars(0, UUT);
  
  // Initialize module inputs.
  clk = 0;
  rst = 1;
  i_valid = 0;
  // i_addr = 8'h10;
  i_data = $random;
  // o_ready = 1;
  // mode = WRITE_8BIT_REGISTER;

  // Assert reset for long enough.
  repeat(2) @(negedge clk);
  rst = 0;

  for (int i = 0; i < 4; i = i + 1) begin
    i_data = i_data + 1;
    for (int side = 0; side < 2; side = side +1) begin
      ws_in = side;
      while(~i_ready) @(posedge clk);
      repeat (2) @(negedge clk);
       
      $display("\nWriting  to the i2s device.");
      i_valid = 1;
      @(negedge clk) i_valid = 0;
      repeat (MAX_CYCLES_PER_TX) @(negedge clk);
      if(~i_ready) begin
        $display("Error, i2s write timed out, quitting.");
        $finish;
      end
    end
  end

  $display("Test completed successfully!");
  $finish;
end


// // A very simple secondary device model that drives sda when the UUT isn't.
// logic sda_secondary_out;
// always @(negedge scl) begin
//   if(rst) sda_secondary_out = 1;
//   else case(UUT.state)
//     S_ACK_ADDR, S_ACK_WR: sda_secondary_out = 0;
//     default: sda_secondary_out = $random;
//   endcase
// end
// assign sda_tristate = UUT.sda_oe ? 1'bz : sda_secondary_out; // opposite of tristate internal to UUT.



// Put a timeout to make sure the simulation doesn't run forever;
initial begin
  repeat (MAX_CYCLES) @(posedge clk);
  $display("Test timed out. Check your FSM logic, or increase MAX_CYCLES");
  $finish;
end

endmodule