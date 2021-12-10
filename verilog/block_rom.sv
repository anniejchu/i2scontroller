// Based on UG901 - The Vivado Synthesis Guide

module block_rom(clk, addr, rd_data);

parameter W = 8; // Width of each row of  the memory
parameter L = 32; // Length fo the memory
parameter INIT = "zeros.memh";

input clk;
input [$clog2(L)-1:0] addr;
output logic [W-1:0] rd_data;
// input wire wr_ena;
// output logic [W-1:0] wr_data;

logic [W-1:0] rom [0:L-1];
initial begin
  $display("Initializing block ram from music file %s.", INIT);
  $readmemh(INIT, rom); // Initializes the ROM with the values in the init file.
end

always_ff @(posedge clk) begin
  rd_data <= ram[addr];
  // if(wr_ena) begin
  //   ram[addr] <= wr_data;
  end
end

endmodule
