`timescale 1ns / 1ps
// `default_nettype none

module i2s_controller(
  clk, rst, sck, sd, ws_data, ws_out, i_ready, i_valid, i_data
);

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ);
parameter I2S_CLK_HZ = 400_000; // Must be <= 400kHz
parameter DIVIDER_COUNT = CLK_HZ/I2S_CLK_HZ/2;  // Divide by two necessary since we toggle the signal
parameter BITS = 8;
//Module I/O and parameters
input wire clk, rst, ws_data; // standard signals
output logic sck; // clock
output logic sd; // data
output logic ws_out; // word select (left or right)
output logic i_ready; // ready/valid handshake signals
input wire i_valid;
input wire [BITS-1:0] i_data; // data to be sent on

// Main FSM logic
enum logic [2:0] {
  S_IDLE = 0,
  S_WORD_SELECT = 1,
  S_LOAD_DATA = 2,
  S_WR_DATA = 3 ,
  S_ERROR
} state; 

logic [$clog2(DIVIDER_COUNT):0] clk_divider_counter;
logic [3:0] bit_counter;
logic [BITS-1:0] data_buffer;

always_ff @(posedge clk) begin : i2s_fsm  
  if(rst) begin
    clk_divider_counter <= DIVIDER_COUNT-1;
    sck <= 0; //natural state of i2s
    bit_counter <= 0;
    i_ready <= 1; 
    state <= S_IDLE;
    ws_out <= 0;
    data_buffer <= 0;
  end else begin
    if(state == S_IDLE) begin
      i_ready <= 1;
      if(i_valid & i_ready) begin
        i_ready <= 0;
        state <= S_WORD_SELECT;
        bit_counter <= 0;
        clk_divider_counter <= DIVIDER_COUNT-1;
      end
    end else begin // handle all non-idle state here
    if (clk_divider_counter == 0) begin
      clk_divider_counter <= DIVIDER_COUNT-1;
      sck <= ~sck;
      case(state)
        S_WORD_SELECT: begin
          if(sck) begin // negative edge logic
            ws_out <= ws_data;
            bit_counter <= BITS-1;
            data_buffer[BITS-1:1] <= data_buffer[BITS-2:0];
            state <= S_LOAD_DATA;
          end
        end
        S_LOAD_DATA: begin
          if(sck) begin // negative edge logic
            data_buffer <= i_data;
            bit_counter <= bit_counter - 1;
            state <= S_WR_DATA;
          end
        end
        S_WR_DATA: begin
          if(sck) begin // negative edge logic
            bit_counter <= bit_counter - 1;
            data_buffer[BITS-1:1] <= data_buffer[BITS-2:0];
            if(bit_counter==1) state <= S_IDLE;           
          end
        end
        S_ERROR: begin
`ifndef SIMULATION // In simulation stop, in synthesis, keep running!
          state <= S_IDLE;
`endif
        end
      endcase
      end else begin // still waiting on clock divider counter
        clk_divider_counter <= clk_divider_counter - 1;
      end
    end
  end
end

always_comb begin
  sd = data_buffer[BITS-1];
end

endmodule
