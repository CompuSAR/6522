`timescale 1ns / 1ps

module wd6522(
    input cs,           // Chip select. The real VIA has CS1 and nCS2. You can get the same functionality by defining this cs to be (cs1 & !cs2)
    input phi2,         // Phase 2 Internal Clock
    input nReset,       // Reset (active low)
    input [3:0]rs,      // Register select
    input rWb,          // read (high) write (low)

    input [7:0]dataIn,
    output [7:0]dataOut,

    input  [7:0]paIn,   // Peripheral data port A
    output [7:0]paOut,  // Peripheral data port A
    input  [7:0]pbIn,   // Peripheral data port B
    output [7:0]pbOut,  // Peripheral data port B

    output nIrq);       // Interrupt request

reg [7:0]dataReg;
assign dataOut = dataReg;
reg irqReg;
assign nIrq = irqReg;

reg [7:0]peripheralA;
reg [7:0]peripheralADirection;

generate
    for( genvar i=0; i<8; i = i+1 ) begin
        assign paOut[i] = peripheralADirection[i] ? peripheralA[i] : 1'bZ;
    end
endgenerate

reg [7:0]peripheralB;
reg [7:0]peripheralBDirection;

generate
    for( genvar i=0; i<8; i = i+1 ) begin
        assign pbOut[i] = peripheralBDirection[i] ? peripheralB[i] : 1'bZ;
    end
endgenerate

initial begin
    reset();
end

always@(posedge phi2)
begin
    if( cs && nReset && rWb )
    begin
        case( rs )
        4'd0: begin
            readPb();
        end
        4'd1: begin
            readPa();
        end
        4'd2: begin
            readPbDir();
        end
        4'd3: begin
            readPaDir();
        end
        default: begin
            // All other registers are not yet implemented
        end
        endcase
    end else begin
        dataReg = 7'bZ;
    end
end

always@(negedge phi2)
begin
    if( cs && nReset )
    begin
        if( !rWb ) begin
            // Write mode
            case( rs )
            4'd0: begin
                writePb();
            end
            4'd1: begin
                writePa();
            end
            4'd2: begin
                writePbDir();
            end
            4'd3: begin
                writePaDir();
            end
            default: begin
                // All other registers are not yet implemented
            end
            endcase
        end
    end else begin
        dataReg = 7'bZ;
    end
end

always@(negedge nReset)
begin
    reset();
end

always@(negedge cs)
begin
    dataReg = 7'bZ;
end

task readPb();
begin 
    // Read. Give true input where applicable, and *desired* output elsewhere. See section 2.1 of the datasheet
    dataReg = (pbIn & ~peripheralBDirection) | (peripheralB & peripheralBDirection);
end
endtask

task writePb();
    peripheralB = dataIn;
endtask

task readPa();
    dataReg = paIn;
endtask

task writePa();
    peripheralA = dataIn;
endtask

task readPbDir();
    dataReg = peripheralBDirection;
endtask

task writePbDir();
    peripheralBDirection = dataIn;
endtask

task readPaDir();
    dataReg = peripheralADirection;
endtask

task writePaDir();
    peripheralADirection = dataIn;
endtask

task reset();
begin
    dataReg = 8'bZ; // High impedance on start
    irqReg = 1;     // Don't request interrupt
    
    peripheralA = 0;
    peripheralADirection = 0;
    peripheralB = 0;
    peripheralBDirection = 0;
end
endtask

endmodule