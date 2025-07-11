`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Manish Kumar

// Create Date: 11.07.2025 20:21:10
// Design Name: 
// Module Name: apb_slave_tb
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////


module apb_slave_tb;

  reg         PCLK, PRESETn;
  reg         PSEL, PENABLE, PWRITE;
  reg [31:0]  PADDR, PWDATA;
  reg [3:0]   PSTRB;
  reg [2:0]   PPROT;
  wire [31:0] PRDATA;
  wire        PREADY, PSLaVERR;

  // DUT instantiation
  apb_slave DUT (
    .PCLK(PCLK), .PRESETn(PRESETn),
    .PSEL(PSEL), .PENABLE(PENABLE), .PWRITE(PWRITE),
    .PADDR(PADDR), .PWDATA(PWDATA), .PSTRB(PSTRB),
    .PPROT(PPROT),
    .PRDATA(PRDATA), .PREADY(PREADY), .PSLVERR(PSLVERR)
  );

  // Clock generation
  initial PCLK = 0;
  always #5 PCLK = ~PCLK;  // 100MHz

  // Test sequence
  initial begin
    $display("Starting APB v2.0 Slave Test...");
    PRESETn = 0;
    PSEL = 0; PENABLE = 0; PWRITE = 0;
    PADDR = 0; PWDATA = 0; PSTRB = 4'b1111; PPROT = 3'b000;
    #20;
    PRESETn = 1;

    // Write Phase
    apb_write(32'h04, 32'hDEADBEEF, 4'b1111);
    apb_write(32'h08, 32'hCAFEBABE, 4'b1111);

    // Read Phase
    apb_read(32'h04, 32'hDEADBEEF);
    apb_read(32'h08, 32'hCAFEBABE);

    $display("APB Slave Test PASSED");
    $finish;
  end

  task apb_write(input [31:0] addr, input [31:0] data, input [3:0] strb);
    begin
      @(posedge PCLK);
      PADDR = addr;
      PWDATA = data;
      PSTRB = strb;
      PWRITE = 1; PSEL = 1; PENABLE = 0;
      @(posedge PCLK);
      PENABLE = 1;
      @(posedge PCLK);
      PSEL = 0; PENABLE = 0;
      @(posedge PCLK);
    end
  endtask

  task apb_read(input [31:0] addr, input [31:0] expected);
    begin
      @(posedge PCLK);
      PADDR = addr;
      PWRITE = 0; PSEL = 1; PENABLE = 0;
      @(posedge PCLK);
      PENABLE = 1;
      @(posedge PCLK);
      #1; // Allow non-blocking assignments to update
      if (PRDATA !== expected)
        $fatal("READ ERROR at %h: expected %h, got %h", addr, expected, PRDATA);
      PSEL = 0; PENABLE = 0; // Deassert after check
      @(posedge PCLK);
    end
  endtask
//  initial begin
//    $dumpvars;
//    $dumfile("dump.vcd");
//  end
  

endmodule