`timescale 1ns/1ps

module SYS_CTRL_TB();
reg CLK,RST;
reg [7:0] UART_RX_DATA;
reg UART_RX_VLD;
reg FIFO_FULL;
reg RF_RdData_VLD;
reg [7:0] RF_RdData;
reg [15:0] ALU_OUT;
reg ALU_OUT_VLD;
wire RF_WrEn,RF_RdEn,CLKG_EN,CLKDIV_EN,ALU_EN;
wire [3:0] RF_Address;
wire [7:0] RF_WrData;
wire [3:0] ALU_FUN;
wire [7:0] UART_TX_DATA;
wire UART_TX_VLD;

always #10 CLK=~CLK;

SYS_CTRL dut(
.CLK(CLK),
.RST(RST),
.UART_RX_DATA(UART_RX_DATA),
.UART_RX_VLD(UART_RX_VLD),
.FIFO_FULL(FIFO_FULL),
.RF_RdData_VLD(RF_RdData_VLD),
.RF_RdData(RF_RdData),
.ALU_OUT(ALU_OUT),
.ALU_OUT_VLD(ALU_OUT_VLD),
.RF_WrEn(RF_WrEn),
.RF_RdEn(RF_RdEn),
.CLKG_EN(CLKG_EN),
.CLKDIV_EN(CLKDIV_EN),
.ALU_EN(ALU_EN),
.RF_Address(RF_Address),
.RF_WrData(RF_WrData),
.ALU_FUN(ALU_FUN),
.UART_TX_DATA(UART_TX_DATA),
.UART_TX_VLD(UART_TX_VLD)
);

initial 
begin
  CLK=0;
  RST=0;
  #20
  RST=1;
  UART_RX_VLD=1;
  UART_RX_DATA=8'hAA;
  #20
  UART_RX_VLD=0;
  #20
  UART_RX_VLD=1;
  UART_RX_DATA=8'd12;
  #20
  UART_RX_VLD=0;
  #20
  UART_RX_VLD=1;
  UART_RX_DATA=8'd20;
  #20
  UART_RX_VLD=0;
  #20
  UART_RX_VLD=1;
  UART_RX_DATA=8'hBB;
  #20
  UART_RX_VLD=0;
  #20
  UART_RX_VLD=1;
  UART_RX_DATA=8'd12;
  #20
  UART_RX_VLD=0;
  RF_RdData_VLD=1;
  RF_RdData=8'd20;
  #20
  FIFO_FULL=0;
  
  #100
  $stop;
end




endmodule