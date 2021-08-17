`timescale 1ns / 1ps

module wd6522(
    input cs,           // Chip select. The real VIA has CS1 and nCS2. You can get the same functionality by defining this cs to be (cs1 & !cs2)
    input phi2,         // Phase 2 Internal Clock
    input nReset,       // Reset (active low)
    input rs[3:0],      // Register select
    input rWb,          // read (high) write (low)

    inout[7:0] data,

    inout[7:0] pa,      // Peripheral data port A
    inout[7:0] pb,      // Peripheral data port B

    output irqb);       // Interrupt request

endmodule