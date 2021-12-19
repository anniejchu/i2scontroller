`default_nettype none // Overrides default behaviour (in a good way)

/*
  Starter module for the etch-a-sketch lab.
*/
// `include "i2s_controller.sv"
module main(
  // On board signals
  clk, buttons, leds, rgb, sck, sd, ws, shutdown, gain
);
parameter CLK_HZ = 12_000_000; // aka ticks per second
parameter CLK_PERIOD_NS = (1_000_000_000/CLK_HZ); // Approximation.
parameter I2S_CLK_HZ = 2*16*22050;

//Module I/O and parameters
input wire clk;
input wire [1:0] buttons;
logic rst; always_comb rst = buttons[0]; // Use button 0 as a reset signal.
output logic [1:0] leds;
output logic [2:0] rgb;
output logic sck;
output logic sd;
output logic ws;
output logic shutdown;
output logic gain;

parameter W = 16;
parameter L = 50000;
parameter INIT = "./music/CantinaBand3_lower.memh";
logic [$clog2(L)-1:0] addr;
logic [W-1:0] rd_data;

parameter BITS = 16;


block_rom #(.W(W), .L(L), .INIT(INIT)) ROM (
    .clk(clk), .addr(addr), .rd_data(rd_data)
);

logic [BITS-1:0] i_data;
logic ws_in;
wire i_ready;
logic i_valid;
logic i_data_prev;


i2s_controller #(
    .CLK_HZ(CLK_HZ), .I2S_CLK_HZ(I2S_CLK_HZ),
    .COOLDOWN_CYCLES(0), .BITS(BITS)
    ) I2S (
  .clk(clk), .rst(rst), 
  .sck(sck), .sd(sd), .ws_in(ws_in), .ws_out(ws),
  .i_ready(i_ready), .i_valid(i_valid), .i_data(i_data),
  .i_data_prev(i_data_prev)
  );

enum logic [3:0] {
  S_IDLE = 0,
  S_INIT = 1, // Unused for now
  S_READ_MEM = 2,
  S_WR_I2S_L = 3,
  S_WR_I2S_R = 4,
  S_WAIT_FOR_I2C_WR = 5,
  S_STOP = 6,
  S_ERROR
} state, state_after_wait;

always_ff @( posedge clk ) begin
    if(rst)begin
        state <= S_IDLE;
        addr <= 0;
        gain <= 0;
    end else begin
        case(state)
            S_IDLE: begin
                if(i_ready) begin
                    state <=S_READ_MEM;
                end
            end
            S_READ_MEM:begin
                addr <= addr + 1;
                if(addr == L) state = S_STOP;
                else state <= S_WR_I2S_L;
            end
            S_WR_I2S_L: begin
                state <= S_WAIT_FOR_I2C_WR;
                state_after_wait<=S_WR_I2S_R;
            end
            S_WR_I2S_R: begin
                state <= S_WAIT_FOR_I2C_WR;
                state_after_wait<=S_READ_MEM;
            end
            S_WAIT_FOR_I2C_WR : begin
                if(i_ready & (addr < L)) state <= state_after_wait;
            end
        endcase
    end
end

always_comb case(state)
    S_WR_I2S_L: ws_in = 1;
    S_WR_I2S_R: ws_in  = 0;
    // default: ws_in = 0;
endcase

always_comb case(state)
    S_WR_I2S_L, S_WR_I2S_R: i_valid = 1;
    default: i_valid = 0;
endcase

always_comb case(state)
    S_IDLE: i_data_prev = rd_data[0];
    // default: i_data_prev = 0;
endcase

always_comb case(state) 
    S_READ_MEM, S_WR_I2S_L, S_WR_I2S_R: i_data = rd_data;
    default: i_data = rd_data;
endcase

always_comb case(state) 
    S_STOP: shutdown = 0;
    default: shutdown = 1;
endcase

endmodule

`default_nettype wire // reengages default behaviour, needed when using 
                      // other designs that expect it.