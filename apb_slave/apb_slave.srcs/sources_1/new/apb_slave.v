`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Manish Kumar
// 
// Create Date: 11.07.2025 20:17:26
// Design Name: 
// Module Name: apb_slave
// Project Name: 
 
//////////////////////////////////////////////////////////////////////////////////

module apb_slave #(
  parameter AWIDTH = 32,
  parameter DWIDTH = 32
)(
  input                  PCLK,
  input                  PRESETn,
  input                  PSEL,
  input                  PENABLE,
  input                  PWRITE,
  input      [AWIDTH-1:0] PADDR,
  input      [DWIDTH-1:0] PWDATA,
  input      [3:0]       PSTRB,
  input      [2:0]       PPROT,
  output reg             PREADY,
  output reg             PSLVERR,
  output reg [DWIDTH-1:0] PRDATA
);

  // 16 32-bit registers (64 bytes)
  reg [DWIDTH-1:0] mem [0:15];

  wire write_enable = PSEL && PENABLE && PWRITE;
  wire read_enable  = PSEL && PENABLE && !PWRITE;

  always @(posedge PCLK or negedge PRESETn) begin
    if (!PRESETn) begin
      PREADY   <= 1'b0;
      PSLVERR  <= 1'b0;
      PRDATA   <= 1'b0;
    end else begin
      PREADY <= 1'b1;  // No wait states

      if (write_enable) begin
        PSLVERR <= 1'b0;  // No error condition
        case (PSTRB)
          4'b1111: mem[PADDR[5:2]] <= PWDATA;  // Full word write
          default: begin
            // Byte enable logic
            if (PSTRB[0]) mem[PADDR[5:2]][7:0]   <= PWDATA[7:0];
            if (PSTRB[1]) mem[PADDR[5:2]][15:8]  <= PWDATA[15:8];
            if (PSTRB[2]) mem[PADDR[5:2]][23:16] <= PWDATA[23:16];
            if (PSTRB[3]) mem[PADDR[5:2]][31:24] <= PWDATA[31:24];
          end
        endcase
      end else if (read_enable) begin
        PSLVERR <= 1'b0;
        PRDATA <= mem[PADDR[5:2]];
      end
    end
  end

endmodule

