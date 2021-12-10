`ifndef I2S_TYPES_H
`define I2S_TYPES_H

// Based on the i2s Specification
// typedef enum logic {
//   WRITE_8BIT_REGISTER = 0, READ_8BIT = 1
// } i2c_transaction_t;


// Main FSM logic
typedef enum logic [3:0] {
  S_IDLE = 0,
  S_START = 1,
  S_WORD_SELECT = 2,
  // S_ADDR = 2,
  // S_ACK_ADDR = 3, 
  S_WR_DATA = 3, 
  // S_ACK_WR = 5,
  // S_RD_DATA = 6,
  // S_ACK_RD = 7,
  S_STOP = 4, 
  S_ERROR
} i2s_state_t;


`endif // I2S_TYPES_H