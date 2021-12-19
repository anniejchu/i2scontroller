`ifndef I2S_TYPES_H
`define I2S_TYPES_H


// Main FSM logic
typedef enum logic [3:0] {
  S_IDLE = 0,
  S_START = 1,
  S_WORD_SELECT = 2,
  S_WR_DATA = 3, 
  S_STOP = 4, 
  S_ERROR
} i2s_state_t;


`endif // I2S_TYPES_H