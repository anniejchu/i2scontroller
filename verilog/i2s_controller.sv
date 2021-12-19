`timescale 1ns / 1ps
// `default_nettype none

`include "i2s_types.sv"

// TI has a good reference on how i2c works: https://training.ti.com/sites/default/files/docs/slides-i2c-protocol.pdf
// In this guide the "main" device is called the "controller" and the "secondary" device is called the "target".
module i2s_controller(
  clk, rst,
  sck, sd, ws_in, ws_out,
  i_ready, i_valid, i_data, i_data_prev
);

parameter CLK_HZ = 12_000_000;
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ);
parameter I2S_CLK_HZ = 400_000; // Must be <= 400kHz
parameter DIVIDER_COUNT = CLK_HZ/I2S_CLK_HZ/2;  // Divide by two necessary since we toggle the signal
`ifdef SIMULATION
parameter COOLDOWN_CYCLES = 12; // Wait between transactions (can help smooth over issues with ACK or STOP or START conditions).
`else
parameter COOLDOWN_CYCLES = 120; // Wait between transactions (can help smooth over issues with ACK or STOP or START conditions).
`endif // SIMULATION
parameter BITS = 8;
//Module I/O and parameters
input wire clk, rst, ws_in; // standard signals
output logic sck; // clock
output logic sd; // data
output logic ws_out; // word select (left or right)

// input wire i2c_transaction_t mode; // See i2c_types.sv, 0 is WRITE and 1 is READ
output logic i_ready; // ready/valid handshake signals
input wire i_valid;
input wire [BITS-1:0] i_data; // data to be sent on a WRITE opearation
input wire i_data_prev;
// Main FSM logic

// Main FSM logic
enum logic [3:0] {
  S_IDLE = 0,
  S_START = 1,
  S_WORD_SELECT = 2,
  S_LOAD_DATA = 3,
  S_WR_DATA = 4, 
  S_STOP = 5, 
  S_ERROR
} state; // see i2s_types for the canonical states.



logic [$clog2(DIVIDER_COUNT):0] clk_divider_counter;
logic [$clog2(COOLDOWN_CYCLES):0] cooldown_counter; // optional, but recommended - have the system wait a few clk cycles before i_ready goes high again - this can make debugging STOP/ACK/START issues way easier!!!
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
  end else begin // out of reset
    if(state == S_IDLE) begin
      if(i_valid & i_ready) begin
        i_ready <= 0;
        cooldown_counter <= COOLDOWN_CYCLES;
        // o_valid <= 0;
        state <= S_WORD_SELECT;
        bit_counter <= 0;
        clk_divider_counter <= DIVIDER_COUNT-1;
        // 
      end
      else begin
        sck <= 0;
        if(cooldown_counter > 0) begin
          i_ready <= 0;
          cooldown_counter <= cooldown_counter - 1;
        end else begin
          i_ready <= 1;
        end
      end
    end else begin // handle all non-idle state here
    if (clk_divider_counter == 0) begin
      clk_divider_counter <= DIVIDER_COUNT-1;
      sck <= ~sck;
      case(state)
        S_WORD_SELECT: begin
          if(sck) begin // negative edge logic
            ws_out <= ws_in;
            state <= S_LOAD_DATA;
            bit_counter <= BITS-1;
            data_buffer[BITS-1:1] <= data_buffer[BITS-2:0];

          end
        end
        S_LOAD_DATA: begin
          if(sck) begin // negative edge logic
            
            data_buffer <= i_data;
            state <= S_WR_DATA;
            bit_counter <= bit_counter - 1;
          end
        end
        S_WR_DATA: begin
          if(sck) begin // negative edge logic
            // if(bit_counter==BITS-1) ;
            if(bit_counter==1) state <= S_IDLE;
            bit_counter <= bit_counter - 1;
            if(bit_counter > 0) begin  
              // data_buffer[0] <= 1'b1; // Shift in ones to leave SDA as default high. More for the prettiness of the waveform, it shouldn't matter.
              data_buffer[BITS-1:1] <= data_buffer[BITS-2:0];
            end
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


always_comb case(state)
  S_START: sd = 0; // Start signal.
  // S_LOAD_DATA
  S_WR_DATA, S_WORD_SELECT, S_LOAD_DATA : sd = data_buffer[BITS-1]; //data_buffer[bit_counter];
  // default : sd = 0; //TODO
endcase

endmodule
